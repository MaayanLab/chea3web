package serv;

import java.math.BigDecimal;
import java.math.MathContext;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Random;

import jsp.Overlap;


public class RankAggregate {
	  
    //function topRank
	public ArrayList<IntegratedRank> topRank(HashMap<String, ArrayList<Overlap>> orig, String query_name) {
		ArrayList<IntegratedRank> integ = new ArrayList<IntegratedRank>();
		
		//hashmap that stores the best rank for each tf
		HashMap<String, Double> tf_ranks = new HashMap<String, Double>();
		
		//string that stores the library and best rank for each tf
		HashMap<String, String> tf_libs = new HashMap<String, String>();
		
		HashMap<String, HashSet<String>> tf_genes = new HashMap<String, HashSet<String>>();
		
		
		for(String lib: orig.keySet()) {
			
			//iterate through each overlap object in the lib results set
			for(Overlap o: orig.get(lib)) {
				//check to see if tf has been added to tf_ranks
				if(!tf_ranks.containsKey(o.lib_tf)) {
					
					tf_ranks.put(o.lib_tf, o.scaledRank);
					tf_libs.put(o.lib_tf, o.lib_name + "," + Double.toString(sigDig(o.scaledRank,4)));
					tf_genes.put(o.lib_tf, o.genes);
					
				}else {
					double r = tf_ranks.get(o.lib_tf);
					
					if(r>o.scaledRank) {
						tf_ranks.put(o.lib_tf, o.scaledRank);
						tf_libs.put(o.lib_tf, o.lib_name + "," + Double.toString(sigDig(o.scaledRank,4)));
						tf_genes.put(o.lib_tf, o.genes);
					}
					
				}
				
			}//done iterating through library results set	
		}// done iterating through all libraries
		
		//iterate through integrated ranks and generate a list of IntegratedRank objects
		for(String tf: tf_ranks.keySet()) {
			
			integ.add(new IntegratedRank(tf, tf_ranks.get(tf), tf_libs.get(tf), query_name, tf_genes.get(tf)));
		}
		
		
		integ = sortRank(integ);
		return integ;
		
		
	}


	//function bordaCount (AKA meanRank)
	public ArrayList<IntegratedRank> bordaCount(HashMap<String, ArrayList<Overlap>> orig, String query_name){
		ArrayList<IntegratedRank> integ = new ArrayList<IntegratedRank>();
		
		//hashmap that stores the cumulative score for each tf
		HashMap<String, Double> tf_scores = new HashMap<String, Double>();
				
		//hashmap that stores the number of libraries that contribute to the score
		HashMap<String, Integer> tf_numlibs = new HashMap<String, Integer>();
		
		//hashmap that stores the libraries and the tf rank in those libraries
		HashMap<String, String> tf_libinfo = new HashMap<String, String>();
		
		HashMap<String, HashSet<String>> tf_genes = new HashMap<String, HashSet<String>>();
		
		for(String lib: orig.keySet()) {
			
			//iterate through each overlap object in the lib results set
			for(Overlap o: orig.get(lib)) {
				//check to see if tf has been added to tf_scores
				if(!tf_scores.containsKey(o.lib_tf)) {
					
					tf_scores.put(o.lib_tf, (double) o.rank);
					tf_numlibs.put(o.lib_tf, 1);
					tf_genes.put(o.lib_tf, o.genes);
					tf_libinfo.put(o.lib_tf, o.lib_name + "," + Integer.toString(o.rank));
					
				}else {
					double score = tf_scores.get(o.lib_tf);
					int count = tf_numlibs.get(o.lib_tf);
					HashSet<String> overlap_genes = new HashSet<>(tf_genes.get(o.lib_tf));
					overlap_genes.addAll(o.genes);
					count++;
					String libinfo = tf_libinfo.get(o.lib_tf);
					tf_libinfo.put(o.lib_tf, o.lib_name + "," + Integer.toString(o.rank) + ";" + libinfo);
					tf_scores.put(o.lib_tf, o.rank + score);
					tf_numlibs.put(o.lib_tf,count);
					tf_genes.put(o.lib_tf,overlap_genes);
					
					
				}
				
			}//done iterating through library results set	
		}// done iterating through all libraries
		
		//iterate through integrated ranks and generate a list of IntegratedRank objects
		for(String tf: tf_scores.keySet()) {
			double score = tf_scores.get(tf)/tf_numlibs.get(tf);
			integ.add(new IntegratedRank(tf, score, tf_libinfo.get(tf), query_name, tf_genes.get(tf)));
		}	
		
		integ = sortRank(integ);
		return(integ);
		
	}
	
	private static double sigDig(double d, int n) {
		if(Double.isNaN(d)|| Double.isInfinite(d)) {
			return Double.NaN;
		}
		BigDecimal bd = new BigDecimal(d);
		bd = bd.round(new MathContext(n));
		double rounded = bd.doubleValue();
		return(rounded);

	}
	
//	//function local kemenization
//	public ArrayList<IntegratedRank> localKemenization(HashMap<String, ArrayList<Overlap>> orig, String query_name){
//		//start with a borda count rank aggregation
//		ArrayList<IntegratedRank> r = bordaCount(orig, query_name);
//		Collections.shuffle(r);
//		
//		HashMap<String, HashMap<String,Integer>> votes = new HashMap<String, HashMap<String,Integer>>();
//		
//		for(String lib_name : orig.keySet()) { //iterate over libraries 
//			ArrayList<Overlap> lib_results = orig.get(lib_name);
//			HashMap<String,Integer> rankings = new HashMap<String, Integer>();
//			for(Overlap o: lib_results) {
//				rankings.put(o.lib_tf, o.rank);
//			}
//			votes.put(lib_name, rankings);
//		}
//		
//		int i = 1;
//		int j = 1;
//		
//		while(i<r.size()) {
//			j = i;	
//			while(j>0 && swap(r, votes, j)) {
//				//swap r[j] and r[j-1]
////				System.out.println(j);
////				System.out.println("swap");
//				Collections.swap(r, j, j-1);
//				j = j-1;	
//			}
//			i++;
//		}
//		
//		for(int k=0;k<r.size();k++) {
//			System.out.println(r.get(k).rank);
//			r.get(k).setRank(k+1);
//			r.get(k).setScore(0);
//			System.out.println(r.get(k).rank);
//		}
//		return r;
//	}
	
	
	private ArrayList<IntegratedRank> sortRank(ArrayList<IntegratedRank> integ){
		Collections.shuffle(integ, new Random(4));
		Collections.sort(integ);
		
		//set rank
		int rank = 1;
		for (IntegratedRank ir:integ) {
			ir.rank = rank;
			rank++;
		}
		return(integ);
	}
	
//	private boolean swap(ArrayList<IntegratedRank> r, HashMap<String, HashMap<String,Integer>> votes, int j) {
//		
//		int j_votes = 0;
//		int jminus_votes = 0;
//
//		for(String judge: votes.keySet()) {
//			
//			HashMap<String, Integer> v = votes.get(judge);
//			
//			if(v.containsKey(r.get(j).tf) & v.containsKey(r.get(j-1).tf)) {
//			
//				if(r.get(j).rank < r.get(j-1).rank) {
//					j_votes++;
//				}
//				else {
//					jminus_votes++;
//				}
//			}	
//		}
//		
//		if (jminus_votes < j_votes) {
//			System.out.println("swap");
//			return true;
//			
//		}else {
//			System.out.println("don't swap");
//			return false;
//			
//		}
//		
//	}
}
