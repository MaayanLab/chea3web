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
extracted_expression_file = "Hepatocyte_expression_matrix.tsv"
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
    samp = c("GSM1076107","GSM1646733","GSM1646725","GSM1646726","GSM1646728","GSM1646686","GSM1646702","GSM1306652","GSM1646729","GSM1646701","GSM1646697","GSM1646723","GSM1646709","GSM1646704","GSM1646698","GSM1646713","GSM1646691","GSM1377537","GSM1646712","GSM1646700","GSM1646699","GSM1306655","GSM1646684","GSM1646689","GSM1646707","GSM1646715","GSM1646688","GSM1306657","GSM1646731","GSM1646683","GSM1646732",
"GSM1646679","GSM1646681","GSM1646714","GSM1646694","GSM1646721","GSM2228738","GSM1646716","GSM1646680","GSM1306654","GSM1646696","GSM1306656","GSM1646730","GSM1646720","GSM1646710","GSM1646692","GSM1377536","GSM1646708","GSM1646685","GSM1646687","GSM1646727","GSM1646719","GSM2228740","GSM1646705","GSM1646695","GSM1646722","GSM1646693","GSM1646718","GSM2228739","GSM1646690","GSM1646706",
"GSM1646717","GSM1646711","GSM1306653","GSM1886915","GSM1657150","GSM1886914","GSM1707675","GSM1886913","GSM1657147","GSM1657148","GSM1707674","GSM1657149","GSM1646682","GSM1646724","GSM1646703","GSM2344261","GSM2071513","GSM2071512","GSM2072603","GSM2072604","GSM2344260","GSM1974235","GSM1974236","GSM2262407","GSM2584723","GSM2584724","GSM2584725","GSM2584726","GSM2610525","GSM2610526",
"GSM2753372","GSM2753373","GSM2753374","GSM2753375","GSM2204135","GSM2204136","GSM2691353","GSM2691354","GSM2691355","GSM2691356","GSM2691357","GSM2691358","GSM2691359","GSM2691360","GSM2753376","GSM2753377","GSM2753378","GSM2753379","GSM2747455","GSM2747456","GSM2747457","GSM2747458","GSM2747459","GSM2747460","GSM2747461","GSM2747462","GSM2747463","GSM2747464","GSM2747465","GSM2747466",
"GSM2747467","GSM2747468","GSM2747469","GSM2747470","GSM2747471","GSM2747472","GSM2747473","GSM2747474","GSM2747475","GSM2747476","GSM2747477","GSM2747478","GSM2747479","GSM2747480","GSM2747481","GSM2747482","GSM2747483","GSM2747484","GSM2747485","GSM2747486","GSM2747487","GSM2747488","GSM2747489","GSM2747490","GSM3036700","GSM3036701","GSM3036702","GSM3036703","GSM3036704","GSM3036705",
"GSM2680338","GSM2680339","GSM2680340","GSM2680341","GSM2680342","GSM2680343","GSM2715279","")

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
