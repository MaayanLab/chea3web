////meanRank bar graph
function parseMeanRankLibraries(){

	var toptfsdat = chea3Results["Integrated--meanRank"].slice(0,20);
	var tfs = toptfsdat.map(function(x){return x["TF"]})
	//var libinfo = toptfs[i]["Library"].split(";")
	var libs = Object.keys(chea3Results).map(function(x){return x.replace("--"," ");});
	libs = libs.slice(2,libs.length)
	var datasets = [];
	
	//loop through library names
	for(i=0; i< libs.length; i++){
		
		//loop through toptfs 
		var ranks = Array(tfs.length).fill(null);
		
		for(j = 0; j < tfs.length; j++){
			var ranksinfo = toptfsdat[j]["Library"].split(";").map(function(x){return x.split(",")})
			
			//ranks to weighted contribution to mean
			var c = ranksinfo.length;
			
			//loop through each contributing rank
			for(k = 0; k<ranksinfo.length; k++){
				if(ranksinfo[k][0] == libs[i]){
					console.log(ranksinfo[k][0])
					ranks[j] = ranks[j] + ranksinfo[k][1]/c;
					console.log(ranks[j])
				
				}
			}
		}
		console.log(ranks)
		datasets[i] = {label: libs[i],
				data: ranks,
				backgroundColor: Array(ranks.length).fill(colorArray[i]),
				borderWidth: 1}
				
				
	}
	var data = {
			labels: tfs,
			datasets: datasets
	}	
	
	return(data);
}

function generateStackedBarChart(){
	
	var ctx = document.getElementById('meanrankbarChart').getContext('2d');
	
	var data = parseMeanRankLibraries();
	
	var stackedBar = new Chart(ctx, {
	    type: 'horizontalBar',
	    
	    data: data,
	    options: {
	    	title: {
	    		display: true,
	    		text: "Weighted Library Contribution to Integrated MeanRank TF Ranks",
	    	},
	        scales: {
	            xAxes: [{
	                stacked: true
	            }],
	            yAxes: [{
	                stacked: true
	            }]
	        }
	    }
	});
}

function renderBarChartPopoverButton(){
	return `<button id = "barchartpopover" type="button" class="btn btn-link display-7" title = "Library Contribution to Integrated meanRank Ranks" data-toggle="popover" style="display:inline;float:right;padding:0;margin-right:0;margin-left:5;color:#28a0c9;font-size:50%" data-placement="right">Bar Chart</button>`;
}