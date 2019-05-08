#map remap files to Lambert TFs and HGNC-approved symbols
rm(list = ls())
indirs = c("/Volumes/External/Projects/TF_libs/gmts/remap_gmts_by_experiment_unmapped_termlabels/","/Volumes/External/Projects/TF_libs/gmts/all_remap_unmapped_termlabels/","/Volumes/External/Projects/TF_libs/gmts/merged_remap_unmapped_termlabels/")
outdirs = gsub("_unmapped_termlabels","",indirs)
lapply(outdirs,dir.create)

dir.create(outdir)
for(j in 1:length(indirs)){
  gmt_filenames = list.files(indirs[j])

  gmts = lapply(paste(indirs[j], gmt_filenames,sep = ""),genesetr::loadGMT)

  gmts = lapply(gmts, genesetr::removeLibWeights)

  gmts = lapply(gmts, genesetr::lib2HGNC, untranslatable.na = T)


  gmts = lapply(gmts, function(g){
    return(lapply(g, function(x){
      return(as.character(na.omit(x)))
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

    names(g) = gsub("_character\\(0\\)","",new_g_names)

    return(g)
  })

  for(i in 1:length(gmts)){
    genesetr::writeGMT(mapped_gmts[[i]],paste(outdirs[j],gmt_filenames[i],sep = ""))
  }
}
