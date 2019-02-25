package serv;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import jsp.Overlap;

public class Enrichment {


	private FastFisher fet = new FastFisher(30000);


	public Enrichment() {

	}

	public ArrayList<Overlap> calculateEnrichment(HashSet<String> queryset, HashMap<String,HashSet<String>> genesetlib, String lib_name, String query_name) {


		ArrayList<Overlap> pvals = new ArrayList<Overlap>();


		for(String key: genesetlib.keySet()) {
			int numGeneQuery = queryset.size();
			int totalBgGenes = 20100;
			int gmtListSize =  genesetlib.get(key).size();
			int numOverlap = setIntersect(queryset,genesetlib.get(key));

			double pvalue = fet.getRightTailedP(numOverlap,(gmtListSize - numOverlap), numGeneQuery, (totalBgGenes - numGeneQuery));
			double oddsratio = (numOverlap*1.0*(totalBgGenes - numGeneQuery))/((gmtListSize - numOverlap)*1.0*numGeneQuery);

			Overlap o = new Overlap(key, numOverlap, pvalue, gmtListSize, oddsratio, lib_name, query_name);
			pvals.add(o);	
		}

		return pvals;
	}

	public int setIntersect(HashSet<String> s1, HashSet<String> s2) {
		Set<String> intersection = new HashSet<String>(s1);
		intersection.retainAll(s2);
		return intersection.size();
	}



}


