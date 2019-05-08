#contains differential expression functions
library(limma)
library(edgeR)
library(DESeq2)
library(matrixStats)
library(preprocessCore)
source("/Volumes/backup2/GeoDE.R")

## ttest ##

getpvalttest = function(counts,design,control_lab,pert_lab){
  vars = rowVars(as.matrix(counts))
  counts$p.value = 1
  
  for(i in 1:nrow(counts)){
    control = counts[,as.logical(design[,control_lab])]
    pert = counts[,as.logical(design[,pert_lab])]
    pval = my.t.test(control[i,],pert[i,])    
    if(!is.na(pval)) counts$p.value[i]  = pval
    else counts$p.value[i] = 1
  }
  
  pvals = data.frame(counts$p.value)
  rownames(pvals) = rownames(counts)
  colnames(pvals) = "val.ttest"
  return(pvals)
}

## limma ##

getpvallimma = function(counts,design){
  v <- voom(counts, design, plot=TRUE, normalize="quantile")
  fit = lmFit(v,design = design)
  cont.matrix = makeContrasts(PerturbationvsControl=Perturbation-Control, levels=design)
  fit2 <- contrasts.fit(fit, cont.matrix)
  fit = eBayes(fit2)
  pvals = data.frame(fit$p.value)
  rownames(pvals) = names(fit$p.value[,1])
  colnames(pvals) = "val.limma"
  return(pvals)
}

## edgeR ##

getpvaledgeR = function(counts,design,control_lab,pert_lab){
  obj <- DGEList(counts , group = as.character(design[,pert_lab]))
  obj <- estimateCommonDisp(obj)
  de <- exactTest(obj, pair = c( "0" , "1" ) )$table
  pvals = data.frame(de$PValue)
  rownames(pvals) = rownames(de)
  colnames(pvals) = "val.edgeR"
  return(pvals)
}

## characteristic direction ##

getcoeffCharDir = function(counts, design, norm_method = "log cpm"){
  if(norm_method == "log cpm"){
    dge <- DGEList(counts=counts)
    logCPM <- cpm(dge, log=TRUE, prior.count=3)
    expr_dat = data.frame(as.factor(rownames(counts)),counts)
    colnames(expr_dat)[1] = "genename"
  }else if(norm_method == "quantile"){
    expr_dat = as.data.frame(normalize.quantiles(as.matrix(counts)))
    colnames(expr_dat) = colnames(counts)
    rownames(expr_dat) = rownames(counts)
    expr_dat = cbind(data.frame(genename = rownames(expr_dat)),expr_dat)
  }else{
    return(warning("Invalid normalization method specified."))
  }
  sample_class = as.factor(design$Perturbation+1)
  temp_chardir <- unlist(chdirAnalysis(expr_dat,sample_class,CalculateSig=FALSE)$chdirprops$chdir)
  chardir = data.frame(temp_chardir)
  rownames(chardir) = rownames(expr_dat)
  colnames(chardir) = "val.chardir"
  return(chardir)
}

## DESeq2 ##
getpvalDESeq2 = function(counts,design,control_lab,pert_lab){
  colData = data.frame(as.factor(design[,pert_lab]),row.names = rownames(design))
  colnames(colData) = "perturbation"
  
  count_table <- DESeqDataSetFromMatrix(
    countData = counts,
    colData = colData,
    design = ~ perturbation)
  
  results = results(DESeq(count_table))
  
  if(any(is.na(results$pvalue))) results[is.na(results$pvalue),]$pvalue = 1
  
  pvals = data.frame(results$pvalue)
  rownames(pvals) = rownames(results)
  colnames(pvals) = "val.deseq"
  return(pvals)
}

MyMerge = function(x, y){
  df = merge(x, y, by= "row.names", all.x= F, all.y= F)
  rownames(df) = df$Row.names
  df$Row.names = NULL
  return(df)
}

my.t.test = function(control,pert){
  obj = try(t.test(control,pert), silent=TRUE)
  if (is(obj, "try-error")) return(NA) else return(obj$p.value)
}




