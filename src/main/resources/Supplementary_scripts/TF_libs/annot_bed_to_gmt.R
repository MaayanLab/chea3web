##################################################
## Project: ChEA3
## Script purpose: Generate gmts from bed files
## with annotated peaks
## Date: 06/20/2018
## Author: Alexandra Keenan
##################################################

annotated_beddir = "/Volumes/External/ReMap_annotated/merged_peaks/"
annotated_bed_filename = list.files(annotated_beddir)
tfs = read.table("/users/alexandrakeenan/Projects/Common/Lambert2018_TFs/human_tfs.tsv",
  stringsAsFactors=F, quote="", comment.char="", sep="\t",header = T)$Name
outdir = "/users/alexandrakeenan/Projects/TF_libs/gmts/merged_remap/"
dir.create(outdir)

for(i in 1:length(annotated_bed_filename)){
  an_bed = read.table(paste(annotated_beddir,annotated_bed_filename[i],sep = ""),stringsAsFactors=F, quote="", comment.char="", sep="\t", header = F)
  an_bed = an_bed[an_bed$V4 %in% tfs,]
  gmt = plyr::dlply(an_bed,plyr::.(V4),function(sub){
    targets = unique(genesetr::HGNCapproved(unlist(strsplit(sub$V10,",")),untranslatable.na = T))
    targets = targets[!is.na(targets)]
  })
  outfile = gsub(".bed","",annotated_bed_filename[i])
  genesetr::writeGMT(gmt,paste(outdir,outfile,".gmt",sep = ""))
}
