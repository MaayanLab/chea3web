package serv;

public class IntegratedRank implements Comparable<IntegratedRank>{
	String tf = "";
	float score;
	int rank;
	String lib_name = "";
	String query_name = "";
	
	public IntegratedRank(String tf, float score, String lib_name, String query_name) {
		this.tf = tf;
		this.score = score;
		this.lib_name = lib_name;
		this.query_name = query_name;
	}
	
	public float getScore() {
		return this.score;
	}
	
	@Override
	public int compareTo(IntegratedRank i) {

		double compares=((IntegratedRank)i).getScore() - this.score;

		if(compares < 0) {
			return 1; 
		}else if(compares > 0) {
			return -1;
		}else {
			return 0;
		}

	}
}
