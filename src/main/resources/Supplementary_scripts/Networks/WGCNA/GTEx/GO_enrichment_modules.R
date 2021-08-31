library("topGO")
library("clusterProfiler")

library("org.Hs.eg.db")
data("ALL")
data("geneList")
network = jsonlite::fromJSON('/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/wgcna_gtex_annotated.json')
modules = unique(network$WGCNA_module)
GO_FET_results = data.frame()
for(i in 1:length(modules)){
  gene_universe = unique(network$name)
  geneList = rep(1,length(gene_universe))
  names(geneList) = gene_universe
  geneList[names(geneList) %in% network[network$WGCNA_module == modules[i],"name"]] = 0
  names(geneList) = genesetr::HGNCapproved(names(geneList),untranslatable.na = T)
  geneList = geneList[!is.na(names(geneList))]

  test =  new("topGOdata",
    description = "Simple session", ontology = "BP",
    allGenes = geneList, geneSel = function(p) p<1, nodeSize = 1, annot = annFUN.org,
    mapping = "org.Hs.eg.db", ID = "symbol")

  resultFisher <- runTest(test, algorithm = "classic", statistic = "fisher")
  temp_result = GenTable(test, classicFisher = resultFisher, topNodes = 1)
  temp_result$module = modules[i]
  GO_FET_results = rbind(GO_FET_results,temp_result)
}

color_mapping = data.frame(GO_term = unique(GO_FET_results$Term), color = colors[1:length(unique(GO_FET_results$Term))])

#add GO assignments to modules
network$GO_enrichment = GO_FET_results[match(network$WGCNA_module,GO_FET_results$module),"Term"]
#since each WGCNA modules maps to a unique GO term, will use module colors
network$GO_enrichment_color = network$WGCNA_hex
jsonlite::write_json(network,'/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/wgcna_gtex_annotated3.json')

color_df = data.frame(GO_term = unique(network$GO_enrichment), color = unique(network$GO_enrichment_color), stringsAsFactors = F)

jsonlite::write_json(color_df,"/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/GO_enrichment.json")
