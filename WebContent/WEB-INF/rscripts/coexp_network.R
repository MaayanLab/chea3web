##################################################
## Project: ChEA3
##
## Script purpose: Generate TF-TF co-expression network from ARCHS4 gene expression
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
library(here)
library(matrixStats)
library(preprocessCore)
library(Hmisc)

#source("/users/alexandrakeenan/Projects/Common/Utilities/Utilities.R")
options(stringsAsFactors = FALSE)

####Set parameters and directories####
counts_file = "human_matrix.h5"
cor_method = "pearson"
n = 50000
tfs = chea3::tfs
counts_file_dir = "/Users/alexandrakeenan/Projects/ChEA3/ARCHS4/downloads/"
species = unlist(strsplit(counts_file,"_"))[1]


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
cors = cor(t(tf_counts),method = cor_method)
cors = as.data.frame(cors)
rownames(cors) = mapped_genes[tf_idx]
colnames(cors) = mapped_genes[tf_idx]

##compute pvals of correlations##
c = rcorr(t(tf_counts), type="pearson")
pvals = c$P
coeffs = c$r
