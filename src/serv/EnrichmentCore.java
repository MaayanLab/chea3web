package serv;



import java.io.File;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import javax.servlet.RequestDispatcher;
import javax.servlet.Servlet;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import jsp.Overlap;

/**
 * Servlet implementation class Test
 */
@WebServlet("/api/*")
public class EnrichmentCore extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public boolean initialized = false;

	static GeneDict dict = null;
	static HashSet<GenesetLibrary> libraries = new HashSet<GenesetLibrary>();

	static Enrichment enrich = null;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public EnrichmentCore() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see Servlet#init(ServletConfig)
	 * 
	 * Initializes class variables
	 * 
	 */
	public void init(ServletConfig config) throws ServletException {
		super.init(config);

		//initialize dictionary object
		try {
			EnrichmentCore.dict = new GeneDict("WEB-INF/dict/hgnc_symbols.txt", this);
			//System.out.println(EnrichmentCore.dict.encode.get("FOXO1"));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		//initialize enrichment object
		EnrichmentCore.enrich = new Enrichment();

		//get gmt file paths
		String libdir = "WEB-INF/tflibs/";
		String[] filenames = new File(getServletContext().getRealPath(libdir)).list(); 
		HashSet<String> libpaths = new HashSet<String>();
		for(String f: filenames) {
			libpaths.add(libdir + f);
		}

		//System.out.println(libpaths);

		//generate gene set library objects
		for(String l: libpaths) {
			try {
				EnrichmentCore.libraries.add(new GenesetLibrary(l,dict,true,this));
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}







	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
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

		else if(pathInfo.matches("^/enrich/.*")){

			response.getWriter().println("You've reached the enrichment function!");
			//http://localhost:8080/chea3-dev/api/enrich/KIAA0907,KDM5A,CDC25A,EGR1,GADD45B,RELB,TERF2IP,SMNDC1,TICAM1,NFKB2,RGS2,NCOA3,ICAM1,TEX10,CNOT4,ARID4B,CLPX,CHIC2,CXCL2,FBXO11,MTF2,CDK2,DNTTIP2,GADD45A,GOLT1B,POLR2K,NFKBIE,GABPB1,ECD,PHKG2,RAD9A,NET1,KIAA0753,EZH2,NRAS,ATP6V0B,CDK7,CCNH,SENP6,TIPARP,FOS,ARPP19,TFAP2A,KDM5B,NPC1,TP53BP2,NUSAP1,SCCPDH,KIF20A,FZD7,USP22,PIP4K2B,CRYZ,GNB5,EIF4EBP1,PHGDH,RRAGA,SLC25A46,RPA1,HADH,DAG1,RPIA,P4HA2,MACF1,TMEM97,MPZL1,PSMG1,PLK1,SLC37A4,GLRX,CBR3,PRSS23,NUDCD3,CDC20,KIAA0528,NIPSNAP1,TRAM2,STUB1,DERA,MTHFD2,BLVRA,IARS2,LIPA,PGM1,CNDP2,BNIP3,CTSL1,CDC25B,HSPA8,EPRS,PAX8,SACM1L,HOXA5,TLE1,PYGL,TUBB6,LOXL1

			String truncPathInfo = pathInfo.replace("/enrich/", "");
			response.getWriter().println(truncPathInfo);

			String[] genes = truncPathInfo.split(",");

			Query q = new Query(genes, EnrichmentCore.dict);

			//compute enrichment for each library

			HashMap<String, ArrayList<Overlap>> results = new HashMap<String, ArrayList<Overlap>>();

			for(GenesetLibrary lib: EnrichmentCore.libraries) {
				response.getWriter().println(lib.symbolsNotFound);
				ArrayList<Overlap> enrichResult = enrich.calculateEnrichment(q.dictMatch, lib.mappableSymbols);
				Collections.sort(enrichResult);
				results.put(lib.name,enrichResult);
			}			
			response.getWriter().println(resultsToJSON(results));
		}

		else {
			PrintWriter out = response.getWriter();
			response.setHeader("Content-Type", "application/json");
			String json = "{\"error\": \"api endpoint not supported\", \"endpoint:\" : \""+pathInfo+"\"}";
			out.write(json);
		}
	}


	public String resultsToJSON(HashMap<String, ArrayList<Overlap>> results) {
		String json = "{";
		for(String key: results.keySet()) {
			json = json + "\"" + key + "\":[";
			ArrayList<Overlap> libresults = results.get(key);

			for(Overlap o: libresults) {
				String entry = "{\"Set1\":" + "\"" + o.name + "\"" + ",";
				entry = entry + "\"Intersect\":" + "\"" + Integer.toString(o.overlap)+ "\"" + ",";
				entry = entry + "\"Set length\":"  + "\"" + Integer.toString(o.setsize) + "\"" + ",";
				entry = entry + "\"FET p-value\":" + "\"" + Double.toString(o.pval) + "\"" + ",";
				entry = entry + "\"Odds Ratio\":" + "\"" + Double.toString(o.oddsratio) + "\"}," ;
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


}




