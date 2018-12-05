function updateHits(){

	$.ajax({
		url : host + "chea3-dev/api/submissions/",
		success : function(results) {
			
			document.getElementById("hitcount").innerHTML = "Submissions: "+results;
		}
	}); // end AJAX call
}

updateHits();