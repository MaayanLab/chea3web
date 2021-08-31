rm(list = ls())
require(viper)


sig_dir = "/volumes/backup2/CREEDS_chardir_sigs/sigs/"
sig_files = list.files(sig_dir)
sig_files = sig_files[grepl("human",sig_files)]

results_dir = "/volumes/backup2/GTEX_VIPER_CREEDS_chdir_sig_results/"
file.create(results_dir)
viper_regulon = readRDS("/volumes/Backup2/ARACNe_output_GTEx/GTEx_regulon.rds")
viper_results = list()

for(j in 1:length(sig_files)){
  sig = read.table(paste(sig_dir,sig_files[j],sep = ""), sep = "\t", comment.char = "", quote = "", stringsAsFactors = F, header = T)
  sig$genes = toupper(sig$genes)
  sig$genes = genesetr::HGNCapproved(sig$genes,untranslatable.na = T)
  sig = sig[!is.na(sig$genes),]
  sig = sig[order(abs(sig$chrdir),decreasing = F),]
  sig = sig[!duplicated(sig$genes),]
  
  signature = sig$chrdir
  names(signature) = sig$genes
  mrs = msviper(ges = signature, regulon = viper_regulon, minsize = 4, ges.filter = F)
  nes = mrs$es$nes
  results_df = data.frame(
    set_name = names(nes), 
    nes = nes,
    query_name = gsub("\\.tsv","",sig_files[j]), 
    stringsAsFactors = F)
  #to enable benchmarking comparison, unreturned TFs are appended to the end of the ranking with NES of "NA"
  if(length(setdiff(names(viper_regulon),results_df$set_name))>0){
    results_df = rbind(results_df,data.frame(
      set_name = setdiff(names(viper_regulon),results_df$set_name),
      nes = NA,
      query_name = gsub("\\.tsv","",sig_files[j]),
      stringsAsFactors = F
    ))}
  
  results_df$set_TF = genesetr::HGNCapproved(unlist(sapply(strsplit(unlist(unlist(sapply(strsplit(results_df$set_name,
    " - "),"[[",1))),"_"),"[[",1)))
  results_df = results_df[results_df$set_TF %in% chea3::tfs,]
  results_df$rank = rank(-abs(results_df$nes),ties.method = "random")
  viper_results[[j]] =  results_df
  
  
}
viper_results = do.call(rbind,viper_results)
write.table(viper_results,"/volumes/backup2/GTEX_VIPER_CREEDS_chdir_sig_results/gtex_viper_creeds_rank_by_nes.tsv", col.names = T, row.names = F, sep = "\t", quote = F)




