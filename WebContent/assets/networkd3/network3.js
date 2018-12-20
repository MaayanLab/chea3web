var radius = 4;
var net_width;

var net_height;
var g;
var max = 100;
function circleColour(){
	return("lightgray");

}


function linkColour(d){
	return("black");
}



function drawNetwork(){
	d3.json("assets/networkd3/wgcna_gtex_annotated.json", function(json){

		var networkDiv = document.getElementById("tfnet");
		
		net_width = networkDiv.clientWidth;
		net_height = networkDiv.clientHeight;
		
		var network_svg = d3.select("#tfnet").append("svg");
		network_svg.attr("viewBox","0,0,${net_width},${net_height}");
		network_svg.attr("preserveAspectRatio","xMidYMid slice")

		network_svg
		.attr("width", net_width)
		.attr("height", net_height);


		var nodes = json;
		var max_x = Math.max.apply(Math, nodes.map(function(o) { return o.x; }))
		var max_y = Math.max.apply(Math, nodes.map(function(o) { return o.y; }))
		var min_x = Math.min.apply(Math, nodes.map(function(o) { return o.x; }))
		var min_y = Math.min.apply(Math, nodes.map(function(o) { return o.y; }))
		
		
		//nodes = adjustCoordinates(nodes);
		
		
		

			// add encompassing group for the zoom
			g = network_svg.append("g")
			.attr("class", "everything");
			
			
			var xScale = d3.scaleLinear()
			  .domain([min_x, max_x])
			  .range([net_width*0.05, net_width*.95]);
			
			var yScale = d3.scaleLinear()
			  .domain([min_y, max_y])
			  .range([net_height*0.05, net_height*0.95]);
			
			var xUnscale = d3.scaleLinear()
				.domain([net_width*0.05, net_width*0.95])
				.range([min_x,max_x]);
				
			var yUnscale = d3.scaleLinear()
				.domain([net_height*0.05, net_width*0.95])
				.range([min_y,max_y]);


// draw circles for the nodes
			var node = g.append("g")
			.selectAll("circle")
			.data(nodes)
			.enter()
			.append("circle")
			.attr("r", radius)
			.attr("id",function(d) {return d.name;})
			.attr("cx",function(d) {return xScale(d.x)})
			.attr("cy",function(d) {return yScale(d.y)})
			.attr("fill", function(d){return d.General_tissue_color})
			.attr("WGCNA_hex", function(d){return d.WGCNA_hex})
			.attr("General_tissue_color", function(d){return d.General_tissue_color})
			.attr("Specific_tissue_color", function(d){return d.Specific_tissue_color});
//			.call(d3.drag()
//				.on("start",drag_start)
//				.on("drag",drag_drag)
//				.on("end",drag_end));
//			
			
			function zoom_actions(){
			// create new scale objects based on event
			    var new_xScale = d3.event.transform.rescaleX(xScale);
			    var new_yScale = d3.event.transform.rescaleY(yScale);
			// update axes

			    node.data(json)
			     .attr('cx', function(d) {return new_xScale(d.x)})
			     .attr('cy', function(d) {return new_yScale(d.y)});
			    
//			    label.data(json)
//			     .attr('x', function(d) {return new_xScale(d.x)})
//			     .attr('y', function(d) {return new_yScale(d.y)-2});
			    
			}
			
			var zoom_handler = d3.zoom()
			.scaleExtent([0.5,40])
			.extent([[0,0],[net_width, net_height]])
			.on("zoom", zoom_actions);
			
			
			

			zoom_handler(network_svg);


// add text for the nodes
//			var label = g.append("g")
//			.attr("class","label")
//			.selectAll("text")
//			.data(nodes)
//			.enter()
//			.append("text")
//			.attr("text-anchor","middle")
//			.text(function(d) { return d.name; })
//			.attr("x",function(d){return xScale(d.x);})
//			.attr("y",function(d){return yScale(d.y)-2;})
//			.attr("id",function(d) {return d.name + "_label";});
			
			

//			function adjustCoordinates(nodes){
//				var max_x = Math.max.apply(Math, nodes.map(function(o) { return o.x; }))
//				var max_y = Math.max.apply(Math, nodes.map(function(o) { return o.y; }))
//				var min_x = Math.min.apply(Math, nodes.map(function(o) { return o.x; }))
//				var min_y = Math.min.apply(Math, nodes.map(function(o) { return o.y; }))
//				
//				for(var i = 0; i < nodes.length; i++){
//					nodes[i].x = (nodes[i].x-min_x*1.05)*net_width*.9/(2*max_x*1.1)
//					nodes[i].y = (nodes[i].y-min_y*1.05)*net_height*.9/(2*max_y*1.1)
//				}
//				
//				return nodes;
//				
//				
//			}
//				
			


			
			// Drag functions
// d is the node
//			function drag_start(d) {
//				d3.select(this).raise().classed("active", true);
//				
//
//			}
//
//// make sure you can't drag the circle outside the box
//			function drag_drag(d) {
//				
//				d.x = d3.event.x, d.y = d3.event.y;
//			    d3.select(this).attr("cx", d.x).attr("cy", d.y);
////			    label.filter(function(l) {return l.name === d.name; }).attr("x",d.x).attr("y",d.y-8);
//			    
//			}
//
//			function drag_end(d) {
//				d3.select(this).classed("active", false);
//			}

	});// end d3.json
}

drawNetwork()




