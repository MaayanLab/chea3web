#map all single-TF perturbation gmts to Lambert et al and HGNC
rm(list = ls())
indir = "/Volumes/External/Projects/TF_libs/gmts/single_TF_pert_unmapped_termlabels/"
outdir = "/Volumes/External/Projects/TF_libs/gmts/single_TF_pert/"
dir.create(outdir)
gmt_filenames = list.files(indir)

gmts = lapply(paste(indir, gmt_filenames,sep = ""),genesetr::loadGMT)

gmts = lapply(gmts, genesetr::lib2HGNC, untranslatable.na = T)

gmts = lapply(gmts, function(g){
  return(lapply(g, function(x){
    return(x[!is.na(x)])
  }))
})

gmts = lapply(gmts, genesetr::removeDupes)

gmts = lapply(gmts, genesetr::removeEmptySets)

mapped_gmts = lapply(gmts,function(g){
  #map gene set names
  g_tfs = unlist(lapply(strsplit(names(g),"_"),"[[",1))
  mapped_g_tfs = genesetr::HGNCapproved(g_tfs,untranslatable.na = T)

  #remove gene sets with unmappable names
  g_na_idx = is.na(mapped_g_tfs)

  g = g[!g_na_idx]

  mapped_g_tfs = mapped_g_tfs[!g_na_idx]

  #remove gene sets associated with tfs that are not in Lambert et al.
  g_in_lamb_idx = mapped_g_tfs %in% chea3::tfs

  g = g[g_in_lamb_idx]

  mapped_g_tfs = mapped_g_tfs[g_in_lamb_idx]

  #replace tf names in gene set labels with mapped tfs
  new_g_names = paste(mapped_g_tfs,regmatches(names(g),gregexpr("(?<=_).*",names(g),perl=TRUE)),sep = "_")

  names(g) = new_g_names

  return(g)
})

for(i in 1:length(gmts)){
  genesetr::writeGMT(mapped_gmts[[i]],paste(outdir,gmt_filenames[i],sep = ""))
}
