function libraryJSONtoTSV(libraryName){
	const items = chea3Results[libraryName]
	const replacer = (key, value) => value === null ? '' : value // specify how you want to handle null values here
	const header = Object.keys(items[0])
	undefined
	let tsv = items.map(row => header.map(fieldName => JSON.stringify(row[fieldName], replacer)).join('\t'))
	tsv.unshift(header.join('\t'))
	tsv = tsv.join('\r\n')
	return(tsv)
}
