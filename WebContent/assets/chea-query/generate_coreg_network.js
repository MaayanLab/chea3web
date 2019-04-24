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

    var colorScale = d3.scaleSequential(d3.interpolateBlues).domain([0, Math.max.apply(null, network['nodes'].map(function (d) { return d['degree'] }))]);

    var svg = d3.select("#coreg-network"),
        width = +svg.attr("width"),
        height = +svg.attr("height"),
        node,
        link;
    svg.selectAll('*').remove();

    // Define arrows
    svg.append("defs").selectAll("marker")
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

    svg.append("defs").selectAll("marker")
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
        .force("link", d3.forceLink().id(function (d) { return d.id; }).distance(100).strength(1))
        .force("charge", d3.forceManyBody())
        .force("center", d3.forceCenter(width / 2, height / 2));


    var vis = svg.append('g');

    var txt = vis.append('text')
        .attrs({
            "transform": 'translate(5,20)',
            "fill": "black",
            "opacity": 0
        })
    var pad = 15;
    var dy = '1.3em';
        
    // Functions to create network
    function update(links, nodes) {
        link = svg.selectAll(".link")
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
                txt.selectAll('*').remove();
                txt.append('tspan')
                    .attrs({'dy': dy, 'x': 0, 'font-weight': 'bold'})
                    .text('Interaction evidence sources:');
                if (d["ABchipseq_evidence"] != "none") {
                    txt.append('tspan')
                        .attrs({'dy': dy, 'x': 0})
                        .text('   •  ChIP-Seq ('+d['TFA'] +'→'+d['TFB']+'): '+d["ABchipseq_evidence"]);
                }
                if (d["BAchipseq_evidence"] != "none") {
                    txt.append('tspan')
                        .attrs({'dy': dy, 'x': 0})
                        .text('   •  ChIP-Seq (' +d['TFB'] +'→'+d['TFA']+'): '+d["BAchipseq_evidence"]);
                }
                if (d["coexpression_evidence"] != "none") {
                    txt.append('tspan')
                        .attrs({'dy': dy, 'x': 0})
                        .text('   • ' +'Co-expression: ' + d["coexpression_evidence"]);
                }
                if (d["cooccurrence_evidence"] != "none") {
                    txt.append('tspan')
                        .attrs({'dy': dy, 'x': 0})
                        .text('   • ' +'Co-occurrence: ' + d["cooccurrence_evidence"]);
                }
                // $.each([''], function(key, value) {
                //     if (key.indexOf('evidence') > -1) {
                //         txt.append('tspan')
                //             .attrs({'dy': dy, 'x': 0})
                //             .text(key+': '+value);
                //     }
                // })
                txt.attrs({
                    "transform": "translate(" + (mousePos[0]+0)+","+(mousePos[1]-txt.selectAll('*')['_groups'][0].length*pad) + ")",
                    "opacity": 1
                });
            })
            .on("mousemove", function (d) {
                var mousePos = d3.mouse(this);
                txt.attrs({
                    "transform": "translate(" + (mousePos[0]+0)+","+(mousePos[1]-txt.selectAll('*')['_groups'][0].length*pad) + ")",
                    "opacity": 1
                });
            })
            .on("mouseout", function (d) {
                txt.attrs({
                    "opacity": 0
                });
            })

        // link.append("title")
        //     .text(function (d) { return d.type; });

        edgepaths = svg.selectAll(".edgepath")
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

        // edgelabels = svg.selectAll(".edgelabel")
        //     .data(links)
        //     .enter()
        //     .append('text')
        //     .style("pointer-events", "none")
        //     .attrs({
        //         'class': 'edgelabel',
        //         'id': function (d, i) { return 'edgelabel' + i },
        //         'font-size': 10,
        //         'fill': '#aaa'
        //     });

        // edgelabels.append('textPath')
        //     .attr('xlink:href', function (d, i) { return '#edgepath' + i })
        //     .style("text-anchor", "middle")
        //     .style("pointer-events", "none")
        //     .attr("startOffset", "50%")
        //     .text(function (d) { return d.type });

        node = svg.selectAll(".node")
            .data(nodes)
            .enter()
            .append("g")
            .attr("class", "node")
            .call(d3.drag()
                .on("start", dragstarted)
                .on("drag", dragged)
                //.on("end", dragended)
            );

        node.append("circle")
            .attr("r", 5)
            .style("stroke", function (d, i) { return "lightgrey" })
            .style("fill", function (d, i) { return colorScale(d.degree); })

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

        // edgelabels.attr('transform', function (d) {
        //     if (d.target.x < d.source.x) {
        //         var bbox = this.getBBox();

        //         rx = bbox.x + bbox.width / 2;
        //         ry = bbox.y + bbox.height / 2;
        //         return 'rotate(180 ' + rx + ' ' + ry + ')';
        //     }
        //     else {
        //         return 'rotate(0)';
        //     }
        // });
    }

    function dragstarted(d) {
        if (!d3.event.active) simulation.alphaTarget(0.3).restart()
        d.fx = d.x;
        d.fy = d.y;
    }

    function dragged(d) {
        d.fx = d3.event.x;
        d.fy = d3.event.y;
    }

//    function dragended(d) {
//        if (!d3.event.active) simulation.alphaTarget(0);
//        d.fx = undefined;
//        d.fy = undefined;
//    }
    // Create network
    update(network.links, network.nodes);

}

generateNetwork = function(tfs) {
    $.getJSON('assets/chea-query/chea3_coreg_sub_network.json', function (coreg_network) {

        // Create network
        var network = createNetwork(coreg_network, tfs = tfs);

        // Display network
        displayNetwork(network);

    })
}