#generate df of BART results
rm(list = ls())
results_dir = "/Volumes/Backup2/Bart_results_pubversion/"
query_names = NULL
filenames = NULL
files = list.files(results_dir)[grep("bart_results",(list.files(results_dir)))]
filenames = paste(results_dir,files,sep= "")
query_names = gsub("_bart_results.txt","",files)

query_tfs = unlist(lapply(strsplit(files,"_"),"[[",1))
bart_results = list()
for(i in 1:length(filenames)){
  r = read.table(filenames[i], stringsAsFactors=F, quote="", comment.char="", sep="\t", header = T)
  #according to BART manual "most functional TFs of input data are ranked first"
  r$TF = genesetr::HGNCapproved(r$TF, untranslatable.na = T)
  r = r[!is.na(r$TF),]
  r = r[r$TF %in% chea3::tfs,]
  # #rank by pvalue
  # r$rank = rank(r$pvalue, ties.method = "random")
  #rank in order returned by the tool
  r$rank = 1:nrow(r)
  r$scaled_rank = r$rank/max(r$rank)
  temp_results = data.frame(query = query_names[i], query_tf = query_tfs[i], set_name = r$TF, rank = r$rank, 
    scaled_rank = r$rank/max(r$rank), class = 0, stringsAsFactors = F)
  temp_results[temp_results$query_tf == temp_results$set_name,"class"] = 1
  bart_results[[i]] = temp_results
}

bart_results = do.call(rbind, bart_results)

write.table(bart_results,"/volumes/Backup2/ChEA3_outsidetool_benchmarks/bart_results_pubversion.tsv", quote = F, row.names = F, col.names = T, sep = "\t")

  
