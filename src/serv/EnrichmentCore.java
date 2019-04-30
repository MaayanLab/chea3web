package serv;

import java.io.BufferedReader;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.RequestDispatcher;
import javax.servlet.Servlet;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


import jsp.Overlap;
import java.math.BigDecimal;
import java.math.MathContext;

/**
 * Servlet implementation class Test
 */
@WebServlet("/api/*")
public class EnrichmentCore extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private int hitCount;
	private int write_hits = 10;
	private int hitIncr;



	public boolean initialized = false;

	static GeneDict dict = null;
	static HashSet<GenesetLibrary> libraries = new HashSet<GenesetLibrary>();
	static HashMap<String, String> lib_descriptions = new HashMap<String, String>();

	static Enrichment enrich = null;
	static RankAggregate aggregate = null;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public EnrichmentCore() {
		super();
	}

	/**
	 * @see Servlet#init(ServletConfig)
	 * 
	 * Initializes class variables
	 * 
	 */

	public void init(ServletConfig config) throws ServletException {
		super.init(config);
		//		System.out.println("hi");

		//initialize dictionary object
		try {
			EnrichmentCore.dict = new GeneDict("WEB-INF/dict/hgnc_symbols.txt", this);
			System.out.println(EnrichmentCore.dict.encode.get("FOXO1"));
		} catch (IOException e) {
			e.printStackTrace();
		}

		//		//read hit counter file
		//		this.hitCount = readHits("WEB-INF/hits.txt", this);
		//		//initialize hitIncr
		//		this.hitIncr = 0;


		//initialize enrichment object
		EnrichmentCore.enrich = new Enrichment();
		EnrichmentCore.aggregate = new RankAggregate();

		//get gmt file paths
		String libdir = "WEB-INF/tflibs/";
		String[] filenames = new File(getServletContext().getRealPath(libdir)).list(); 
		HashSet<String> libpaths = new HashSet<String>();
		for(String f: filenames) {
			//			System.out.println(f);
			if(!f.equals(".DS_Store")) {
				libpaths.add(libdir + f);
			}

		}


		//generate gene set library objects
		for(String l: libpaths) {
			try {
				EnrichmentCore.libraries.add(new GenesetLibrary(l,dict,true,this));
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		//get library description paths
		String libdesc = "WEB-INF/lib_descriptions/";
		String[] fnames = new File(getServletContext().getRealPath(libdesc)).list();
		HashSet<String> descpaths = new HashSet<String>();
		for(String f: fnames) {
			if(!f.equals(".DS_Store")) {
				descpaths.add(libdesc + f);
			}
		}

		//set library descriptions
		for(String path : descpaths) {
			String desc_name = path.replaceAll(".*/lib_descriptions/", "").split("_")[0];	
			// load gmt file
			InputStream file = this.getServletContext().getResourceAsStream(path);		
			BufferedReader br = new BufferedReader(new InputStreamReader(file));	
			try {
				EnrichmentCore.lib_descriptions.put(desc_name, br.readLine());
			} catch (IOException e) {
				e.printStackTrace();
			}
		}	
	}
	public void destroy() {
		System.out.println("destroying server instance");
		//		try {
		//			this.writeHits("WEB-INF/hits.txt", this);
		//		} catch (IOEtackTrace();
		//		}
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		//response.getWriter().append("My servlet served at: "+fish.getFish()+" : ").append(request.getContextPath());

		response.setHeader("Access-Control-Allow-Origin", "*");

		String pathInfo = request.getPathInfo();
		//System.out.println(pathInfo);

		if(pathInfo == null || pathInfo.equals("/index.html") || pathInfo.equals("/")){
			RequestDispatcher rd = getServletContext().getRequestDispatcher("/index.html");
			PrintWriter out = response.getWriter();
			out.write("index.html URL");
			rd.include(request, response);

		}
		else if(pathInfo.matches("^/submissions/.*")){
			System.out.println(Integer.toString(this.hitCount));
			response.setContentType("text/plain");
			response.getWriter().write(Integer.toString(this.hitCount));

		}

		else if(pathInfo.matches("^/enrich/.*")){

			String query_name = "user query";

			//if hitCount is legitimate
			if(this.hitCount >0) {
				this.hitIncr++;
				this.hitCount++;
			}

			if(this.hitIncr > this.write_hits) {
				this.writeHits("WEB-INF/hits.txt", this);
				this.hitIncr = 0;
			}

			//http://localhost:8080/chea3-dev/api/enrich/KIAA0907,KDM5A,CDC25A,EGR1,GADD45B,RELB,TERF2IP,SMNDC1,TICAM1,NFKB2,RGS2,NCOA3,ICAM1,TEX10,CNOT4,ARID4B,CLPX,CHIC2,CXCL2,FBXO11,MTF2,CDK2,DNTTIP2,GADD45A,GOLT1B,POLR2K,NFKBIE,GABPB1,ECD,PHKG2,RAD9A,NET1,KIAA0753,EZH2,NRAS,ATP6V0B,CDK7,CCNH,SENP6,TIPARP,FOS,ARPP19,TFAP2A,KDM5B,NPC1,TP53BP2,NUSAP1,SCCPDH,KIF20A,FZD7,USP22,PIP4K2B,CRYZ,GNB5,EIF4EBP1,PHGDH,RRAGA,SLC25A46,RPA1,HADH,DAG1,RPIA,P4HA2,MACF1,TMEM97,MPZL1,PSMG1,PLK1,SLC37A4,GLRX,CBR3,PRSS23,NUDCD3,CDC20,KIAA0528,NIPSNAP1,TRAM2,STUB1,DERA,MTHFD2,BLVRA,IARS2,LIPA,PGM1,CNDP2,BNIP3,CTSL1,CDC25B,HSPA8,EPRS,PAX8,SACM1L,HOXA5,TLE1,PYGL,TUBB6,LOXL1

			String truncPathInfo = pathInfo.replace("/enrich/", "");

			String[] genes = new String[0];

			Pattern p = Pattern.compile("(.*)/qid/(.*)");
			Matcher m = p.matcher(truncPathInfo);

			// if our pattern matches the URL extract groups
			if (m.find()){
				//System.out.println("HI");
				String gene_identifiers = m.group(1);
				genes = gene_identifiers.split(",");
				query_name = m.group(2);
			}
			else{	// enrichment over all geneset libraries
				genes = truncPathInfo.split(",");
			}

			genes = toUpper(genes);

			Query q = new Query(genes, EnrichmentCore.dict);

			//compute enrichment for each library

			HashMap<String, ArrayList<Overlap>> results = new HashMap<String, ArrayList<Overlap>>();

			double size = 0;
			double r = 1;
			int d = 0;
			

			for(GenesetLibrary lib: EnrichmentCore.libraries) {
				ArrayList<Overlap> enrichResult = enrich.calculateEnrichment(q.dictMatch, lib.mappableSymbols, lib.name, query_name);
				Collections.shuffle(enrichResult, new Random(4));
				Collections.sort(enrichResult);
				computeFDR(enrichResult);
				
				
				//where multiple library gene sets correspond to the same TF, take only the best 
				//performing gene set and remove the rest from the list
				HashSet<String> lib_tfs = new HashSet<String>();
				ArrayList<Integer> duplicated_tf_idx = new ArrayList<>();
				d=0;
				
				for(Overlap o: enrichResult) {
					if(lib_tfs.contains(new String(o.getLibTF()))){
						duplicated_tf_idx.add(d);
						//System.out.println(o.lib_name);
						
					}else {
						lib_tfs.add(new String(o.getLibTF()));
					}
					d++;
				}
				
				Collections.sort(duplicated_tf_idx, Collections.reverseOrder());
				
				for(Integer dupe: duplicated_tf_idx) {
					int duplicated = dupe;
					System.out.println(dupe);
					enrichResult.remove(duplicated);
				}
				
				//set ranks of remaining results
				r = 1;
				size = enrichResult.size();
				for(Overlap o: enrichResult) {
					o.setRank((int) r);
					o.setScaledRank(r/size);
					//System.out.println(Integer.toString(size));
					r++;
				}
				results.put(lib.name,enrichResult);

				//integrate results

			}		

			ArrayList<IntegratedRank> top_rank = aggregate.topRank(results, query_name);
			ArrayList<IntegratedRank> borda = aggregate.bordaCount(results, query_name);
//			ArrayList<IntegratedRank> kemen = aggregate.localKemenization(results, query_name);

			HashMap<String, ArrayList<IntegratedRank>> integrated_results = new HashMap<String, ArrayList<IntegratedRank>>();
			integrated_results.put("topRank", top_rank);
			integrated_results.put("meanRank",borda);
//			integrated_results.put("localKemenization",kemen);

			String json = resultsToJSON(results, integrated_results);

			//respond to request
			response.setContentType("text/plain");
			response.getWriter().write(json);

		}
		else if(pathInfo.matches("^/main/.*")) {
			PrintWriter out = response.getWriter();
			out.write(Integer.toString(this.hitCount));
		}

		else if(pathInfo.matches("^/libdescriptions/.*")) {
			String json = "{";
			for(String l : lib_descriptions.keySet()) {
				json = json + "\"" + l + "\":[";
				json = json + "\"" + lib_descriptions.get(l) + "\"],";
			}
			json = json + "}";

			//remove trailing comma
			json = json.replaceAll("],}", "]}");	
			response.getWriter().write(json);
		}

		else {
			PrintWriter out = response.getWriter();
			response.setHeader("Content-Type", "application/json");
			String json = "{\"error\": \"api endpoint not supported\", \"endpoint:\" : \""+pathInfo+"\"}";
			out.write(json);
		}
	}

	public String resultsToJSON(HashMap<String, ArrayList<Overlap>> results, HashMap<String, ArrayList<IntegratedRank>> integ) {
		String json = "{";

		for(String key: integ.keySet()) {
			json = json + "\"" + "Integrated--" + key + "\":[";
			ArrayList<IntegratedRank> integ_results = integ.get(key);
			for(IntegratedRank i: integ_results) {
				String entry = "{\"Query Name\":" + "\"" + i.query_name + "\"" + ",";
				entry = entry + "\"Rank\":" + "\"" + Integer.toString(i.rank) + "\"" + ",";
				entry = entry + "\"TF\":" + "\"" + i.tf + "\"" + ",";
				entry = entry + "\"Score\":" + "\"" + Double.toString(sigDig(i.score,4)) + "\"" + ",";
				entry = entry + "\"Library\":" + "\"" + i.lib.replace("--"," ") + "\"" + "," ;
				entry = entry + "\"Overlapping_Genes\":" + "\"" + set2String(i.genes) + "\"}," ;
				json = json + entry;

			}

			//remove trailing comma
			json = json.replaceAll(",$", "");
			json = json + "],";

		}

		for(String key: results.keySet()) {
			json = json + "\"" + key + "\":[";
			ArrayList<Overlap> libresults = results.get(key);

			for(Overlap o: libresults) {
				String entry = "{\"Query Name\":" + "\"" + o.query_name + "\"" + ",";
				entry = entry + "\"Rank\":" + "\"" + Integer.toString(o.rank) + "\"" + ",";
				entry = entry + "\"Scaled Rank\":" + "\"" + Double.toString(sigDig(o.scaledRank,4)) + "\"" + ",";
				entry = entry + "\"Set_name\":" + "\"" + o.libset_name + "\"" + ",";
				entry = entry + "\"TF\":" + "\"" + o.lib_tf+ "\"" + ",";
				entry = entry + "\"Intersect\":" + "\"" + Integer.toString(o.overlap)+ "\"" + ",";
				entry = entry + "\"Set length\":"  + "\"" + Integer.toString(o.setsize) + "\"" + ",";
				entry = entry + "\"FET p-value\":" + "\"" + Double.toString(sigDig(o.pval,4)) + "\"" + ",";
				entry = entry + "\"FDR\":" + "\"" + Double.toString(sigDig(o.fdr,3)) + "\"" + ",";
				entry = entry + "\"Odds Ratio\":" + "\"" + Double.toString(sigDig(o.oddsratio,4)) + "\"" + ",";
				entry = entry + "\"Library\":" + "\"" + o.lib_name + "\"" + ",";
				entry = entry + "\"Overlapping_Genes\":" + "\"" + set2String(o.genes) + "\"}," ;
				json = json + entry;	
			}

			//remove trailing comma
			json = json.replaceAll(",$", "");
			json = json + "],";

		}

		//remove trailing comma
		json = json.replaceAll(",$", "");
		json = json + "}";

		return json;
	}


	public int readHits(String hit_filename, EnrichmentCore c) {
		InputStream file = c.getServletContext().getResourceAsStream(hit_filename);

		BufferedReader br = new BufferedReader(new InputStreamReader(file));
		int h = -1;
		try {
			h = Integer.parseInt(br.readLine());

		} catch (IOException e) {

			e.printStackTrace();
		}
		return(h);	
	}

	private void writeHits(String hit_filename, EnrichmentCore c) throws IOException {

		//only write to file if hitCount is valid
		if(this.hitCount>0) {
			FileWriter f;


			String contextPath = c.getServletContext().getRealPath("/");

			String hits_filepath=contextPath+hit_filename;

			System.out.println(hits_filepath);

			File myfile = new File(hits_filepath);

			f = new FileWriter(myfile,false);
			f.write(Integer.toString(this.hitCount));
			f.flush();
			f.close();

		}

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

	private static String[] toUpper(String[] genes) {
		for(int i=1; i<genes.length; i++) { //why doesn't i start at 0? come back to this.
			genes[i] = genes[i].toUpperCase();
		}
		return(genes);
	}
	
	private static String set2String(HashSet<String> stringset) {
		return(String.join(",", stringset));
	}
	
	private void computeFDR(ArrayList<Overlap> over){
		 //sort Overlap object
		 Collections.sort(over);
		 
		 //get pvals from overlap object
		 double pvals[] = new double[over.size()];
		 int i=0;
		 for(Overlap o: over) {
			 pvals[i] = o.getPval();
			 i++;	 
		 }
		 
	    BenjaminiHochberg bh  = new BenjaminiHochberg(pvals);
	    bh.calculate();
	    double[] adj_pvals = bh.getAdjustedPvalues();
	    int j = 0;
	    for(Overlap o: over) {
	    	o.setFDR(adj_pvals[j]);
	    	//System.out.println(pvals[j]);
	    	//System.out.println(adj_pvals[j]);
	    	j++;

	    }
	    
	    	
	 }



}



