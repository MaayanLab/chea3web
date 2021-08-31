##################################################
## Project: ChEA3
##
## Script purpose: Generate discrete set and ranked
## list TF-gene co-expression libraries from ARCHS4 gene expression
## matrices. ARCHS4 expression count hdf5 files used in our
## analysis were downloaded 4/27/2018
## List of human TFs are from:
## The Human Transcription Factors
## Lambert, Samuel A. et al.
## Cell , Volume 172 , Issue 4 , 650 - 665
##
## Date: 04/27/2018
## edited: 08/12/2018 A.K.
## Author: Alexandra Keenan
##################################################
rm(list = ls())
library(rhdf5)
library(matrixStats)
library(preprocessCore)

options(stringsAsFactors = FALSE)

####Set parameters and directories####
counts_file = "human_matrix.h5"
cor_method = "pearson"
n = 50000
geneset_threshold = 300
tfs = chea3::tfs
counts_file_dir = "/Volumes/External/Projects/ChEA3/ARCHS4/downloads/"
species = unlist(strsplit(counts_file,"_"))[1]
gmt_outdir = "/Volumes/External/Projects/TF_libs/gmts/coexpression_v2/"
dir.create(gmt_outdir)
# list_outdir = "/Volumes/External/Projects/TF_libs/ranked_lists/"
outfile = paste(paste("ARCHS4","TFs",cor_method,"n",n,species,sep = "_"),"gmt",sep = ".")

####Load/normalize counts and map genes####
num_samples = as.numeric(subset(h5ls(paste(counts_file_dir,counts_file,sep="")),
                                name == "Sample_characteristics_ch1")$dim)
if(n>num_samples)(stop("Choose n that is less than number of samples available."))
counts = h5read(file = paste(counts_file_dir,counts_file,sep  = ""),
       name = "/data/expression/",
       index = list(NULL,sample(1:num_samples, n, replace = F)))
counts = normalize.quantiles(counts)
genes = h5read(file = paste(counts_file_dir,counts_file,sep  = ""),
               name = "/meta/genes/")
mapped_genes = genesetr::HGNCapproved(genes, untranslatable.na = T)

counts = counts[!is.na(mapped_genes),]
mapped_genes = mapped_genes[!is.na(mapped_genes)]

####For duplicate genes, take those that have the highest variance####
dup_idx = which(mapped_genes %in% mapped_genes[duplicated(mapped_genes)])
vars = data.frame(idx = dup_idx, gene = mapped_genes[dup_idx],
  var = rowVars(counts[dup_idx,]),stringsAsFactors = F)
rm_idx = unlist(plyr::dlply(vars,plyr::.(gene),function(sub){
  return(sub[-which(sub$var==max(sub$var))[1],"idx"])
}))
mapped_genes = mapped_genes[-rm_idx]
counts = counts[-rm_idx,]

####Compute correlation####

##remove genes with no variance
novar_idx = rowVars(counts) == 0
counts = counts[!novar_idx,]
mapped_genes = mapped_genes[!novar_idx]

##subset counts to tfs##
mapped_tfs = na.omit(genesetr::HGNCapproved(tfs,untranslatable.na = T))
tf_idx = mapped_genes %in% mapped_tfs
tf_counts = counts[tf_idx,]

##compute correlation##
cors = cor(t(counts),t(tf_counts),method = cor_method)
cors = as.data.frame(cors)
rownames(cors) = mapped_genes
colnames(cors) = mapped_genes[tf_idx]

####Write gmt####
gmt = lapply(cors,function(col){
  idx = order(abs(col),decreasing = T)
  row = paste(rownames(cors)[idx][2:(geneset_threshold+1)],col[idx][2:(geneset_threshold+1)],sep = ",")
})

pos_gmt = lapply(cors, function(col){
  idx = order(col, decreasing = T)
  row = paste(rownames(cors)[idx][2:(geneset_threshold+1)],col[idx][2:(geneset_threshold+1)],sep = ",")
})

neg_gmt = lapply(cors, function(col){
  idx = order(-col, decreasing = T)
  row = paste(rownames(cors)[idx][2:(geneset_threshold+1)],col[idx][2:(geneset_threshold+1)],sep = ",")
})

names(gmt) = paste(names(gmt),"_ARCHS4_",cor_method,sep = "")
genesetr::writeGMT(gmt, paste(gmt_outdir, outfile, sep = ""))

####Write ranked list####
# ranked_lists = cors
# colnames(ranked_lists) = paste(colnames(ranked_lists),"_ARCHS4_",cor_method,sep = "")
# dir.create(list_outdir)
# write.table(ranked_lists,paste(list_outdir,outfile),quote = F, sep = "\t",col.names = T, row.names = T)








