// Create network
createNetwork = function(coreg_network, tfs) {

    // Initialize network
    var network = {"nodes": [], "links": []};
    // Loop through top TFs
    $.each(coreg_network, function(index, edge) {
        if (tfs.includes(edge['TFA']) && tfs.includes(edge['TFB'])) {
            edge['source'] = edge['TFA'];
            edge['target'] = edge['TFB'];
            network['links'].push(edge);
        }
    })
    
    // Add nodes
    $.each(tfs, function (index, tf) { network["nodes"].push({ "id": tf, "name": tf, "label": tf, "degree": network['links'].filter(function (d) { return d.TFA === tf || d.TFB === tf }).length }) })
    
    // Return
    return network

}

// Display network
displayNetwork = function(network) {

    // Initialize network
    var colorScale = d3.scaleSequential(d3.interpolateBlues).domain([0, Math.max.apply(null, network['nodes'].map(function (d) { return d['degree'] }))]);
    var svg = d3.select("#coreg-network"),
        width = +svg.attr("width"),
        height = +svg.attr("height"),
        node,
        link;
        
    // Clear network
    svg.selectAll('*').remove();
    
    // Zoom wrapper
    var zoom_wrapper = svg.append("g");

    // Tooltips elements
    var tooltip_wrapper = svg.append('g');
    var bg = tooltip_wrapper.append('rect').attrs({
        'fill': 'transparent',
        'stroke-width': 1,
        'rx': 5,
        'ry': 5
    })
    var txt = tooltip_wrapper.append('text')
        .attrs({
            "opacity": 0
        })

    // Define arrows
    zoom_wrapper.append("defs").selectAll("marker")
        .data(["arrow"])
        .enter().append("marker")
        .attr("id", "markerEnd")
        .attr("viewBox", "0 -5 10 10")
        .attr("refX", 19)
        .attr("refY", -0, 7)
        .attr("markerWidth", 6)
        .attr("markerHeight", 6)
        .attr('markerUnits', "userSpaceOnUse")
        .attr("orient", "auto")
        .append("path")
        .attr("d", "M0,-5L10,0L0,5");

    zoom_wrapper.append("defs").selectAll("marker")
        .data(["arrow"])
        .enter().append("marker")
        .attr("id", "markerStart")
        .attr("viewBox", "0 -5 10 10")
        .attr("refX", -12)
        .attr("refY", -0, 7)
        .attr("markerWidth", 6)
        .attr("markerHeight", 6)
        .attr('markerUnits', "userSpaceOnUse")
        .attr("orient", "auto")
        .append("path")
        .attr("d", "M0,0L10,-5L10,5Z");

    // Force directed
    var simulation = d3.forceSimulation()
        .force("link", d3.forceLink().id(function (d) { return d.id; }).distance(100).strength(0.1))
        .force("charge", d3.forceManyBody().theta(0.9).distanceMin(1).distanceMax(Infinity))
        .force("center", d3.forceCenter(width / 2, height / 2));

    // Tooltip variables
    var pad = 20;
    var nr_lines = 0;
    var dy = '1.3em';
    var xpos=10, ypos=0;
        
    // Functions to create network
    function update(links, nodes) {
        link = zoom_wrapper.selectAll(".link")
            .data(links)
            .enter()
            .append("line")
            .attrs({
                "class":"link",
                "stroke": "#999",
                "opacity": function(d) { return d.edge_score/5 },
                "stroke-width": 2
            })
            .attr('marker-start', function (d, i) { return ['BA', 'bidir'].indexOf(d.edge_type) > -1 ? 'url(#markerStart)' : null })
            .attr('marker-end', function (d, i) { return ['AB', 'bidir'].indexOf(d.edge_type) > -1 ? 'url(#markerEnd)' : null })
            .on("mouseover", function (d) {

                // Create tooltip
                var mousePos = d3.mouse(this);

                // Text
                txt.selectAll('*').remove();
                txt.append('tspan')
                    .attrs({'dy': dy, 'x': 10, 'font-weight': 'bold'})
                    .style('z-index', 1000)
                    .text('Interaction evidence sources:');
                if (d["ABchipseq_evidence"] != "none") {
                    txt.append('tspan')
                        .attrs({'dy': dy, 'x': 15})
                        .text('   •  ChIP-Seq ('+d['TFA'] +'→'+d['TFB']+'): '+d["ABchipseq_evidence"]);
                }
                if (d["BAchipseq_evidence"] != "none") {
                    txt.append('tspan')
                        .attrs({'dy': dy, 'x': 15})
                        .text('   •  ChIP-Seq (' +d['TFB'] +'→'+d['TFA']+'): '+d["BAchipseq_evidence"]);
                }
                if (d["coexpression_evidence"] != "none") {
                    txt.append('tspan')
                        .attrs({'dy': dy, 'x': 15})
                        .text('   • ' +'Co-expression: ' + d["coexpression_evidence"]);
                }
                if (d["cooccurrence_evidence"] != "none") {
                    txt.append('tspan')
                        .attrs({'dy': dy, 'x': 15})
                        .text('   • ' +'Co-occurrence: ' + d["cooccurrence_evidence"]);
                }

                // Nr lines
                nr_lines = txt.selectAll('tspan')._groups[0].length;
                var max_length = Math.max.apply(null, Array.from(txt.selectAll('tspan')._groups[0]).map(function (x) { return x.innerHTML.length })) ;

                // Text attributes
                txt.attrs({
                    "transform": "translate(" + (mousePos[0]+xpos)+","+(mousePos[1]+ypos-nr_lines*pad) + ")",
                    "opacity": 1
                });

                // Background attributes
                bg.attrs({
                    'fill': '#fcfcfc',
                    'width': max_length*8.8,
                    'height': pad * nr_lines + 10,
                    "transform": "translate(" + (mousePos[0]) + "," + (mousePos[1] + ypos - nr_lines * pad) + ")",
                    'stroke': 'lightgrey'
                })

            })
            .on("mousemove", function (d) {
                var mousePos = d3.mouse(this);
                txt.attrs({
                    "transform": "translate(" + (mousePos[0]+xpos)+","+(mousePos[1]+ypos-nr_lines*pad) + ")"
                });
                bg.attrs({
                    "transform": "translate(" + (mousePos[0]+xpos)+","+(mousePos[1]+ypos-nr_lines*pad) + ")"
                });
            })
            .on("mouseout", function (d) {
                txt.attrs({
                    "opacity": 0
                });
                bg.attrs({
                    "fill": "transparent",
                    "stroke": "transparent"
                });
            })

        edgepaths = zoom_wrapper.selectAll(".edgepath")
            .data(links)
            .enter()
            .append('path')
            .attrs({
                'class': 'edgepath',
                'fill-opacity': 0,
                'stroke-opacity': 0,
                'stroke': 'red',
                'id': function (d, i) { return 'edgepath' + i }
            })
            .style("pointer-events", "none");

        node = zoom_wrapper.selectAll(".node")
            .data(nodes)
            .enter()
            .append("g")
            .attr("class", "node")
            .call(d3.drag()
                .on("start", dragstarted)
                .on("drag", dragged)
                // .on("end", dragended)
            );

        node.append("circle")
            .attr("r", 7)
            .style("stroke", function (d, i) { return "lightgrey" })
            .style("stroke-width", 1)
            // .style("fill", function (d, i) { return colorScale(d.degree); })
            .style("fill", function (d, i) { return getColor('colorpicker') })

        node.append("title")
            .text(function (d) { return d.id; });

        node.append("text")
            .attr("dy", -3)
            .text(function (d) { return d.name; });

        simulation
            .nodes(nodes)
            .on("tick", ticked);

        simulation.force("link")
            .links(links);
    }

    function ticked() {
        link
            .attr("x1", function (d) { return d.source.x; })
            .attr("y1", function (d) { return d.source.y; })
            .attr("x2", function (d) { return d.target.x; })
            .attr("y2", function (d) { return d.target.y; });

        node
            .attr("transform", function (d) { return "translate(" + d.x + ", " + d.y + ")"; });

        edgepaths.attr('d', function (d) {
            return 'M ' + d.source.x + ' ' + d.source.y + ' L ' + d.target.x + ' ' + d.target.y;
        });

    }

    function dragstarted(d) {
        if (!d3.event.active) simulation.alphaTarget(0.01).restart()
        d.fx = d.x;
        d.fy = d.y;
    }

    function dragged(d) {
        d.fx = d3.event.x;
        d.fy = d3.event.y;
    }

   function dragended(d) {
       if (!d3.event.active) simulation.alphaTarget(0);
       d.fx = undefined;
       d.fy = undefined;
   }

    //add zoom capabilities 
    var zoom_handler = d3.zoom()
        .on("zoom", zoom_actions);

    // zoom_handler(svg);

    //Zoom functions 
    function zoom_actions() {
        zoom_wrapper.attr("transform", d3.event.transform)
    }
    
    // Create network
    update(network.links, network.nodes);

}

generateNetwork = function() {

    // Get TFs
    var tfs = getTFs2();

    // Get JSON
    $.getJSON('assets/chea-query/chea3_coreg_sub_network.json', function (coreg_network) {

        // Create network
        var network = createNetwork(coreg_network, tfs = tfs);

        // Display network
        displayNetwork(network);

    })
}
