rm(list = ls())
require(viper)

# Load TF regulon genesets in VIPER format
reg_dir = "/volumes/backup2/DoRothEA-master/data/TFregulons/consensus/Robjects_VIPERformat/normal/"
reg_files = list.files(reg_dir)

sig_dir = "/volumes/backup2/GEO_TF_RNAseq_mining/signature_files_chardir_logcpm_0905018/"
sig_files = list.files(sig_dir)
sig_files_df = data.frame(sig = gsub(".txt","",sig_files), stringsAsFactors = F)
sig_files_df$TF = unlist(sapply(strsplit(sig_files_df$sig,"_"),"[[",1))
sig_files_df$TF_hgnc = genesetr::HGNCapproved(sig_files_df$TF,untranslatable.na = T)
sig_files_df$in_bench = sig_files_df$TF_hgnc %in% unlist(sapply(strsplit(names(chea3::Perturbations),"_"),"[[",1))
sig_files = sig_files[sig_files_df$in_bench]
sig_file_df = sig_files_df[sig_files_df$in_bench,]


results_dir = "/volumes/backup2/DoRoTHEA_GEORNASEQ_chrdir_sig_results/results/"

dir.create(results_dir)



for(i in 1:length(reg_files)){
  
  dorothea_results = list()
  
  load(paste(reg_dir,reg_files[i],sep = ""))
  
  for(j in 1:length(sig_files)){
    sig = read.table(paste(sig_dir,sig_files[j],sep = ""), sep = "\t", comment.char = "", quote = "", stringsAsFactors = F, header = T)
    sig$genes = rownames(sig)
    sig$genes = genesetr::HGNCapproved(sig$genes,untranslatable.na = T)
    sig = sig[!is.na(sig$genes),]
    sig = sig[order(abs(sig$val.chardir),decreasing = T),]
    sig = sig[!duplicated(sig$genes),]
    rownames(sig) = sig$genes
    signature = sig$val.chardir
    names(signature) = toupper(rownames(sig))
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
    dorothea_results[[j]] =  results_df
  }
  dorothea_results = do.call(rbind,dorothea_results)
  write.table(dorothea_results,paste(results_dir,gsub(".rdata","",reg_files[i]),"NES_ranked.tsv",sep = ""), col.names = T, row.names = F, sep = "\t", quote = F)
}






