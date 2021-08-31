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
workingDir = "/Volumes/Backup2/WGCNA_GTEx/";
setwd(workingDir);

# The following setting is important, do not omit.
options(stringsAsFactors = FALSE);
counts_file = "/Volumes/Backup2/Projects/Common/GTEx/downloads/GTEx_Analysis_2016-01-15_v7_RNASeQCv1.1.8_gene_reads.gct"


####Load, normalize, clean counts matrix####
counts = read.gct(counts_file)
rows = rownames(counts)
cols = colnames(counts)
counts = normalize.quantiles(as.matrix(counts))
counts = as.data.frame(counts)
colnames(counts) = cols
rownames(counts) = rows
ensembl_ids = cleanid(rownames(counts))
genes = grex(ensembl_ids)$hgnc_symbol
mapped_genes = genesetr::HGNCapproved(genes,untranslatable.na = T) #for consistency
na_idx = is.na(mapped_genes)
mapped_genes = mapped_genes[!na_idx]
counts = counts[!na_idx,]

####For duplicate genes, take those that have the highest variance####
dup_idx = which(mapped_genes %in% mapped_genes[duplicated(mapped_genes)])
vars = data.frame(idx = dup_idx, gene = mapped_genes[dup_idx],
  var = rowVars(as.matrix(counts[dup_idx,])),stringsAsFactors = F)
rm_idx = unlist(plyr::dlply(vars,plyr::.(gene),function(sub){
  return(sub[-which(sub$var==max(sub$var))[1],"idx"])
}))
mapped_genes = mapped_genes[-rm_idx]
counts = counts[-rm_idx,]
expData = counts

rownames(expData) = mapped_genes

# Take a quick look at what is in the data set:

expData = t(expData)
gsg = goodSamplesGenes(expData, verbose = 3);
if (!gsg$allOK)
{
  # Optionally, print the gene and sample names that were removed:
  if (sum(!gsg$goodGenes)>0)
    printFlush(paste("Removing genes:", paste(names(expData)[!gsg$goodGenes], collapse = ", ")));
  if (sum(!gsg$goodSamples)>0)
    printFlush(paste("Removing samples:", paste(rownames(expData)[!gsg$goodSamples], collapse = ", ")));
  # Remove the offending genes and samples from the data:
  expData = expData[gsg$goodSamples, gsg$goodGenes]
}

#down sample
# load("/Volumes/Backup2/WGCNA_GTEx/tfs.rda")
expDataTF = expData[,colnames(expData) %in% chea3::tfs]


nGenes = ncol(expDataTF)
nSamples = nrow(expDataTF)


# Choose a set of soft-thresholding powers
powers = c(c(1:10), seq(from = 12, to=30, by=2))
# Call the network topology analysis function
sft = pickSoftThreshold(expDataTF, powerVector = powers, verbose = 5)

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


net = blockwiseModules(expDataTF, power = 5,
  TOMType = "unsigned", minModuleSize = 5,
  reassignThreshold = 0, mergeCutHeight = 0.25,
  numericLabels = TRUE, pamRespectsDendro = FALSE,
  saveTOMs = TRUE,
  saveTOMFileBase = "GTEx_TF",
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
  file = "GTEx_TFs-networkConstruction-auto.RData")

# load("/Volumes/Backup2/WGCNA_GTEx/GTEx_TFs-networkConstruction-auto.RData")

#open GTEx metadata
all_traits = read.table("/Volumes/Backup2/Projects/Common/GTEx/downloads/GTEx_v7_Annotations_SampleAttributesDS.txt",stringsAsFactors=F, quote="", comment.char="", sep="\t", header = T)
all_traits[,1] = gsub("-",".",all_traits[,1])
traits = all_traits[all_traits[,1] %in% rownames(expDataTF),c(1,6,7)]
gentiss_traits = traits[,c(1,2)]
spectiss_traits = traits[,c(1,3)]
gentiss_mat = reshape2::dcast(gentiss_traits,SAMPID ~ SMTS,fun.aggregate = function(x){as.integer(length(x) > 0)})
spectiss_mat = reshape2::dcast(spectiss_traits,SAMPID ~ SMTSD,fun.aggregate = function(x){as.integer(length(x) > 0)})
rownames(gentiss_mat) = gentiss_mat[,1]
rownames(spectiss_mat) = spectiss_mat[,1]
gentiss_mat = gentiss_mat[,-1]
spectiss_mat = spectiss_mat[,-1]

#reorder matrices
gentiss_mat = gentiss_mat[match(rownames(expDataTF),rownames(gentiss_mat)),]
spectiss_mat = spectiss_mat[match(rownames(expDataTF),rownames(spectiss_mat)),]

# Recalculate MEs with color labels
MEs0 = moduleEigengenes(expDataTF, moduleColors)$eigengenes
MEs = orderMEs(MEs0)

##compute module / specific tissue correlation
spec_moduleTraitCor = cor(MEs, spectiss_mat, use = "p")
spec_moduleTraitPvalue = corPvalueStudent(spec_moduleTraitCor, nSamples)
bonf_spec_moduleTraitPvalue = matrix(p.adjust(spec_moduleTraitPvalue,method = "bonferroni"),nrow = nrow(spec_moduleTraitPvalue),ncol = ncol(spec_moduleTraitPvalue))

sizeGrWindow(10,6)
# Will display correlations and their p-values
textMatrix = paste(signif(spec_moduleTraitCor, 2), "\n(",
  signif(bonf_spec_moduleTraitPvalue, 2), ")", sep = "");
dim(textMatrix) = dim(spec_moduleTraitCor)
par(mar = c(12, 10, 3, 3));
# Display the correlation values within a heatmap plot
labeledHeatmap(Matrix = spec_moduleTraitCor,
  xLabels = names(spectiss_mat),
  yLabels = names(MEs),
  ySymbols = names(MEs),
  colorLabels = FALSE,
  colors = blueWhiteRed(50),
  # textMatrix = textMatrix,
  setStdMargins = F,
  cex.text = 0.5,
  zlim = c(-1,1),
  main = paste("Module-tissue relationships"))


##compute module / general tissue correlation
gen_moduleTraitCor = cor(MEs, gentiss_mat, use = "p")
gen_moduleTraitPvalue = corPvalueStudent(gen_moduleTraitCor, nSamples)
bonf_gen_moduleTraitPvalue = matrix(p.adjust(gen_moduleTraitPvalue,method = "bonferroni"),ncol = ncol(gen_moduleTraitPvalue),nrow = nrow(gen_moduleTraitPvalue))

sizeGrWindow(10,6)
# Will display correlations and their p-values
textMatrix = paste(signif(gen_moduleTraitCor, 2), "\n(",
  signif(bonf_gen_moduleTraitPvalue, 2), ")", sep = "");
dim(textMatrix) = dim(gen_moduleTraitCor)
par(mar = c(6, 8.5, 3, 3));
# Display the correlation values within a heatmap plot
labeledHeatmap(Matrix = gen_moduleTraitCor,
  xLabels = names(gentiss_mat),
  yLabels = names(MEs),
  ySymbols = names(MEs),
  colorLabels = FALSE,
  colors = blueWhiteRed(50),
  # textMatrix = textMatrix,
  setStdMargins = FALSE,
  cex.text = 0.5,
  zlim = c(-1,1),
  main = paste("Module-tissue relationships"))


#visualize the gene network
dissTOM = 1-TOMsimilarityFromExpr(expDataTF, power = 5);
# Transform dissTOM with a power to make moderately strong connections more visible in the heatmap
plotTOM = dissTOM^12;
# Set diagonal to NA for a nicer plot
diag(plotTOM) = NA;
# Call the plot function
sizeGrWindow(9,9)
TOMplot(plotTOM, geneTree, moduleColors, main = "Network heatmap plot, all genes")

MET = orderMEs(cbind(MEs, spectiss_mat))
# Plot the relationships among the eigengenes and the trait
sizeGrWindow(20,20);
par(cex = 0.8)
plotEigengeneNetworks(MET, "", marDendro = c(0,4,1,2), marHeatmap = c(3,4,1,2), cex.lab = 0.8, xLabelsAngle
  = 90)

##export to cytoscape
# Recalculate topological overlap if needed
TOM = TOMsimilarityFromExpr(expDataTF, power = 5);

# Select modules
modules = unique(moduleColors);
# Select module probes
genes = colnames(expDataTF)
inModule = is.finite(match(moduleColors, modules));
modGenes = genes[inModule];
# Select the corresponding Topological Overlap
modTOM = TOM[inModule, inModule];
dimnames(modTOM) = list(modGenes, modGenes)
# Export the network into edge and node list files Cytoscape can read
setwd(paste(workingDir,"cytoscape/",sep = ""))
cyt = exportNetworkToCytoscape(modTOM,
  edgeFile = paste("CytoscapeInput-edges01.txt", sep=""),
  nodeFile = paste("CytoscapeInput-nodes01.txt", sep=""),
  weighted = TRUE,
  threshold = 0.01,
  nodeNames = modGenes,
  altNodeNames = modGenes,
  nodeAttr = moduleColors[inModule])

net_nodes = read.table("/volumes/backup2/WGCNA_GTEx/cytoscape/CytoscapeInput-nodes06.txt",header = T,sep = "\t",quote = "")

#merge wgcna modules with nodes
net_nodes$WGCNA_module = moduleColors[match(net_nodes$nodeName,modGenes)]

#assign specific tissue to each module
spectiss_cor_idx = as.numeric(apply(spec_moduleTraitCor,1,which.max))
moduleSpecTiss = colnames(spec_moduleTraitCor)[spectiss_cor_idx]
moduleSpecTiss_pval = NULL

for(i in 1:nrow(bonf_spec_moduleTraitPvalue)){
  moduleSpecTiss_pval = c(moduleSpecTiss_pval,bonf_spec_moduleTraitPvalue[i,spectiss_cor_idx[i]])
}



#assign general tissue to each module
gentiss_cor_idx = as.numeric(apply(gen_moduleTraitCor,1,which.max))
moduleGenTiss = colnames(gen_moduleTraitCor)[gentiss_cor_idx]
moduleGenTiss_pval = NULL

for(i in 1:nrow(bonf_gen_moduleTraitPvalue)){
  moduleGenTiss_pval = c(moduleGenTiss_pval,bonf_gen_moduleTraitPvalue[i,gentiss_cor_idx[i]])
}

#merge module tissues
net_nodes$General_tissue = moduleGenTiss[match(net_nodes$WGCNA_module,gsub("ME","",names(MEs)))]
net_nodes$Specific_tissue = moduleSpecTiss[match(net_nodes$WGCNA_module,gsub("ME","",names(MEs)))]

net_nodes[net_nodes$WGCNA_module == "grey",c("General_tissue","Specific_tissue")] = NA

colors = c("chartreuse4","chartreuse","chocolate4","aquamarine4","darkgoldenrod3","darkmagenta","firebrick","deeppink","darkturquoise","darkorchid1","orange","blue4","black","lightblue","seagreen","yellow","lightcoral","plum","tan4","sienna1","aquamarine","springgreen2","orangered3","pink","midnightblue","forestgreen","red","purple","darkred","cyan","chocolate3")
pie(x = rep(1/length(colors),length(colors)),col = colors)

hex_colors = NULL
for(i in 1:length(colors)){
  hex_colors = c(hex_colors,gplots::col2hex(colors[i])[1])
}

spec_tissue_colors = data.frame(Specific_tissue = unique(net_nodes$Specific_tissue), Specific_tissue_color = hex_colors[1:length(unique(net_nodes$Specific_tissue))])

gen_tissue_colors = data.frame(General_tissue = unique(net_nodes$General_tissue), General_tissue_color = hex_colors[1:length(unique(net_nodes$General_tissue))])

net_nodes = merge(net_nodes,spec_tissue_colors,by="Specific_tissue",all.x = T)

net_nodes = merge(net_nodes,gen_tissue_colors,by="General_tissue",all.x = T)




#substitute yellow color for module colors
net_nodes[net_nodes$WGCNA_module == "yellow","WGCNA_module"] = "deeppink4"
net_nodes[net_nodes$WGCNA_module == "white","WGCNA_module"] = "goldenrod4"
module_hex = NULL
for(i in 1:nrow(net_nodes)){
  module_hex = c(module_hex,gplots::col2hex(net_nodes[i,"WGCNA_module"]))
}
net_nodes$WGCNA_hex = module_hex

net_nodes_json = jsonlite::toJSON(net_nodes)

filepath = "/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/wgcna_gtex_annotated4.json"
file.remove(filepath)
fileConn<-file(filepath)
writeLines(net_nodes_json, fileConn)
close(fileConn)



general_tissue_legend = data.frame(tissue = net_nodes[!duplicated(paste(net_nodes$General_tissue,net_nodes$General_tissue_color)),"General_tissue"], color = net_nodes[!duplicated(paste(net_nodes$General_tissue,net_nodes$General_tissue_color)),"General_tissue_color"])

general_tissue_legend_json = jsonlite::toJSON(general_tissue_legend)

filepath = "/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/general_tissue_legend2.json"
file.remove(filepath)
fileConn<-file(filepath)
writeLines(general_tissue_legend_json, fileConn)
close(fileConn)

specific_tissue_legend = data.frame(tissue = net_nodes[!duplicated(net_nodes$Specific_tissue),"Specific_tissue"], color = net_nodes[!duplicated(net_nodes$Specific_tissue),"Specific_tissue_color"])

specific_tissue_legend_json = jsonlite::toJSON(specific_tissue_legend)

filepath = paste("/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/specific_tissue_legend2.json")
file.remove(filepath)
fileConn<-file(filepath)
writeLines(specific_tissue_legend_json, fileConn)
close(fileConn)

test = jsonlite::fromJSON('/users/alexandrakeenan/eclipse-workspace/chea3/WebContent/assets/networkd3/wgcna_gtex_annotated2.json')
