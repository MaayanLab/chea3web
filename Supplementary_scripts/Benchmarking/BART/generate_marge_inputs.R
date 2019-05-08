rm(list = ls())

job = 1:3
perts = chea3::libs[["Perturbations"]]
perts = perts[grepl("HUMAN",names(perts))]
outfile_names = paste("new_marge_job",job,sep ="_")
outdir = "/volumes/backup2/"



for(i in 1:150){
  dir.create(paste(outdir,outfile_names[1],sep = ""))
  genes = data.frame(genes = perts[[i]],stringsAsFactors = F)
  write.table(genes,paste(outdir,outfile_names[1],"/",names(perts)[i],".txt",sep = ""),quote = F, row.names = F, col.names = F)
}


for(i in 151:300){
  dir.create(paste(outdir,outfile_names[2],sep = ""))
    genes = data.frame(genes = perts[[i]],stringsAsFactors = F)
  write.table(genes,paste(outdir,outfile_names[2],"/",names(perts)[i],".txt",sep = ""),quote = F, row.names = F, col.names = F)
}

for(i in 301:length(perts)){
  dir.create(paste(outdir,outfile_names[3],sep = ""))
    genes = data.frame(genes = perts[[i]],stringsAsFactors = F)
  write.table(genes,paste(outdir,outfile_names[3],"/",names(perts)[i],".txt",sep = ""),quote = F, row.names = F, col.names = F)
}
