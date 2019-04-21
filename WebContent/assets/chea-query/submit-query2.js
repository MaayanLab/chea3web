
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
	
	var outputId = `${event.target.id}_output`;
	document.getElementById(outputId).innerHTML = renderSliderValueString(event.target.value);
	document.getElementById("colorby").value = "none";
	recolorAllNodes();
	setLegendView();
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

function getTFs(sliders){
	
}

function highlightNodes(sliders){
	// if sliders are defined
	
	if(sliders.length>0){
		for (var s of sliders) {
			var libraryName = s.id.replace('_slider', '');
			var colorpicker_id = libraryName + "_colorpicker";
			var set1Values = chea3Results[libraryName].map(function (transcriptionFactors) {

				return transcriptionFactors.TF;

			});
			var set1ValuesSliderSubset = set1Values.splice(0, s.value);
			for (var tf of set1ValuesSliderSubset) {
				
				node = document.getElementById(tf);
				if (node) {
					node.setAttribute("stroke", getColor(colorpicker_id));
					node.setAttribute("stroke-width", radius*2.5)
					node.setAttribute("stroke-opacity", .5)
				}
			}

		}
	}
	
}

function recolorAllNodes() {
	defaultNodeColorAll();
	var sliders = document.querySelectorAll(".slider");
	highlightNodes(sliders);
}

function addSliderEventListeners() {
	var sliders = document.querySelectorAll(`.${sliderClassName}`);
	Array.from(sliders).forEach(function (slider) {
		slider.addEventListener('change', sliderChange);
	});
}

function renderSliderValueString(value) {
	return `Top ${value} TFs highlighted in network`;
}

function renderCaption(libraryName) {
	var captionId = `${libraryName}_${sliderClassName}`;
	var value = 0;
	var caption = `
	<caption>
	</span>
	<input id="${captionId}" class="${sliderClassName}" type="range" min="0" max="50" value="${value}">
	<span id="${captionId}_output" style="color:white;font-size:14px;font-color:white">
	${renderSliderValueString(value)}
	</span>	
	<input type='text' id="${libraryName}_colorpicker" />
	</caption>`;
	
	if (libraryName == "Integrated--meanRank"){
		return `
		<caption>
		</span>
		<input id="${captionId}" class="${sliderClassName}" type="range" min="0" max="50" value="${value}">
		<span id="${captionId}_output" style="color:white;font-size:14px;font-color:white">
		${renderSliderValueString(value)}
		</span>	
		<input type='text' id="${libraryName}_colorpicker" />` + renderBarChartPopoverButton() + `</caption>`;
		
		
	}else{
		return `
		<caption>
		</span>
		<input id="${captionId}" class="${sliderClassName}" type="range" min="0" max="50" value="${value}">
		<span id="${captionId}_output" style="color:white;font-size:14px;font-color:white">
		${renderSliderValueString(value)}
		</span>	
		<input type='text' id="${libraryName}_colorpicker" />
		</caption>`;
	}
	
	
}

function renderColorPicker(libraryName, i) {
	var colorpicker_id = libraryName + "_colorpicker";
	$("#" + colorpicker_id)
	.on('change', function () {
		recolorAllNodes();
	})
	.spectrum({
		color: colorArray[i]
	});
}

function renderTable(libraryName) {
	return `
	<table class="display" style="width:500px" id="table_${libraryName}"></table>
	`
}

function renderCardHeader(libraryName){
	var libraryTitle = libraryName.replace("--"," ");
	var libraryTitle = libraryTitle.replace("--"," ");
	var rocauc = aucs[libraryName];
	return `    <div class="card-header" style="padding:0" role="tab" id="${libraryName}_header">
	<a role="button" id="${libraryName}_headerbutton" class="lablab collapsed panel-title text-white"
	data-toggle="collapse" data-parent="#accordion" data-core=""
	href="#${libraryName}_body" aria-expanded="false"
	aria-controls="collapse2">
	<h4 class="mbr-fonts-style display-7" style="margin-bottom:0">
	<span class="sign mbr-iconfont mbri-down inactive"></span>
	<span class="color-emphasis-1" style = "font-size:100%">${libraryTitle}</span>
	<span class="lib_description" id="${libraryName}_tooltip" data-tooltip="Loading library information..." data-tooltip_position="right">
	<span class="mbri-info mbr-iconfont mbr-iconfont-btn"></span>
	<span style="font-size:70%",font-color:red">ROC AUC: ${rocauc}</span>
	</h4>
	</a>

	</div>
	`
}

function renderDownloadLibraryButton(libraryName){
	var libraryTitle = libraryName.replace("--","_");
	var libraryTitle = libraryTitle.replace("--","_");
	return `<a id = "downloadJSON" class="btn btn-link display-7" style="padding:0;color:#28a0c9;font-size:80%" 
	onclick="downloadResults('${libraryTitle}.tsv',libraryJSONtoTSV('${libraryName}'));">
	Download All ${libraryTitle} Results as TSV</a>`

}

function renderCardBody(libraryName) {
	return `<div id="${libraryName}_body" class="funfun panel-collapse noScroll collapse" style="width:100%;padding:7px"
	role="tabpanel" aria-labelledby="${libraryName}_header">
	<div class="panel-body">`
	+ renderCaption(libraryName) + renderTable(libraryName) + renderDownloadLibraryButton(libraryName) +

	`</div>
	</div>`
}

function renderDownloadResultsBtn(){
	return `<a id = "downloadJSON" class="btn btn-sm btn-primary display-4" style="padding:0" 
	onclick="downloadResults('results.json',json);"><span
	class="mbri-save mbr-iconfont mbr-iconfont-btn"></span>Download All Results as JSON</a>`
}


function addCardHeaderEventListeners(){
	$(".lablab").click(function() {
		var classes = this.classList;
		var card_id = this.id;
		var slider_id = card_id.replace("headerbutton","slider");
		var output_id = card_id.replace("headerbutton","slider_output")
		var slider = document.getElementById(slider_id)
		var table_id = '#table_' + card_id.replace("_headerbutton","");	
		var body_id = card_id.replace("headerbutton","body");
		
		//if object is being collapsed
		if(!(Object.values(classes).indexOf('collapsed') > -1)){
			//reset slider
			slider.value = 0;
			document.getElementById(output_id).innerHTML = renderSliderValueString(0);
			recolorAllNodes();
			
		}else{ //object is being expanded
			var card_id = this.id;
			
			
			$(table_id).css('width', '100%');
			slider.value = 10;
			document.getElementById(output_id).innerHTML = renderSliderValueString(10);
			
			//collapse all other open nodes and set their sliders to 0
			$(".lablab:not(#"+card_id+")").addClass("collapsed");
			$(".lablab:not(#"+card_id+")").attr("aria-expanded",false);
			$(".funfun:not(#"+body_id+")").removeClass("show");
			$(".slider:not(#"+slider_id+")").val(0);
			
			document.getElementById("colorby").value = "none";
			recolorAllNodes();
			setLegendView();

		}   
	});

}

function validateGeneSet(geneset) {
	var x = false;
	if (geneset.length > 1 & geneset.length < 2000) {
		x = true;
	}else{
		alert("Gene set must contain more than 1 gene and fewer than 2,000 genes. One gene per line.");
	}
	return x;
}

var buttonCommon = {
		exportOptions: {
			format: {
				body: function (data, column, row) {
					var filterData = data.replace(/&lt;/g, '<')
					return filterData.replace(/&gt;/g, '>');

				}
			}
		}
};

function getLibraryDescriptions(){
	var url =  host + "chea3/api/libdescriptions/";
	$.ajax({
		url : url,
		success : function(results) {
			descriptions = JSON.parse(results);
			var lib_names = Object.keys(descriptions);
			for(l in lib_names){
//				console.log(l)
				lib = lib_names[l];
				$("#"+lib.replace(".txt","")+"_tooltip").attr("data-tooltip",descriptions[lib][0])
//				console.log("#"+lib_names[l]+"_tooltip")
//				console.log(descriptions[lib_names[l]][0])
			}
		}
	});
		
}

function downloadText(element_id, filename) {
	  var element = document.getElementById(element_id);
	  element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(json));
	  element.setAttribute('download', filename);

	  element.style.display = 'none';
	  document.body.appendChild(element);

	  element.click();

	  document.body.removeChild(element);
}

function newQuery(){
	$("#results").addClass("d-none");
	$("#pills-tab").addClass("d-none");
	
	$('#pills-tab a[href="#pills-coexpression"]').tab('show');
	
	$("#results").html(`
				<div id="resultssidenav" class="sidenavR"
					style="top: 60px; height: 90%; padding-top: 20px; padding-bottom: 20px">
					<a href="javascript:void(0)" class="closebtn"
						onclick="closeNav('resultssidenav')">&times;</a>
					<h1
						class="mbr-section-title mbr-bold mbr-fonts-style display-7 text-white"
						align="left" style='padding-left: 2em'>Results by Library</h1>
				</div>

				<div id="expandresults"
					style="float:left; padding-top: 30px">
					<span style="font-size: 15px; cursor: pointer; padding-top: 30px"
						onclick="openNav('resultssidenav','40%')">&#9776;
						
					</span> <h6 class="mbr-iconfont display-5"
							style="font-size: 1rem; display: inline">Back to Results</h6> <button type="button" class="btn btn-primary"
								id="newquerybutton" type="submit" onclick="newQuery()" style="padding: .5rem 1.5rem">New Query</button>


				</div>`);
	
	
	$('#translucent-net').removeClass("d-none");
	$('#tfea-submission').removeClass("d-none");
	$('#tfea-title').removeClass("d-none");
	var gl = document.getElementById("genelist");
	gl.value = "";
	gl.placeholder = "Submit gene list with one gene per line."
	chea3Results = null;
	
	document.getElementById("colorby").value = "Tissue (general)";
	defaultNodeColorAll();
	setLegendView();
	
	// reset text box
	
}

$(document).ready(function () {
	
	
	
	$('#example-genelist').on('click', function () {
		var gl = document.getElementById("genelist");
		gl.placeholder = "";
		jQuery.get('assets/chea-query/example_genelist.txt', function (data) {
			gl.value = data;
			checkGeneList(data);
		});

	});
	
	$('#submit-genelist').on('click', function (evt) {

		var geneset = document.getElementById("genelist").value.split(/\n/);
		// generate url
		var enrich_url = host + "chea3/api/enrich/";
		enrich_url = enrich_url + geneset.join();

		if (validateGeneSet(geneset)) {

			$('#loading-screen').removeClass('d-none');
			$('#translucent-net').addClass("d-none");
			$('#tfea-submission').addClass("d-none");
			$('#tfea-title').addClass("d-none");

			// send gene set to java servlet
			$.ajax({
				url : enrich_url,
				success : function(results) {
					
					json = results;
					results = JSON.parse(results);
					chea3Results = results;
					//reorder results based on ROC AUCs
					
					
					var lib_names = Object.keys(aucs);
					var results_div = document.getElementById("resultssidenav");

					var captionAndTableMarkup = lib_names.reduce(function (accumulator, libraryName) {
						accumulator += renderCardHeader(libraryName)
						accumulator += renderCardBody(libraryName)
						return accumulator;
					}, '');
					results_div.innerHTML += `<div class="clearfix"></div>
						<div id="bootstrap-toggle"
						class="toggle-panel accordionStyles tab-content">` + 
						captionAndTableMarkup + `</div>` + renderDownloadResultsBtn();
					for (i = 0; i < lib_names.length; i++) {
						renderColorPicker(lib_names[i],i);
						var lib_results = results[lib_names[i]];
						var column_names = Object.keys(lib_results[1]);
						if(lib_names[i].includes("Integrated")){
							$(`#table_${lib_names[i]}`).DataTable({
								data: lib_results.slice(0,100),
								aoColumns: [
									{mData: "Rank", sTitle: "Rank"},
									{mData: "TF", sTitle: "TF", 
										mRender: function(data, type, full){
											return '<a href="http://amp.pharm.mssm.edu/Harmonizome/gene/' + data + '" target="_blank" style="color:#149dcc">' + data + '</a>'
										}},
									{mData: "Score", sTitle: "Score"},
									{mData: "Overlapping_Genes",sTitle: "Overlapping Genes", mRender: function(data, type, row, meta){
										var genes = row.Overlapping_Genes;
										space_genes = genes.replace(/,/g, ', ');
										var count = genes.split(',').length;
										
										return `<div class="popover-block-container">
  <button id="overlappinggenespopover" tabindex="0" type="button" class="btn-link display-7" style="border:none; color:#28a0c9" data-popover-content="#` + row.TF + row.Score.split(".")[0] + `" data-toggle="popover" data-placement="right">
   ` + count +
  `</button>
  <div id="` + row.TF + row.Score.split(".")[0] + `" style="display:none;">
    <div class="popover-body">
      <button type="button" class="popover-close close">
        <span class="mbri-close mbr-iconfont mbr-iconfont-btn display-7"></span>
      </button>` +
      space_genes + 
      
    `<a id = "downloadOverlap" class="btn btn-link display-7" style="padding:0;color:#28a0c9;font-size:80%" 
	onclick="downloadResults('overlap.csv','`+ genes +`');">
	<span class="mbri-save mbr-iconfont mbr-iconfont-btn display-7"></span>Download overlapping gene list</a>
 </div>
  </div>
</div>`
									}},	
									{mData: "Library", sTitle: "Library"}],
									scrollY: "200px",
									scrollX: "500px",
									sScrollX: "500px",
									scrollCollapse: true,
									paging: false,
									info: false,
									dom: "Bfrtip",
									buttons: [
										$.extend(true, {}, buttonCommon, {
											extend: 'copyHtml5'
										}),
//										$.extend(true, {}, buttonCommon, {
//											extend: 'excelHtml5'
//										}),
//										$.extend(true, {}, buttonCommon, {
//											extend: 'pdfHtml5'
//										}),
//										$.extend(true, {}, buttonCommon, {
//											extend: 'colvis'
//										})
										]
							});
						}else{
							$(`#table_${lib_names[i]}`).DataTable({
								data: lib_results.slice(0,100),
								aoColumns: [
									{mData: "Rank", sTitle: "Rank"},
									{mData: "TF",sTitle: "TF", mRender: function(data, type, full){
										return '<a href="http://amp.pharm.mssm.edu/Harmonizome/gene/' + data + '" target="_blank" style="color:#149dcc">' + data + '</a>'
									}},
																
									{mData: "Set_name", sTitle: "Set name"},
									{mData: "Set length", sTitle: "Set size"},
									{mData: "Intersect",sTitle: "Intersection", mRender: function(data, type, row, meta){
										var genes = row.Overlapping_Genes;
										space_genes = genes.replace(/,/g, ', ');
										return `<div class="popover-block-container">
  <button id="overlappinggenespopover" tabindex="0" type="button" class="btn-link display-7" style="border:none; color:#28a0c9" data-popover-content="#` + row.Set_name + row.Library + `" data-toggle="popover" data-placement="right">
   ` + data +
  `</button>
  <div id="` + row.Set_name + row.Library + `" style="display:none;">
    <div class="popover-body">
      <button type="button" class="popover-close close">
        <span class="mbri-close mbr-iconfont mbr-iconfont-btn display-7"></span>
      </button>` +
      space_genes + 
      
    `<a id = "downloadOverlap" class="btn btn-link display-7" style="padding:0;color:#28a0c9;font-size:80%" 
	onclick="downloadResults('overlap.csv','`+ genes +`');">
	<span class="mbri-save mbr-iconfont mbr-iconfont-btn display-7"></span>Download overlapping gene list</a>
 </div>
  </div>
</div>`
									}},		
									{mData: "FET p-value", sTitle: "FET p-value"},
									{mData: "FDR", sTitle: "FDR"},
									{mData: "Odds Ratio", sTitle: "Odds Ratio"}],
									scrollY: "200px",
									scrollX: "4000px",
									sScrollX: "4000px",
									scrollCollapse: true,
									info: false,
									paging: false,
									dom: "Bfrtip",
									buttons: [
										$.extend(true, {}, buttonCommon, {
											extend: 'copyHtml5'
										}),
//										$.extend(true, {}, buttonCommon, {
//											extend: 'excelHtml5'
//										}),
//										$.extend(true, {}, buttonCommon, {
//											extend: 'pdfHtml5'
//										}),
//										$.extend(true, {}, buttonCommon, {
//											extend: 'colvis'
//										})
										]
							});

						}
						$('#'+lib_names[i] + "_body").on('shown.bs.collapse', function () {
							$($.fn.dataTable.tables(true)).DataTable()
							.columns.adjust();
						})
					}
					getLibraryDescriptions();
					addSliderEventListeners();
					addCardHeaderEventListeners();
					$("#results").removeClass("d-none");
					$('#loading-screen').addClass('d-none');	
					$(".dataTables_scrollHeadInner").css({"width":"4000px"});
					$(".table ").css({"width":"4000px"});

					
					
					//updateHits();
					
					
					openNav("resultssidenav","40%");
					headers = document.querySelectorAll("thead");
					for(var h of headers){
						h.classList.add("text-white");
						h.classList.add("compact");
					}
					tables = document.querySelectorAll("table")
					for(var t of tables){
						t.classList.add("squished");
					}
					
					searches = document.querySelectorAll("input.form-control-sm")
					for(var s of searches){
						s.setAttribute("style","height:14px;padding: 0px 0px;font-size: 14px;min-height:16px;line-height: .75;")
					}
					filters = document.querySelectorAll(".dataTables_filter")
					for(var f of filters){
						f.setAttribute("style","font-size:14px; padding: 0px");
						f.classList.add("text-white");
					}
					copies = document.querySelectorAll(".buttons-copy")
					for(var c of copies){
						c.setAttribute("style","font-size:14px; padding: 0px");
						
					}
					
					//default open first table					
					var card_id = $( ".lablab:first" ).attr('id');
					var slider_id = card_id.replace("headerbutton","slider");
					var output_id = card_id.replace("headerbutton","slider_output");
					var table_id = '#table_' + card_id.replace("_headerbutton","");	
					var body_id = card_id.replace("headerbutton","body");
					
					
					$(table_id).css('width', '100%');
					$("#"+slider_id).val(10);
					document.getElementById(output_id).innerHTML = renderSliderValueString(10);
					
					$('#'+body_id).collapse()
					
//					$("#"+card_id).removeClass("collapsed");
//					$("#"+card_id).attr("aria-expanded",true);
//					$("#"+body_id).addClass("show");
					
					
					document.getElementById("colorby").value = "none";
					recolorAllNodes();
					setLegendView();
					location.href = '#top'
						
					$("[id=overlappinggenespopover]").popover({
				        html : true,
				        trigger: 'focus',
				        content: function() {
				            var content = $(this).attr("data-popover-content");
				            return $(content).children(".popover-body").html();
				        }
				    });
					
					$("#barchartpopover").popover({
						html: true,
						trigger: 'focus',
						content: `<button type="button" class="popover-close close">
						        <span class="mbri-close mbr-iconfont mbr-iconfont-btn display-7"></span>
						        </button> <canvas id="meanrankbarChart" width="400" height="400"></canvas>`,
						}).on('shown.bs.popover', function() {
							generateStackedBarChart();
		
						});
					
					$("#pills-tab").removeClass("d-none");
				
				
					
					  // Get matrix
				    matrix_str = buildClustergrammerMatrix(chea3Results);
				    

				    // Send to Clustergrammer
				    generateClustergram(matrix_str);
				    


				}//end success function
			}); // end AJAX call

		}
	}); 
});








