#reannotate colors on netnodes 4
net_nodes = jsonlite::fromJSON('/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/wgcna_gtex_annotated3.json')

colors = c("chartreuse4","chartreuse","chocolate4","aquamarine4","darkgoldenrod3","darkmagenta","firebrick","deeppink","darkturquoise","darkorchid1","orange","blue4","black","lightblue","seagreen","yellow","lightcoral","plum","tan4","sienna1","aquamarine","springgreen2","orangered3","pink","midnightblue","forestgreen","red","purple","darkred","cyan","chocolate3")
pie(x = rep(1/length(colors),length(colors)),col = colors)

hex_colors = NULL
for(i in 1:length(colors)){
  hex_colors = c(hex_colors,gplots::col2hex(colors[i])[1])
}

net_nodes$General_tissue_color = NULL
net_nodes$Specific_tissue_color = NULL
net_nodes$GO_enrichment_color = NULL

spec_tissue_colors = data.frame(Specific_tissue = unique(net_nodes$Specific_tissue), Specific_tissue_color = hex_colors[1:length(unique(net_nodes$Specific_tissue))])

gen_tissue_colors = data.frame(General_tissue = unique(net_nodes$General_tissue), General_tissue_color = hex_colors[1:length(unique(net_nodes$General_tissue))])

go_colors = data.frame(GO_enrichment = unique(net_nodes$GO_enrichment),
  GO_enrichment_color = hex_colors[1:length(unique(net_nodes$GO_enrichment))])

net_nodes = merge(net_nodes,spec_tissue_colors,by="Specific_tissue",all.x = T)

net_nodes = merge(net_nodes,gen_tissue_colors,by="General_tissue",all.x = T)

net_nodes = merge(net_nodes,go_colors,by = "GO_enrichment",all.x = T)

net_nodes[net_nodes$WGCNA_module == "grey","GO_enrichment"] = NA
net_nodes[net_nodes$WGCNA_module == "grey","Specific_tissue_color"] = "#BEBEBE"
net_nodes[net_nodes$WGNCA_module == "grey","General_tissue_color"] = "#BEBEBE"
net_nodes[net_nodes$WGCNA_module == "grey", "GO_enrichment_color"] = "#BEBEBE"

net_nodes_json = jsonlite::toJSON(net_nodes)

filepath = "/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/wgcna_gtex_annotated5.json"
file.remove(filepath)
fileConn<-file(filepath)
writeLines(net_nodes_json, fileConn)
close(fileConn)

#make legends
general_tissue_legend = data.frame(tissue = net_nodes[!duplicated(paste(net_nodes$General_tissue,net_nodes$General_tissue_color)),"General_tissue"], color = net_nodes[!duplicated(paste(net_nodes$General_tissue,net_nodes$General_tissue_color)),"General_tissue_color"])
general_tissue_legend = general_tissue_legend[!is.na(general_tissue_legend$tissue),]
general_tissue_legend_json = jsonlite::toJSON(general_tissue_legend)

filepath = "/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/general_tissue_legend3.json"
file.remove(filepath)
fileConn<-file(filepath)
writeLines(general_tissue_legend_json, fileConn)
close(fileConn)

specific_tissue_legend = data.frame(tissue = net_nodes[!duplicated(net_nodes$Specific_tissue),"Specific_tissue"], color = net_nodes[!duplicated(net_nodes$Specific_tissue),"Specific_tissue_color"])

specific_tissue_legend = specific_tissue_legend[!is.na(specific_tissue_legend$tissue),]

specific_tissue_legend_json = jsonlite::toJSON(specific_tissue_legend)

filepath = paste("/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/specific_tissue_legend3.json")
file.remove(filepath)
fileConn<-file(filepath)
writeLines(specific_tissue_legend_json, fileConn)
close(fileConn)

GO_enrichment_legend = data.frame(GO_enrichment = net_nodes[!duplicated(net_nodes$GO_enrichment),"GO_enrichment"], color = net_nodes[!duplicated(net_nodes$GO_enrichment),"GO_enrichment_color"])

GO_enrichment_legend = GO_enrichment_legend[!is.na(GO_enrichment_legend$GO_enrichment),]

GO_enrichment_legend_json = jsonlite::toJSON(GO_enrichment_legend)

filepath = paste("/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/GO_enrichment_legend3.json")
file.remove(filepath)
fileConn<-file(filepath)
writeLines(GO_enrichment_legend_json, fileConn)
close(fileConn)


