# R script to download selected samples
# Copy code and run on a local machine to initiate download

# Check for dependencies and install if missing
packages <- c("rhdf5")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
    print("Install required packages")
    source("https://bioconductor.org/biocLite.R")
    biocLite("rhdf5")
}
library("rhdf5")
library("tools")

destination_file = "human_matrix_download.h5"
extracted_expression_file = "Dendritic_expression_matrix.tsv"
url = "https://s3.amazonaws.com/mssm-seq-matrix/human_matrix.h5"

# Check if gene expression file was already downloaded and check integrity, if not in current directory download file form repository
if(!file.exists(destination_file)){
    print("Downloading compressed gene expression matrix.")
    download.file(url, destination_file, quiet = FALSE)
} else{
    print("Verifying file integrity...")
    checksum = md5sum(destination_file)
    
    if(destination_file == "human_matrix_download.h5"){
        # human checksum (checksum is for latest version of ARCHS4 data)
        correct_checksum = "f78da4a1855ff20da768eed1b73508be"
    } else{
        # mouse checksum (checksum is for latest version of ARCHS4 data)
        correct_checksum = "065abb20d2b9d2661e74328de8d23eb3"
    }
    
    if(checksum != correct_checksum){
        print("Existing file looks corrupted or is out of date. Downloading compressed gene expression matrix again.")
        download.file(url, destination_file, quiet = FALSE)
    } else{
        print("Latest ARCHS4 file already exists.")
    }
}

checksum = md5sum(destination_file)
if(destination_file == "human_matrix_download.h5"){
    # human checksum (checksum is for latest version of ARCHS4 data)
    correct_checksum = "f78da4a1855ff20da768eed1b73508be"
} else{
    # mouse checksum (checksum is for latest version of ARCHS4 data)
    correct_checksum = "065abb20d2b9d2661e74328de8d23eb3"
}

if(checksum != correct_checksum){
    print("File download ran into problems. Please try to download again. The files are also available for manual download at http://amp.pharm.mssm.edu/archs4/download.html.")
} else{
    # Selected samples to be extracted
    samp = c("GSM1556295","GSM1565956","GSM1565966","GSM1565960","GSM2090439","GSM1565963","GSM2090443","GSM2090448","GSM1565965","GSM1565962","GSM1640152","GSM1565998","GSM1640154","GSM1565958","GSM1565955","GSM1565959","GSM2090447","GSM1565957","GSM1566002","GSM1566000","GSM2090440","GSM1565997","GSM2090433","GSM2090442","GSM2090437","GSM2090435","GSM1566001","GSM1565964","GSM1565961","GSM2090441","GSM2090434",
"GSM2090445","GSM2090432","GSM1640156","GSM2090444","GSM2090446","GSM2090436","GSM1640155","GSM1565999","GSM1640153","GSM2090438","GSM2361538","GSM2361552","GSM2361537","GSM2361539","GSM2361553","GSM2361555","GSM2361554","GSM2361551","GSM2361598","GSM2361648","GSM2361556","GSM2361601","GSM2361640","GSM2361535","GSM2361561","GSM2361647","GSM2361639","GSM2361557","GSM2361636","GSM2361524",
"GSM2361558","GSM2361644","GSM2361637","GSM2361588","GSM2361525","GSM2361589","GSM2361550","GSM2361641","GSM2361545","GSM2361590","GSM2361587","GSM2361529","GSM2361646","GSM2361593","GSM2361559","GSM2361596","GSM2361547","GSM2361595","GSM2361528","GSM2361633","GSM2361548","GSM2361623","GSM2361584","GSM2361527","GSM2361542","GSM2361532","GSM2361632","GSM2361546","GSM2361526","GSM2361543",
"GSM2361569","GSM2361565","GSM2361530","GSM2361631","GSM2361541","GSM2361580","GSM2361531","GSM2361630","GSM2361608","GSM2361627","GSM2361578","GSM2361534","GSM2361574","GSM2361599","GSM2361597","GSM2361605","GSM2361611","GSM2361562","GSM2361560","GSM2361579","GSM2361615","GSM2361606","GSM2361521","GSM2361628","GSM2361568","GSM2361522","GSM2361616","GSM2361566","GSM2361572","GSM2361619",
"GSM2361621","GSM2361622","GSM2361517","GSM2361520","GSM2361519","GSM2361514","GSM2361610","GSM2361613","GSM2361510","GSM2361511","GSM2361518","GSM2361607","GSM2361513","GSM2361516","GSM2361506","GSM2361512","GSM2361504","GSM2361509","GSM2027310","GSM2027316","GSM2027314","GSM2027311","GSM2027321","GSM2027318","GSM2027320","GSM2027317","GSM2027313","GSM2027315","GSM2027319","GSM2027312",
"GSM2055642","GSM2055645","GSM2055643","GSM2055641","GSM2055644","GSM2055640","GSM2360280","GSM2360281","GSM2360282","GSM2358595","GSM2358596","GSM2358597","GSM2358598","GSM2358599","GSM2358600","GSM2358601","GSM2358602","GSM2471231","GSM2471234","GSM2471240","GSM2471242","GSM2471261","GSM2471262","GSM2471264","GSM2471267","GSM2471270","GSM2471278","GSM2471279","GSM2471281","GSM2471284",
"GSM2471291","GSM2471295","GSM2471304","GSM2228986","GSM2228987","GSM2228988","GSM2228989","GSM2228990","GSM2228991","GSM2228992","GSM2228993","GSM2228994","GSM2228995","GSM2228996","GSM2228997","GSM2228998","GSM2228999","GSM2229000","GSM2471248","GSM2471252","GSM2471282","GSM2471292","GSM2717603","GSM2717605","GSM2717607","GSM2717608","GSM2717613","GSM2717615","GSM2717616","GSM2717617",
"GSM2717618","GSM2717619","GSM2717620","GSM2717621","GSM2717622","GSM2717623","GSM2717624","GSM2717625","GSM2717626","GSM2717627","GSM2717628","GSM2898233","GSM2898234","GSM2898235","GSM2898236","GSM2898237","GSM2898238","GSM2898239","GSM2898240","GSM2898364","GSM2898365","GSM2898366","GSM2898367","GSM2898368","GSM2898369","GSM2898370","GSM2898371","GSM2898372","GSM2898373","GSM2898374",
"GSM2898375","GSM2898376","GSM2898377","GSM2898378","GSM2898379","GSM2898380","GSM2902781","GSM2902782","GSM2902783","GSM2902784","GSM2902785","GSM2902786","GSM2902787","GSM2902788","GSM2902789","GSM2902790","GSM2902791","GSM2902792","GSM2902793","GSM2902794","GSM2902795","GSM2902796","GSM2902797","GSM2902798","GSM2902799","GSM2902800","GSM2902801","GSM2902802","GSM2902803","GSM2902804",
"GSM2902805","GSM2902806","GSM2902807","GSM2902808","GSM2902809","GSM2902810","GSM2469538","GSM2469539","GSM2469540","GSM2469541","GSM2469542","GSM2469543","GSM2469544","GSM2469545","GSM2469547","GSM2469548","GSM2469549","GSM2469550","GSM2469551","GSM2469552","GSM2469553","GSM2469554","GSM2469555","GSM2469556","GSM2469557","GSM2469558","GSM2469559","GSM2469560","GSM2469561","GSM2469562",
"GSM2469563","GSM2469564","GSM2469565","GSM2469566","GSM2469567","GSM2469569","GSM2469570","GSM2469571","GSM2469572","GSM2469573","GSM2469574","GSM2469575","GSM2469576","GSM2469577","GSM2469578","GSM2469579","GSM2469580","GSM2469581","GSM2469582","GSM2469583","GSM2469584","GSM2469585","GSM2469586","GSM2469587","GSM3162630","GSM3162632","GSM2536303","GSM2536305","GSM2536311","GSM2536312",
"GSM2536313","GSM2536314","GSM2536315","")

    # Retrieve information from compressed data
    samples = h5read(destination_file, "meta/Sample_geo_accession")
    tissue = h5read(destination_file, "meta/Sample_source_name_ch1")
    genes = h5read(destination_file, "meta/genes")

    # Identify columns to be extracted
    sample_locations = which(samples %in% samp)

    # extract gene expression from compressed data
    expression = h5read(destination_file, "data/expression", index=list(1:length(genes), sample_locations))
    H5close()
    rownames(expression) = genes
    colnames(expression) = samples[sample_locations]

    # Print file
    write.table(expression, file=extracted_expression_file, sep="\t", quote=FALSE)
    print(paste0("Expression file was created at ", getwd(), "/", extracted_expression_file))
}
