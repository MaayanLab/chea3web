package serv;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Random;

import jsp.Overlap;


public class RankAggregate {
	  
    //function topRank
	public ArrayList<IntegratedRank> topRank(HashMap<String, ArrayList<Overlap>> orig, String query_name) {
		ArrayList<IntegratedRank> integ = new ArrayList<IntegratedRank>();
		
		//hashmap that stores the best rank for each tf
		HashMap<String, Float> tf_ranks = new HashMap<String, Float>();
		
		//hashmap that stores the library of the best rank for each tf
		HashMap<String, String> tf_libs = new HashMap<String, String>();
		
		for(String lib: orig.keySet()) {
			
			//iterate through each overlap object in the lib results set
			for(Overlap o: orig.get(lib)) {
				//check to see if tf has been added to tf_ranks
				if(!tf_ranks.containsKey(o.lib_tf)) {
					
					tf_ranks.put(o.lib_tf, o.scaledRank);
					tf_libs.put(o.lib_tf, o.lib_name);
					
				}else {
					float r = tf_ranks.get(o.lib_tf);
					
					if(r>o.scaledRank) {
						tf_ranks.put(o.lib_tf, o.scaledRank);
						tf_libs.put(o.lib_tf, o.lib_name);
					}
					
				}
				
			}//done iterating through library results set	
		}// done iterating through all libraries
		
		//iterate through integrated ranks and generate a list of IntegratedRank objects
		for(String tf: tf_ranks.keySet()) {
			integ.add(new IntegratedRank(tf, tf_ranks.get(tf), tf_libs.get(tf), query_name));
		}
		
		
		integ = sortRank(integ);
		return integ;
		
		
	}


	//function bordaCount
	public ArrayList<IntegratedRank> bordaCount(HashMap<String, ArrayList<Overlap>> orig, String query_name){
		ArrayList<IntegratedRank> integ = new ArrayList<IntegratedRank>();
		
		String lib_name = "all";
		//hashmap that stores the cumulative score for each tf
		HashMap<String, Integer> tf_scores = new HashMap<String, Integer>();
				
		//hashmap that stores the number of libraries that contribute to the score
		HashMap<String, Integer> tf_libs = new HashMap<String, Integer>();
		
		for(String lib: orig.keySet()) {
			
			//iterate through each overlap object in the lib results set
			for(Overlap o: orig.get(lib)) {
				//check to see if tf has been added to tf_ranks
				if(!tf_scores.containsKey(o.lib_tf)) {
					
					tf_scores.put(o.lib_tf, o.rank);
					tf_libs.put(o.lib_tf, 1);
					
				}else {
					int score = tf_scores.get(o.lib_tf);
					int count = tf_libs.get(o.lib_tf);
					count++;
					
					tf_scores.put(o.lib_tf, o.rank + score);
					tf_libs.put(o.lib_tf,count);
					
				}
				
			}//done iterating through library results set	
		}// done iterating through all libraries
		
		//iterate through integrated ranks and generate a list of IntegratedRank objects
		for(String tf: tf_scores.keySet()) {
			integ.add(new IntegratedRank(tf, tf_scores.get(tf)/tf_libs.get(tf),lib_name, query_name));
		}	
		
		integ = sortRank(integ);
		return(integ);
		
	}
	
	
	//function local kemenization
	public ArrayList<IntegratedRank> localKemenization(HashMap<String, ArrayList<Overlap>> orig, String query_name){
		//start with a borda count rank aggregation
		ArrayList<IntegratedRank> r = topRank(orig, query_name);
		Collections.shuffle(r);
		
		HashMap<String, HashMap<String,Integer>> votes = new HashMap<String, HashMap<String,Integer>>();
		for(String lib_name : orig.keySet()) {
			ArrayList<Overlap> lib_results = orig.get(lib_name);
			HashMap<String,Integer> rankings = new HashMap<String, Integer>();
			for(Overlap o: lib_results) {
				rankings.put(o.lib_tf, o.rank);
			}
			votes.put(lib_name, rankings);
		}
		
		int i = 1;
		int j = 1;
		
		while(i<r.size()) {
			j = i;	
			while(j>0 && swap(r, votes, j)) {
				//swap r[j] and r[j-1]
				System.out.println(j);
				System.out.println("swap");
				Collections.swap(r, j, j-1);
				j = j-1;	
			}
			i++;
		}
		return r;
	}
	
	
	private ArrayList<IntegratedRank> sortRank(ArrayList<IntegratedRank> integ){
		//Collections.shuffle(integ, new Random());
		Collections.sort(integ);
		
		//set rank
		int rank = 1;
		for (IntegratedRank ir:integ) {
			ir.rank = rank;
			rank++;
		}
		return(integ);
	}
	
	private boolean swap(ArrayList<IntegratedRank> r, HashMap<String, HashMap<String,Integer>> votes, int j) {
		
		int j_votes = 0;
		int jminus_votes = 0;

		for(String judge: votes.keySet()) {
			
			HashMap<String, Integer> v = votes.get(judge);
			System.out.println("outwhile" + Integer.toString(j));
			if(v.containsKey(r.get(j).tf) & v.containsKey(r.get(j-1).tf)) {
			
				if(r.get(j).rank < r.get(j-1).rank) {
					j_votes++;
				}
				else {
					jminus_votes++;
				}
			}	
		}
		
		if (jminus_votes < j_votes) {
			return true;
		}else {
			return false;
		}
		
	}
}
