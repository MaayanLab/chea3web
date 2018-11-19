var networkDiv = document.getElementById("tfnet");
var network_svg = d3.select("#tfnet").append("svg");

var min_zoom = 0.1;
var max_zoom = 7;

var radius = 5

var simtest;


//Extract the width and height that was computed by CSS.
function draw_network(){


	var net_width = networkDiv.clientWidth;
	var net_height = networkDiv.clientHeight;

	network_svg
	.attr("width", net_width)
	.attr("height", net_height);

	d3.json("assets/networkd3/tf.json", function(json){
		
		//initialize node positions
		json.nodes_dat.forEach(function(d){
			d.x = (net_width * Math.random())/4;
			d.y = (net_height * Math.random())/2;
		});

//		create simulation and add nodes
		var simulation = d3.forceSimulation()
		.nodes(json.nodes_dat);
		
//		create some forces                            
		var link_force =  d3.forceLink(json.links_dat)
		.id(function(d) { return d.name; }).strength(2);   


		var charge_force = d3.forceManyBody()
		.strength(-0.5); 

		var center_force = d3.forceCenter(net_width/4, net_height/2);  

		simulation
		.force("charge_force", charge_force)
		.force("center_force", center_force)
		.force("links",link_force)
		;


//		add tick instructions: 
		simulation.on("tick", tickActions);
		simulation.velocityDecay(.36);


//		add encompassing group for the zoom 
		var g = network_svg.append("g")
		.attr("class", "everything");

//		draw lines for the links 
		var link = g.append("g")
		.attr("class", "links")
		.selectAll("line")
		.data(json.links_dat)
		.enter()
		.append("line")
		.attr("stroke-width", 0.3)
		.style("stroke", linkColour);   

//		draw circles for the nodes 
		var node = g.append("g")
		.attr("class", "nodes") 
		.selectAll("circle")
		.data(json.nodes_dat)
		.enter()
		.append("circle")
		.attr("r", radius)
		.attr("id",function(d) {return d.name;})
		.attr("fill", circleColour);
		

//		add text for the nodes
		var label = g.append("g")
		.attr("class","label")
		.selectAll("text")
		.data(json.nodes_dat)
		.enter()
		.append("text")
		.attr("text-anchor","middle")
		.text(function(d) { return d.name; });


//		add drag capabilities  
		var drag_handler = d3.drag()
		.on("start", drag_start)
		.on("drag", drag_drag)
		.on("end", drag_end); 

		drag_handler(node);
//		drag_handler(label);


//		add zoom capabilities 
		var zoom_handler = d3.zoom()
		.on("zoom", zoom_actions);

		zoom_handler(network_svg);     

		/** Functions **/

//		Function to choose what color circle we have
//		Let's return blue for males and red for females
		function circleColour(){
			return("gray");

		}

//		Function to choose the line colour and thickness 
//		If the link type is "A" return green 
//		If the link type is "E" return red 
		function linkColour(d){
			return("black");
		}

//		Drag functions 
//		d is the node 
		function drag_start(d) {
			if (!d3.event.active) simulation.alphaTarget(0.3).restart();
			d.fx = d.x;
			d.fy = d.y;

		}

//		make sure you can't drag the circle outside the box
		function drag_drag(d) {
			d.fx = d3.event.x;
			d.fy = d3.event.y;
		}

		function drag_end(d) {
			if (!d3.event.active) simulation.alphaTarget(0);
			d.fx = d3.event.x;
			d.fy = d3.event.y;
		}

//		Zoom functions 
		function zoom_actions(){
			g.attr("transform", d3.event.transform)
		}

		function tickActions() {
			//update circle positions each tick of the simulation 
			node
			.attr("cx", function(d) { return d.x; })
			.attr("cy", function(d) { return d.y; });

			// update label positions 
			label
			.attr("x", function(d) { return d.x; })
			.attr("y", function(d) { return d.y-8; });

			//update link positions 
			link
			.attr("x1", function(d) { return d.source.x; })
			.attr("y1", function(d) { return d.source.y; })
			.attr("x2", function(d) { return d.target.x; })
			.attr("y2", function(d) { return d.target.y; });
		}
		

		console.log(node);
		//console.log(net_height);
		

	});//end d3.json
	

}//end draw_network()


//draw network on page load
draw_network();

