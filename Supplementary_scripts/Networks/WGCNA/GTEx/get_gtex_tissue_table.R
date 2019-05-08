trait_table = data.frame(General_tissue = all_traits$SMTS[all_traits$SMTS %in% net_nodes$General_tissue], Specific_tissue = all_traits$SMTSD[all_traits$SMTS %in% net_nodes$General_tissue])
trait_table = trait_table[trait_table$Specific_tissue %in% net_nodes$Specific_tissue,]
trait_table$id = paste(trait_table$General_tissue,trait_table$Specific_tissue)
trait_table = trait_table[!duplicated(trait_table$id),]
trait_table = trait_table[order(trait_table$General_tissue),]
trait_table$id = NULL
hwriter::hwrite(trait_table, border = 0, rownames = F)
write.table(trait_table,'/users/alexandrakeenan/Desktop/gtex_table.tsv',sep ="\t", row.names = F, col.names = T, quote = F)
