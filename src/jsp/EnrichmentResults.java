package jsp;
import java.io.InputStream;
import java.util.HashMap;
import java.util.HashSet;

public class EnrichmentResults {
	
	public int listid;
	public String description;
	public HashSet<String> genes;
	public HashMap<Integer, HashMap<Integer, Overlap>> enrichment;
	
	public EnrichmentResults(int _id, String _desc, HashSet<String> _genes, HashMap<Integer, HashMap<Integer, Overlap>> _enrichment) {
		listid = _id;
		description = _desc;
		genes = _genes;
		enrichment = _enrichment;
	}
}
