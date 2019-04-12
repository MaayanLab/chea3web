package main.java.serv;

import java.util.HashSet;

public class IntegratedRank implements Comparable<IntegratedRank>{
	String tf = "";
	double score;
	int rank;
	//lib_name stores the contributing librarie's name and score 
	//(for top rank this score is scaled for meanRank this score is an integer score)
	String lib = "";
	String query_name = "";
	HashSet<String> genes = new HashSet<String>();
	
	public IntegratedRank(String tf, double score, String lib, String query_name, HashSet<String> genes) {
		this.tf = tf;
		this.score = score;
		this.lib = lib;
		this.query_name = query_name;
		this.genes = genes;
	}
	
	public void setRank(int rank) {
		this.rank = rank;
	}
	
//	public void setScore(double score) {
//		this.score = score;
//	}
	
	public double getScore() {
		return this.score;
	}
	
	@Override
	public int compareTo(IntegratedRank i) {

		double compares=((IntegratedRank)i).getScore() - this.score;

		if(compares < 0) {
			return 1; 
		}else if(compares > 0) {
			return -1;
		}else {
			return 0;
		}

	}
}
