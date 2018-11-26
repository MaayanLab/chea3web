var radius = 5;
var net_width;
var net_height;
var g;
function circleColour(){
	return("gray");

}


function linkColour(d){
	return("black");
}



function drawNetwork(){
	d3.json("assets/networkd3/tf10perc.json", function(json){





		var networkDiv = document.getElementById("tfnet");
		
		net_width = networkDiv.clientWidth;
		net_height = networkDiv.clientHeight;
		
		var network_svg = d3.select("#tfnet").append("svg");
		network_svg.attr("viewBox","0,0,${net_width},${net_height}");
		network_svg.attr("preserveAspectRatio","xMidYMid slice")

		network_svg
		.attr("width", net_width)
		.attr("height", net_height);


		var nodes = json.nodes_dat;
		var links = json.links_dat;



		var meter = document.querySelector("#progress");
		var loading = document.querySelector("#loadingnetwork")
		var worker = new Worker("assets/networkd3/networker.js");

		worker.postMessage({
			nodes: nodes,
			links: links,
			net_width: net_width,
			net_height: net_height,
			radius: radius
		});

		worker.onmessage = function(event) {
			switch (event.data.type) {
			case "tick": return ticked(event.data);
			case "end": return ended(event.data);
			}
		};

		function ticked(data) {
			var progress = data.progress;

			meter.style.width = 100 * progress + "%";
		}

		function ended(data) {
	
			
			var nodes = data.nodes;
			var links = data.links;

			meter.style.display = "none";
			loading.style.display = "none";

			// add encompassing group for the zoom
			g = network_svg.append("g")
			.attr("class", "everything");

// draw lines for the links
			var link = g.append("g")
			.attr("class", "links")
			.selectAll("line")
			.data(links)
			.enter()
			.append("line")
			.attr("stroke-width", 1.0)
			.style("stroke", linkColour)  
			.attr("x1",function(d){return d.source.x;})
			.attr("y1",function(d){return d.source.y;})
			.attr("x2",function(d){return d.target.x;})
			.attr("y2",function(d){return d.target.y;});

// draw circles for the nodes
			var node = g.append("g")
			.attr("class", "nodes") 
			.selectAll("circle")
			.data(nodes)
			.enter()
			.append("circle")
			.attr("r", radius)
			.attr("id",function(d) {return d.name;})
			.attr("cx",function(d) {return d.x;})
			.attr("cy",function(d) {return d.y;})
			.attr("fill", circleColour)
			.call(d3.drag()
				.on("start",drag_start)
				.on("drag",drag_drag)
				.on("end",drag_end));
			
			 
			


// add text for the nodes
			var label = g.append("g")
			.attr("class","label")
			.selectAll("text")
			.data(nodes)
			.enter()
			.append("text")
			.attr("text-anchor","middle")
			.text(function(d) { return d.name; })
			.attr("x",function(d){return d.x;})
			.attr("y",function(d){return d.y-8;})
			.attr("id",function(d) {return d.name + "_label";});
			
			
// //add drag capabilities
// var drag_handler = d3.drag()
// .on("start", drag_start)
// .on("drag", drag_drag)
// .on("end", drag_end);
//
// drag_handler(node);
// drag_handler(label);


// add zoom capabilities
			var zoom_handler = d3.zoom()
			.on("zoom", zoom_actions);

			zoom_handler(network_svg); 
			
			// Drag functions
// d is the node
			function drag_start(d) {
				d3.select(this).raise().classed("active", true);
				

			}

// make sure you can't drag the circle outside the box
			function drag_drag(d) {
				
				d.x = d3.event.x, d.y = d3.event.y;
			    d3.select(this).attr("cx", d.x).attr("cy", d.y);
			    link.filter(function(l) { return l.source === d; }).attr("x1", d.x).attr("y1", d.y);
			    link.filter(function(l) { return l.target === d; }).attr("x2", d.x).attr("y2", d.y);
			    label.filter(function(l) {return l.name === d.name; }).attr("x",d.x).attr("y",d.y-8);
			    
			}

			function drag_end(d) {
				d3.select(this).classed("active", false);
			}

// Zoom functions
			function zoom_actions(){
				g.attr("transform", d3.event.transform);
			}
			
			var zoom = d3
			.zoom()
			.scaleExtent([1/4, 4])
			.on('zoom.zoom', function () {
				console.trace("zoom", d3.event.translate, d3.event.scale);
				g.attr('transform',d3.event.transform);
			});
			
			function zoomFit(paddingPercent, transitionDuration) {
				var bounds = g.node().getBBox();
				var parent = g.node().parentElement;
				var fullWidth = parent.clientWidth,
				fullHeight = parent.clientHeight;
				var width = bounds.width,
				height = bounds.height;
				var midX = bounds.x + width / 2,
				    midY = bounds.y + height / 2;
				if (width == 0 || height == 0) return; // nothing to fit
				var scale = (paddingPercent || 0.75) / Math.max(width / fullWidth, height / fullHeight);
				var translate = [fullWidth / 2 - scale * midX, fullHeight / 2 - scale * midY];

				console.trace("zoomFit", translate, scale);
				
				var transform = d3.zoomIdentity
			    	.translate(translate[0], translate[1])
			    	.scale(scale);

				g
			    	.transition()
			    	.duration(transitionDuration || 0) // milliseconds
			    	.call(zoom.transform, transform);
			}
			
			zoomFit(.95,10);

			
			
		}//end function "ended"
		


	});// end d3.json
}

drawNetwork()




