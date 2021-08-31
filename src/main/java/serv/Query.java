package main.java.serv;


import java.util.HashSet;



public class Query {
	public short[] queryshort = null;
	public String name = "user_submission";
	public HashSet<String> noMatch = new HashSet<String>();
	public HashSet<String> dictMatch = new HashSet<String>();
	
	public Query(String[] genes, GeneDict dict, String submission_name) {
    	this.name = submission_name;
		for(String g: genes) {
    		if(dict.encode.containsKey(g)) {
    			this.dictMatch.add(g);
    		}else {
    			this.noMatch.add(g);
    		}	
    	}
		short[] query = new short[dictMatch.size()];
		int i = 0;
		for(String g: dictMatch) {
			query[i] = dict.encode.get(g);
		}
		this.queryshort = query;
    }
	
	public Query(String[] genes, GeneDict dict) {
		
		for(String g: genes) {
    		if(dict.encode.containsKey(g)) {
    			this.dictMatch.add(g);
    		}else {
    			this.noMatch.add(g);
    		}	
    	}
		short[] query = new short[dictMatch.size()];
		int i = 0;
		for(String g: dictMatch) {
			query[i] = dict.encode.get(g);
		}
		this.queryshort = query;
    }

}
