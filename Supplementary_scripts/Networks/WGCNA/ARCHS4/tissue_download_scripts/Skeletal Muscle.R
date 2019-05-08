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
extracted_expression_file = "Skeletal Muscle_expression_matrix.tsv"
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
    samp = c("GSM742949","GSM2310429","GSM1482939","GSM1356677","GSM2310424","GSM1489580","GSM1409702","GSM1489572","GSM1489571","GSM1489624","GSM1482949","GSM1409688","GSM1409705","GSM1489559","GSM1489610","GSM1489591","GSM1489623","GSM1489618","GSM1482945","GSM1489602","GSM1482947","GSM1482951","GSM1409697","GSM1409694","GSM1489586","GSM1528675","GSM1489619","GSM1482962","GSM1482932","GSM1489574","GSM1415128",
"GSM2310425","GSM1409690","GSM1482938","GSM1489593","GSM1482954","GSM1415144","GSM1489606","GSM1482944","GSM1489612","GSM1482961","GSM1489575","GSM1482957","GSM1482963","GSM1489598","GSM1489576","GSM1409693","GSM1415136","GSM1482940","GSM1415149","GSM1409689","GSM1409696","GSM1489611","GSM1409709","GSM1409706","GSM1409695","GSM1489603","GSM1489584","GSM1482959","GSM1489558","GSM1489579",
"GSM1409707","GSM1489608","GSM1415130","GSM1482960","GSM1489577","GSM1489581","GSM1409698","GSM1489622","GSM1409691","GSM1415137","GSM1482937","GSM1482946","GSM1489562","GSM1489617","GSM1409703","GSM1482941","GSM1415129","GSM1482958","GSM1415147","GSM1409708","GSM1415133","GSM1489585","GSM1356676","GSM1415146","GSM1489620","GSM1489616","GSM1489595","GSM1409699","GSM1415142","GSM1482953",
"GSM1489592","GSM1489607","GSM1482964","GSM2310427","GSM1489596","GSM1482933","GSM1482950","GSM1482955","GSM1482936","GSM1489587","GSM1489605","GSM1489567","GSM2310426","GSM1489614","GSM1489560","GSM1489625","GSM1489582","GSM1415127","GSM1489578","GSM1489563","GSM1415138","GSM1489583","GSM1489597","GSM1409687","GSM1528674","GSM1489613","GSM1415135","GSM1482934","GSM1409692","GSM1489570",
"GSM1415141","GSM1489561","GSM1489601","GSM1489569","GSM1489604","GSM1489568","GSM1489621","GSM1482943","GSM1415145","GSM1489588","GSM1482942","GSM2310428","GSM1482952","GSM1415134","GSM1489590","GSM1489609","GSM1489589","GSM1489599","GSM1482948","GSM1415132","GSM1489566","GSM1489564","GSM1489565","GSM1415143","GSM1415140","GSM1489600","GSM1409704","GSM1415148","GSM1415131","GSM1415139",
"GSM1415126","GSM1482956","GSM1482935","GSM1489594","GSM1489615","GSM1489573","GSM2072394","GSM2072395","GSM2072544","GSM2072543","GSM2071283","GSM2072593","GSM2072468","GSM2072469","GSM2071284","GSM2728767","GSM2728768","GSM2728769","GSM2728770","GSM2728771","GSM2728772","GSM2728773","GSM2728774","GSM2728775","GSM2728776","GSM2728777","GSM2728778","GSM2732854","GSM2732855","GSM2732856",
"GSM2732860","GSM2732861","GSM2732862","GSM2732884","GSM2732885","GSM2732886","GSM2732887","GSM2732888","GSM2732889","GSM2732890","GSM2732891","GSM2732892","")

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
