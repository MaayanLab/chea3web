rm(list = ls())
##WGCNA example
library(WGCNA)
library(CePa)
library(preprocessCore)
library(grex)
library(matrixStats)
library(Rtsne)
# If necessary, change the path below to the directory where the data files are stored.
# "." means current directory. On Windows use a forward slash / instead of the usual \.
workingDir = "/volumes/Backup2/WGCNA_ARCHS4/";
setwd(workingDir);

# The following setting is important, do not omit.
options(stringsAsFactors = FALSE);
counts_file = "/Volumes/Backup2/WGCNA_ARCHS4/ARCHS4_download/ARCHS4_subsample_tissue_expression.tsv"

####Load, normalize, clean counts matrix####
counts = read.table(counts_file, sep = "\t", header = T, quote = "", comment.char = "", stringsAsFactors = F)
rows = rownames(counts)
cols = colnames(counts)
counts = normalize.quantiles(as.matrix(counts))
counts = as.data.frame(counts)
colnames(counts) = cols
rownames(counts) = rows
counts = t(counts)

nGenes = ncol(counts)
nSamples = nrow(counts)

# Choose a set of soft-thresholding powers
powers = c(c(1:10), seq(from = 12, to=30, by=2))
# Call the network topology analysis function
sft = pickSoftThreshold(counts, powerVector = powers, verbose = 5)

# Plot the results:
sizeGrWindow(9, 5)
par(mfrow = c(1,2));
cex1 = 0.9;
# Scale-free topology fit index as a function of the soft-thresholding power
plot(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
  xlab="Soft Threshold (power)",ylab="Scale Free Topology Model Fit,signed R^2",type="n",
  main = paste("Scale independence"));
text(sft$fitIndices[,1], -sign(sft$fitIndices[,3])*sft$fitIndices[,2],
  labels=powers,cex=cex1,col="red");
# this line corresponds to using an R^2 cut-off of h
abline(h=0.95,col="red")

# Mean connectivity as a function of the soft-thresholding power
plot(sft$fitIndices[,1], sft$fitIndices[,5],
  xlab="Soft Threshold (power)",ylab="Mean Connectivity", type="n",
  main = paste("Mean connectivity"))
text(sft$fitIndices[,1], sft$fitIndices[,5], labels=powers, cex=cex1,col="red")

net = blockwiseModules(counts, power = 2,
  TOMType = "unsigned", minModuleSize = 5,
  reassignThreshold = 0, mergeCutHeight = 0.25,
  numericLabels = TRUE, pamRespectsDendro = FALSE,
  saveTOMs = TRUE,
  saveTOMFileBase = "ARCHS4_TF",
  verbose = 3)

# open a graphics window
sizeGrWindow(12, 9)
# Convert labels to colors for plotting
mergedColors = labels2colors(net$colors)
# Plot the dendrogram and the module colors underneath
plotDendroAndColors(net$dendrograms[[1]], mergedColors[net$blockGenes[[1]]],
  "Module colors",
  dendroLabels = FALSE, hang = 0.03,
  addGuide = TRUE, guideHang = 0.05)

moduleLabels = net$colors
moduleColors = labels2colors(net$colors)
MEs = net$MEs;
geneTree = net$dendrograms[[1]];
save(MEs, moduleLabels, moduleColors, geneTree,
  file = "ARCHS4_TFs-networkConstruction-auto.RData")


#open ARCHS4 metadata
all_traits = read.table("/volumes/Backup2/WGCNA_ARCHS4/ARCHS4_download/ARCHS4_subsample_tissue_meta.tsv",stringsAsFactors=F, quote="", comment.char="", sep="\t", header = T)
tiss_mat = reshape2::dcast(all_traits,sample ~ tissue,fun.aggregate = function(x){as.integer(length(x) > 0)})

rownames(tiss_mat) = tiss_mat[,1]
tiss_mat = tiss_mat[,-1]

#reorder matrices
tiss_mat = tiss_mat[match(rownames(counts),rownames(tiss_mat)),]


# Recalculate MEs with color labels
MEs0 = moduleEigengenes(counts, moduleColors)$eigengenes
MEs = orderMEs(MEs0)

##compute module / specific tissue correlation
moduleTraitCor = cor(MEs, tiss_mat, use = "p")
moduleTraitPvalue = corPvalueStudent(moduleTraitCor, nSamples)
bonf_moduleTraitPvalue = matrix(p.adjust(moduleTraitPvalue,method = "bonferroni"),nrow = nrow(moduleTraitPvalue),ncol = ncol(moduleTraitPvalue))

sizeGrWindow(10,6)
# Will display correlations and their p-values
textMatrix = paste(signif(moduleTraitCor, 2), "\n(",
  signif(bonf_moduleTraitPvalue, 2), ")", sep = "");
dim(textMatrix) = dim(moduleTraitCor)
par(mar = c(12, 10, 3, 3));

# Display the correlation values within a heatmap plot
labeledHeatmap(Matrix = moduleTraitCor,
  xLabels = names(tiss_mat),
  yLabels = names(MEs),
  ySymbols = names(MEs),
  colorLabels = FALSE,
  colors = blueWhiteRed(50),
  textMatrix = textMatrix,
  setStdMargins = F,
  cex.text = 0.5,
  zlim = c(-1,1),
  main = paste("Module-tissue relationships"))

#visualize the gene network
dissTOM = 1-TOMsimilarityFromExpr(counts, power = 5);
# Transform dissTOM with a power to make moderately strong connections more visible in the heatmap
plotTOM = dissTOM^12;
# Set diagonal to NA for a nicer plot
diag(plotTOM) = NA;
# Call the plot function
sizeGrWindow(9,9)
TOMplot(plotTOM, geneTree, moduleColors, main = "Network heatmap plot, all genes")

MET = orderMEs(cbind(MEs, tiss_mat))
# Plot the relationships among the eigengenes and the trait
sizeGrWindow(20,20);
par(cex = 0.8)
plotEigengeneNetworks(MET, "", marDendro = c(0,4,1,2), marHeatmap = c(3,4,1,2), cex.lab = 0.8, xLabelsAngle
  = 90)

##export to cytoscape
# Recalculate topological overlap if needed
TOM = TOMsimilarityFromExpr(counts, power = 2);

# Select modules
modules = unique(moduleColors);
# Select module probes
genes = colnames(counts)
inModule = is.finite(match(moduleColors, modules));
modGenes = genes[inModule];
# Select the corresponding Topological Overlap
modTOM = TOM[inModule, inModule];
dimnames(modTOM) = list(modGenes, modGenes)
# Export the network into edge and node list files Cytoscape can read
setwd(paste(workingDir,"cytoscape/",sep = ""))
cyt = exportNetworkToCytoscape(modTOM,
  edgeFile = paste("CytoscapeInput-edges09.txt", sep=""),
  nodeFile = paste("CytoscapeInput-nodes09.txt", sep=""),
  weighted = TRUE,
  threshold = 0.09,
  nodeNames = modGenes,
  altNodeNames = modGenes,
  nodeAttr = moduleColors[inModule])

network = jsonlite::fromJSON('/volumes/Backup2/WGCNA_ARCHS4/cytoscape/CytoscapeInput-edges06.txt.cyjs')

net_nodes = data.frame(nodeName = network$elements$nodes$data$name, x = network$elements$nodes$position$x, y = network$elements$nodes$position$y, WGCNA_module = network$elements$nodes$data$nodeAttr_nodesPresent_, stringsAsFactors = F)

#assign tumor to each module
tiss_cor_idx = as.numeric(apply(moduleTraitCor,1,which.max))
moduleTiss = colnames(moduleTraitCor)[tiss_cor_idx]
moduleTiss_pval = NULL

for(i in 1:nrow(bonf_moduleTraitPvalue)){
  moduleTiss_pval = c(moduleTiss_pval,bonf_moduleTraitPvalue[i,tiss_cor_idx[i]])
}

#merge module tissues
net_nodes$Tissue = moduleTiss[match(net_nodes$WGCNA_module,gsub("ME","",names(MEs)))]
net_nodes$Tissue_pval = moduleTiss_pval[match(net_nodes$WGCNA_module,gsub("ME","",names(MEs)))]

colors = c("chartreuse4","chartreuse","chocolate4","aquamarine4","darkgoldenrod3","darkmagenta","firebrick","deeppink","darkturquoise","darkorchid1","orange","blue4","black","lightblue","seagreen","yellow","lightcoral","plum","tan4","sienna1","aquamarine","springgreen2","orangered3","pink","midnightblue","forestgreen","red","purple","darkred","cyan","chocolate3")
pie(x = rep(1/length(colors),length(colors)),col = colors)

hex_colors = NULL
for(i in 1:length(colors)){
  hex_colors = c(hex_colors,gplots::col2hex(colors[i])[1])
}

tiss_colors = data.frame(Tissue = unique(net_nodes$Tissue), Tissue_color = hex_colors[1:length(unique(net_nodes$Tissue))])


net_nodes = merge(net_nodes,tiss_colors,by="Tissue",all.x = T)

net_nodes[net_nodes$WGCNA_module == "yellow","WGCNA_module"] = "deeppink4"
net_nodes[net_nodes$WGCNA_module == "white","WGCNA_module"] = "goldenrod4"
module_hex = NULL
for(i in 1:nrow(net_nodes)){
  module_hex = c(module_hex,gplots::col2hex(net_nodes[i,"WGCNA_module"]))
}
net_nodes$WGCNA_hex = module_hex

net_nodes_json = jsonlite::toJSON(net_nodes)

filepath = "/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/wgcna_archs4_annotated.json"
file.remove(filepath)
fileConn<-file(filepath)
writeLines(net_nodes_json, fileConn)
close(fileConn)

tissue_legend = data.frame(Tissue = net_nodes[!duplicated(paste(net_nodes$Tissue,net_nodes$Tissue_color)),"Tissue"], color = net_nodes[!duplicated(paste(net_nodes$Tumor,net_nodes$Tissue_color)),"Tissue_color"])

tissue_legend_json = jsonlite::toJSON(tissue_legend)

filepath = "/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/archs4_tissue_legend.json"
file.remove(filepath)
fileConn<-file(filepath)
writeLines(tissue_legend_json, fileConn)
close(fileConn)



