destination_file = "human_matrix.h5"

# Check if gene expression file was already downloaded, if not in current directory download file form repository
if (!file.exists(destination_file)) {
  print("Downloading compressed gene expression matrix.")
  url = 'https://s3.amazonaws.com/mssm-seq-matrix/human_matrix.h5'
  download.file(url, destination_file, quiet = FALSE)
} else{
  print("Local file already exists.")
}
library(rhdf5)
h5ls(destination_file)
sample_title = gsub("-","",toupper(h5read(destination_file, "meta/Sample_title")))
sample_char = gsub("-","",toupper(h5read(destination_file, "meta/Sample_characteristics_ch1")))
sample_desc = gsub("-","",toupper(h5read(destination_file, "meta/Sample_description")))
sample_name = gsub("-","",toupper(h5read(destination_file,"meta/Sample_source_name_ch1")))
series_id = h5read(destination_file,"meta/Sample_series_id")
sample_id = h5read(destination_file,"meta/Sample_geo_accession")

tfs = toupper(gsub("-","",chea3::tfs))
##add TF aliases
aliases = names(genesetr::hgnc_dict)[toupper(gsub("-","",genesetr::hgnc_dict)) %in% tfs]
tfs = unique(c(tfs,aliases))

tf_series = data.frame()

for(i in 1:length(tfs)){
  t = tfs[i]
  series = unique(series_id[unique(c(grep(t,sample_char),grep(t,sample_desc),grep(t,sample_name),grep(t,sample_title)))])
  temp = data.frame(tf = rep(t,length(series)),series = series)
  tf_series = rbind(tf_series, temp)
}

tf_series = tf_series[!tf_series$tf == "T",]
tf_series = tf_series[!tf_series$tf == "AR",]
tf_series = tf_series[!tf_series$tf == "KIN",]
tf_series = tf_series[!tf_series$tf == "MET",]
tf_series = tf_series[!tf_series$tf == "REL",]
tf_series = tf_series[!tf_series$tf == "KIN",]

mined = as.character(read.table("/Volumes/External/GEO_TF_RNAseq_mining/tf_mining.txt",sep = "\t",header = T)$series)

test = tf_series[!tf_series$series %in% mined,]

write.table(test,"/Volumes/External/tf_mining_partial_10082019.txt",sep = "\t",col.names = T, row.names = F, quote = F)

