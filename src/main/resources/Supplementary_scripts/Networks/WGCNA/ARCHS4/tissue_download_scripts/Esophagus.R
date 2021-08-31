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
extracted_expression_file = "Esophagus_expression_matrix.tsv"
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
    print("File download ran into problems. Please try to download again. The files are also available for manual download at http://maayanlab.cloud/archs4/download.html.")
} else{
    # Selected samples to be extracted
    samp = c("GSM1385778","GSM1385782","GSM1505566","GSM1385783","GSM1385779","GSM1385780","GSM1385781","GSM1505565","GSM1505595","GSM1173237","GSM1173238","GSM2343350","GSM2343934","GSM2343602","GSM2343213","GSM1010956","GSM1120303","GSM2344101","GSM2343599","GSM2343741","GSM2343785","GSM2343458","GSM2343488","GSM2343518","GSM2343527","GSM2343634","GSM2343641","GSM2344141","GSM3057174","GSM3057175","GSM3119245",
"GSM3119246","GSM2519485","GSM2519489","GSM2519490","GSM2519501","GSM2519502","GSM2519507","GSM2519512","GSM2519516","GSM2519523","GSM2519527","GSM2519528","GSM2519535","GSM2519543","GSM2519548","GSM2519553","GSM2519554","GSM2519561","GSM2519569","GSM2519570","GSM2519578","GSM2519579","GSM2519580","GSM2519581","GSM2519584","GSM2519586","GSM2519587","GSM2519588","GSM2519589","GSM2519590",
"GSM2519591","GSM2519592","GSM2519593","GSM2519594","GSM2519595","GSM2519596","GSM2519597","GSM2519599","GSM2519600","GSM2519601","GSM2519602","GSM2519603","GSM2519605","GSM2519606","GSM2519607","GSM2519608","GSM2519609","GSM2519610","GSM2519612","GSM2519613","GSM2519615","GSM2519616","GSM2519618","GSM2519619","GSM2519620","GSM2519621","GSM2519622","GSM2519623","GSM2519624","GSM2519625",
"GSM2519626","GSM2519627","GSM2519628","GSM2519629","GSM2519630","GSM2519632","GSM2519633","GSM2519634","GSM2519635","GSM2519636","GSM2519637","GSM2519638","GSM2519639","GSM2519640","GSM2519641","GSM2519642","GSM2519643","GSM2519644","GSM2519645","GSM2519646","GSM2519647","GSM2519649","GSM2519650","GSM2519651","GSM2519652","GSM2519653","GSM2519654","GSM2519655","GSM2519657","GSM2519658",
"GSM2519659","GSM2519660","GSM2519661","GSM2519662","GSM2519663","GSM2519664","GSM2519665","GSM3165102","GSM3165104","GSM3165105","GSM3165106","GSM3165110","GSM3165112","GSM3165113","GSM3165114","GSM3165117","")

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
