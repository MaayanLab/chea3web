var radius = 6;
var net_width;
var net_height;
var g;
var max = 100;
var zm;
var global_nodes;
var global_labels;

function whichNetwork(){
	var net = document.getElementById("whichnetwork").value;
	if(net == "GTEx TF Network"){
		return "gtex";
	}else if(net == "TCGA TF Network"){
		return("tcga");
	}else if(net == "ARCHS4 TF Network"){
		return("archs4");
	}else{
		return null;
	}	
}

function changeNetwork(){
	var net_svg = document.getElementById("net_svg");
	if (net_svg != null) {
		deleteNetwork(net_svg);}
		zm = 1;
		var netview = whichNetwork()
		if(netview == "gtex"){
			setGTExColorByOptions();
			drawNetwork();
			setGTExLegendView();
			//recolorAllNodes();
			$("#gtextablelink").removeClass("d-none")
			
			
		}else if(netview == "archs4"){
			setARCHS4ColorByOptions();
			drawARCHS4Network();
			setARCHS4LegendView();	
			//recolorAllNodes();
			$("#gtextablelink").addClass("d-none")
			
			
		}else if(netview== "tcga"){
			setTCGAColorByOptions();
			drawTCGANetwork();
			setTCGALegendView();
			$("#gtextablelink").addClass("d-none")
			//recolorAllNodes();
		}
	
}

function requestFullScreen(element_id) {
	var element = document.getElementById(element_id);
	// Supports most browsers and their versions.
	if (element.requestFullScreen) {
		  element.requestFullScreen();
		} else if (element.mozRequestFullScreen) {
		  element.mozRequestFullScreen();
		} else if (element.webkitRequestFullScreen) {
		  element.webkitRequestFullScreen();
		}
}

function setTCGAColorByOptions(){
	$("#colorby").html(`<select class="form-control" id="colorby"
						onchange="recolorAllNodes();setTCGALegendView()">
						<option>Tumor</option>
						<option>WGCNA modules</option>
						<option>none</option>
					</select>`)
	
}

function setGTExColorByOptions(){
		$("#colorby").html(`<select class="form-control" id="colorby"
						onchange="recolorAllNodes();setGTExLegendView()">
						<option>Tissue (general)</option>
						<option>Tissue (specific)</option>
						<option>GO Enrichment</option>
						<option>WGCNA modules</option>
						<option>none</option>
					</select>`)
}

function setARCHS4ColorByOptions(){
	$("#colorby").html(`<select class="form-control" id="colorby"
					onchange="recolorAllNodes();setARCHS4LegendView()">
					<option>Tissue</option>
					<option>WGCNA modules</option>
					<option>none</option>
				</select>`)
}

function saveSvg(svg_id, name) {
	var svgEl = document.getElementById(svg_id);
	svgEl.setAttribute("xmlns", "http://www.w3.org/2000/svg");
	var svgData = svgEl.outerHTML;
	var preface = '<?xml version="1.0" standalone="no"?>\r\n';
	var svgBlob = new Blob([preface, svgData], {type:"image/svg+xml;charset=utf-8"});
	var svgUrl = URL.createObjectURL(svgBlob);
	var downloadLink = document.createElement("a");
	downloadLink.href = svgUrl;
	downloadLink.download = name;
	document.body.appendChild(downloadLink);
	downloadLink.click();
	document.body.removeChild(downloadLink);
}

function setLabelView(){
	var labelview = getLabelView();
	if(labelview == "auto"){
		if(zm >= 2){
			global_labels.style("opacity",1);
		}else{
			global_labels.style("opacity",0);
		}
	}else if(labelview == "always"){
		global_labels.style("opacity",1);
	}else{
		global_labels.style("opacity",0);
	}

}

function circleColour() {
	return ("#d3d3d3");

}

function openNav(nav, width) {
	$('#'+nav).removeClass('closeNav')
	$('#'+nav).addClass('openNav')
}

function closeNav(nav) {
	$('#'+nav).removeClass('openNav')
	$('#'+nav).addClass('closeNav')
}

function getLabelView(){
	return(document.getElementById("labelview").value)
}

function isLegendChecked(){
	var chk = document.getElementById("legend_checkbox").checked;
	return(chk);
}

function setGTExLegendView(){
	var colby = document.getElementById("colorby").value;
	var gen_hidden = $("#general_tissue_legend").hasClass("hidden");
	var spec_hidden = $("#specific_tissue_legend").hasClass("hidden");
	var go_hidden = $("#GO_legend").hasClass("hidden");
	
	if(isLegendChecked()){
		if(colby == "Tissue (general)"){
			if(gen_hidden){
				$("#general_tissue_legend").removeClass("hidden");
			} 
			
			if(!spec_hidden){
				$("#specific_tissue_legend").addClass("hidden");
			}
			if(!go_hidden){
				$("#GO_legend").addClass("hidden");
			}
			
			
		

		} else if(colby == "Tissue (specific)"){
			if(spec_hidden){
				$("#specific_tissue_legend").removeClass("hidden");

			}
			if(!gen_hidden){
				$("#general_tissue_legend").addClass("hidden");
			}
			if(!go_hidden){
				$("#GO_legend").addClass("hidden");
			}
		} else if(colby == "GO Enrichment"){
			console.log("GO")
			if(go_hidden){
				$("#GO_legend").removeClass("hidden");
			}
			if(!gen_hidden){
				$("#general_tissue_legend").addClass("hidden");
			}
			if(!spec_hidden){
				$("#specific_tissue_legend").addClass("hidden");
			}
			
		}
		else{
			if(!gen_hidden){
				$("#general_tissue_legend").addClass("hidden");

			}

			if(!spec_hidden){
				$("#specific_tissue_legend").addClass("hidden");
			}	
			if(!go_hidden){
				$("#GO_legend").addClass("hidden");
			}
		}
	}else{
		if(!gen_hidden){
			$("#general_tissue_legend").addClass("hidden");

		}

		if(!spec_hidden){
			$("#specific_tissue_legend").addClass("hidden");
		}
		if(!go_hidden){
			$("#GO_legend").addClass("hidden");
		}
	}	
}

function setTCGALegendView(){
	var colby = document.getElementById("colorby").value;
	var tumor_hidden = $("#Tumor_legend").hasClass("hidden");
		
	if(isLegendChecked()){
		if(colby == "Tumor"){
			if(tumor_hidden){
				$("#Tumor_legend").removeClass("hidden");
			} 			
		}
		else{
			if(!tumor_hidden){
				$("#Tumor_legend").addClass("hidden");
			}
		}
	}else{
		if(!tumor_hidden){
			$("#Tumor_legend").addClass("hidden");
		}
	}	
}

function setARCHS4LegendView(){
	var colby = document.getElementById("colorby").value;
	var tumor_hidden = $("#Tissue_legend").hasClass("hidden");
		
	if(isLegendChecked()){
		if(colby == "Tissue"){
			if(tumor_hidden){
				$("#Tissue_legend").removeClass("hidden");
			} 			
		}
		else{
			if(!tumor_hidden){
				$("#Tissue_legend").addClass("hidden");
			}
		}
	}else{
		if(!tumor_hidden){
			$("#Tissue_legend").addClass("hidden");
		}
	}	
}

function setLegendView(){
	net = whichNetwork()
	if(net == "gtex"){
		setGTExLegendView();
	}else if(net == "archs4"){
		setARCHS4LegendView();
	}else if(net == "tcga"){
		setTCGALegendView();
	}
}

//Define the div for the tooltip
var div = d3.select("body").append("div")	
.attr("class", "tooltip")	
.attr("id","tf_tooltip")
.style("opacity", 0);


function drawNetwork() {
	d3.json("assets/networkd3/wgcna_gtex_annotated5.json", function(net_json) {

		var networkDiv = document.getElementById("tfnet");
		net_width = networkDiv.clientWidth;
		net_height = Math.max($('#tfea-submission').height(),networkDiv.clientHeight,500);
		//console.log(net_width)
		//console.log(net_height)
		//console.log($('#tfnet').width())
		//console.log($('#tfnet').css('padding'))


		var network_svg = d3.select("#tfnet").append("svg");
		// network_svg.attr("viewBox","0,0,${net_width},${net_height}");
		network_svg.attr("preserveAspectRatio",
		"xMidYMid slice");
		network_svg.attr("id", "net_svg");

		network_svg.attr("width", net_width).attr("height",
				net_height);

		var nodes = net_json;
		var max_x = Math.max.apply(Math, nodes.map(function(o) {
			return o.x;
		}))
		var max_y = Math.max.apply(Math, nodes.map(function(o) {
			return o.y;
		}))
		var min_x = Math.min.apply(Math, nodes.map(function(o) {
			return o.x;
		}))
		var min_y = Math.min.apply(Math, nodes.map(function(o) {
			return o.y;
		}))

//		nodes = adjustCoordinates(nodes);

		// add encompassing group for the zoom
		g = network_svg.append("g").attr("class", "everything");

		var xScale = d3.scaleLinear().domain([ min_x, max_x ])
		.range([ net_width * 0.05, net_width * .95 ]);

		var yScale = d3
		.scaleLinear()
		.domain([ min_y, max_y ])
		.range([ net_height * 0.05, net_height * 0.95 ]);

		var xUnscale = d3.scaleLinear().domain(
				[ net_width * 0.05, net_width * 0.95 ]).range(
						[ min_x, max_x ]);

		var yUnscale = d3.scaleLinear().domain(
				[ net_height * 0.05, net_width * 0.95 ]).range(
						[ min_y, max_y ]);

		var colorby_val = document.getElementById("colorby").value;
		if(colorby_val == null){
			var circle_fill = "General_tissue_color"
		}else{
			var circle_fill = translateNodeColor(colorby_val);
		}
		
		// draw circles for the nodes
		var node = g
		.append("g")
		.selectAll("circle")
		.data(nodes)
		.enter()
		.append("circle")
		.attr("r", radius)
		.attr("id", function(d) {
			return d.name;
		})
		.attr("cx", function(d) {
			return xScale(d.x)
		})
		.attr("cy", function(d) {
			return yScale(d.y)
		})
		.attr(
				"fill",
				function(d) {
					if (circle_fill == "General_tissue_color") {
						return d.General_tissue_color;
					} else if (circle_fill == "Specific_tissue_color") {
						return d.Specific_tissue_color;
					} else if (circle_fill == "WGCNA_hex") {
						return d.WGCNA_hex;
					} else if (circle_fill == "GO_enrichment_color"){
						return d.GO_enrichment_color
					}
					else {
						return defaultNodeColor;
					}
				}).attr("stroke", 0).attr(
						"stroke-opacity", 0).attr(
								"WGCNA_hex", function(d) {
									return d.WGCNA_hex
								}).attr("General_tissue_color",
										function(d) {
									return d.General_tissue_color
								}).attr("Specific_tissue_color",
										function(d) {
									return d.Specific_tissue_color
								}).attr("GO_enrichment_color",
										function(d) {
									return d.GO_enrichment_color
								}).on("mouseover", function(d) {
									div.transition()		
									.duration(100)		
									.style("opacity", .9);		
									div	.html(d.name)	
									.style("left", (d3.event.pageX) + "px")		
									.style("top", (d3.event.pageY - 28) + "px");	
								})					
								.on("mouseout", function(d) {		
									div.transition()		
									.duration(2000)		
									.style("opacity", 0);	
								});

		var label = g.append("g")
		.attr("class","label")
		.selectAll("text")
		.data(nodes)
		.enter()
		.append("text")
		.attr("text-anchor","middle")
		.style("stroke-opacity",0)
		.text(function(d) { return d.name; })
		.attr("x",function(d){return xScale(d.x);})
		.attr("y",function(d){return yScale(d.y)-6;})
		.attr("id",function(d) {return d.name + "_label";})
		.style("opacity",op).on("mouseover", function(d) {
			div.transition()		
			.duration(100)		
			.style("opacity", .9);		
			div	.html(d.name)	
			.style("left", (d3.event.pageX) + "px")		
			.style("top", (d3.event.pageY - 28) + "px");	
		})					
		.on("mouseout", function(d) {		
			div.transition()		
			.duration(2000)		
			.style("opacity", 0);	
		});

		function zoom_actions() {
			// create new scale objects based on event
			var new_xScale = d3.event.transform
			.rescaleX(xScale);
			var new_yScale = d3.event.transform
			.rescaleY(yScale);
			// update axes

			node.data(net_json)
			.attr('cx', function(d) {
				return new_xScale(d.x)
			}).attr('cy', function(d) {
				return new_yScale(d.y)
			});

			label.data(net_json)
			.attr('x', function(d) {return new_xScale(d.x)})
			.attr('y', function(d) {return new_yScale(d.y)-6});

			zm = d3.event.transform.k;

			if(getLabelView() =="auto"){
				if( zm >= 2 ){
					label.style("opacity","1");

				}else{
					label.style("opacity","0");
				}
			}
		}

		var zoom_handler = d3
		.zoom()
		.scaleExtent([ 0.5, 40 ])
		.extent([ [ 0, 0 ], [ net_width, net_height ] ])
		.on("zoom", zoom_actions);



		zoom_handler(network_svg);

		var labelview = getLabelView();
		var op;
		if((labelview == "auto" & zm > 2) | (labelview == "always")){
			op = 1;
		}else{
			op = 0;
		}


		var legend = g.append("g")
		.attr("class", "legend")
		.attr("id","general_tissue_legend")
		.attr("x", net_width - 100)
		.attr("y", net_height)
		.attr("height", 100)
		.attr("width", 100)
		.attr("class","hidden")
		.style("pointer-events","none");

		legend.selectAll('g').data(general_tissue)
		.enter()
		.append('g')
		.each(function(d, i) {
			
			var g = d3.select(this);
			g.append("rect")
			.attr("x", net_width - 118)
			.attr("y", i*15 + 140)
			.attr("width", 10)
			.attr("height", 10)
			.style("stroke-width",1)
			.style("stroke","white")
			.style("fill", function(d){return d.color});
			
			g.append("text")
			.attr("x", net_width - 105)
			.attr("y", i * 15 + 150)
			.attr("height",10)
			.attr("width",100)
			.style("fill", "white")
			.style("font-size","10pt")
			.style("stroke-width","0.4em")
			.style("stroke","white")
			.text(function(d){return d.tissue});

			g.append("text")
			.attr("x", net_width - 105)
			.attr("y", i * 15 + 150)
			.attr("height",10)
			.attr("width",100)
			.style("stroke-opacity",0)
			.style("fill", "black")
			.style("font-size","10pt")
			.text(function(d){return d.tissue});
		});
				
		var legend = g.append("g")
		.attr("class", "legend")
		.attr("id","specific_tissue_legend")
		.attr("x", net_width - 100)
		.attr("y", net_height)
		.attr("height", 100)
		.attr("width", 100)
		.attr("class","hidden")
		.style("pointer-events","none");

		legend.selectAll('g').data(specific_tissue)
		.enter()
		.append('g')
		.each(function(d, i) {
			var g = d3.select(this);
			g.append("rect")
			.attr("x", net_width - 148)
			.attr("y", i*15 + 140)
			.attr("width", 10)
			.attr("height", 10)
			.style("stroke-width",1)
			.style("stroke","white")
			.style("fill", function(d){return d.color});
			
			g.append("text")
			.attr("x", net_width - 135)
			.attr("y", i * 15 + 150)
			.attr("height",10)
			.attr("width",100)
			.style("fill", "white")
			.style("font-size","10pt")
			.style("stroke-width","0.4em")
			.style("stroke","white")
			.text(function(d){return d.tissue});

			g.append("text")
			.attr("x", net_width - 135)
			.attr("y", i * 15 + 150)
			.attr("height",10)
			.attr("width",100)
			.style("stroke-opacity",0)
			.style("fill", "black")
			.style("font-size","10pt")
			.text(function(d){return d.tissue});
		});
		
		
		
		var legend = g.append("g")
		.attr("class", "legend")
		.attr("id","GO_legend")
		.attr("x", net_width - 400)
		.attr("y", net_height)
		.attr("height", 400)
		.attr("width", 400)
		.attr("class","hidden")
		.style("pointer-events","none");

		legend.selectAll('g').data(GO_enrichment)
		.enter()
		.append('g')
		.each(function(d, i) {
			var g = d3.select(this);
			g.append("rect")
			.attr("x", net_width - 248)
			.attr("y", i*15 + 50)
			.attr("width", 10)
			.attr("height", 10)
			.style("stroke-width",1)
			.style("stroke","white")
			.style("fill", function(d){return d.color});
			
			g.append("text")
			.attr("x", net_width - 235)
			.attr("y", i * 15 + 60)
			.attr("height",10)
			.attr("width",100)
			.style("fill", "white")
			.style("font-size","10pt")
			.style("stroke-width","0.4em")
			.style("stroke","white")
			.text(function(d){return d.GO_term});

			g.append("text")
			.attr("x", net_width - 235)
			.attr("y", i * 15 + 60)
			.attr("height",10)
			.attr("width",100)
			.style("stroke-opacity",0)
			.style("fill", "black")
			.style("font-size","10pt")
			.text(function(d){return d.GO_term});
		});
		
		
		var sliders = document.querySelectorAll(".slider");
		if (sliders != null) {
			highlightNodes(sliders);
		}
		global_nodes = node;
		global_labels = label;
		setLabelView();
		
		setGTExLegendView();

	});// end d3.json
}//end function drawNetwork()

function drawTCGANetwork() {
	d3.json("assets/networkd3/wgcna_tcga_annotated.json", function(net_json) {

		var networkDiv = document.getElementById("tfnet");
		net_width = networkDiv.clientWidth;
		net_height = Math.max($('#tfea-submission').height(),networkDiv.clientHeight,500);
		//console.log(net_width)
		//console.log(net_height)
		//console.log($('#tfnet').width())
		//console.log($('#tfnet').css('padding'))


		var network_svg = d3.select("#tfnet").append("svg");
		// network_svg.attr("viewBox","0,0,${net_width},${net_height}");
		network_svg.attr("preserveAspectRatio",
		"xMidYMid slice");
		network_svg.attr("id", "net_svg");

		network_svg.attr("width", net_width).attr("height",
				net_height);

		var nodes = net_json;
		var max_x = Math.max.apply(Math, nodes.map(function(o) {
			return o.x;
		}))
		var max_y = Math.max.apply(Math, nodes.map(function(o) {
			return o.y;
		}))
		var min_x = Math.min.apply(Math, nodes.map(function(o) {
			return o.x;
		}))
		var min_y = Math.min.apply(Math, nodes.map(function(o) {
			return o.y;
		}))

//		nodes = adjustCoordinates(nodes);

		// add encompassing group for the zoom
		g = network_svg.append("g").attr("class", "everything");

		var xScale = d3.scaleLinear().domain([ min_x, max_x ])
		.range([ net_width * 0.05, net_width * .95 ]);

		var yScale = d3
		.scaleLinear()
		.domain([ min_y, max_y ])
		.range([ net_height * 0.05, net_height * 0.95 ]);

		var xUnscale = d3.scaleLinear().domain(
				[ net_width * 0.05, net_width * 0.95 ]).range(
						[ min_x, max_x ]);

		var yUnscale = d3.scaleLinear().domain(
				[ net_height * 0.05, net_width * 0.95 ]).range(
						[ min_y, max_y ]);

		var colorby_val = document.getElementById("colorby").value;
		console.log(colorby_val)
		if(colorby_val == null){
			alert('null')
			var circle_fill = "Tumor Type"
		}else{
			var circle_fill = translateNodeColor(colorby_val);
		}
		



		// draw circles for the nodes
		var node = g
		.append("g")
		.selectAll("circle")
		.data(nodes)
		.enter()
		.append("circle")
		.attr("r", radius)
		.attr("id", function(d) {
			return d.name;
		})
		.attr("cx", function(d) {
			return xScale(d.x)
		})
		.attr("cy", function(d) {
			return yScale(d.y)
		})
		.attr(
				"fill",
				function(d) {
					if (circle_fill == "Tumor_color") {
						return d.Tumor_color;
					} else if (circle_fill == "WGCNA_hex") {
						return d.WGCNA_hex;
					} 
					else {
						return defaultNodeColor;
					}
				}).attr("stroke", 0).attr(
						"stroke-opacity", 0).attr(
								"WGCNA_hex", function(d) {
									return d.WGCNA_hex
								}).attr("Tumor_color",
										function(d) {
									return d.Tumor_color
								}).on("mouseover", function(d) {
									div.transition()		
									.duration(100)		
									.style("opacity", .9);		
									div	.html(d.name)	
									.style("left", (d3.event.pageX) + "px")		
									.style("top", (d3.event.pageY - 28) + "px");	
								})					
								.on("mouseout", function(d) {		
									div.transition()		
									.duration(2000)		
									.style("opacity", 0);	
								});

		var label = g.append("g")
		.attr("class","label")
		.selectAll("text")
		.data(nodes)
		.enter()
		.append("text")
		.attr("text-anchor","middle")
		.style("stroke-opacity",0)
		.text(function(d) { return d.name; })
		.attr("x",function(d){return xScale(d.x);})
		.attr("y",function(d){return yScale(d.y)-6;})
		.attr("id",function(d) {return d.name + "_label";})
		.style("opacity",op).on("mouseover", function(d) {
			div.transition()		
			.duration(100)		
			.style("opacity", .9);		
			div	.html(d.name)	
			.style("left", (d3.event.pageX) + "px")		
			.style("top", (d3.event.pageY - 28) + "px");	
		})					
		.on("mouseout", function(d) {		
			div.transition()		
			.duration(2000)		
			.style("opacity", 0);	
		});

		function zoom_actions() {
			// create new scale objects based on event
			var new_xScale = d3.event.transform
			.rescaleX(xScale);
			var new_yScale = d3.event.transform
			.rescaleY(yScale);
			// update axes

			node.data(net_json)
			.attr('cx', function(d) {
				return new_xScale(d.x)
			}).attr('cy', function(d) {
				return new_yScale(d.y)
			});

			label.data(net_json)
			.attr('x', function(d) {return new_xScale(d.x)})
			.attr('y', function(d) {return new_yScale(d.y)-6});

			zm = d3.event.transform.k;

			if(getLabelView() =="auto"){
				if( zm >= 2 ){
					label.style("opacity","1");

				}else{
					label.style("opacity","0");
				}
			}
		}

		var zoom_handler = d3
		.zoom()
		.scaleExtent([ 0.5, 40 ])
		.extent([ [ 0, 0 ], [ net_width, net_height ] ])
		.on("zoom", zoom_actions);



		zoom_handler(network_svg);

		var labelview = getLabelView();
		var op;
		if((labelview == "auto" & zm > 2) | (labelview == "always")){
			op = 1;
		}else{
			op = 0;
		}


		var legend = g.append("g")
		.attr("class", "legend")
		.attr("id","Tumor_legend")
		.attr("x", net_width - 100)
		.attr("y", net_height)
		.attr("height", 100)
		.attr("width", 100)
		.attr("class","hidden")
		.style("pointer-events","none");

		legend.selectAll('g').data(tumor)
		.enter()
		.append('g')
		.each(function(d, i) {
			
			var g = d3.select(this);
			g.append("rect")
			.attr("x", net_width - 118)
			.attr("y", i*15 + 140)
			.attr("width", 10)
			.attr("height", 10)
			.style("stroke-width",1)
			.style("stroke","white")
			.style("fill", function(d){return d.color});
			
			g.append("text")
			.attr("x", net_width - 105)
			.attr("y", i * 15 + 150)
			.attr("height",10)
			.attr("width",100)
			.style("fill", "white")
			.style("font-size","10pt")
			.style("stroke-width","0.4em")
			.style("stroke","white")
			.text(function(d){return d.Tumor});

			g.append("text")
			.attr("x", net_width - 105)
			.attr("y", i * 15 + 150)
			.attr("height",10)
			.attr("width",100)
			.style("fill", "black")
			.style("stroke-opacity",0)
			.style("font-size","10pt")
			.text(function(d){return d.Tumor});
		});
	

		var sliders = document.querySelectorAll(".slider");
		if (sliders != null) {
			highlightNodes(sliders);
		}

		global_nodes = node;
		global_labels = label;
		
		setLabelView();
		setTCGALegendView();

	});// end d3.json
}//end function drawTCGANetwork()


function drawARCHS4Network() {
	d3.json("assets/networkd3/wgcna_archs4_annotated.json", function(net_json) {

		var networkDiv = document.getElementById("tfnet");
		net_width = networkDiv.clientWidth;
		net_height = Math.max($('#tfea-submission').height(),networkDiv.clientHeight,500);
		

		var network_svg = d3.select("#tfnet").append("svg");
		// network_svg.attr("viewBox","0,0,${net_width},${net_height}");
		network_svg.attr("preserveAspectRatio",
		"xMidYMid slice");
		network_svg.attr("id", "net_svg");

		network_svg.attr("width", net_width).attr("height",
				net_height);

		var nodes = net_json;
		var max_x = Math.max.apply(Math, nodes.map(function(o) {
			return o.x;
		}))
		var max_y = Math.max.apply(Math, nodes.map(function(o) {
			return o.y;
		}))
		var min_x = Math.min.apply(Math, nodes.map(function(o) {
			return o.x;
		}))
		var min_y = Math.min.apply(Math, nodes.map(function(o) {
			return o.y;
		}))

//		nodes = adjustCoordinates(nodes);

		// add encompassing group for the zoom
		g = network_svg.append("g").attr("class", "everything");

		var xScale = d3.scaleLinear().domain([ min_x, max_x ])
		.range([ net_width * 0.05, net_width * .95 ]);

		var yScale = d3
		.scaleLinear()
		.domain([ min_y, max_y ])
		.range([ net_height * 0.05, net_height * 0.95 ]);

		var xUnscale = d3.scaleLinear().domain(
				[ net_width * 0.05, net_width * 0.95 ]).range(
						[ min_x, max_x ]);

		var yUnscale = d3.scaleLinear().domain(
				[ net_height * 0.05, net_width * 0.95 ]).range(
						[ min_y, max_y ]);

		var colorby_val = document.getElementById("colorby").value;
		console.log(colorby_val)
		var circle_fill = translateNodeColor(colorby_val);
		
		



		// draw circles for the nodes
		var node = g
		.append("g")
		.selectAll("circle")
		.data(nodes)
		.enter()
		.append("circle")
		.attr("r", radius)
		.attr("id", function(d) {
			return d.name;
		})
		.attr("cx", function(d) {
			return xScale(d.x)
		})
		.attr("cy", function(d) {
			return yScale(d.y)
		})
		.attr(
				"fill",
				function(d) {
					if (circle_fill == "Tissue_color") {
						return d.Tissue_color;
					} else if (circle_fill == "WGCNA_hex") {
						return d.WGCNA_hex;
					} 
					else {
						return defaultNodeColor;
					}
				}).attr("stroke", 0).attr(
						"stroke-opacity", 0).attr(
								"WGCNA_hex", function(d) {
									return d.WGCNA_hex
								}).attr("Tissue_color",
										function(d) {
									return d.Tissue_color
								}).on("mouseover", function(d) {
									div.transition()		
									.duration(100)		
									.style("opacity", .9);		
									div	.html(d.name)	
									.style("left", (d3.event.pageX) + "px")		
									.style("top", (d3.event.pageY - 28) + "px");	
								})					
								.on("mouseout", function(d) {		
									div.transition()		
									.duration(2000)		
									.style("opacity", 0);	
								});

		var label = g.append("g")
		.attr("class","label")
		.selectAll("text")
		.data(nodes)
		.enter()
		.append("text")
		.attr("text-anchor","middle")
		.style("stroke-opacity",0)
		.text(function(d) { return d.name; })
		.attr("x",function(d){return xScale(d.x);})
		.attr("y",function(d){return yScale(d.y)-6;})
		.attr("id",function(d) {return d.name + "_label";})
		.style("opacity",op).on("mouseover", function(d) {
			div.transition()		
			.duration(100)		
			.style("opacity", .9);		
			div	.html(d.name)	
			.style("left", (d3.event.pageX) + "px")		
			.style("top", (d3.event.pageY - 28) + "px");	
		})					
		.on("mouseout", function(d) {		
			div.transition()		
			.duration(2000)		
			.style("opacity", 0);	
		});

		function zoom_actions() {
			// create new scale objects based on event
			var new_xScale = d3.event.transform
			.rescaleX(xScale);
			var new_yScale = d3.event.transform
			.rescaleY(yScale);
			// update axes

			node.data(net_json)
			.attr('cx', function(d) {
				return new_xScale(d.x)
			}).attr('cy', function(d) {
				return new_yScale(d.y)
			});

			label.data(net_json)
			.attr('x', function(d) {return new_xScale(d.x)})
			.attr('y', function(d) {return new_yScale(d.y)-6});

			zm = d3.event.transform.k;

			if(getLabelView() =="auto"){
				if( zm >= 2 ){
					label.style("opacity","1");

				}else{
					label.style("opacity","0");
				}
			}
		}

		var zoom_handler = d3
		.zoom()
		.scaleExtent([ 0.5, 40 ])
		.extent([ [ 0, 0 ], [ net_width, net_height ] ])
		.on("zoom", zoom_actions);



		zoom_handler(network_svg);

		var labelview = getLabelView();
		var op;
		if((labelview == "auto" & zm > 2) | (labelview == "always")){
			op = 1;
		}else{
			op = 0;
		}


		var legend = g.append("g")
		.attr("class", "legend")
		.attr("id","Tissue_legend")
		.attr("x", net_width - 100)
		.attr("y", net_height)
		.attr("height", 100)
		.attr("width", 100)
		.attr("class","hidden")
		.style("pointer-events","none");

		legend.selectAll('g').data(tissue)
		.enter()
		.append('g')
		.each(function(d, i) {
			
			var g = d3.select(this);
			g.append("rect")
			.attr("x", net_width - 118)
			.attr("y", i*15 + 140)
			.attr("width", 10)
			.attr("height", 10)
			.style("stroke-width",1)
			.style("stroke","white")
			.style("fill", function(d){return d.color});
			
			g.append("text")
			.attr("x", net_width - 105)
			.attr("y", i * 15 + 150)
			.attr("height",10)
			.attr("width",100)
			.style("fill", "white")
			.style("font-size","10pt")
			.style("stroke-width","0.4em")
			.style("stroke","white")
			.text(function(d){return d.Tissue});

			g.append("text")
			.attr("x", net_width - 105)
			.attr("y", i * 15 + 150)
			.attr("height",10)
			.attr("width",100)
			.style("fill", "black")
			.style("stroke-opacity",0)
			.style("font-size","10pt")
			.text(function(d){return d.Tissue});
		});
	

		var sliders = document.querySelectorAll(".slider");
		if (sliders != null) {
			highlightNodes(sliders);
		}

		global_nodes = node;
		global_labels = label;
		
		setLabelView();
		setARCHS4LegendView();

	});// end d3.json
}//end function drawARCHS4Network()


function deleteNetwork(net_svg) {
	net_svg.remove();
}

$(document).ready(function() {
	drawNetwork();
	$('#legend_checkbox').change(function(){
		var netview = whichNetwork()
		if(netview == "gtex"){
			setGTExLegendView();
		}else if(netview == "archs4"){
			setARCHS4LegendView();
			
		}else if(netview== "tcga"){
			setTCGALegendView();
		}
	});
	
	$(window).resize(function() {
		var net_svg = document.getElementById("net_svg");
		if (net_svg != null) {
			deleteNetwork(net_svg);
			zm = 1;
			var netview = whichNetwork()
			if(netview == "gtex"){
				drawNetwork();
			}else if(netview == "archs4"){
				drawARCHS4Network();
				
			}else if(netview== "tcga"){
				drawTCGANetwork();
			}
		}

	});
});
