#prepare TCGA data for WGCNA
library(preprocessCore)

tumor_types = c("Primary Solid Tumor", "Primary Blood Derived Cancer - Peripheral Blood","Primary Blood Derived Cancer - Bone Marrow")
tumor_type_codes = c("01","03","09")
tumor_type_letter = c("TP","TB","TBM")

tcga_dir = '/volumes/backup2/TCGA/'
tcga_files = list.files(tcga_dir)
tcga_files = tcga_files[grepl("TCGA-",tcga_files)]

tcga_exp = list()
for(i in 1:length(tcga_files)){
  filedir = paste(tcga_dir,tcga_files[i],"/",tcga_files[i],"-counts.txt",sep = "")
  exp = read.table(filedir,comment.char = "", quote = "", stringsAsFactors = F, header = T, sep = "\t")
  rownames(exp) = exp[,1]
  exp = exp[,-1]
  sample_type = unlist(sapply(strsplit(colnames(exp),"\\."),'[[',4))
  exp = exp[,sample_type %in% tumor_type_codes]
  colnames(exp) = paste(gsub("TCGA-","",tcga_files[i]),colnames(exp),sep = "_")
  if(ncol(exp)>99){
    exp = exp[,sample(colnames(exp),100)]
    tcga_exp[[gsub("TCGA-","",tcga_files[i])]] = exp
  }
  
}

tcga_exp_df = do.call(cbind, tcga_exp)
cnames = colnames(tcga_exp_df)
rnames = rownames(tcga_exp_df)

tcga_exp_df = as.data.frame(normalize.quantiles(as.matrix(tcga_exp_df)))
rownames(tcga_exp_df) = rnames
colnames(tcga_exp_df) = cnames
tcga_exp_df = tcga_exp_df[rownames(tcga_exp_df) %in% chea3::tfs,]

write.table(tcga_exp_df, paste("/volumes/Backup2/WGCNA_TCGA/","subsampled_tcga_exp.tsv",sep = ""), row.names = T, col.names = T, quote = F, sep = "\t")
