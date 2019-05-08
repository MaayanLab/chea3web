##################################################
## Project: ChEA3
## Script purpose: Generate gmts from TSS-peak scores
## Date: 06/27/2018
## Author: Alexandra Keenan
##################################################

dfdir = "/Volumes/External/ReMap_annotated/all_peaks/"
df_filename = list.files(dfdir)
top_percent = 0.025
outdir = "/users/alexandrakeenan/Projects/TF_libs/gmts/all_remap/"
dir.create(outdir)

for(i in 1:length(df_filename)){
  df = read.table(paste(dfdir,df_filename[i],sep = ""), stringsAsFactors=F, quote="", comment.char="", sep="\t", header = F)
  colnames(df) = c("chr","target","score","TF")
  list = plyr::dlply(df,plyr::.(TF),function(sub){
    sub = sub[order(sub$score,decreasing = T),][1:round(nrow(sub)*top_percent),]
    sub = sub[sub$score>0,]
    return(paste(sub$target,sub$score,sep = ","))
  })
  genesetr::writeGMT(list,paste(outdir,top_percent,"_",df_filename[i],sep = ""))
}
