rm(list = ls())
pkgTest <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x,dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}


pkgTest("data.table")
library(data.table)
library(RJSONIO)
library(tidyr)
library(plyr)
library(genefilter)
options(stringsAsFactors = F)

#remove double quotes from userlist csv that make it difficult to parse by fread()
ul1 = readLines("/Volumes/External/Enrichr/enrichr_userlists.csv", encoding="UTF-8")
ul2 = gsub("\"\"", "\"", ul1)  

file.remove("/Volumes/External/Enrichr/enrichr_userlists_new.csv")
writeLines(ul2, "/Volumes/External/Enrichr/enrichr_userlists_new.csv", useBytes = TRUE)

#parse userlist csv
userlists  = fread("/Volumes/External/Enrichr/enrichr_userlists_mod.csv",
  sep = ",",
  col.names= c("userListId","description","inputMethod",
                     "ipAddress","datetime","isFuzzy",
                     "userId","listId","isSaved","shortId",
                     "contributed","fullDescription","privacy"))

listgenes = fread("/Volumes/External/Enrichr/enrichr_listgenes.csv",sep = ",",
                  col.names = c("listGeneid","geneId","weight","listId"))


tfs = read.table("/Volumes/External/transcription_factors/tfs_Nature2009.txt",header = T)
kinases = read.table("/Volumes/External/kinases/uniprot_human_kinase_symbols.txt",header = T)


# ncbi_genes_df = read.table("/Volumes/External/Homo_sapiens.gene_info",sep = "\t",header = T,fill = T)
# ncbi_genes_df$Symbol = gsub(" ","",gsub("-","",toupper(ncbi_genes_df$Symbol)))
# ncbi_genes_df$Synonyms = gsub(" ","",gsub("-","",toupper(ncbi_genes_df$Synonyms)))
# ncbi_genes = c(as.character(ncbi_genes_df$Symbol), unlist(strsplit(as.character(ncbi_genes_df$Synonyms),"\\|")))

hgnc_genes_df = read.table("/Volumes/External/hgnc.tsv",sep = "\t", header = T,quote = "",comment.char="")
hgnc_genes_df[hgnc_genes_df$Previous_Symbols %in% "",]$Previous_Symbols = "|"
hgnc_genes_df[hgnc_genes_df$Synonyms %in% "",]$Synonyms = "|"
hgnc_genes_df$Synonyms = paste(hgnc_genes_df$Previous_Symbols,hgnc_genes_df$Synonyms,sep = ",")
hgnc_genes_df$Synonyms = gsub(",","\\|",gsub(" ","",gsub("-","",toupper(hgnc_genes_df$Synonyms))))
hgnc_genes_df$Symbol = gsub(" ","",gsub("-","",toupper(hgnc_genes_df$Approved_Symbol)))
hgnc_genes_df$Synonyms = gsub("\\|\\|\\|","",hgnc_genes_df$Synonyms)
hgnc_genes_df$Synonyms = gsub("\\|\\|","",hgnc_genes_df$Synonyms)
hgnc_genes_df$Synonyms = gsub(" ","\\|",hgnc_genes_df$Synonyms)
hgnc_genes = c(as.character(hgnc_genes_df$Symbol), unlist(strsplit(as.character(hgnc_genes_df$Synonyms),"\\|")))

genes = fromJSON("/Volumes/External/Enrichr/enrichr_genes.json")
genes = rbindlist(genes)
genes$name  = iconv(enc2utf8(genes$name),sub="byte")
genes$name = gsub(" ","",gsub("-","",toupper(genes$name)))
genes = as.data.frame(genes[genes$name %in% hgnc_genes,])
genes = genes[genes[,2]!="",]


#subset listgenes
listgenes = listgenes[listgenes$geneId %in% genes$geneId,]

#remove sample lists
userlists = userlists[!(userlists$listId %in% 1:12),]
listgenes = listgenes[!(listgenes$listId %in% 1:12),]

#remove lists that have >2000 genes
list_gene_counts = as.data.frame(table(listgenes$listId))
large_listIds = list_gene_counts[list_gene_counts$Freq>2000,]$Var1
userlists = userlists[!(userlists$listId %in% large_listIds),]
listgenes = listgenes[!(listgenes$listId %in% large_listIds),]

#remove lists that have 1 gene
small_listIds = list_gene_counts[list_gene_counts$Freq == 1,]$Var1
userlists = userlists[!(userlists$listId %in% small_listIds),]
listgenes = listgenes[!(listgenes$listId %in% small_listIds),]
#remove users that contributed a large number of lists (i.e. through the API)
#plot distribution of list contributions for each IP address
ip_list_counts = as.data.frame(table(userlists$ipAddress))
ip_list_counts = ip_list_counts[order(ip_list_counts$Freq,decreasing = T),]
plot(density(ip_list_counts$Freq[1:100]))

freq_user_ips = ip_list_counts[ip_list_counts$Freq>1000,]$Var1
freq_user_lists = userlists[userlists$ipAddress %in% freq_user_ips,]$listId
userlists = userlists[!(userlists$listId %in% freq_user_lists),]
listgenes = listgenes[!(listgenes$listId %in% freq_user_lists),]
listgenes_sub = listgenes[,c("listId","geneId")]
n_genes = length(unique(listgenes_sub$geneId))
syns = strsplit(hgnc_genes_df$Synonyms,"\\|")
names(syns) = hgnc_genes_df$Symbol
alias2official = ldply(syns, function(x) data.frame(synonyms = x))
colnames(alias2official) = c("official","name")
alias2official = alias2official[!duplicated(alias2official$name),]

#remove any synonyms that are also official gene names
syns_idx = alias2official$name %in% alias2official$official
alias2official = alias2official[!syns_idx,]

genes = merge(genes,alias2official,by="name",all.x = T,all.y = F)
genes[is.na(genes$official),"official"]=genes[is.na(genes$official),"name"]
alex = merge(listgenes_sub,genes,by = "geneId",all.x = T, all.y = F)

#count the number of unofficial symbols in each list
na_counts = ddply(alex,.(listId),function(sub) data.frame(listId = unique(sub$listId), na_counts = sum(sub$name_is_official)))

okay_listids = gene_counts[gene_counts$fraction_official>0.7,]$listId
alex = alex[alex$listId %in% okay_listids,]
alex = alex[alex$name %in% unique(alias2official$official),]


tfs$name = tfs$gene_symbol
tfs = merge(tfs,alias2official,by = "name",all.x =T,all.y = F)
tfs[is.na(tfs$official),"official"]=tfs[is.na(tfs$official),"name"]
tfs = tfs$name

kinases$name = kinases$gene_symbol
kinases = merge(kinases,alias2official,by = "name",all.x =T,all.y = F)
kinases[is.na(kinases$official),"official"]=kinases[is.na(kinases$official),"name"]
kinases = kinases$name



listgenes_sub = merge(listgenes_sub,genes,by="geneId",all.x = T)
all_genes = unique(listgenes_sub$official)
listids = unique(listgenes_sub$listId)
n_genes = length(all_genes)
tfs_cooccur = matrix(0,ncol = length(tfs),nrow = n_genes)
rownames(tfs_cooccur) = all_genes
colnames(tfs_cooccur) = tfs
listgenes_sub$geneId = NULL
listgenes_sub$name = NULL
rm(alias2official,genes,ip_list_counts,list_gene_counts,listgenes,
   userlists,freq_user_ips,freq_user_lists,large_listIds,
   small_listIds,syns,hgnc_genes_df,hgnc_genes)
for(i in 1:length(tfs)){
  gene = tfs[i]
  listids = listgenes_sub[listgenes_sub$official %in% gene,]$listId
  co_genes = listgenes_sub[listgenes_sub$listId %in% listids,]$official
  tab = as.data.frame(table(co_genes))
  tfs_cooccur[match(tab$co_genes,all_genes),i]=tab$Freq
}
tfs_cooccur = tfs_cooccur[,colSums(tfs_cooccur)>0]
write.table(tfs_cooccur,"/Volumes/External/CHEA3/tfs_cooccur1.tsv",quote = F, row.names = T, col.names = T, sep="\t")



kinases_cooccur = matrix(0,ncol = length(kinases),nrow = n_genes)
rownames(kinases_cooccur) = all_genes
colnames(kinases_cooccur) = kinases

for(i in 1:length(kinases)){
  gene = tfs[i]
  listids = listgenes_sub[listgenes_sub$official %in% gene,]$listId
  co_genes = listgenes_sub[listgenes_sub$listId %in% listids,]$official
  tab = as.data.frame(table(co_genes))
  kinases_cooccur[match(tab$co_genes,all_genes),i]=tab$Freq
}
kinases_cooccur = kinases_cooccur[,colSums(kinases_cooccur)>0]

write.table(kinases_cooccur,"/Volumes/External/CHEA3/kinases_cooccur1.tsv",quote = F, row.names = T, col.names = T, sep="\t")





# #sample lists
# iter = 10
# n_lists = 10000
# pairs = expand.grid(target = all_genes, tf = tfs)
# co_occur = matrix(data = 0, ncol = iter, nrow = nrow(pairs))
# colnames(co_occur) = paste(rep("co_occur",iter),1:iter,sep = ".")
# rownames(co_occur) = paste(pairs$tf,pairs$target,sep = ":")
# 
# for(i in 1:iter){
#   temp_listgenes = listgenes_sub[listgenes_sub$listId %in% listids[sample(1:length(listids),n_lists)],c("listId","official")]
#   temp_listgenes$listId  = as.character(temp_listgenes$listId)
#   temp_cooccur = crossprod(table(temp_listgenes))
#   temp_cooccur = temp_cooccur/rowSums(temp_cooccur)
#   temp_cooccur = temp_cooccur[,colnames(temp_cooccur) %in% tfs]
#   temp_cooccur = cbind(data.frame(target = rownames(temp_cooccur)), temp_cooccur)
#   gather.cooccur = gather(as.data.frame(temp_cooccur),"tf","cooccurrence",2:ncol(temp_cooccur))
#   gather.cooccur$pair = paste(gather.cooccur$tf,gather.cooccur$target,sep = ":")
#   gather.cooccur = gather.cooccur[gather.cooccur$cooccurrence>0,]
#   gather.cooccur$tf = NULL
#   gather.cooccur$target = NULL
# 
#   co_occur[match(gather.cooccur$pair,rownames(co_occur)),i] = gather.cooccur$cooccurrence
# }
# 
# 
