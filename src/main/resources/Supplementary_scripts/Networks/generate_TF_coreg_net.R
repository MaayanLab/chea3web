#ChEA3 co-regulatory network
#gmts to dataframes
rm(list = ls())
library(foreach)
library(doMC)
registerDoMC(4) 

libs_dfs = lapply(chea3::libs,genesetr::toLongDF)
libs_dfs = plyr::adply(setdiff(names(chea3::libs),"Perturbations"),1,
  function(name){
  lib = chea3::libs[[name]]
  lib_df = genesetr::toLongDF(lib)
  lib_df$TF = unlist(sapply(strsplit(lib_df$set_name,"_"),head,1))
  lib_df = lib_df[lib_df$TF != lib_df$gene,]
  lib_df = lib_df[lib_df$gene %in% chea3::tfs,]
  edges = as.data.frame(table(lib_df[,c("TF","gene")]))
  edges = edges[edges$Freq>0,]
  total_tf_sets = as.data.frame(table(lib_df[!duplicated(lib_df$set_name),"TF"]))
  colnames(total_tf_sets) = c("TF","total_tf_sets")
  edges = merge(edges,total_tf_sets,by = "TF",all.x = T)
  edges$lib = name
  return(edges)
  
})

libs_dfs$temp = paste(libs_dfs$TF,libs_dfs$gene)

all_edges = as.data.frame(t(combn(chea3::tfs,2)))
all_edges$TFA = as.character(all_edges$V1)
all_edges$TFB = as.character(all_edges$V2)
all_edges$V1 = NULL
all_edges$V2 = NULL

#subset all edges
all_edges$temp = paste(all_edges$TFA,all_edges$TFB)
all_edges$temp2 = paste(all_edges$TFB,all_edges$TFA)

all_edges = all_edges[all_edges$temp %in% libs_dfs$temp | all_edges$temp2 %in% libs_dfs$temp,]
all_edges$temp = NULL
all_edges$temp2 = NULL

all_edges$edge_type = ""
all_edges$edge_score = ""
all_edges$ABchipseq_evidence = "none"
all_edges$coexpression_evidence = "none"
all_edges$cooccurrence_evidence = "none"
all_edges$BAchipseq_evidence = "none"


undir = c("GTEx","ARCHS4","Enrichr")
dir = c("ReMap", "ENCODE", "ChEA")
coexp = c("GTEx","ARCHS4")
cooccur = c("Enrichr")
chip = c("ReMap","ENCODE","ChEA")

#A>B edges
edges = foreach(i=1:nrow(all_edges)) %dopar% {
  
  AB_edges = libs_dfs[libs_dfs$TF == all_edges$TFA[i] & libs_dfs$gene == all_edges$TFB[i],]
  BA_edges = libs_dfs[libs_dfs$gene == all_edges$TFA[i] & libs_dfs$TF == all_edges$TFB[i],]
  edges = all_edges[i,]
  #determine edge direction
  if(any(AB_edges$lib %in% dir) && any(BA_edges$lib %in% dir)){
    edges$edge_type = "bidir"
    
  }else if(any(AB_edges$lib %in% dir)){
    edges$edge_type = "AB"
  }else if(any(BA_edges$lib %in% dir)){
    edges$edge_type = "BA"
  }else{
    edges$edge_type = "undir"
  }
  
  #determine edge score
  edges$edge_score = sum(unique(c(BA_edges$lib,AB_edges$lib)) %in% c(dir,undir))
  
  #set evidence
  if(any(AB_edges$lib %in% chip)){
    edges$ABchipseq_evidence = paste(unique(AB_edges$lib[AB_edges$lib %in% chip]),collapse = ",")
  }
  
  if(any(BA_edges$lib %in% chip)){
    edges$BAchipseq_evidence = paste(unique(BA_edges$lib[BA_edges$lib %in% chip]),collapse = ",")
  }
  
  if(any(AB_edges$lib %in% cooccur) || any(BA_edges$lib %in% cooccur)){
    edges$cooccurrence_evidence = paste(unique(c(BA_edges$lib[BA_edges$lib %in% cooccur],
      AB_edges$lib[AB_edges$lib %in% cooccur])),collapse = ",")
  }
  
  if(any(AB_edges$lib %in% coexp) || any(BA_edges$lib %in% coexp)){
    edges$coexpression_evidence = paste(unique(c(BA_edges$lib[BA_edges$lib %in% coexp],
      AB_edges$lib[AB_edges$lib %in% coexp])),collapse = ",")
  }
  
  edges
}
edges_df = do.call(rbind,edges)

jsonlite::write_json(edges_df,'/volumes/backup2/chea3_coreg_network.json')
edges_sub = edges_df[edges_df$edge_score>1,]
jsonlite::write_json(edges_sub,"/volumes/backup2/chea3_coreg_sub_network.json")
