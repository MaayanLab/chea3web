#benchmark ChEA3 API tool
rm(list = ls())
library(magrittr)
library(jsonlite)
library(httr)

gmt = genesetr::loadGMT('/users/summerstudent/Desktop/ChEA3_up_dn_plots/ RNAseq_Micro_TF_perts_up_inactivating.gmt')
type = "inactiv_up"
outdir = '/users/summerstudent/Desktop/ChEA3_up_dn_plots/'
dir.create(outdir)

library_results = data.frame()
bordacount_results = data.frame()
toprank_results = data.frame()

base = "https://maayanlab.cloud/chea3/api/enrich/"

for(j in 1:length(gmt)){
  genes = paste(unique(gmt[[j]]),collapse=",")
  query_name = names(gmt)[j]
  call = paste(base, genes, "/qid/", query_name, sep = "")
  response = GET(call)
  json = content(response, "text")
  l = jsonlite::fromJSON(json)
  libs = do.call("rbind",l[3:length(l)])
  libs$library = gsub("\\..*","",rownames(libs))
  query_tf = unlist(strsplit(query_name,"_"))[1]
  libs$class = 0
  libs[libs$TF == query_tf,"class"] = 1
  library_results = rbind(library_results, data.frame(
    library = libs$library,
    query_name = libs$`Query Name`,
    scaled_rank = libs$`Scaled Rank`,
    rank = libs$Rank,
    set_name = libs$`Set name`,
    class = libs$class,stringsAsFactors = F)
  )
  bc = l[[1]]
  bc$scaled_rank = as.numeric(bc$Rank)/max(as.numeric(bc$Rank))
  bc$class = 0
  bc[bc$TF == query_tf,"class"] = 1
  bordacount_results = rbind(bordacount_results,
                             data.frame(query_set = bc$`Query Name`,
                                        set_name = bc$TF,
                                        rank = bc$Rank,
                                        scaled_rank = bc$scaled_rank,
                                        class = bc$class))
  
  tr = l[[2]]
  tr$scaled_rank = as.numeric(tr$Rank)/max(as.numeric(tr$Rank))
  tr$class = 0
  tr[tr$TF == query_tf,"class"] = 1
  toprank_results = rbind(toprank_results,
                          data.frame(query_set = tr$`Query Name`,
                                     set_name = tr$TF,
                                     rank = tr$Rank,
                                     scaled_rank = tr$scaled_rank,
                                     class = tr$class))
}

write.table(library_results, paste(outdir,type,'library_results.tsv',sep = ""), sep = "\t", quote = F, row.names = F, col.names = T)
write.table(bordacount_results, paste(outdir,type,'meanrank_results.tsv',sep = ""), sep = "\t", quote = F, row.names = F, col.names = T)
write.table(toprank_results, paste(outdir,type,'toprank_results.tsv',sep = ""), sep = "\t", quote = F, row.names = F, col.names = T)

