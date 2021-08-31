#generate matrix for input to ARACNe from GTEx data
rm(list = ls())
library(CePa)
library(preprocessCore)
library(grex)
library(matrixStats)
counts_file = "/Volumes/Backup2/Projects/Common/GTEx/downloads/GTEx_Analysis_2016-01-15_v7_RNASeQCv1.1.8_gene_reads.gct"
counts = read.gct(counts_file)
rows = rownames(counts)
cols = colnames(counts)
counts = normalize.quantiles(as.matrix(counts))
counts = as.data.frame(counts)
colnames(counts) = cols
rownames(counts) = rows
counts = counts[,sample(colnames(counts),200)]

ensembl_ids = cleanid(rownames(counts))
genes = grex(ensembl_ids)$hgnc_symbol
mapped_genes = genesetr::HGNCapproved(genes,untranslatable.na = T) #for consistency
na_idx = is.na(mapped_genes)
mapped_genes = mapped_genes[!na_idx]
counts = counts[!na_idx,]

####For duplicate genes, take those that have the highest variance####
dup_idx = which(mapped_genes %in% mapped_genes[duplicated(mapped_genes)])
vars = data.frame(idx = dup_idx, gene = mapped_genes[dup_idx],
  var = rowVars(as.matrix(counts[dup_idx,])),stringsAsFactors = F)
rm_idx = unlist(plyr::dlply(vars,plyr::.(gene),function(sub){
  return(sub[-which(sub$var==max(sub$var))[1],"idx"])
}))
mapped_genes = mapped_genes[-rm_idx]
counts = counts[-rm_idx,]
expData = counts
rownames(expData) = mapped_genes
expData = cbind(genes = rownames(expData), expData)
tfs = data.frame(tfs = rownames(expData)[rownames(expData) %in% chea3::tfs], stringsAsFactors = F)
write.table(expData,"/volumes/Backup2/Cusanovich/ARACNe_input_GTEx/matrix.txt",sep = "\t",col.names = T, row.names = F, quote = F)
write.table(tfs,"/volumes/Backup2/Cusanovich/ARACNe_input_GTEx/tfs.txt",sep = "\t", col.names = F, row.names = F, quote = F)

#generate matrix for input to ARACNe from ARCHS4 data
rm(list = ls())
library(CePa)
library(preprocessCore)
library(grex)
library(matrixStats)
library("rhdf5")
library("tools")

destination_file = '/volumes/Backup2/WGCNA_ARCHS4/ARCHS4_download/human_matrix_download.h5'

# Retrieve information from compressed data
ARCH_samples = h5read(destination_file, "meta/Sample_geo_accession")
ARCH_tissue = h5read(destination_file, "meta/Sample_source_name_ch1")
ARCH_genes = h5read(destination_file, "meta/genes")

samp = sample(ARCH_samples,2000)

sample_locations = which(ARCH_samples %in% samp)

expression = h5read(destination_file, "data/expression", index=list(1:length(ARCH_genes), sample_locations))

colnames(expression) = ARCH_samples[sample_locations]
rownmames(expression) = ARCH_genes

rowMeans = rowMeans(expression)
expression = expression[order(rowMeans,decreasing = T),][1:20000,]
subsample = sample(1:ncol(expression),200)
sample_locations = which(ARCH_samples %in% subsample)
expression = expression[,subsample]


norm_expression = normalize.quantiles(expression)

mapped_genes = genesetr::HGNCapproved(ARCH_genes,untranslatable.na = T)



vars = rowVars(norm_expression)
norm_expression = norm_expression[order(vars,decreasing = T),]
expression = expression[order(vars,decreasing = T),]
mapped_genes = mapped_genes[order(vars,decreasing = T)]
dup_genes = duplicated(mapped_genes)
norm_expression = norm_expression[!dup_genes,]
expression = expression[!dup_genes,]
mapped_genes = mapped_genes[!dup_genes]
rownames(norm_expression) = mapped_genes
rownames(expression) = mapped_genes
norm_expression = cbind(genes = rownames(norm_expression), norm_expression)
tfs = data.frame(tfs = rownames(norm_expression)[rownames(norm_expression) %in% chea3::tfs])
write.table(norm_expression,"/volumes/Backup2/Cusanovich/ARACNe_input_ARCHS4/matrix.txt",sep = "\t",col.names = T, row.names = F, quote = F)
write.table(tfs,"/volumes/Backup2/Cusanovich/ARACNe_input_ARCHS4/tfs.txt",sep = "\t", col.names = F, row.names = F, quote = F)
