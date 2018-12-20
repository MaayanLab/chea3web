package jsp;

public class Overlap implements Comparable<Overlap>{
	public int overlap;
	public double pval = 0;
	public int id = 0;
	public String libset_name = "";
	public String lib_name = "";
	public String query_name = "";
	public String lib_tf = "";
	public int setsize = 0;
	public double oddsratio = 0;
	public int rank = 0;
	public float scaledRank = 0;


	public Overlap(String libset_name, int overlap, double pval, int setsize, double odds, String lib_name, String query_name) {
		this.pval = pval;
		this.overlap = overlap;
		this.libset_name = libset_name;
		this.query_name = query_name;
		this.setsize = setsize;
		this.oddsratio = odds;
		this.lib_name = lib_name;
		this.lib_tf =  before(this.libset_name,"_");
	}

	public void setRank(int rank) {
		this.rank = rank;
	}
	
	public void setScaledRank(float sc) {
		this.scaledRank = sc;
	}

	@Override
	public int compareTo(Overlap o) {

		double comparep=((Overlap)o).getPval() - this.pval;

		if(comparep < 0) {
			return 1; 
		}else if(comparep > 0) {
			return -1;
		}else {
			return 0;
		}

	}

	public double getPval() {
		return this.pval;
	}
	
	private static String before(String value, String a) {
	    // Return substring containing all characters before a string.
	    int posA = value.indexOf(a);
	    if (posA == -1) {
	        return value;
	    }
	    return value.substring(0, posA);
	}

}
