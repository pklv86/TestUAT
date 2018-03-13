public class TriggerHandler { 
    public static boolean firstRun = true;  
    public static boolean pricingUpdate = true;
    public static boolean EDIUpdate = true;
    public static boolean LSResponse = true;                // Used for LS response to sf and also for account supplement trigger
    public static boolean contractValidation = true;        //Used for Contract activation and contract term's 
    public static boolean changeDASR = true;                //Used for Peakload insertion
}