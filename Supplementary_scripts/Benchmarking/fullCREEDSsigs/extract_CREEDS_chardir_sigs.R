rm(list = ls())
#generate CREEDS query terms, reconcile with ChEA3 perturbations benchmark
creeds_gmt = genesetr::loadGMT("/users/summerstudent/CREEDS_limma_sigs/Single_Gene_Perturbations_from_GEO_up.txt")

chea3_gmt = chea3::Perturbations   
chea3_gmt = chea3_gmt[grepl("CREEDS",names(chea3_gmt))]
chea3_samples = unlist(lapply(names(chea3_gmt),function(x){tail(unlist(strsplit(x,"_")),1)}))
creeds_samples = unlist(lapply(names(creeds_gmt),function(x){tail(unlist(strsplit(x,"_")),1)}))
creeds_labels = data.frame(creeds = names(creeds_gmt), sample = creeds_samples, stringsAsFactors = F)
creeds_labels$chea3 = names(chea3_gmt)[match(creeds_labels$sample, chea3_samples)]
creeds_labels = creeds_labels[!is.na(creeds_labels$chea3),]
creeds_labels$sample= as.numeric(creeds_labels$sample)
#creeds_labels = creeds_labels[creeds_labels$species == "HUMAN",]
creeds_ids = paste("gene:",creeds_labels$sample,sep = "")


library(mongolite)
con = mongo(collection = "signatures", db = "microtask_signatures", url = "")

for(i in 1:length(creeds_ids)){
  query = paste('{"id":"',creeds_ids[i],'"}',sep = "")
  it = con$iterate(query = query)
  while(!is.null(x <- it$one())){
    result_id = paste(x$hs_gene_symbol,x$organism,x$geo_id,"sample",gsub("gene:","",x$id),sep = "_")
    result = data.frame(genes = unlist(x$chdir$genes), stringsAsFactors = F)
    result$chrdir = unlist(x$chdir$vals)[match(result$genes,unlist(x$chdir$genes))]
    result$chrdir_sva = unlist(x$chdir_sva_exp2$vals)[match(result$genes,unlist(x$chdir_sva_exp2$genes))]
    write.table(result, paste("/users/summerstudent/CREEDS_chardir_sigs/sigs/",result_id,".tsv",sep = ""), col.names = T, 
                row.names = F, sep = "\t", quote = F)
  }
  
}


