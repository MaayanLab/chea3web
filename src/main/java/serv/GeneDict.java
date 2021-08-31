package main.java.serv;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;



import java.io.InputStreamReader;



/**
 * Servlet implementation class GeneDict
 */


public class GeneDict{

	public HashMap<String, Short> encode = new HashMap<String, Short>();
	public HashMap<Short, String> decode = new HashMap<Short, String>();
	
	
	/**
	 * constructor
	 */
	public GeneDict(String hgnc_filename, EnrichmentCore c) throws IOException {
		
		InputStream file = c.getServletContext().getResourceAsStream(hgnc_filename);
		
		BufferedReader br = new BufferedReader(new InputStreamReader(file));
		String st;
		
		//check for uniqueness
		
		short value = Short.MIN_VALUE;
		while ((st = br.readLine()) != null) {
			this.encode.put(st, value);
			value++;	
		}
		System.out.println(value);
		br.close();
		this.decode = ReverseDict(this.encode);
	}
	
	public static HashMap<Short, String> ReverseDict(HashMap<String, Short> dict){
		HashMap<Short, String> revdict = new HashMap<Short, String>();
		
		for(String key : dict.keySet()) {
			revdict.put(dict.get(key), key);
		}
		
		return(revdict);
	}
	
	public HashMap<String, Short> getEnDict(){
		return this.encode;
	}
	
	public  HashMap<Short, String> getDeDict(){
		return this.decode;
	}
	

}

