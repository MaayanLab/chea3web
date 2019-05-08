#benchmark ChEA3 API tool
rm(list = ls())
library(magrittr)
library(jsonlite)
library(httr)

gmt = genesetr::loadGMT('/volumes/Backup2/perturbation_gmts_short_long/TFpertGEO1000.gmt')
outdir = "/Volumes/backup2/ChEA3_API_Benchmark/"
dir.create(outdir)

library_results = data.frame()
bordacount_results = data.frame()
toprank_results = data.frame()

base = "https://amp.pharm.mssm.edu/chea3/api/enrich/"
encode = "json"

for(j in 1:length(gmt)){

  payload = list(query_name = names(gmt)[j], gene_set = gmt[[j]])
  response = POST(url = base, body = payload, encode = encode)
  
  json = content(response, "text")
  l = jsonlite::fromJSON(json)
  libs = do.call("rbind",l[3:length(l)])
  libs$Library = gsub("\\..*","",rownames(libs))
  query_tf = unlist(strsplit(names(gmt)[j],"_"))[1]
  libs$Overlapping_Genes = NULL
  libs$class = 0
  libs[libs$TF == query_tf,"class"] = 1
  library_results = rbind(library_results, data.frame(
    library = libs$Library,
    query_name = libs$`Query Name`,
    scaled_rank = libs$`Scaled Rank`,
    rank = libs$Rank,
    set_name = libs$Set_name,
    class = libs$class,stringsAsFactors = F)
  )
  bc = l[[which(names(l) %in% "Integrated--meanRank")]]
  bc$scaled_rank = as.numeric(bc$Rank)/max(as.numeric(bc$Rank))
  bc$class = 0
  bc[bc$TF == query_tf,"class"] = 1
  bordacount_results = rbind(bordacount_results,
                             data.frame(query_set = bc$`Query Name`,
                                        set_name = bc$TF,
                                        rank = bc$Rank,
                                        scaled_rank = bc$scaled_rank,
                                        class = bc$class))

  tr = l[[which(names(l) %in% "Integrated--topRank")]]
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

write.table(library_results, paste(outdir,'library_results_TFpertGEO1000.tsv',sep=""), sep = "\t", quote = F, row.names = F, col.names = T)
write.table(bordacount_results, paste(outdir,'meanrank_results_TFpertGEO1000.tsv',sep = ""), sep = "\t", quote = F, row.names = F, col.names = T)
write.table(toprank_results, paste(outdir,'toprank_results_TFpertGEO1000.tsv',sep =""), sep = "\t", quote = F, row.names = F, col.names = T)

