package jsp;

public class Overlap implements Comparable<Overlap>{
	public int overlap;
	public double pval = 0;
	public int id = 0;
	public String name = "";
	public int setsize = 0;
	public double oddsratio = 0;
	public int rank = 0;

	public Overlap(String name, int overlap, double pval, int setsize, double odds) {
		this.pval = pval;
		this.overlap = overlap;
		this.name = name;
		this.setsize = setsize;
		this.oddsratio = odds;
	}

	public void setRank(int rank) {
		this.rank = rank;
	}

	@Override
	public int compareTo(Overlap o) {

		double comparep=((Overlap)o).getPval() - this.pval;

		if(comparep < 0) {
			return 1; 
		}else if(comparep > 0) {
			return -1;
		}else {
			double r = Math.random();
			if(r < 0.5) {
				return -1;
			}
			else {
				return 1;
			}
		}

	}

	public double getPval() {
		return this.pval;
	}

}
