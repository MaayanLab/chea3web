package serv;

import java.io.*;
import java.util.HashMap;
import java.util.HashSet;

public class GenesetLibrary {
	public String name;
	public String description = null;
	public HashMap<String, HashSet<String>> allSymbols = new HashMap<String, HashSet<String>>();
	public HashMap<String, HashSet<String>> mappableSymbols = new HashMap<String, HashSet<String>>();
	public HashMap<String, short[]> encoded = new HashMap<String, short[]>();
	public HashSet<String> symbolsNotFound = new HashSet<String>();

	/**
	 * constructor reads flat GMT file and generates short encoding from dictionary
	 * @throws IOException 
	 */
	public GenesetLibrary(String gmtfilename, GeneDict dict, boolean removeGeneWeights, EnrichmentCore ec) throws IOException {
		this.allSymbols = LoadGenesetLib(gmtfilename,removeGeneWeights, ec);
		this.name = gmtfilename.replaceAll(".*/tflibs/", "").split("_")[0];	
		this.mappableSymbols = getMappableSymbols(this.allSymbols, dict);
		this.symbolsNotFound = getUnmappableSymbols(this.allSymbols, dict);
		this.encoded = EncodeLibrary(this.mappableSymbols, dict);
	}

	public static HashMap<String, HashSet<String>> LoadGenesetLib(String gmtfilename, boolean removeGeneWeights, EnrichmentCore ec) throws IOException {
		HashMap<String, HashSet<String>> genesetlib = new HashMap<String, HashSet<String>>();

		// load gmt file
		InputStream file = ec.getServletContext().getResourceAsStream(gmtfilename);		
		BufferedReader br = new BufferedReader(new InputStreamReader(file));
		
		String st;
		while ((st = br.readLine()) != null) {

			String[] tokens = st.split("\\t");
			HashSet<String> set = new HashSet<String>();

			String geneset_name = tokens[0];
			for (int x=1; x<tokens.length; x++) {
				String gene = tokens[x];
				if(removeGeneWeights) {
					set.add(RemoveGeneWeight(gene));
				}else {
					set.add(gene);
				}

			}
			genesetlib.put(geneset_name, set);
		}
		br.close();
		


		return (genesetlib);
	}
	
	public void loadLibDescription(String path, EnrichmentCore ec) throws IOException{
				// load gmt file
				InputStream file = ec.getServletContext().getResourceAsStream(path);		
				BufferedReader br = new BufferedReader(new InputStreamReader(file));	
				this.description = br.readLine();
	}

	public static HashMap<String, short[]> EncodeLibrary(HashMap<String, HashSet<String>> lib, GeneDict dict) {

		HashMap<String, short[]> encoded_lib = new HashMap<String, short[]>();
		for(String set_name: lib.keySet()) {
			HashSet<String> geneset = lib.get(set_name);
			short[] encoded_geneset = new short[geneset.size()];
			int i = 0;
			for(String gene: geneset) {
				encoded_geneset[i] = dict.encode.get(gene);	
				i++;
			}
			encoded_lib.put(set_name, encoded_geneset);	
		}	
		return(encoded_lib);

	}



	public static HashMap<String, HashSet<String>> getMappableSymbols(HashMap<String, HashSet<String>> lib, GeneDict dict){

		HashMap<String, HashSet<String>> mappableLib = new HashMap<String, HashSet<String>>();

		for(String set_name: lib.keySet()) {
			HashSet<String> mappable = new HashSet<String>();
			for(String gene:lib.get(set_name)) {
				if(dict.encode.containsKey(gene)) {
					mappable.add(gene);
					//System.out.println(gene);
				}
			}
			mappableLib.put(set_name, mappable);
		}

		return(mappableLib);
	}

	public static HashSet<String> getUnmappableSymbols(HashMap<String, HashSet<String>> lib, GeneDict dict){

		HashSet<String> unmappable = new HashSet<String>();
		for(String set_name: lib.keySet()) {
			for(String gene:lib.get(set_name)) {
				if(!dict.encode.containsKey(gene)) {
					unmappable.add(gene);
					//System.out.println(gene);

				}
			}
		}

		return(unmappable);



	}

	public static String RemoveGeneWeight(String gene) {
		return(gene.split(",")[0]);
	}
	
	private void setDescription(String desc) {
		this.description = desc;
	}

//	public static void main(String[] args) throws IOException {
//		//initialize dictionary object
//		GeneDict dict = new GeneDict("./WebContent/dict/hgnc_symbols.txt");
//		
//		// initialize FET object
//		FastFisher fet = new FastFisher(40000);
//
//		//get gmt file paths
//		String libdir = "./WebContent/tflibs/";
//		
//		HashSet<String> filenames = new HashSet<String>();
//
//		File[] files = new File(libdir).listFiles();
//
//		for (File file : files) {
//			if (file.isFile()) {
//				filenames.add(libdir + file.getName());
//			}
//		}
//
//		//generate gene set library objects
//		HashSet <GenesetLibrary> libraries= new HashSet <GenesetLibrary>();
//		for(String libpath: filenames) {
//			libraries.add(new GenesetLibrary(libpath,dict,true));
//		}
//		
//	}

}
