#separate up/dn sets into activator up, activator dn, repressor up, repressor dn sets
up = genesetr::loadGMT("/Volumes/Backup2/perturbation_gmts_short_long/TFpertGEO1000_up.gmt")
dn = genesetr::loadGMT("/Volumes/Backup2/perturbation_gmts_short_long/TFpertGEO1000_dn.gmt")

#get creeds perturb type
chea3_gmt = chea3::Perturbations   
chea3_gmt = chea3_gmt[grepl("CREEDS",names(chea3_gmt))]
chea3_samples = unlist(lapply(names(chea3_gmt),function(x){tail(unlist(strsplit(x,"_")),1)}))
df = data.frame(creeds = names(chea3_gmt), sample = chea3_samples, stringsAsFactors = F)
df2 = data.frame(updn_creeds = names(up)[grepl("CREEDS",names(up))],stringsAsFactors = F)
df2$sample = unlist(sapply(strsplit(gsub("_CREEDS","",df2$updn_creeds),"_"),tail,1))
df = merge(df,df2,by = "sample",all.x = T, all.y = T)

creeds_labels = data.frame(creeds = names(chea3_gmt), sample = creeds_samples, stringsAsFactors = F)
creeds_labels$chea3 = names(chea3_gmt)[match(creeds_labels$sample, chea3_samples)]
creeds_labels = creeds_labels[!is.na(creeds_labels$chea3),]
creeds_labels$sample= as.numeric(creeds_labels$sample)

OE_terms = c("OE","INDUCTION","INDUCED","HYPERACTIVE","CHEMICALACTIVATOR","ACTIVATION",
  "KNOCKIN")
KD_terms = c("SIRNA","SHRNA","KO","KD","MUTATION","MUT","ABLATION","DEPLETION","DEFICIENCY",
  "INHIBITION","INACTIVATION","DELETION","TRUNCATED","DOMNEG","SILENCING","DEPLET")
OE_terms = paste(paste("_",OE_terms,"_",sep = ""),collapse = "|")
KD_terms = paste(paste("_",KD_terms,"_",sep = ""),collapse = "|")
#rename up/dn
up_act = up[grepl(OE_terms,names(up)) | grepl(OE_terms, df[match(names(up),df$updn_creeds),"creeds"])]
dn_act = dn[grepl(OE_terms,names(dn)) | grepl(OE_terms, df[match(names(dn),df$updn_creeds),"creeds"])]

up_inact = up[grepl(KD_terms,names(up)) | grepl(KD_terms, df[match(names(up),df$updn_creeds),"creeds"])]
dn_inact = dn[grepl(KD_terms,names(dn)) | grepl(KD_terms, df[match(names(dn),df$updn_creeds),"creeds"])]

genesetr::writeGMT(up_inact,"/volumes/Backup2/ChEA3_TF_activ_repressor_roles/up_inact.gmt")
genesetr::writeGMT(dn_inact,"/volumes/Backup2/ChEA3_TF_activ_repressor_roles/dn_inact.gmt")
genesetr::writeGMT(up_act,"/volumes/Backup2/ChEA3_TF_activ_repressor_roles/up_act.gmt")
genesetr::writeGMT(dn_act,"/volumes/Backup2/ChEA3_TF_activ_repressor_roles/dn_act.gmt")




