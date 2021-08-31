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
extracted_expression_file = "Ventricle_expression_matrix.tsv"
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
    samp = c("GSM1126635","GSM1126641","GSM1126648","GSM1126629","GSM1126666","GSM1126667","GSM1126671","GSM1126632","GSM1126644","GSM1126645","GSM1126686","GSM1126616","GSM1126664","GSM1126636","GSM1126681","GSM1126674","GSM1126615","GSM1126673","GSM1126682","GSM1126638","GSM1126621","GSM1126640","GSM1126613","GSM1126660","GSM1126633","GSM1126639","GSM1126655","GSM1126650","GSM1126643","GSM1126647","GSM1126677",
"GSM1126631","GSM1126654","GSM1126684","GSM1126663","GSM1126689","GSM1126672","GSM1126642","GSM1126622","GSM1126690","GSM1126627","GSM1126670","GSM1126617","GSM1126656","GSM1126668","GSM1126675","GSM1126678","GSM1126623","GSM1126634","GSM1126688","GSM1126661","GSM1126646","GSM1126662","GSM1126624","GSM1126687","GSM1126619","GSM1126626","GSM1126618","GSM1126683","GSM1126651","GSM1126628",
"GSM1126649","GSM1126625","GSM1126637","GSM1126612","GSM1126620","GSM1126614","GSM1126676","GSM1126685","GSM1126691","GSM1126630","GSM1808033","GSM1808025","GSM1808038","GSM1808036","GSM1536187","GSM1808039","GSM1808034","GSM1808024","GSM1808019","GSM1808018","GSM1808021","GSM1808027","GSM1808035","GSM1808026","GSM1808030","GSM1808023","GSM1808017","GSM1808040","GSM1808031","GSM1536186",
"GSM1808041","GSM1808032","GSM1808037","GSM1808029","GSM1808022","GSM1808020","GSM1808028","GSM1010972","GSM1010938","GSM2072535","GSM2072536","GSM1010964","GSM2343702","GSM2343662","GSM1120312","GSM2495522","GSM2495523","GSM2495524","GSM2495521","GSM2495526","GSM2495525","GSM2676187","GSM2641079","GSM2641080","GSM2641081","GSM2641082","GSM2641083","GSM2641084","GSM2641085","GSM2641086",
"GSM2641087","GSM2641088","GSM2641089","GSM2641090","GSM2641091","GSM2641092","")

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
