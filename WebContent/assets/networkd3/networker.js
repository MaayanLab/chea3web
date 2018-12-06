importScripts("https://d3js.org/d3-collection.v1.min.js");
importScripts("https://d3js.org/d3-dispatch.v1.min.js");
importScripts("https://d3js.org/d3-quadtree.v1.min.js");
importScripts("https://d3js.org/d3-timer.v1.min.js");
importScripts("https://d3js.org/d3-force.v1.min.js");

var alpha = 0.4;
var veldecay = .5;
var forceMB = -5;
var forceLink = 2;


onmessage = function(event) {
  var nodes = event.data.nodes,
      links = event.data.links,
  	  net_width = event.data.net_width,
  	  net_height = event.data.net_height,
  	  radius = radius;
  
//	create some forces                            
	var link_force =  d3.forceLink(links)
	.id(function(d) { return d.name; }).strength(forceLink);   


	var charge_force = d3.forceManyBody()
	.strength(forceMB); 

	var center_force = d3.forceCenter(net_width*.5, net_height*.5);  

  var simulation = d3.forceSimulation()
  	.nodes(nodes)
  	.force("charge_force", charge_force)
	.force("center_force", center_force)
	.force("links",link_force)
	.force("collide", d3.forceCollide().radius(5))
	.stop();
  

  for (var i = 0, n = Math.ceil(Math.log(simulation.alphaMin()) / Math.log(1 - simulation.alphaDecay())); i < n; ++i) {
    postMessage({type: "tick", progress: i / n});
    simulation.tick();
  }

  postMessage({type: "end", nodes: nodes, links: links});
};
