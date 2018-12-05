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
	private int hitCount;
	private int write_hits = 10;
	private int hitIncr;


	public boolean initialized = false;

	static GeneDict dict = null;
	static HashSet<GenesetLibrary> libraries = new HashSet<GenesetLibrary>();

	static Enrichment enrich = null;

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

		//initialize dictionary object
		try {
			EnrichmentCore.dict = new GeneDict("WEB-INF/dict/hgnc_symbols.txt", this);
			//System.out.println(EnrichmentCore.dict.encode.get("FOXO1"));
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		//read hit counter file
		this.hitCount = readHits("WEB-INF/hits.txt", this);
		//initialize hitIncr
		this.hitIncr = 0;
		
			
		//initialize enrichment object
		EnrichmentCore.enrich = new Enrichment();

		//get gmt file paths
		String libdir = "WEB-INF/tflibs/";
		String[] filenames = new File(getServletContext().getRealPath(libdir)).list(); 
		HashSet<String> libpaths = new HashSet<String>();
		for(String f: filenames) {
			libpaths.add(libdir + f);
		}

		//generate gene set library objects
		for(String l: libpaths) {
			try {
				EnrichmentCore.libraries.add(new GenesetLibrary(l,dict,true,this));
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	public void destroy() {
		System.out.println("destroying server instance");
		try {
			this.writeHits("WEB-INF/hits.txt", this);
		} catch (IOException e) {
			e.printStackTrace();
		}
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
			

			String[] genes = truncPathInfo.split(",");

			Query q = new Query(genes, EnrichmentCore.dict);

			//compute enrichment for each library

			HashMap<String, ArrayList<Overlap>> results = new HashMap<String, ArrayList<Overlap>>();

			for(GenesetLibrary lib: EnrichmentCore.libraries) {
				ArrayList<Overlap> enrichResult = enrich.calculateEnrichment(q.dictMatch, lib.mappableSymbols);
				Collections.sort(enrichResult);
				results.put(lib.name,enrichResult);
			}		
			
			String json = resultsToJSON(results);
			
			//respond to request
			response.setContentType("text/plain");
			response.getWriter().write(json);
			
		}
		else if(pathInfo.matches("^/main/.*")) {
			PrintWriter out = response.getWriter();
			out.write(Integer.toString(this.hitCount));
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
				String entry = "{\"Set name\":" + "\"" + o.name + "\"" + ",";
				entry = entry + "\"TF\":" + "\"" + before(o.name,"_")+ "\"" + ",";
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
	
	private static String before(String value, String a) {
	    // Return substring containing all characters before a string.
	    int posA = value.indexOf(a);
	    if (posA == -1) {
	        return value;
	    }
	    return value.substring(0, posA);
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
	
}



