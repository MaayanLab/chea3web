##################################################
## Project: ChEA3
##
## Script purpose: Generate discrete set and ranked
## list TF-gene co-expression libraries from GTEx gene expression
## matrices. GTEx expression count gct and meta data files used in our
## analysis were downloaded 01/06/2018
## List of human TFs are from:
## The Human Transcription Factors
## Lambert, Samuel A. et al.
## Cell , Volume 172 , Issue 4 , 650 - 665
##
## Date: 04/27/2018
## Author: Alexandra Keenan
##################################################
rm(list = ls())
library(here)
library(CePa)
library(grex)
library(preprocessCore)
library(matrixStats)

####Set parameters and directories####
counts_file = "/Volumes/External/Projects/Common/GTEx/downloads/GTEx_Analysis_2016-01-15_v7_RNASeQCv1.1.8_gene_reads.gct"

list_outdir = '/Volumes/External/Projects/TF_libs/ranked_lists/'
gmt_outdir = '/Volumes/External/Projects/TF_libs/gmts/coexpression_v2/'
dir.create(gmt_outdir)
cor_method = "pearson"

geneset_threshold = 300
tfs = chea3::tfs
outfile = paste(paste("GTEx","TFs",cor_method,sep = "_"),"gmt",sep = ".")
pos_outfile = paste(paste("pos_GTEx","TFs",cor_method,sep = "_"),"gmt",sep = ".")
neg_outfile = paste(paste("neg_GTEx","TFs",cor_method,sep = "_"),"gmt",sep = ".")

####Load, normalize, clean counts matrix####
counts = read.gct(counts_file)
rows = rownames(counts)
cols = colnames(counts)
counts = normalize.quantiles(as.matrix(counts))
counts = as.data.frame(counts)
colnames(counts) = cols
rownames(counts) = rows
ensembl_ids = cleanid(rownames(counts))
genes = grex(ensembl_ids)$hgnc_symbol
mapped_genes = genesetr::HGNCapproved(genes,untranslatable.na = T) #for consistency
na_idx = is.na(mapped_genes)
mapped_genes = mapped_genes[!na_idx]
counts = counts[!na_idx,]


####Remove duplicate genes by retaining those with greatest variance####
dup_idx = which(mapped_genes %in% mapped_genes[duplicated(mapped_genes)])
vars = data.frame(idx = dup_idx, gene = mapped_genes[dup_idx], var = rowVars(as.matrix(counts[dup_idx,])),stringsAsFactors = F)
rm_idx = unlist(plyr::dlply(vars,plyr::.(gene),function(sub){
  return(sub[-which(sub$var==max(sub$var))[1],"idx"])
}))
mapped_genes = mapped_genes[-rm_idx]
counts = counts[-rm_idx,]

####Compute correlation####
##remove genes with no variance
novar_idx = rowVars(as.matrix(counts)) == 0
counts = counts[!novar_idx,]
mapped_genes = mapped_genes[!novar_idx]

##subset counts to tfs##
mapped_tfs = as.character(na.omit(genesetr::HGNCapproved(tfs,untranslatable.na = T)))
tf_idx = mapped_genes %in% mapped_tfs
tf_counts = counts[tf_idx,]

##compute correlation##
cors = cor(t(counts),t(tf_counts),method = cor_method)
cors = as.data.frame(cors)
rownames(cors) = mapped_genes
colnames(cors) = mapped_genes[tf_idx]

# ####write list####
# ranked_lists = cors
# colnames(ranked_lists) = paste(colnames(ranked_lists),"_GTEx_",cor_method,sep = "")
# dir.create(list_outdir)
# write.table(ranked_lists,paste(list_outdir,outfile,sep = ""),quote = F, sep = "\t",col.names = T, row.names = T)

####write GMT####
gmt = lapply(cors,function(col){
  idx = order(abs(col),decreasing = T)
  col = paste(rownames(cors)[idx][2:(geneset_threshold+1)],col[idx][2:(geneset_threshold+1)],sep = ",")
})

gmt_pos = lapply(cors,function(col){
  idx = order(col,decreasing = T)
  col = paste(rownames(cors)[idx][2:(geneset_threshold+1)],col[idx][2:(geneset_threshold+1)],sep = ",")
})

gmt_neg = lapply(cors,function(col){
  idx = order(-col,decreasing = T)
  col = paste(rownames(cors)[idx][2:(geneset_threshold+1)],col[idx][2:(geneset_threshold+1)],sep = ",")
})


genesetr::writeGMT(gmt, paste(gmt_outdir, outfile, sep = ""))
genesetr::writeGMT(gmt_pos, paste(gmt_outdir, pos_outfile, sep = ""))
genesetr::writeGMT(gmt_neg, paste(gmt_outdir, neg_outfile, sep = ""))








