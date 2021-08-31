##################################################
## Project: ChEA3
##
## Script purpose: Map Enrichr gmts (downloaded from
## enrichr and available here:
## http://maayanlab.cloud/Enrichr/#stats)
## to approved HGNC-approved symbols (2018). Unmapped symbols are removed.
## Duplicate symbols within a gene set are also removed. Only gene sets
## associated with TFs as defined in Lambert et al. 2018 are included.
##
## Date: 06/20/2018
## Author: Alexandra Keenan
##################################################
gmt_dir = "/Volumes/External/CREEDS/downloaded_gmts/"
gmt_filenames = list.files(gmt_dir)
outdir = "/Users/alexandrakeenan/Projects/TF_libs/gmts/"
tfs = read.table("/Users/alexandrakeenan/Projects/Common/Lambert2018_TFs/human_tfs.tsv",
  stringsAsFactors=F, quote="", comment.char="", sep="\t",header = T)$Name
tfs = genesetr::HGNCapproved(tfs)
tfs = gsub("-","",tfs)
for(i in 1:length(gmt_filenames)){
  gmt = genesetr::loadGMT(paste(gmt_dir,gmt_filenames[i],sep = ""))
  gmt = genesetr::removeLibWeights(gmt)
  genes = genesetr::HGNCapproved(toupper(unlist(sapply(strsplit(names(gmt),"_"),"[",1))))
  genes = gsub("-","",genes)
  tf_gmt = gmt[genes %in% tfs]
  mapped_gmt = genesetr::lib2HGNC(tf_gmt,untranslatable.na = T)
  #remove nas
  mapped_gmt = lapply(mapped_gmt,function(set){
    return(set = set[!is.na(set)])
  })
  mapped_gmt = genesetr::removeDupes(mapped_gmt)
  mapped_gmt = genesetr::removeEmptySets(mapped_gmt)
  genesetr::writeGMT(mapped_gmt,paste(outdir,"HGNC_mapped_enrichr_",gmt_filenames[i],sep = ""))
}

