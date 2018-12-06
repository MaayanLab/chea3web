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
library(optrees)
library(jsonlite)

#source("/users/alexandrakeenan/Projects/Common/Utilities/Utilities.R")
options(stringsAsFactors = FALSE)


getNetworkJSON = function(edges){

  nodes = data.frame(name = unique(c(as.character(edges$target),as.character(edges$source))), stringsAsFactors = F)
  d3json = toJSON(list(nodes_dat = nodes, links_dat = edges))
  return(d3json)

}

writeJSON = function(json, filename){
  dir = "/users/alexandrakeenan/eclipse-workspace/chea3-dev/WebContent/assets/networkd3/"
  filepath = paste(dir,filename,sep = "")
  file.remove(filepath)
  fileConn<-file(filepath)
  writeLines(json, fileConn)
  close(fileConn)
}

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
rownames(pvals) = mapped_genes[tf_idx]
colnames(pvals) = mapped_genes[tf_idx]
coeffs = c$r
rownames(coeffs) = mapped_genes[tf_idx]
colnames(coeffs) = mapped_genes[tf_idx]

pvals_adj = matrix(p.adjust(pvals,method = "bonferroni"),ncol = ncol(pvals))
rownames(pvals_adj) = mapped_genes[tf_idx]
colnames(pvals_adj) = mapped_genes[tf_idx]

##retain connections that have a positive correlation coefficient and are significant following pvalue correction
m_coeffs = reshape2::melt(coeffs)
m_pvals_adj = reshape2::melt(pvals_adj)

m_coeffs$pval = m_pvals_adj[match(paste(m_coeffs$Var1,m_coeffs$Var2),paste(m_pvals_adj$Var1, m_pvals_adj$Var2)),"value"]

##remove self-connections
m_coeffs = m_coeffs[!is.na(m_coeffs$pval),]

##remove duplicate edges
dup_idx = duplicated(t(apply(as.matrix(m_coeffs[,c("Var1","Var2")]), 1, sort))) 
m_coeffs = m_coeffs[!dup_idx,]

#remove negative edges and edges that are not statistically significant
m_coeffs = m_coeffs[m_coeffs$pval <= 0.05,]
m_coeffs = m_coeffs[m_coeffs$value > 0,]

#express factors as strings
m_coeffs$Var1 = as.character(m_coeffs$Var1)
m_coeffs$Var2 = as.character(m_coeffs$Var2)

#maximum spanning tree (MST)
unique_genes = unique(c(m_coeffs$Var1,m_coeffs$Var2))
node_indices = data.frame(gene_symbol = unique_genes, index = 1:length(unique_genes))

m_coeffs$Var1_idx = node_indices[match(m_coeffs$Var1, node_indices$gene_symbol),"index"]
m_coeffs$Var2_idx = node_indices[match(m_coeffs$Var2, node_indices$gene_symbol),"index"]

#generate arc matrix
arcs = as.matrix(cbind(m_coeffs$Var1_idx, m_coeffs$Var2_idx, m_coeffs$value))
arcs[,3] = arcs[,3]*-1

#Kruskal MST
kruskal_tree = msTreeKruskal(1:length(unique_genes), arcs)
kruskal_edges= as.data.frame(kruskal_tree$tree.arcs)

kruskal_net_json = getNetworkJSON(data.frame(source = node_indices[match(kruskal_edges$ept1,node_indices$index),"gene_symbol"], target = node_indices[match(kruskal_edges$ept2,node_indices$index),"gene_symbol"],stringsAsFactors = F))

writeJSON(kruskal_net_json,"kruskal_MST_coexp.json")

#Primm MST
primm_tree = msTreePrim(1:length(unique_genes), arcs)
primm_edges= as.data.frame(primm_tree$tree.arcs)

primm_net_json = getNetworkJSON(data.frame(source = node_indices[match(primm_edges$ept1,node_indices$index),"gene_symbol"], target = node_indices[match(primm_edges$ept2,node_indices$index),"gene_symbol"],stringsAsFactors = F))

writeJSON(kruskal_net_json,"primm_MST_coexp.json")

#Boruvka MST
boruvka_tree = msTreeBoruvka(1:length(unique_genes), arcs)
boruvka_edges= as.data.frame(boruvka_tree$tree.arcs)

boruvka_net_json = getNetworkJSON(data.frame(source = node_indices[match(boruvka_edges$ept1,node_indices$index),"gene_symbol"], target = node_indices[match(boruvka_edges$ept2,node_indices$index),"gene_symbol"],stringsAsFactors = F))

writeJSON(boruvka_net_json,"boruvka_MST_coexp.json")




