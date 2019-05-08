#2/20/2019
#process and map ENCODE 2015 and ChEA 2015 gmts downloaded from Enrichr on 2/20/2019
rm(list = ls())
chea  = genesetr::loadGMT("/volumes/External/Projects/TF_libs/gmts/enrichr_dwnlds/ChEA_2015.txt")
encode = genesetr::loadGMT("/volumes/External/Projects/TF_libs/gmts/enrichr_dwnlds/ENCODE_TF_ChIP-seq_2015.txt")

outdir = '/Volumes/External/Projects/TF_libs/gmts/chea_encode_chipseq_gmts/'
dir.create(outdir)

tfs = chea3::tfs

#map geneset members to HGNC
chea = genesetr::lib2HGNC(chea, untranslatable.na = T)
encode = genesetr::lib2HGNC(encode, untranslatable.na = T)

#remove duplicate gene set members
chea = genesetr::removeDupes(chea)
encode = genesetr::removeDupes(encode)

#remove empty sets
chea = genesetr::removeEmptySets(chea)
encode = genesetr::removeEmptySets(encode)

#remove unmappable geneset members
chea = lapply(chea, function(x){
  return(as.character(na.omit(x)))
})

encode = lapply(encode, function(x){
  return(as.character(na.omit(x)))
})

#map gene set names
chea_tfs = unlist(lapply(strsplit(names(chea),"_"),"[[",1))
encode_tfs = unlist(lapply(strsplit(names(encode),"_"),"[[",1))
mapped_chea_tfs = genesetr::HGNCapproved(chea_tfs,untranslatable.na = T)
mapped_encode_tfs = genesetr::HGNCapproved(encode_tfs,untranslatable.na = T)

#remove gene sets with unmappable names
chea_na_idx = is.na(mapped_chea_tfs)
encode_na_idx = is.na(mapped_encode_tfs)

chea = chea[!chea_na_idx] 
encode = encode[!encode_na_idx]

mapped_chea_tfs = mapped_chea_tfs[!chea_na_idx]
mapped_encode_tfs = mapped_encode_tfs[!encode_na_idx] 

#remove gene sets associated with tfs that are not in Lambert et al.
chea_in_lamb_idx = mapped_chea_tfs %in% chea3::tfs
encode_in_lamb_idx = mapped_encode_tfs %in% chea3::tfs

chea = chea[chea_in_lamb_idx]
encode = encode[encode_in_lamb_idx]

mapped_chea_tfs = mapped_chea_tfs[chea_in_lamb_idx]
mapped_encode_tfs = mapped_encode_tfs[encode_in_lamb_idx]

#replace tf names in gene set labels with mapped tfs
new_chea_names = paste(mapped_chea_tfs,regmatches(names(chea),gregexpr("(?<=_).*",names(chea),perl=TRUE)),sep = "_")

new_encode_names = paste(mapped_encode_tfs,regmatches(names(encode),gregexpr("(?<=_).*",names(encode),perl=TRUE)),sep = "_")

names(chea) = new_chea_names
names(encode) = new_encode_names

genesetr::writeGMT(chea,paste(outdir,"ChEA2015_mapped.gmt", sep = ""))
genesetr::writeGMT(encode,paste(outdir,"ENCODE2015_mapped.gmt",sep = ""))

