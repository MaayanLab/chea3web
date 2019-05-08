##the purpose of this script is to format the single-tf perturbations for use in the MAGICACT software


perts = chea3::libs[["Perturbations"]]

max = max(unlist(lapply(perts,length)))

magin = data.frame(All = c("!!",rep("",max-1)))

for(i in 1:length(perts)){
  temp_df = data.frame(x = c(perts[[i]],rep("",max - length(perts[[i]]))))
  colnames(temp_df) = names(perts)[i]
  magin = cbind(magin, temp_df)
}

write.table(magin,"/Volumes/External/ChEA3_outsidetool_benchmarks/magicact_input.txt",sep = "\t",
  col.names = T, row.names = F, quote = F)
