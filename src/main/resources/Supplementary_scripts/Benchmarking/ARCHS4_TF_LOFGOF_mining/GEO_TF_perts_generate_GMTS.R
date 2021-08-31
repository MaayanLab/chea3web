rm(list = ls())
library(rhdf5)
library(limma)
library(plyr)
source("/Volumes/External/AIM2/DEG_functions.R")
expression_matrix_filename = "/users/alexandrakeenan/Projects/Common/ARCHS4/downloads/human_matrix.h5"
mining_filename = "/Volumes/External/GEO_TF_RNAseq_mining/tf_mining.txt"
exp_datadir = "/Volumes/External/GEO_TF_RNAseq_mining/expression_files_09052018/"
sig_datadir = "/Volumes/External/GEO_TF_RNAseq_mining/signature_files_chardir_logcpm_0905018/"
gmt_datadir = "/Volumes/External/GEO_TF_RNAseq_mining/gmt_files_chardir_logcpm_09052018/"
gmt_filename = "DEGs_GEO_RNAseq_TF_perturbations.gmt"
norm_method = "log cpm"

dir.create(exp_datadir)
dir.create(sig_datadir)
dir.create(gmt_datadir)

####extract case and control samples from ARCHS4 count matrix and write to flat files####
sample_ids =h5read(expression_matrix_filename,"meta/Sample_geo_accession")
samples = read.table(mining_filename,stringsAsFactors=F, quote="", comment.char="", sep="\t",fill = T,header = T)
samples = samples[samples$case!=""&samples$ctl!=""&samples$cell.type!=""&samples$pert!="",]
samples$species = toupper(samples$species)
samples$cell.type = gsub("-","",gsub(" ","",toupper(samples$cell.type)))
samples$pert = gsub("-","",gsub(" ","",toupper(samples$pert)))
expression = h5read(expression_matrix_filename,"data/expression")
genes = h5read(expression_matrix_filename,"meta/genes")

#subset genes and expression data to approved HGNC symbols
genes = genesetr::HGNCapproved(genes,untranslatable.na = T)
expression = expression[!is.na(genes),]
genes = genes[!is.na(genes)]
expression = expression[!duplicated(genes),]
genes = genes[!duplicated(genes)]


for(i in 1:nrow(samples)){
  control_samples = unlist(strsplit(samples$ctl[i],'\\|'))
  pert_samples = unlist(strsplit(samples$case[i],'\\|'))

  if(length(pert_samples)<2 | length(control_samples)<2){
    warning(paste("Insufficient case or control samples for",samples$series[i],samples$tf[i]))
    next
  }

  ctrl_idx = match(control_samples,sample_ids)
  pert_idx = match(pert_samples,sample_ids)

  if(sum(!is.na(ctrl_idx))<2||sum(!is.na(pert_idx))<2){
    warning(paste("Expression data not found for samples within ",
                  samples$series[i],". Now insufficient samples. Skipping.",sep = ""))
    next}

  ctrl_idx = ctrl_idx[!is.na(ctrl_idx)]
  pert_idx = pert_idx[!is.na(pert_idx)]

  ctrl_expr = expression[,ctrl_idx]
  pert_expr = expression[,pert_idx]

  if(any(colSums(ctrl_expr)==0)) next
  if(any(colSums(pert_expr)==0)) next

  expr  = cbind(ctrl_expr,pert_expr)
  colnames(expr) = c(sample_ids[ctrl_idx],sample_ids[pert_idx])
  rownames(expr) = genes

  design = data.frame(c(rep(1,length(ctrl_idx)),rep(0,length(pert_idx))))
  design = cbind(design,as.numeric(!design))
  colnames(design) = c("Control","Perturbation")
  rownames(design) = c(sample_ids[ctrl_idx],sample_ids[pert_idx])
  term = paste(samples$tf[i],"_",samples$pert[i],"_",samples$cell.type[i],"_",
    samples$species[i],"_",samples$series[i],sep = "")
  if(samples$additional.meta[i] != "") term = paste(term,samples$additional.meta[i],sep="_")



  write.table(expr,paste(exp_datadir,term,"_expr.txt",sep=""),quote = F, col.names = T, row.names = T,sep = "\t")
  write.table(design,paste(exp_datadir,term,"_design.txt",sep=""), quote = F, col.names = T, row.names = T,sep = "\t")

}

####build signatures####
exp_datadir_files = list.files(exp_datadir)
design_files = exp_datadir_files[grepl("_design.txt",exp_datadir_files)]
exp_files = exp_datadir_files[grepl("_expr.txt",exp_datadir_files)]
for(i in 1:length(design_files)){
  counts = read.table(paste(exp_datadir,exp_files[i],sep=""),stringsAsFactors=F, quote="", comment.char="", sep="\t",fill = T,header = T)
  design = read.table(paste(exp_datadir,design_files[i],sep=""),stringsAsFactors=F, quote="", comment.char="", sep="\t",fill = T,header = T)

  ####LIMMA####
  # v <- voom(counts, design, plot=TRUE, normalize="quantile")
  # fit = lmFit(v,design = design)
  # cont.matrix = makeContrasts(PerturbationvsControl=Perturbation-Control, levels=design)
  # fit2 <- contrasts.fit(fit, cont.matrix)
  # fit = eBayes(fit2)
  # # write.table(topTable(fit,sort="none",n=Inf,adjust = "BH"),
  # #             paste(sig_datadir,gsub("_expr","",exp_files[i]),sep = ""),sep = "\t",col.names = T, quote = F)

  ####CHAR DIR####
  chardir = getcoeffCharDir(counts, design, norm_method = norm_method)
  write.table(chardir,paste(sig_datadir,gsub("_expr","",exp_files[i]),sep = ""),sep = "\t",col.names = T, quote = F)


  ####DESEQ2####
}
####write gmt file from signatures####
sig_datadir_files = list.files(sig_datadir)
gmt_up = list()
gmt_dn = list()
gmt_all = list()
for(i in 1:length(sig_datadir_files)){
  sig = read.table(paste(sig_datadir,sig_datadir_files[i],sep=""),stringsAsFactors=F, quote="", comment.char="", sep="\t",fill = T,header = T)
  exp_label = gsub(".txt","",sig_datadir_files[i])
  # sig = sig[order(sig$adj.P.Val),]
  # all_sig_genes = sig[sig$adj.P.Val<=0.05,]
  # up_sig_genes = all_sig_genes[all_sig_genes$logFC>0,]
  # dn_sig_genes = all_sig_genes[all_sig_genes$logFC<0,]
  # gmt_up[[i]] = c(exp_label, rownames(up_sig_genes))
  # gmt_dn[[i]] = c(exp_label, rownames(dn_sig_genes))
  # gmt_all[[i]] = c(exp_label, rownames(all_sig_genes))
  sig = sig[order(abs(sig$val.chardir),decreasing = T),,drop = FALSE]
  all_sig_genes = sig[1:600,,drop = FALSE]
  up_sig_genes = all_sig_genes[all_sig_genes$val.chardir >0,,drop = FALSE]
  dn_sig_genes = all_sig_genes[all_sig_genes$val.chardir <0,,drop = FALSE]
  gmt_up[[i]] = c(exp_label, rownames(up_sig_genes))
  gmt_dn[[i]] = c(exp_label, rownames(dn_sig_genes))
  gmt_all[[i]] = c(exp_label, rownames(all_sig_genes))
}

gmt_up = gmt_up[!sapply(gmt_up, is.null)]
gmt_dn = gmt_dn[!sapply(gmt_dn, is.null)]
gmt_all = gmt_all[!sapply(gmt_all, is.null)]



up_out_file = paste(gmt_datadir,"up_",gmt_filename,sep = "")
dn_out_file = paste(gmt_datadir,"dn_",gmt_filename,sep = "")
all_out_file = paste(gmt_datadir,"all_",gmt_filename,sep = "")
file.remove(up_out_file)
file.remove(dn_out_file)
file.remove(all_out_file)
lapply(X = gmt_up, FUN = function(x) {
  write(x, append = T, file = up_out_file, ncolumns = length(x), sep = "\t")
})
lapply(X = gmt_dn, FUN = function(x) {
  write(x, append = T, file = dn_out_file, ncolumns = length(x), sep = "\t")
})
lapply(X = gmt_all, FUN = function(x) {
  write(x, append = T, file = all_out_file, ncolumns = length(x), sep = "\t")
})
