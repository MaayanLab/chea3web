
var sliderClassName = 'slider';
var defaultNodeColor = '#d3d3d3';
var chea3Results;
var json;
var descriptions;
var aucs = {"Integrated--meanRank":"0.786", "Integrated--topRank":"0.783", "Enrichr--Queries":"0.725", "ARCHS4--Coexpression":"0.711", "GTEx--Coexpression":"0.703", "ReMap--ChIP-seq": "0.629", "Literature--ChIP-seq": "0.613", "ENCODE--ChIP-seq": "0.606"};

//function downloadResults(filename, text) {
//	  var element = document.createElement('a');
//	  element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
//	  element.setAttribute('download', filename);
//
//	  element.style.display = 'none';
//	  document.body.appendChild(element);
//
//	  element.click();
//
//	  document.body.removeChild(element);
//}

function downloadResults(filename, text){
	var blob = new Blob([text], { type: 'text/csv;charset=utf-8;' });
    if (navigator.msSaveBlob) { // IE 10+
        navigator.msSaveBlob(blob, filename);
    }else {
        var link = document.createElement("a");
        if (link.download !== undefined) { // feature detection
            var url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", filename);
            link.style.visibility = 'hidden';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    }
    
}

function sliderChange(event) {
	// change slider output text
	
	// var outputId = `${event.target.id}_output`;
	// document.getElementById(outputId).innerHTML = renderSliderValueString(event.target.value);
	// document.getElementById("colorby").value = "none";
	recolorAllNodes();
	setLegendView();
	generateNetwork();
	generateBarChart();
	$('#nr-selected-tfs').html($('#tf-slider').val());
}

function getColor(id) {
	return ($("#" + id).spectrum('get').toHexString())
}

function translateNodeColor(val){
	if(val == "Tissue (general)"){
		return("General_tissue_color");
	}else if (val == "Tissue (specific)"){
		return("Specific_tissue_color");
	}else if(val == "WGCNA modules"){
		return("WGCNA_hex");
	}else if(val == "GO Enrichment"){
		return("GO_enrichment_color");
	}else if(val == "Tumor"){
		return("Tumor_color");	
	}else if(val == "Tissue"){
		return("Tissue_color");
		
	}
	else{
		return(defaultNodeColor);
	}
}

function defaultNodeColorAll(){
	
	var colorby_val = document.getElementById("colorby").value;
	var fill = translateNodeColor(colorby_val);
	nodes = document.querySelectorAll("circle");
	for (var n of nodes) {
		if(fill == defaultNodeColor){
			n.setAttribute("fill",fill);	
		}else{
			n.setAttribute("fill",n.getAttribute(fill));	
		}
		n.setAttribute("stroke-width","0");
		
	}
}

// function getTFs(slider){
// 	var set1Values = chea3Results[slider.id.replace('_slider', '')].map(function (transcriptionFactors) {
// 		return transcriptionFactors.TF;
// 	});
// 	var set1ValuesSliderSubset = set1Values.splice(0, slider.value);
// 	return set1ValuesSliderSubset
// }

function getTFs2(){
	var library = $('#library-selectpicker').val(),
			nr_tfs = parseInt($('#tf-slider').val()),
			tfs = typeof chea3Results !== "undefined" ? chea3Results[library].slice(0, nr_tfs).map(function(x) { return x['TF'] }) : [];
	return tfs		
}

// function highlightNodes(sliders){
// 	// if sliders are defined
	
// 	if(sliders.length>0){
// 		for (var s of sliders) {
// 			set1ValuesSliderSubset = getTFs(s);
// 			var colorpicker_id = s.id.replace('_slider', '') + "_colorpicker";

// 			for (var tf of set1ValuesSliderSubset) {
// 				node = document.getElementById(tf);
// 				if (node) {
// 					node.setAttribute("stroke", getColor(colorpicker_id));
// 					node.setAttribute("stroke-width", radius*2.5)
// 					node.setAttribute("stroke-opacity", .5)
// 				}
// 			}

// 		}
// 	}
	
// }

function highlightNodes2() {
	set1ValuesSliderSubset = getTFs2();
	// var colorpicker_id = s.id.replace('_slider', '') + "_colorpicker";

	for (var tf of set1ValuesSliderSubset) {
		node = document.getElementById(tf);
		if (node) {
			node.setAttribute("stroke", getColor('colorpicker')); //getColor(colorpicker_id)
			node.setAttribute("stroke-width", radius * 2.5)
			node.setAttribute("stroke-opacity", .5)
		}
	}
}

function recolorAllNodes() {
	defaultNodeColorAll();
	// var sliders = document.querySelectorAll(".slider");
	highlightNodes2();
}

// function addSliderEventListeners() {
// 	var sliders = document.querySelectorAll(`.${sliderClassName}`);
// 	Array.from(sliders).forEach(function (slider) {
// 		slider.addEventListener('change', sliderChange);
// 	});
// }

function addSliderEventListener() {
	document.getElementById('tf-slider').addEventListener('change', sliderChange);
}

function renderSliderValueString(value) {
	return `Top ${value} TFs highlighted in network`;
}

// function renderCaption(libraryName) {
// 	var captionId = `${libraryName}_${sliderClassName}`;
// 	var value = 0;
// 	// var caption = `
// 	// <caption>
// 	// </span>
// 	// <input id="${captionId}" class="${sliderClassName}" type="range" min="0" max="50" value="${value}">
// 	// <span id="${captionId}_output" style="color:white;font-size:14px;font-color:white">
// 	// ${renderSliderValueString(value)}
// 	// </span>	
// 	// <input type='text' id="${libraryName}_colorpicker" />
// 	// </caption>`;
	
// 	if (libraryName == "Integrated--meanRank"){
// 		return `
// 		<caption>
// 		</span>
// 		<input id="${captionId}" class="${sliderClassName}" type="range" min="0" max="50" value="${value}">
// 		<span id="${captionId}_output" style="color:white;font-size:14px;font-color:white">
// 		${renderSliderValueString(value)}
// 		</span>
// 		<input type='text' id="${libraryName}_colorpicker" />${renderBarChartPopoverButton()}
// 		<button type="button" class="btn btn-link tf-tf-network display-7 p-0">TF-TF Network</button>
// 		</caption>`;
		
		
// 	}else{
// 		return `
// 		<caption>
// 		</span>
// 		<input id="${captionId}" class="${sliderClassName}" type="range" min="0" max="50" value="${value}">
// 		<span id="${captionId}_output" style="color:white;font-size:14px;font-color:white">
// 		${renderSliderValueString(value)}
// 		</span>	
// 		<input type='text' id="${libraryName}_colorpicker" />
// 		</caption>`;
// 	}
	
	
// }

function renderColorPicker() {
	// New colorpicker
	$('#colorpicker')
		.spectrum({
			color: colorArray[i],
			change: function() {
				recolorAllNodes();
				generateBarChart();
				generateNetwork();
			}
		})
}

// function renderTable(libraryName) {
// 	return `
// 	<table class="display" style="width:500px" id="table_${libraryName}"></table>
// 	`
// }

// function renderCardHeader(libraryName){
// 	var libraryTitle = libraryName.replace("--"," ");
// 	var libraryTitle = libraryTitle.replace("--"," ");
// 	var rocauc = aucs[libraryName];
// 	return `    <div class="card-header" style="padding:0" role="tab" id="${libraryName}_header">
// 	<a role="button" id="${libraryName}_headerbutton" class="lablab collapsed panel-title text-white"
// 	data-toggle="collapse" data-parent="#accordion" data-core=""
// 	href="#${libraryName}_body" aria-expanded="false"
// 	aria-controls="collapse2">
// 	<h4 class="mbr-fonts-style display-7 px-3 py-2" style="margin-bottom:0">
// 	<span class="sign mbr-iconfont mbri-down inactive"></span>
// 	<span class="color-emphasis-1" style = "font-size:100%">${libraryTitle}</span>
// 	<span class="lib_description" id="${libraryName}_tooltip" data-tooltip="Loading library information..." data-tooltip_position="right">
// 	<span class="mbri-info mbr-iconfont mbr-iconfont-btn"></span>
// 	<span style="font-size:70%",font-color:red">ROC AUC: ${rocauc}</span>
// 	</h4>
// 	</a>

// 	</div>
// 	`
// }

function renderDownloadLibraryButton(libraryName, display){
	var libraryTitle = libraryName.replace("--","_");
	var libraryTitle = libraryTitle.replace("--","_");
	var displayClass = display ? '' : 'd-none';
	return `<a id = "${libraryName}-download" class="btn btn-primary display-7 ${displayClass} download-tsv ml-0" style="padding:0;color:#28a0c9;font-size:80%" 
	onclick="downloadResults('${libraryTitle}.tsv',libraryJSONtoTSV('${libraryName}'));"><span class="mbri-download display-5 mr-2"></span>
	Download All ${libraryTitle.replace('_', ' ')} Results as TSV</a>`

}

// function renderCardBody(libraryName) {
// 	return `<div id="${libraryName}_body" class="funfun panel-collapse noScroll collapse" style="width:100%;padding:7px"
// 	role="tabpanel" aria-labelledby="${libraryName}_header">
// 	<div class="panel-body">`
// 	+ renderCaption(libraryName) + renderTable(libraryName) + renderDownloadLibraryButton(libraryName) +

// 	`</div>
// 	</div>`
// }

// function renderDownloadResultsBtn(){
// 	return `<a id = "downloadJSON" class="btn btn-sm btn-primary display-4" style="padding:0" 
// 	onclick="downloadResults('results.json',json);"><span
// 	class="mbri-save mbr-iconfont mbr-iconfont-btn"></span>Download All Results as JSON</a>`
// }


// function addCardHeaderEventListeners(){
// 	$(".lablab").click(function() {
// 		var classes = this.classList;
// 		var card_id = this.id;
// 		var slider_id = card_id.replace("headerbutton","slider");
// 		var output_id = card_id.replace("headerbutton","slider_output")
// 		var slider = document.getElementById(slider_id)
// 		var table_id = '#table_' + card_id.replace("_headerbutton","");	
// 		var body_id = card_id.replace("headerbutton","body");
		
// 		//if object is being collapsed
// 		if(!(Object.values(classes).indexOf('collapsed') > -1)){
// 			//reset slider
// 			slider.value = 0;
// 			document.getElementById(output_id).innerHTML = renderSliderValueString(0);
// 			recolorAllNodes();
			
// 		}else{ //object is being expanded
// 			var card_id = this.id;
			
			
// 			$(table_id).css('width', '100%');
// 			slider.value = 10;
// 			document.getElementById(output_id).innerHTML = renderSliderValueString(10);
			
// 			//collapse all other open nodes and set their sliders to 0
// 			$(".lablab:not(#"+card_id+")").addClass("collapsed");
// 			$(".lablab:not(#"+card_id+")").attr("aria-expanded",false);
// 			$(".funfun:not(#"+body_id+")").removeClass("show");
// 			$(".slider:not(#"+slider_id+")").val(0);
			
// 			document.getElementById("colorby").value = "none";
// 			recolorAllNodes();
// 			setLegendView();

// 		}   
// 	});

// }

function validateGeneSet(geneset) {
	var x = false;
	console.log($('#num-valid-genes').html());
	if (geneset.length > 1 & $('#num-valid-genes').html() === "0") {
		alert("No valid gene symbols have were recognized. Please note that CHEA3 currently only supports HGNC gene symbols (https://www.genenames.org/). If the submitted genes are identified using other systems, such as Ensembl IDs or Entrez IDs, please converting them to HGNC to proceed.");
	}
	else if (geneset.length > 1 & geneset.length < 8000) {
		x = true;
	} else {
		alert("Gene set must contain more than 1 gene and fewer than 8,000 genes. One gene per line.");
	}
	return x;
}

// function getLibraryDescriptions(){
// 	var url =  host + "chea3/api/libdescriptions/";
// 	$.ajax({
// 		url : url,
// 		success : function(results) {
// 			descriptions = JSON.parse(results);
// 			var lib_names = Object.keys(descriptions);
// 			for(l in lib_names){
// 				lib = lib_names[l];
// 				$("#"+lib.replace(".txt","")+"_tooltip").attr("data-tooltip",descriptions[lib][0])
// 			}
// 		}
// 	});
		
// }

// function downloadText(element_id, filename) {
// 	  var element = document.getElementById(element_id);
// 	  element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(json));
// 	  element.setAttribute('download', filename);

// 	  element.style.display = 'none';
// 	  document.body.appendChild(element);

// 	  element.click();

// 	  document.body.removeChild(element);
// }

// function newQuery(){
// 	$("#results").addClass("d-none");
// 	$("#pills-tab").addClass("d-none");
	
// 	$('#pills-tab a[href="#pills-coexpression"]').tab('show');
	
// 	$("#results").html(`
// 				<div id="resultssidenav" class="sidenavR"
// 					style="top: 60px; height: 90%; padding-top: 20px; padding-bottom: 20px">
// 					<a href="javascript:void(0)" class="closebtn"
// 						onclick="closeNav('resultssidenav')">&times;</a>
// 					<h1
// 						class="mbr-section-title mbr-bold mbr-fonts-style display-7 text-white"
// 						align="left" style='padding-left: 2em'>Results by Library</h1>
// 				</div>

// 				<div id="expandresults"
// 					style="float:left; padding-top: 30px">
// 					<span style="font-size: 15px; cursor: pointer; padding-top: 30px"
// 						onclick="openNav('resultssidenav','40%')">&#9776;
						
// 					</span> <h6 class="mbr-iconfont display-5"
// 							style="font-size: 1rem; display: inline">Back to Results</h6> <button type="button" class="btn btn-primary"
// 								id="newquerybutton" type="submit" onclick="newQuery()" style="padding: .5rem 1.5rem">New Query</button>


// 				</div>`);
	
	
// 	$('#translucent-net').removeClass("d-none");
// 	$('#tfea-submission').removeClass("d-none");
// 	$('#tfea-title').removeClass("d-none");
// 	var gl = document.getElementById("genelist");
// 	gl.value = "";
// 	gl.placeholder = "Submit gene list with one gene per line."
// 	chea3Results = null;
	
// 	document.getElementById("colorby").value = "Tissue (general)";
// 	defaultNodeColorAll();
// 	setLegendView();
	
// 	// reset text box
	
// }

function intersectionPopover(row, library) {
	var genes = row.Overlapping_Genes.split(','),
			genes_link = genes.map(function(x) { return `<a href="https://amp.pharm.mssm.edu/Harmonizome/gene/${x}" target="_blank">${x}</a>` });
	return `
<div class="w-100 text-center">
	<button id="overlappinggenespopover" tabindex="0" type="button" class="btn-link display-7 nodecoration cursor-pointer" style="border:none; color:#28a0c9" data-popover-content="#${library}-${row.Rank}" data-toggle="popover" data-placement="right">${genes.length}</button>
	<div id="${library}-${row.Rank}" style="display:none;">
		<div class="popover-body">
			<button type="button" class="nodecoration cursor-pointer popover-close close pr-2" onclick="$(this).parents('.popover').popover('hide');">&times</button>
			<div class="gene-popover">${genes_link.join(', ')}</div>
			<a id = "downloadOverlap" class="btn btn-link display-7" style="padding:0;color:#28a0c9;font-size:80%" onclick="downloadResults('overlap.csv','${genes}');">
			<span class="mbri-save mbr-iconfont mbr-iconfont-btn display-7"></span>Download overlapping gene list</a>
		</div>
	</div>
</div>`
}

function uploadFileListener() {
	$('#file-input').on('change', function (evt) {
		var f = evt.target.files[0],
				reader = new FileReader();

		// Closure to capture the file information.
		reader.onload = (function () {
			return function (e) {
				$('#genelist').val(e.target.result);
				checkGeneList(e.target.result);
			};
		})(f);

		reader.readAsText(f);
	})
}

function generateDatatable(library, library_results, default_library, filter_top_results=false) {

	// Create table
	var $table = $('<table>', { 'id': library + '-table', 'class': 'w-100 text-black' }) // + (library === default_library ? '' : 'd-none')
		.append($('<thead>', { 'class': 'text-black' }).html($('<tr>')))
		.append($('<tbody>', { 'class': 'text-black' }))
		.append($('<tfoot>', { 'class': 'text-black' }));

	// Append
	$('#tables-wrapper').append($table);

	// Filter
	if (filter_top_results) {
		library_results = library_results.slice(0, filter_top_results);
	}

	// Integrated libraries
	if (library.includes('Integrated')) {

		// Get score column
		if (library === 'Integrated--meanRank') {
			score_th = 'Mean Rank';
			library_render = function (x) { return x }
		} else if (library === 'Integrated--topRank') {
			score_th = 'Integrated Scaled Rank';
			library_render = function (x) { return x.split(',')[0] }
		}

		// Initialize
		$table.DataTable({
			data: library_results,
			pagingType: "simple",
			columns: [
				{ "mData": "Rank", "sTitle": "Rank" , "className": "dt-head-center"},
				{ "mData": "TF", "sTitle": "TF", "mRender": function (x) { return `<a href="https://amp.pharm.mssm.edu/Harmonizome/gene/${x}" target="_blank">${x}</a>` } , "className": "dt-head-center"},
				{ "mData": "Score", "sTitle": score_th , "className": "dt-head-center"},
				{ "mData": "Overlapping_Genes", "sTitle": "Overlapping Genes", "mRender": function (data, type, row, meta) { return intersectionPopover(row, library) } , "className": "dt-head-center"},
				{ "mData": "Library", "sTitle": "Library", "mRender": library_render, "className": "dt-head-left" }
			]
		})

	} else {

		// Initialize
		$table.DataTable({
			data: library_results,
			pagingType: "simple",
			columns: [
				{ "mData": "Rank", "sTitle": "Rank" , "className": "dt-head-center"},
				{ "mData": "TF", "sTitle": "TF", "mRender": function (x) { return `<a href="https://amp.pharm.mssm.edu/Harmonizome/gene/${x}" target="_blank">${x}</a>` } , "className": "dt-head-center"},
				{ "mData": "Set_name", "sTitle": "Set name" , "className": "dt-head-center"},
				{ "mData": "Set length", "sTitle": "Set size" , "className": "dt-head-center"},
				{ "mData": "Overlapping_Genes", "sTitle": "Overlapping Genes", "mRender": function (data, type, row, meta) { return intersectionPopover(row, library) } , "className": "dt-head-center"},
				{ "mData": "FET p-value", "sTitle": "FET p-value" , "className": "dt-head-center"},
				{ "mData": "FDR", "sTitle": "FDR" , "className": "dt-head-center"},
				{ "mData": "Odds Ratio", "sTitle": "Odds Ratio", "className": "dt-head-center" }
			]
		})
	}

	// Append
	$('#tables-wrapper').append(renderDownloadLibraryButton(library, library === default_library));

	// Hide
	if (library != default_library) {
		$(`#${library}-table_wrapper`).addClass('d-none');
	}
}

function toggleSelectors(library, tab) {
	if (tab.includes('network')) {
		$('.tf-selector').removeClass('d-none');
	} else if (tab.includes('barchart')) {
		$('.tf-selector').removeClass('d-none');
		if (library === 'Integrated--meanRank') {
			$('#colorpicker-col').addClass('d-none');
		}
	} else {
		$('.tf-selector').addClass('d-none');
	}
}

function displayResults(results) {

	chea3Results = results;

	// Loop through results
	default_library = 'Integrated--meanRank';
	$.each(chea3Results, function (key, value) {
		generateDatatable(key, value, default_library);
	})

	// Add libraries
	addSliderEventListener();
	generateNetwork();
	generateBarChart();
	renderColorPicker();

	// Toggle views
	$('#homepage').addClass("d-none");
	$("#results").removeClass("d-none");
	$('#loading-screen').addClass('d-none');
	
	// Create selectpicker
	$('#library-selectpicker').change(function (evt) {
		var library = $(evt.target).val();

		// Toggle
		toggleSelectors(library=$(evt.target).val(), tab = $('#nav-tab .nav-item.active').attr('aria-controls'));

		// Hide
		$('#tables-wrapper .dataTables_wrapper').addClass('d-none');
		$('.download-tsv').addClass('d-none');

		// Show
		$('#' + library + '-table_wrapper').removeClass('d-none');
		$('#' + library + '-download').removeClass('d-none');
		generateBarChart();
		generateNetwork();
		recolorAllNodes();
	})
	$('#library-selectpicker').selectpicker('val', default_library);

	document.getElementById("colorby").value = "none";
	recolorAllNodes();
	setLegendView();
	location.href = '#top'

	// Popovers
	// Ovrerlapping genes
	$("[id=overlappinggenespopover]").popover({
		html: true,
		trigger: 'click',
		content: function () {
			var content = $(this).attr("data-popover-content");
			return $(content).children(".popover-body").html();
		}
	});

	// Clustergrammer
	// Get matrix and send to clustergrammer
	matrix_str = buildClustergrammerMatrix(chea3Results);
	generateClustergram(matrix_str);


}

$(document).ready(function () {

	uploadFileListener()	
	
	$('#example-genelist').on('click', function () {
		var gl = document.getElementById("genelist");
		gl.placeholder = "";
		jQuery.get('assets/chea-query/example_genelist.txt', function (data) {
			gl.value = data;
			checkGeneList(data);
		});

	});

	// Submit genelist button event listener
	$('#submit-genelist').on('click', function (evt) { 

		var geneset = document.getElementById("genelist").value.split(/\n/); 
		var geneset = geneset.map(function(x){return x.toUpperCase()})
		var uniq_genes = [...new Set(geneset)];
		var intersect = uniq_genes.filter(value => hgnc.includes(value));
		var enrich_url = host + "chea3/api/enrich/"; 
		var payload = {
				"query_name" : "gene_set_query",
				"gene_set" : intersect
		}

		if (validateGeneSet(intersect)) { 

			$('#loading-screen').removeClass('d-none');

			// send gene set to java servlet
			$.ajax({ 
				type: "POST",
				data: JSON.stringify(payload),
				dataType: "json",
				contentType: "application/json",
				url : enrich_url, 
				success : function(results) { 
					displayResults(results);

				} //end success function 
			}); // end AJAX call

		} 
	});

	// Tab listener
	$('#nav-tab [data-toggle="tab"]').on('shown.bs.tab', function (evt) {
		toggleSelectors(library=$('#library-selectpicker').val(), tab = $(evt.target).attr('aria-controls'));
	})

	// Automatic genelist submission for dev
	var dev = true;
	if (dev) {
		$('#loading-screen').removeClass('d-none');
		$.get("chea3Results.json", function (results) { //dev
			displayResults(results);
		})
	}


});








