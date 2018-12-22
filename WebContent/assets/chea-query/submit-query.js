
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
	<span id="${captionId}_output" style="font-weight:lighter;font-size:small,font-style:italic">
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
	<table class="display" style="width:4000px" id="table_${libraryName}"></table>
	`
}

function renderCardHeader(libraryName){
	
	var libraryTitle = libraryName.replace("--"," ");
	alert(libraryTitle);
	
	return `    <div class="card-header" style="padding:0" role="tab" id="${libraryName}_header">
	<a role="button" class="collapsed panel-title text-black"
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

	return `<div id="${libraryName}_body" class="panel-collapse noScroll collapse"
	role="tabpanel" aria-labelledby="${libraryName}_header">
	<div class="panel-body">`
	+ renderCaption(libraryName) + renderTable(libraryName)+

	`</div>
	</div>`

}

function renderDownloadResultsBtn(){
	return `<a id = "downloadJSON" class="btn btn-sm btn-primary display-4"><span
	class="mbri-save mbr-iconfont mbr-iconfont-btn"></span>Download All Results as JSON</a>`
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

function renderResultsDialog(){
	$(function() {
		// initialize dialog
		$( "#resultsdialog" ).dialog({
			appendTo: "#dialogoverlay",
			title: "Results by Library",
			beforeClose: function(event, ui) {
				alert("Are you sure you want to close? You will lose your results. Note you can download a json of all of your results here.")
			},
			close: function(event,ui){
				$("#dialogoverlay").html(`<div id="resultsdialog" class="myDialogClass">
				<div id="tablecontents" style="overflow:scroll;height:100%;width:100%"></div></div>`);
				$("#dialogoverlay").addClass("d-none");
				renderResultsDialog();
				// reset tf network to gray
				defaultNodeColorAll();
				// display overlay
				$('#translucent-net').removeClass("d-none");
				chea3Results = null;
				// reset text box



			}
		});
		$("[aria-describedby='resultsdialog']").css(
				{	"position":"relative",
					"width":"80%",
					"height":"50%",
					"left":"0px",
					"top":"20px",
					"overflow":"scroll"
				});
	} );


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
	renderResultsDialog();
	
	

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
//			document.getElementById("tfea-submission").remove();




			// send gene set to java servlet
			$.ajax({
				url : enrich_url,
				success : function(results) {
					results = JSON.parse(results);
					chea3Results = results;
					var lib_names = Object.keys(results);
					var results_div = document.getElementById("resultsdialog");

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
								data: lib_results,
								aoColumns: [
									{mData: "Query Name", sTitle: "Query Name"},
									{mData: "Rank", sTitle: "Rank"},
									{mData: "TF",sTitle: "TF"},
									{mData: "Score",sTitle: "Score"},
									{mData: "Library", sTitle: "Library"}],
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
										$.extend(true, {}, buttonCommon, {
											extend: 'excelHtml5'
										}),
										$.extend(true, {}, buttonCommon, {
											extend: 'pdfHtml5'
										}),
										$.extend(true, {}, buttonCommon, {
											extend: 'colvis'
										})
										]
							});
						}else{
							$(`#table_${lib_names[i]}`).DataTable({
								data: lib_results,
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
										$.extend(true, {}, buttonCommon, {
											extend: 'excelHtml5'
										}),
										$.extend(true, {}, buttonCommon, {
											extend: 'pdfHtml5'
										}),
										$.extend(true, {}, buttonCommon, {
											extend: 'colvis'
										})
										]
							});

						}



						$('#'+lib_names[i] + "_body").on('shown.bs.collapse', function () {
							$($.fn.dataTable.tables(true)).DataTable()
							.columns.adjust();
						})

					}
					addSliderEventListeners();
					$("#dialogoverlay").removeClass("d-none");
					$('#loading-screen').addClass('d-none');	
					$(".dataTables_scrollHeadInner").css({"width":"4000px"});
					$(".table ").css({"width":"4000px"});
					$('#GTEx_body').on('shown.bs.collapse', function () {
						console.log("hi");
					})
					updateHits();





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






