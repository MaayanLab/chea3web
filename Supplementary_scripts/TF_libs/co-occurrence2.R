
#load libraries
library(data.table)
library(jsonlite)
library(tidyr)
library(plyr)
library(genefilter)
options(stringsAsFactors = F)

#parse genes
genes = fromJSON("/Volumes/External/Enrichr/enrichr_genes.json")

#map gene symbols to HGNC approved symbols
genes$mapped_names = genesetr::HGNCapproved(genes$name, untranslatable.na = T)
genes = genes[!is.na(genes$mapped_names),]

#parse listgenes
listgenes = fread("/Volumes/External/Enrichr/enrichr_listgenes.csv",sep = ",",
  col.names = c("listGeneid","geneId","weight","listId"))

#subset listgenes to include only those that could 
#be mapped to approved HGNC symbols
listgenes = listgenes[listgenes$geneId %in% genes$geneId,]

#remove sample lists
listgenes = listgenes[!(listgenes$listId %in% 1:12),]

#remove lists that have >5000 genes
list_gene_counts = as.data.frame(table(listgenes$listId))
large_listIds = list_gene_counts[list_gene_counts$Freq>5000,]$Var1
listgenes = listgenes[!(listgenes$listId %in% large_listIds),]

#remove lists that have <5 genes
small_listIds = list_gene_counts[list_gene_counts$Freq < 5,]$Var1
listgenes = listgenes[!(listgenes$listId %in% small_listIds),]

#parse userlists
userlists = readLines("/Volumes/External/Enrichr/enrichr_userlists.csv", encoding="UTF-8")
userlists = reshape2::colsplit(userlists,",",c("userListId","description","inputMethod",
  "ipAddress","datetime","isFuzzy",
  "userId","listId","isSaved","shortId",
  "contributed","fullDescription","privacy"))

#remove users that contributed a large number of lists (i.e. through the API)
#plot distribution of list contributions for each IP address
ip_list_counts = as.data.frame(table(userlists$ipAddress))
freq_user_ips = ip_list_counts[ip_list_counts$Freq>2000,]$Var1
freq_user_lists = userlists[userlists$ipAddress %in% freq_user_ips,]$listId
userlists = userlists[!(userlists$listId %in% freq_user_lists),]
listgenes = listgenes[listgenes$listId %in% userlists$listId,]

listgenes$gene_name = genes[match(listgenes$geneId,genes$geneId),
  "mapped_names"]

all_genes = unique(listgenes$gene_name)
listids = unique(listgenes$listId)
n_genes = length(all_genes)

cooccur = matrix(0,ncol = n_genes,nrow = n_genes)
rownames(cooccur) = all_genes
colnames(cooccur) = all_genes

#store listgenes as Big File Backed memory
fbm_sigs = bigstatsr::FBM(nrow = nrow(listgenes), ncol = ncol(listgenes), init = listgenes)
listnames_rid = rownames(all_sigs)
listnames_cid = colnames(all_sigs)
rm(all_sigs)

#clear unneeded memory
listgenes[,c("geneId","weight","listGeneid")] = NULL
rm(userlists,genes,ip_list_counts,list_gene_counts,
  userlists,freq_user_ips,freq_user_lists,large_listIds,
  small_listIds)

write.table(listgenes,"/volumes/external/Enrichr/cooccurrence_input.tsv",sep = "\t",row.names = F, col.names = F, quote = F)

file.remove("/volumes/external/Enrichr/cooccurence_output.tsv")
command = "java -Xmx10G -jar /volumes/external/Enrichr/cooccurrence.jar -f /volumes/external/Enrichr/cooccurrence_input.tsv -o /volumes/external/Enrichr/cooccurrence_output.tsv -e 1 -p 0"
system(command)


# t = proc.time()
# #for each gene, count co-occurrence with all other genes
# for(i in 1:100){
#   gene = all_genes[i]
#   listids = listgenes[listgenes$gene_name %in% gene,]$listId
#   co_genes = listgenes[listgenes$listId %in% listids,]$gene_name
#   tab = as.data.frame(table(co_genes))
#   cooccur[match(tab$co_genes,all_genes),i]=tab$Freq
# }
# proc.time()-t

#write listgenes to file for .jar command line function

