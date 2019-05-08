#map enrichr co-occurrence file to Lamb et al. and HGNC
rm(list = ls())
outdir = "/Volumes/External/Projects/TF_libs/gmts/enricher_cooccurrence/"
dir.create(outdir)
gmt = genesetr::loadGMT("/Volumes/External/Projects/TF_libs/gmts/enrichr_cooccurrence_unmapped_termlabels/enrichr_coocurrence.gmt")
gmt = genesetr::lib2HGNC(gmt,untranslatable.na = T)
gmt = lapply(gmt,function(x){
  return(as.character(na.omit(x)))
})
gmt = genesetr::removeDupes(gmt)
gmt = genesetr::removeEmptySets(gmt)
gmt_tfs = names(gmt)
mapped_gmt_tfs = genesetr::HGNCapproved(gmt_tfs, untranslatable.na = T)
na_gmt_tfs = is.na(mapped_gmt_tfs)

gmt = gmt[!na_gmt_tfs]
mapped_gmt_tfs = mapped_gmt_tfs[!na_gmt_tfs]

names(gmt) = mapped_gmt_tfs

in_lamb_idx = mapped_gmt_tfs %in% chea3::tfs

gmt = gmt[in_lamb_idx]

genesetr::writeGMT(gmt,paste(outdir,"enrichr_coocurrence.gmt"))
