// Function to build matrix str
function buildClustergrammerMatrix(chea_results, top_tfs = 5) {

    // Initialize variables
    var genes = new Set(),
        tfs = ['', ''],
        libraries = ['', ''],
        ranks = ['', ''],
        rows = [];

    // Get axis names
    $.each(chea_results, function (key, value) {
        if (key.indexOf('Integrated') === -1) {
            for (i = 0; i < top_tfs; i++) {

                // Value
                var chea_result = value[i],
                    library = key.split('--')[0];

                // Rows
                $.each(chea_result['Overlapping_Genes'].split(','), function (index, gene) {
                    genes.add(gene);
                })

                // Column labels
                tfs.push('TF: ' + library + '-' + chea_result['Rank'].padStart(2, '0') + '-' + chea_result['TF']);
                libraries.push('Library: ' + library);
                ranks.push('Rank: ' + chea_result['Rank']);
            }
        }
    })

    // Get values
    $.each(Array.from(genes), function (index, gene) {

        // Initialize row
        var rowData = ['Gene: ' + gene],
            gene_bools = [];

        // Get binary values
        $.each(chea_results, function (key, value) {
            if (key.indexOf('Integrated') === -1) {
                for (i = 0; i < top_tfs; i++) {

                    // Check if gene
                    var gene_bool = value[i]['Overlapping_Genes'].indexOf(gene) > -1 ? 1 : 0;

                    // Append
                    gene_bools.push(gene_bool);
                }
            }
        })

        // Get count
        rowData.push('Count: ' + gene_bools.reduce(function (a, b) { return a + b; }, 0));
        rowData.push(gene_bools.join('\t'));

        // Append
        rows.push(rowData.join('\t'));
    })

    // Build string
    columns_str = $.map([tfs, libraries, ranks], function (x) { return x.join('\t') }).join('\n');
    matrix_str = columns_str + '\n' + rows.join('\n');

    // Return
    return matrix_str;
}   

// Function to generate clustergrammer
function generateClustergram(matrix_str) {

    // Create file
    var formData = new FormData();
    var blob = new Blob([matrix_str], { type: 'plain/text' });
    formData.append('file', blob, 'chea_clustergram.txt');

    // Make request
    var request = new XMLHttpRequest();
    request.open('POST', 'https://amp.pharm.mssm.edu/clustergrammer/matrix_upload/');
    request.send(formData);

    // Callback
    request.onreadystatechange = function () {
        if (request.readyState === 4) {
            var response = request.responseText;
            if (request.status === 200) {
            	console.log(response)
                document.getElementById("clustergram-iframe").dataset.source = response;
            } else {
                console.log('failed');
            }
        }
    }

}




