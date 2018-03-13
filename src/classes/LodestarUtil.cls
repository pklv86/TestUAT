/* 
 * Name: LodestarUtil
 * Type: Apex Class
 * Test Class: LodestarUtilTest
 * Description:  This class is to get the record type so that only that account would be sent to LS 
 * Change History:
 *=====================================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Chiatanya Kurra              10/25/2017       1. Initial Version created
*/
public class LodestarUtil {

    public static set<String> getrecordtype()
    {
        set<String> RecordtypeLS = new set<String>();
                
        for(Lodestar_Job__c LSVal : Lodestar_Job__c.getall().values())
        {
            if(LSVal.Hour__c  != null && LSVal.Hour__c == datetime.now().time().hour())
            {
                if(LSVal.C_I_Customer__c == TRUE)
                RecordtypeLS.add('C&I Customer');
                if(LSVal.Mass_Market_Individual_Customer__c == TRUE)
                RecordtypeLS.add('Mass Market Individual Customer');
                if(LSVal.Muni_Agg_Individual_Customer__c == TRUE)
                RecordtypeLS.add('Muni Agg Individual Customer');
            }
        }
    return RecordtypeLS;
    }

}