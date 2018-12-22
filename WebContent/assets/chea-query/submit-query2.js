

var sliderClassName = 'slider';
var defaultNodeColor = 'gray';
var chea3Results;



function sliderChange(event) {
	// change slider output text
	var outputId = `${event.target.id}_output`;
	document.getElementById(outputId).innerHTML = renderSliderValueString(event.target.value);
	recolorAllNodes();
}

function getColor(id) {
	return ($("#" + id).spectrum('get').toHexString())
}

function defaultNodeColorAll(){

	var colorby_val = document.getElementById("colorby").value;
	nodes = document.querySelectorAll("circle");
	if(colorby_val == "Tissue (general)"){
		for (var n of nodes) {
			n.setAttribute("fill",n.getAttribute("General_tissue_color"));
			n.setAttribute("stroke-width","0")
		}
	}else if(colorby_val == "Tissue (specific)"){
		for (var n of nodes) {
			n.setAttribute("fill",n.getAttribute("Specific_tissue_color"));
			n.setAttribute("stroke-width","0")
		}
	}else if(colorby_val == "WGCNA modules"){
		for (var n of nodes) {
			n.setAttribute("fill",n.getAttribute("WGCNA_hex"));
			n.setAttribute("stroke-width","0")
		}
	}else{
		// reset to gray
		for (var n of nodes) {
			n.setAttribute("fill", defaultNodeColor);
			n.setAttribute("stroke-width","0")
		}
	}

}



function recolorAllNodes() {
	defaultNodeColorAll()

	// loop through sliders and colorpickers
	sliders = document.querySelectorAll(".slider");
	// if sliders are defined
	if(sliders.length>0){
		for (var s of sliders) {
			var libraryName = s.id.replace('_slider', '');
			var colorpicker_id = libraryName + "_colorpicker";
			console.log(colorpicker_id)
			var set1Values = chea3Results[libraryName].map(function (transcriptionFactors) {

				return transcriptionFactors.TF;

			});
			var set1ValuesSliderSubset = set1Values.splice(0, s.value);
			for (var tf of set1ValuesSliderSubset) {
				console.log(tf)
				node = document.getElementById(tf);

				if (node) {
					node.setAttribute("stroke", getColor(colorpicker_id));
					node.setAttribute("stroke-width", radius*2.5)
				}
			}

		}
	}

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

function renderColorPicker(libraryName) {
	var colorpicker_id = libraryName + "_colorpicker";
	$("#" + colorpicker_id)
	.on('change', function () {
		recolorAllNodes();
	})
	.spectrum({
		color: "#4dca4f"
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
	return `    <div class="card-header" style="padding:0" role="tab" id="${libraryName}_header">
	<a role="button" class="collapsed panel-title text-white"
	data-toggle="collapse" data-parent="#accordion" data-core=""
	href="#${libraryName}_body" aria-expanded="false"
	aria-controls="collapse2">
	<h4 class="mbr-fonts-style display-7" style="margin-bottom:0">
	<span class="sign mbr-iconfont mbri-down inactive"></span>
	<span class="color-emphasis-1" style = "font-size:100%">${libraryTitle}</span>
	<span data-tooltip="library information text will go here" data-tooltip_position="right">
	<span class="mbri-info mbr-iconfont mbr-iconfont-btn"></span>
	</h4>
	</a>

	</div>

	`
}

function renderCardBody(libraryName) {

	return `<div id="${libraryName}_body" class="panel-collapse noScroll collapse" style="width:100%;padding:7px"
	role="tabpanel" aria-labelledby="${libraryName}_header">
	<div class="panel-body">`
	+ renderCaption(libraryName) + renderTable(libraryName)+

	`</div>
	</div>`

}

function renderDownloadResultsBtn(){
	return `<a id = "downloadJSON" class="btn btn-sm btn-primary display-4" style="padding:0"><span
	class="mbri-save mbr-iconfont mbr-iconfont-btn" ></span>Download All Results as JSON</a>`
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

//function renderResultsSideNav(){
//	$(function() {
//		// initialize dialog
//		$( "#resultsdialog" ).dialog({
////			appendTo: "#dialogoverlay",
//			title: "Results by Library",
//			beforeClose: function(event, ui) {
//				alert("Are you sure you want to close? You will lose your results. Note you can download a json of all of your results here.")
//			},
//			close: function(event,ui){
//				
//
//
//
//			}
//		});
//		$("[aria-describedby='resultsdialog']").css(
//				{	"position":"relative",
//					"width":"80%",
//					"height":"50%",
//					"left":"0px",
//					"top":"20px",
//					"overflow":"scroll"
//				});
//	} );
//
//
//}

function newQuery(){
	$("#results").addClass("d-none");
	$("#results").html(`
				<div id="resultssidenav" class="sidenavR">
					<a href="javascript:void(0)" class="closebtn"
						onclick="closeNav('resultssidenav')">&times;</a>
				</div>
				<div id="expandresults" style="position: absolute; left: 5%">
					<span style="font-size: 15px; cursor: pointer"
						onclick="openNav('resultssidenav','40%')">&#9776; Back to
						Results</span>
					<button type="button" class="btn btn-primary" id="newquery"
						type="submit" onclick="newQuery()" style="padding: .5rem .5rem">New
						Query</button>
				</div>on>`);
	
	defaultNodeColorAll();
	$('#translucent-net').removeClass("d-none");
	$('#tfea-submission').removeClass("d-none");
	$('#tfea-title').removeClass("d-none");
	var gl = document.getElementById("genelist");
	gl.value = "";
	gl.placeholder = "Submit gene list with one gene per line."
	chea3Results = null;
	
	
	// reset text box
	
}



function genesetSubmission(){}


$(document).ready(function () {
	
	
	
	$('#example-genelist').on('click', function () {
		var gl = document.getElementById("genelist");
		gl.placeholder = "";
		jQuery.get('assets/chea-query/example_genelist.txt', function (data) {
			gl.value = data;
		});

	});
	
//	renderResultsDialog();
	
	

	$('#submit-genelist').on('click', function (evt) {

		var geneset = document.getElementById("genelist").value.split(/\n/);
		// generate url
		var enrich_url = host + "chea3-dev/api/enrich/";
		enrich_url = enrich_url + geneset.join();
		console.log(enrich_url);



		if (validateGeneSet(geneset)) {

			$('#loading-screen').removeClass('d-none');
//			//remove tools
//			document.getElementById("tfea-title").remove();
			$('#translucent-net').addClass("d-none");
			$('#tfea-submission').addClass("d-none");
			$('#tfea-title').addClass("d-none");
//			document.getElementById("tfea-submission").remove();




			// send gene set to java servlet
			$.ajax({
				url : enrich_url,
				success : function(results) {
					
					
					results = JSON.parse(results);
					chea3Results = results;
					var lib_names = Object.keys(results);
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
						renderColorPicker(lib_names[i]);
						var lib_results = results[lib_names[i]];
						var column_names = Object.keys(lib_results[1]);
						if(lib_names[i].includes("Integrated")){
							$(`#table_${lib_names[i]}`).DataTable({
								data: lib_results.slice(0,100),
								aoColumns: [
									{mData: "Query Name", sTitle: "Query Name"},
									{mData: "Rank", sTitle: "Rank"},
									{mData: "TF",sTitle: "TF"},
									{mData: "Score",sTitle: "Score"},
									{mData: "Library", sTitle: "Library"}],
									scrollY: "200px",
									scrollX: "500px",
									sScrollX: "500px",
									scrollCollapse: true,
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
						}else{
							$(`#table_${lib_names[i]}`).DataTable({
								data: lib_results.slice(0,100),
								aoColumns: [
									{mData: "Query Name", sTitle: "Query Name"},
									{mData: "Rank", sTitle: "Rank"},
									{mData: "Scaled Rank", sTitle: "Scaled Rank"},
									{mData: "TF",sTitle: "TF"},
									{mData: "Set name", sTitle: "Set name"},
									{mData: "Set length", sTitle: "Set size"},
									{mData: "Intersect", sTitle: "Intersection"},
									{mData: "FET p-value", sTitle: "FET p-value"},
									{mData: "Odds Ratio", sTitle: "Odds Ratio"}],
									scrollY: "200px",
									scrollX: "4000px",
									sScrollX: "4000px",
									scrollCollapse: true,
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
					addSliderEventListeners();
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
					
					
					





				}
			}); // end AJAX call

		}
	}); 
});





//var request = ocpu.call("queryCheaWeb", {
//geneset: geneset,
//set_name: "usergeneset"
//},
//function (session) {
//session.getObject(function (data) {
//chea3Results = JSON.parse(data);
//var lib_names = Object.keys(chea3Results);
//var results_div = document.getElementById("query-results");

//var captionAndTableMarkup = lib_names.reduce(function (accumlator,
//libraryName) {
//accumlator += renderCaption(libraryName)
//accumlator += renderTable(libraryName);

//return accumlator;
//}, '');

//results_div.innerHTML += captionAndTableMarkup;

//for (var i = 0; i < lib_names.length; i++) {

//renderColorPicker(lib_names[i]);

//var lib_results = chea3Results[lib_names[i]];

//$(`#table_${lib_names[i]}`).DataTable({
//data: lib_results,
//aoColumns: [
//{mData: "rank", sTitle: "Rank"},
//{mData: "set1", sTitle: "TF Gene Set", sWidth: "20em"},
//{mData: "intersect", sTitle: "Intersection"},
//{mData: "FET p-value", sTitle: "FET p-value"}],
//scrollY: "100px",
//scrollX: true,
//scrollCollapse: true,
//paging: false,

//fixedColumns: true,
//dom: "Bfrtip",
//buttons: [
//$.extend(true, {}, buttonCommon, {
//extend: 'copyHtml5'
//}),
//$.extend(true, {}, buttonCommon, {
//extend: 'excelHtml5'
//}),
//$.extend(true, {}, buttonCommon, {
//extend: 'pdfHtml5'
//}),
//$.extend(true, {}, buttonCommon, {
//extend: 'colvis'
//})
//]
//});
//$("div.toolbar").html('<b>Custom tool bar! Text/images etc.</b>');


//}

//addSliderEventListeners();


//$('#loading-screen').addClass('d-none');


//});


//});





////FAKE RESULTS -- USE FOR TESTING
//setTimeout(function () {
//$('#loading-screen').addClass('d-none');
////remove tools
//document.getElementById("tfea-title").remove();
//document.getElementById('translucent-net').remove();
//document.getElementById("tfea-submission").remove();
////load fake results
//jQuery.get('assets/chea-query/example_results.json', function (results) {
//chea3Results = results;
//var lib_names = Object.keys(results);
//var results_div = document.getElementById("query-results");
//var captionAndTableMarkup = lib_names.reduce(function (accumlator,
//libraryName) {
//accumlator += renderCaption(libraryName)
//accumlator += renderTable(libraryName);
//return accumlator;
//}, '');
//results_div.innerHTML += captionAndTableMarkup;
//for (i = 0; i < lib_names.length; i++) {
//renderColorPicker(lib_names[i]);
//var lib_results = results[lib_names[i]];
//var column_names = Object.keys(lib_results[1])
//$(`#table_${lib_names[i]}`).DataTable({
//data: lib_results,
//aoColumns: [
//{mData: "set1", sTitle: "TF Gene Set", sWidth: "20em"},
//{mData: "intersect", sTitle: "Intersection"},
//{mData: "FET p-value", sTitle: "FET p-value"}],
//scrollY: "100px",
//scrollX: false,
//scrollCollapse: true,
//paging: false,
//fixedColumns: true,
//dom: "Bfrtip",
//buttons: [
//$.extend(true, {}, buttonCommon, {
//extend: 'copyHtml5'
//}),
//$.extend(true, {}, buttonCommon, {
//extend: 'excelHtml5'
//}),
//$.extend(true, {}, buttonCommon, {
//extend: 'pdfHtml5'
//}),
//$.extend(true, {}, buttonCommon, {
//extend: 'colvis'
//})
//]
//});
//$("div.toolbar").html('<b>Custom tool bar! Text/images etc.</b>');
//}
//addSliderEventListeners();
//});


//}, 500);






