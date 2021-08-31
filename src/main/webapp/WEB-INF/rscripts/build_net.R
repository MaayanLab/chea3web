rm(list = ls())
library(plyr)
library(magrittr)
library(genesetr)
library(jsonlite)

##max_edges = 10
##min_edges = 1
percent_edges = .01

##build network for d3 visualization
tfs = chea3::tfs
libs = chea3::libs[setdiff(names(chea3::libs),"BioGRID")]

##edge list for each library
edgelist = ldply(libs, function(lib){
  tf_subset = llply(removeLibWeights(lib), function(set){
    return(set[set %in% tfs])
  })
  tf_subset = tf_subset %>% removeEmptySets() %>% toLongDF()
  return(tf_subset);
})

#designate library types
chip_idx = edgelist$.id == "ReMap" | edgelist$.id == "ENCODE" | edgelist$.id == "ChEA"
coexp_idx = edgelist$.id == "GTEx" | edgelist$.id == "ARCHS4"
cooccur_idx = edgelist$.id == "Enrichr"
perturb_idx = edgelist$.id == "Perturbations"

edgelist$assay = ""
edgelist[chip_idx,"assay"] = "chip"
edgelist[coexp_idx,"assay"] = "coexp"
edgelist[cooccur_idx,"assay"] = "cooccur"
edgelist[perturb_idx,"assay"] = "perturb"
edgelist$weight = NULL
#edgelist$.id = NULL
edgelist$assay = NULL

#one edge per assay type
edgelist$set_name = unlist(lapply(strsplit(edgelist$set_name,"_"),"[[",1))
edgelist = edgelist[!duplicated(paste(edgelist$gene,edgelist$set_name,edgelist$.id)),]


tf_edge_count = as.data.frame(table(edgelist$set_name, edgelist$gene))
tf_edge_count = tf_edge_count[tf_edge_count$Freq>0,]
tf_edge_count$Var1 = as.character(tf_edge_count$Var1)
tf_edge_count$Var2 = as.character(tf_edge_count$Var2)
colnames(tf_edge_count) = c("source","target","score")
tf_edge_count = tf_edge_count[tf_edge_count$source != tf_edge_count$target,]
network = ddply(tf_edge_count,.(source),function(s){
  s = s[order(s$score,decreasing = T),]
  n = s[s$score > 4,]
  if(empty(n)){
    n = s[1,]
  }else if(empty(n)){
    n = s[s$score >= 4,]
  }else{
    n = s[1,]
  }
  return(n)
})
#network = tf_edge_count[tf_edge_count$score >= 4,]

network$score = NULL

nodes = data.frame(name = unique(c(as.character(network$target),as.character(network$source))), stringsAsFactors = F)
d3json = toJSON(list(nodes_dat = nodes, links_dat = network))

#write to file
file.remove("/users/alexandrakeenan/eclipse-workspace/chea3-dev/WebContent/assets/networkd3/tf10perc.json")
fileConn<-file("/users/alexandrakeenan/eclipse-workspace/chea3-dev/WebContent/assets/networkd3/tf10perc.json")
writeLines(d3json, fileConn)
close(fileConn)

