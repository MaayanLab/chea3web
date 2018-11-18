package serv;
import java.util.HashSet;
import java.util.Random;

/* This class is taken from the Pal-Project: http://www.cebl.auckland.ac.nz/pal-project/ */

/**
 * This does a Fisher Exact test.  The Fisher's Exact test procedure calculates an exact probability value
 * for the relationship between two dichotomous variables, as found in a two by two crosstable. The program
 * calculates the difference between the data observed and the data expected, considering the given marginal
 * and the assumptions of the model of independence. It works in exactly the same way as the Chi-square test
 * for independence; however, the Chi-square gives only an estimate of the true probability value, an estimate
 * which might not be very accurate if the marginal is very uneven or if there is a small value (less than five)
 * in one of the cells.
 *
 * It uses an array of factorials initialized at the beginning to provide speed.
 * There could be better ways to do this.
 *
 * @author Ed Buckler
 * @version $Id: FisherExact.java,v 1
 */

public class FastFisher {
    private static final boolean DEBUG = false;
    private double[] f;
    private double[] ef;
    int maxSize;


    /**
     * constructor for FisherExact table
     *
     * @param maxSize is the maximum sum that will be encountered by the table (a+b+c+d)
     */
    public FastFisher(int maxSize) {
        this.maxSize = maxSize;
        
        f = new double[maxSize + 1];

        f[0] = 0.0;
        for (int i = 1; i <= this.maxSize; i++) {
            f[i] = f[i - 1] + Math.log(i);
        }
    }

    /**
     * calculates the P-value for this specific state
     *
     * @param a     a, b, c, d are the four cells in a 2x2 matrix
     * @param b
     * @param c
     * @param d
     * @return the P-value
     */
    public final double getP2(int a, int b, int c, int d, double same) {
        return Math.exp(same - (f[a] + f[b] + f[c] + f[d]));
    }
    
    public final double getP3(int a, int b, int c, int d, double same) {
        return exp20(same - (f[a] + f[b] + f[c] + f[d]));
    }
    
    public static double exp5(double x) {
    	x = 1.0 + x / 32;
    	x *= x; x *= x; x *= x; x *= x; x *= x;
    	return x;
  	}
    
    public static double exp10(double x) {
    	  x = 1.0 + x / 1024;
    	  x *= x; x *= x; x *= x; x *= x;
    	  x *= x; x *= x; x *= x; x *= x;
    	  x *= x; x *= x;
    	  return x;
    }
    
    public static double exp20(double x) {
    	x = 1.0 + x / 1048576;
    	x *= x; x *= x; x *= x; x *= x;
    	x *= x; x *= x; x *= x; x *= x;
    	x *= x; x *= x;
    	x *= x; x *= x; x *= x; x *= x;
    	x *= x; x *= x; x *= x; x *= x;
    	x *= x; x *= x;
    	return x;
  	}
    
    /**
     * calculates the P-value for this specific state
     *
     * @param a     a, b, c, d are the four cells in a 2x2 matrix
     * @param b
     * @param c
     * @param d
     * @return the P-value
     */
    public final double getP(int a, int b, int c, int d) {
        int n = a + b + c + d;
        if (n > maxSize) {
            return Double.NaN;
        }
        double p;
        p = (f[a + b] + f[c + d] + f[a + c] + f[b + d]) - (f[a] + f[b] + f[c] + f[d] + f[n]);
        return Math.exp(p);
    }

    /**
     * Calculates the one-tail P-value for the Fisher Exact test.  Determines whether to calculate the right- or left-
     * tail, thereby always returning the smallest p-value.
     *
     * @param a     a, b, c, d are the four cells in a 2x2 matrix
     * @param b
     * @param c
     * @param d
     * @return one-tailed P-value (right or left, whichever is smallest)
     */
    public final double getCumlativeP(int a, int b, int c, int d) {
        int min, i;
        int n = a + b + c + d;
        if (n > maxSize) {
            return Double.NaN;
        }
        double p = 0;

        p += getP(a, b, c, d);
        if (DEBUG) {System.out.println("p = " + p);}
        if ((a * d) >= (b * c)) {
            if (DEBUG) {System.out.println("doing R-tail: a=" + a + " b=" + b + " c=" + c + " d=" + d);}
            min = (c < b) ? c : b;
            for (i = 0; i < min; i++) {
                if (DEBUG) {System.out.print("doing round " + i);}
                p += getP(++a, --b, --c, ++d);
                if (DEBUG) {System.out.println("\ta=" + a + " b=" + b + " c=" + c + " d=" + d);}
            }
            System.out.println("");
        }
        if ((a * d) < (b * c)) {
            if (DEBUG) {System.out.println("doing L-tail: a=" + a + " b=" + b + " c=" + c + " d=" + d);}
            min = (a < d) ? a : d;
            for (i = 0; i < min; i++) {
                if (DEBUG) {System.out.print("doing round " + i);}
                double pTemp = getP(--a, ++b, ++c, --d);
                if (DEBUG) {System.out.print("\tpTemp = " + pTemp);}
                p += pTemp;
                if (DEBUG) {System.out.println("\ta=" + a + " b=" + b + " c=" + c + " d=" + d);}
            }
        }
        return p;
    }

    /**
     * Calculates the right-tail P-value for the Fisher Exact test.
     *
     * @param a     a, b, c, d are the four cells in a 2x2 matrix
     * @param b
     * @param c
     * @param d
     * @return one-tailed P-value (right-tail)
     */
    public final double getRightTailedP(int a, int b, int c, int d) {
        int min, i;
        int n = a + b + c + d;
        if (n > maxSize) {
            return Double.NaN;
        }
        double p = 0;

        double same = f[a + b] + f[c + d] + f[a + c] + f[b + d] - f[n];
        
        //p += getP2(a, b, c, d, same);
        p += getP3(a, b, c, d, same);
        
        //p += getP(a, b, c, d);
       
        min = (c < b) ? c : b;
        for (i = 0; i < min; i++) {
            p += getP3(++a, --b, --c, ++d, same);

        }
        return p;
    }

    /**
     * Calculates the left-tail P-value for the Fisher Exact test.
     *
     * @param a     a, b, c, d are the four cells in a 2x2 matrix
     * @param b
     * @param c
     * @param d
     * @return one-tailed P-value (left-tail)
     */
    public final double getLeftTailedP(int a, int b, int c, int d) {
        int min, i;
        int n = a + b + c + d;
        if (n > maxSize) {
            return Double.NaN;
        }
        double p = 0;

        p += getP(a, b, c, d);
        if (DEBUG) {System.out.println("p = " + p);}
        if (DEBUG) {System.out.println("doing L-tail: a=" + a + " b=" + b + " c=" + c + " d=" + d);}
        min = (a < d) ? a : d;
        for (i = 0; i < min; i++) {
            if (DEBUG) {System.out.print("doing round " + i);}
            double pTemp = getP(--a, ++b, ++c, --d);
            if (DEBUG) {System.out.print("\tpTemp = " + pTemp);}
            p += pTemp;
            if (DEBUG) {System.out.println("\ta=" + a + " b=" + b + " c=" + c + " d=" + d);}
        }


        return p;
    }


    /**
     *   Calculates the two-tailed P-value for the Fisher Exact test.
     *
     *   In order for a table under consideration to have its p-value included
     *   in the final result, it must have a p-value less than the original table's P-value, i.e.
     *   Fisher's exact test computes the probability, given the observed marginal
     *   frequencies, of obtaining exactly the frequencies observed and any configuration more extreme.
     *   By "more extreme," we mean any configuration (given observed marginals) with a smaller probability of
     *   occurrence in the same direction (one-tailed) or in both directions (two-tailed).
     *
     * @param a     a, b, c, d are the four cells in a 2x2 matrix
     * @param b
     * @param c
     * @param d
     * @return two-tailed P-value
     */
    public final double getTwoTailedP(int a, int b, int c, int d) {
        int min, i;
        int n = a + b + c + d;
        if (n > maxSize) {
            return Double.NaN;
        }
        double p = 0;

        double baseP = getP(a, b, c, d);
//         in order for a table under consideration to have its p-value included
//         in the final result, it must have a p-value less than the baseP, i.e.
//         Fisher's exact test computes the probability, given the observed marginal
//         frequencies, of obtaining exactly the frequencies observed and any configuration more extreme.
//         By "more extreme," we mean any configuration (given observed marginals) with a smaller probability of
//         occurrence in the same direction (one-tailed) or in both directions (two-tailed).

        if (DEBUG) {System.out.println("baseP = " + baseP);}
        int initialA = a, initialB = b, initialC = c, initialD = d;
        p += baseP;
        if (DEBUG) {System.out.println("p = " + p);}
        if (DEBUG) {System.out.println("Starting with R-tail: a=" + a + " b=" + b + " c=" + c + " d=" + d);}
        min = (c < b) ? c : b;
        for (i = 0; i < min; i++) {
            if (DEBUG) {System.out.print("doing round " + i);}
            double tempP = getP(++a, --b, --c, ++d);
            if (tempP <= baseP) {
                if (DEBUG) {System.out.print("\ttempP (" + tempP + ") is less than baseP (" + baseP + ")");}
                p += tempP;
            }
            if (DEBUG) {System.out.println(" a=" + a + " b=" + b + " c=" + c + " d=" + d);}
        }

        // reset the values to their original so we can repeat this process for the other side
        a = initialA;
        b = initialB;
        c = initialC;
        d = initialD;

        if (DEBUG) {System.out.println("Now doing L-tail: a=" + a + " b=" + b + " c=" + c + " d=" + d);}
        min = (a < d) ? a : d;
        if (DEBUG) {System.out.println("min = " + min);}
        for (i = 0; i < min; i++) {
            if (DEBUG) {System.out.print("doing round " + i);}
            double pTemp = getP(--a, ++b, ++c, --d);
            if (DEBUG) {System.out.println("  pTemp = " + pTemp);}
            if (pTemp <= baseP) {
                if (DEBUG) {System.out.print("\ttempP (" + pTemp + ") is less than baseP (" + baseP + ")");}
                p += pTemp;
            }
            if (DEBUG) {System.out.println(" a=" + a + " b=" + b + " c=" + c + " d=" + d);}
        }
        return p;
    }

//    public static void main(String[] args) {
//
//        
//        
//        FastFisher fish = new FastFisher(11000);
//        double ff = fish.getRightTailedP(100, 500, 200, 10040);
//        System.out.println("p-value: "+ff);
//        
//        long time = System.currentTimeMillis();
//        System.out.println("e1: "+Math.exp(4.5));
//        for(int i=2; i< 1000000; i++) {
//        		double d = Math.exp(Math.log(i));
//        }
//        System.out.println(System.currentTimeMillis() - time);
//        
//        time = System.currentTimeMillis();
//        for(int i=2; i< 1000000; i++) {
//        		double d = exp20(Math.log(i));
//        }
//        System.out.println(System.currentTimeMillis() - time);
//        
//        time = System.currentTimeMillis();
//        for(int i=0; i< 1000000; i++) {
//        		//double e = Math.exp(Math.log(i));
//        		double e =  ff = fish.getRightTailedP((int)Math.round(Math.log(i)), 100, 200, 140);
//        		//double e = i + i + 4 + 5;
//        }
//        System.out.println(System.currentTimeMillis() - time);
//        
//        HashSet<Integer> i1 = new HashSet<Integer>();
//        HashSet<Integer> i2 = new HashSet<Integer>();
//        int[] i3  = new int[500];
//        Random r = new Random();
//        for(int i=0; i< 500; i++) {
//        		i1.add(r.nextInt(10000));
//        		i2.add(r.nextInt(10000));
//        		i3[i] = r.nextInt(10000);
//        }
//        
//        time = System.currentTimeMillis();
//        for(int i=0; i< 1000000; i++) {
//        		int size = 0;
//        		
//        		
//        	 	//HashSet<Integer> ti = new HashSet<Integer>(i1);
//        	 	//ti.retainAll(i2);
//        	 	//size = ti.size();
//        		
//        	 	
//        	 	for(int j=0; j<i3.length; j++) {
//        	 		if(i2.contains(i3[j])){
//        	 			size++;
//        	 		}
//        	 	}
//        	 	
//        	 	double e =  ff = fish.getRightTailedP(size, 100, 200, 140);
//        	 	//double e1 =  ff = fish.getRightTailedP(size+1, 100, 200, 140);
//        	 	//double e2 =  ff = fish.getRightTailedP(size+3, 100, 200, 140);
//        }
//
//        System.out.println(System.currentTimeMillis() - time);
//    }
}


