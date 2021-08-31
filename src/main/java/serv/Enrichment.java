package main.java.serv;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import main.java.jsp.Overlap;

public class Enrichment {


	private FastFisher fet = new FastFisher(30000);


	public Enrichment() {

	}

	public ArrayList<Overlap> calculateEnrichment(HashSet<String> queryset, HashMap<String,HashSet<String>> genesetlib, String lib_name, String query_name) {


		ArrayList<Overlap> pvals = new ArrayList<Overlap>();


		for(String key: genesetlib.keySet()) {
			int numGeneQuery = queryset.size();
			int totalBgGenes = 20000;
			int gmtListSize =  genesetlib.get(key).size();
			HashSet<String> genes = setIntersect(queryset,genesetlib.get(key));
			int numOverlap = genes.size();

			double pvalue = fet.getRightTailedP(numOverlap,(gmtListSize - numOverlap), numGeneQuery, (totalBgGenes - numGeneQuery));
			double oddsratio = (numOverlap*1.0*(totalBgGenes - numGeneQuery))/((gmtListSize - numOverlap)*1.0*numGeneQuery);

			Overlap o = new Overlap(key, numOverlap, pvalue, gmtListSize, oddsratio, lib_name, query_name, genes);
			pvals.add(o);	
		}

		return pvals;
	}

	public HashSet<String> setIntersect(HashSet<String> s1, HashSet<String> s2) {
		HashSet<String> intersection = new HashSet<String>(s1);
		intersection.retainAll(s2);
		return intersection;
	}



}


