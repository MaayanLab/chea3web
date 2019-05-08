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
extracted_expression_file = "Motor Neuron_expression_matrix.tsv"
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
    samp = c("GSM1024416","GSM1024417","GSM1024418","GSM1261108","GSM1261111","GSM1261110","GSM1261105","GSM1314597","GSM1314596","GSM1314598","GSM1314599","GSM1261106","GSM1261109","GSM1261112","GSM1599013","GSM1599011","GSM1599012","GSM1599014","GSM1261107","GSM1314595","GSM2326820","GSM2326818","GSM2326822","GSM2326816","GSM2326819","GSM2326821","GSM2326817","GSM2496034","GSM2496035","GSM2496033","GSM2496036",
"GSM2590534","GSM2590524","GSM2590521","GSM2590535","GSM2590522","GSM2590531","GSM2590523","GSM2590536","GSM2590533","GSM2590525","GSM2590530","GSM2590532","GSM2590526","GSM2287020","GSM2287021","GSM2287022","GSM2287023","GSM2287024","GSM2287025","GSM2287026","GSM2287027","GSM2287028","GSM2287029","GSM2287030","GSM2287031","GSM2287032","GSM2287033","GSM2287034","GSM2287035","GSM2287036",
"GSM2287037","GSM2287038","GSM2287039","GSM2287040","GSM2287041","GSM2287042","GSM2287043","GSM2287044","GSM2287045","GSM2287046","GSM2287047","GSM2287048","GSM2287049","GSM2287050","GSM2287051","GSM2287052","GSM2287053","GSM2287054","GSM2287055","GSM2287056","GSM2287057","GSM2287058","GSM2287059","GSM2287060","GSM2287061","GSM2287062","GSM2287063","GSM2287064","GSM2287065","GSM2287066",
"GSM2287067","GSM2287068","GSM2287069","GSM2287070","GSM2287071","GSM2287074","GSM2287075","GSM2287076","GSM2287077","GSM2287078","GSM2287079","GSM2287080","GSM2287081","GSM2287082","GSM2287083","GSM2287084","GSM2287085","GSM2287086","GSM2287087","GSM2287088","GSM2287089","GSM2287090","GSM2287091","GSM2287092","GSM2287093","GSM2287094","GSM2590542","GSM2500595","GSM2500596","GSM3017282",
"GSM3017283","GSM3017284","GSM3017285","GSM3017286","GSM3017287","GSM3017288","GSM3017289","GSM3017290","GSM3017291","GSM3017292","GSM3017293","GSM3017294","GSM3017295","GSM3017296","")

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
