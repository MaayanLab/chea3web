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
extracted_expression_file = "Heart_expression_matrix.tsv"
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
    samp = c("GSM742942","GSM1695908","GSM1841270","GSM1808033","GSM1505568","GSM1808025","GSM1281862","GSM2309540","GSM1808038","GSM1281756","GSM2309534","GSM2309544","GSM1567921","GSM1567920","GSM1808036","GSM2309537","GSM1281831","GSM1281888","GSM1808039","GSM1536192","GSM1281758","GSM1281798","GSM1808034","GSM1281883","GSM1505567","GSM1567919","GSM2309538","GSM1808024","GSM1281759","GSM1841266","GSM1567918",
"GSM2309539","GSM1808019","GSM1281824","GSM1808018","GSM1808021","GSM1808027","GSM1281867","GSM1281801","GSM1281785","GSM1808035","GSM1808026","GSM2309545","GSM1281885","GSM1808030","GSM2309547","GSM1666977","GSM1841268","GSM1808023","GSM1808017","GSM2309535","GSM1281848","GSM1281879","GSM1841261","GSM1808040","GSM1281884","GSM1808031","GSM2309542","GSM1281881","GSM1281799","GSM1841273",
"GSM1505596","GSM1554466","GSM2055781","GSM1808041","GSM1808032","GSM1281795","GSM2309546","GSM1841259","GSM1536193","GSM1841251","GSM2055787","GSM1808037","GSM1281886","GSM2309541","GSM1695907","GSM1281837","GSM1808029","GSM1281880","GSM2309536","GSM1666976","GSM1808022","GSM1567917","GSM1281825","GSM1281783","GSM1281764","GSM1808020","GSM1281835","GSM1281784","GSM1281800","GSM1281882",
"GSM1554465","GSM1567916","GSM1567922","GSM1808028","GSM1841263","GSM2098154","GSM2098155","GSM2098157","GSM2098156","GSM2309543","GSM2387234","GSM2387228","GSM2387229","GSM2387232","GSM2387233","GSM2387236","GSM2387235","GSM2387230","GSM2387231","GSM2343070","GSM1059495","GSM1059494","GSM2072383","GSM2072382","GSM2343702","GSM2071272","GSM2071273","GSM2343662","GSM2453454","GSM2453453",
"GSM2463767","GSM2563037","GSM2563038","GSM2563039","GSM2641079","GSM2641080","GSM2641081","GSM2641082","GSM2641083","GSM2641084","GSM2641085","GSM2641086","GSM2641087","GSM2641088","GSM2641089","GSM2641090","GSM2641091","GSM2641092","GSM2845466","GSM2845467","")

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
