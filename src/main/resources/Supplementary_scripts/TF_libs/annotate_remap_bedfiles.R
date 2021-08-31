library(ChIPhandlr)
bedfile = "/Volumes/External/ReMap_downloads/merged_peaks/remap2018_public_nr_macs2_hg38_v1_2.bed"
bedname = "remap2018_public_merged"

bed = read.table(bedfile,stringsAsFactors=F, quote="", comment.char="", sep="\t", header = F)
colnames(bed) = c("chr","feature_start","feature_end","gene","unk1","strand",
  "peak_start","peak_end","unk2")

ChIPhandlr::fixedWindow(bed,paste(bedfile,"_fixedWin_-1000_1000.bed",sep = ""),c(-1000,1000))
ChIPhandlr::fixedWindow(bed,paste(bedfile,"_fixedWin_-5000_1000.bed",sep = ""),c(-5000,1000))
ChIPhandlr::fixedWindow(bed,paste(bedfile,"_fixedWin_-5000_5000.bed",sep = ""),c(-5000,5000))
ChIPhandlr::closestTSS(bed,paste(bedfile,"_closestTSS.bed",sep = ""))
ChIPhandlr::closestPeak(bed,paste(bedfile,"_closestPeak.bed",sep = ""))

bedfile2 = "/Volumes/External/ReMap_downloads/merged_peaks/remap2018_encode_nr_macs2_hg38_v1_2.bed"
bedname2 = "remap2018_encode_merged"
bed2 = read.table(bedfile2,stringsAsFactors=F, quote="", comment.char="", sep="\t", header = F)
colnames(bed2) = c("chr","feature_start","feature_end","gene","unk1","strand",
  "peak_start","peak_end","unk2")
ChIPhandlr::fixedWindow(bed2,paste(bedfile2,"_fixedWin_-1000_1000.bed",sep = ""),c(-1000,1000))
ChIPhandlr::fixedWindow(bed2,paste(bedfile2,"_fixedWin_-5000_1000.bed",sep = ""),c(-5000,1000))
ChIPhandlr::fixedWindow(bed2,paste(bedfile2,"_fixedWin_-5000_5000.bed",sep = ""),c(-5000,5000))
ChIPhandlr::closestTSS(bed2,paste(bedfile2,"_closestTSS.bed",sep = ""))
ChIPhandlr::closestPeak(bed2,paste(bedfile2,"_closestPeak.bed",sep = ""))


bedfile3 = "/Volumes/External/ReMap_downloads/merged_peaks/remap2018_nr_macs2_hg38_v1_2.bed"
bedname3 = "remap2018_all_merged"
bed3 = read.table(bedfile2,stringsAsFactors=F, quote="", comment.char="", sep="\t", header = F)
colnames(bed3) = c("chr","feature_start","feature_end","gene","unk1","strand",
  "peak_start","peak_end","unk2")
ChIPhandlr::fixedWindow(bed3,paste(bedfile3,"_fixedWin_-1000_1000.bed",sep = ""),c(-1000,1000))
ChIPhandlr::fixedWindow(bed3,paste(bedfile3,"_fixedWin_-5000_1000.bed",sep = ""),c(-5000,1000))
ChIPhandlr::fixedWindow(bed3,paste(bedfile3,"_fixedWin_-5000_5000.bed",sep = ""),c(-5000,5000))
ChIPhandlr::closestTSS(bed3,paste(bedfile3,"_closestTSS.bed",sep = ""))
ChIPhandlr::closestPeak(bed3,paste(bedfile3,"_closestPeak.bed",sep = ""))


####these bed files aren't annotated. rather, TF libs are generated directly given

rm(list = ls())
bedfile4 = "/users/summerstudent/Downloads/remap2018_all_macs2_hg38_v1_2.bed"

bedname4 = "remap_all"
bed4 = data.table::fread(bedfile4, sep = "\t", header = F)

colnames(bed4) = c("chr","feature_start","feature_end","meta","unk1","strand",
  "peak_start","peak_end","unk2")

bed4 = plyr::ddply(bed4,plyr::.(chr),function(chr){
  chr = cbind(chr,genesetr::dfcols.tochar(reshape::colsplit(chr$meta,split = "\\.", names = c("series","TF","cell_line"))))
  idx = gsub("-","",chr$TF) %in% gsub("-","",chea3::tfs)
  chr = chr[idx,]
  return(chr)},.parallel = T)

bed4$geneset = paste(bed5$TF,bed5$series, bed5$cell_line, sep = "_")

ChIPhandlr::linearPeakScore(bed = bed4,paste("/users/summerstudent/TF_libs/",bedname4,".tsv",sep = ""),window = 50000)
###########
rm(list = ls())
bedfile5 = "/users/summerstudent/Downloads/remap2018_encode_all_macs2_hg38_v1_2.bed"
bedname5 = "remap_encode_all"
bed5 = data.table::fread(bedfile5, sep = "\t", header = F)

colnames(bed5) = c("chr","feature_start","feature_end","meta","unk1","strand",
                   "peak_start","peak_end","unk2")

bed5 = plyr::ddply(bed5,plyr::.(chr),function(chr){
  chr = cbind(chr, genesetr::dfcols.tochar(reshape::colsplit(chr$meta,split = "\\.", names = c("series","TF","cell_line"))))
  idx = gsub("-", "", chr$TF) %in% gsub("-", "", chea3::tfs)
  chr = chr[idx, ]
  return(chr)}, .parallel = T)

bed5$geneset = paste(bed5$TF,bed5$series, bed5$cell_line, sep = "_")

outdir = "/users/summerstudent/TF_libs/remap_encode_all_by_experiment/"
dir.create(outdir)
plyr::ddply(bed5, plyr::.(geneset), function(exp){
  ChIPhandlr::linearPeakScore(bed = exp, 
                              paste(outdir, unique(exp$geneset) ,sep = ""), 
                              window = 50000)
  return("written")
})


ChIPhandlr::linearPeakScore(bed = bed5,paste("/users/summerstudent/TF_libs/",bedname5,".tsv",sep = ""),window = 50000)

#################
rm(list = ls())
doMC::registerDoMC(6)
bedfile6 = "/users/summerstudent/Downloads/remap2018_public_all_macs2_hg38_v1_2.bed"
bedname6 = "remap_public_all"
bed6 = data.table::fread(bedfile6, sep = "\t", header = F)

colnames(bed6) = c("chr","feature_start","feature_end","meta","unk1","strand",
                   "peak_start","peak_end","unk2")

bed6 = plyr::ddply(bed6,plyr::.(chr),function(chr){
  chr = cbind(chr,genesetr::dfcols.tochar(reshape::colsplit(chr$meta,split = "\\.", names = c("series","TF","cell_line"))))
  idx = gsub("-","",chr$TF) %in% gsub("-","",chea3::tfs)
  chr = chr[idx,]
  return(chr)},.parallel = T)

bed6$geneset = paste(bed6$TF,bed6$series, bed6$cell_line, sep = "_")

#create separate gene set for each experiment
outdir = "/users/summerstudent/TF_libs/remap_public_all_by_experiment/"
dir.create(outdir)
plyr::ddply(bed6,plyr::.(geneset),function(exp){
  ChIPhandlr::linearPeakScore(bed = exp, 
                              paste(outdir, unique(exp$geneset) ,sep = ""), 
                              window = 50000)
  return("written")
})


#all 
ChIPhandlr::linearPeakScore(bed = bed6,paste("/users/summerstudent/TF_libs/",bedname6,".tsv",sep = ""),window = 50000)







