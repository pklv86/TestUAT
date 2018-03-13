/* 
 * Name: LDCAccountTriggerHandler
 * Type: Apex Class
 * Test Class: LDC Trigger
 * Description:  This class is a LDC Account Trigger Handler class. 
 * Change History:
 *=====================================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Prasad Paladugu              01/13/2017       1. Initial Version created
 * 2.0         Prasad Paladugu              03/27/2017       1. Updated the flow
 * 3.0         Prasad Paladugu              08/11/2017       1. Control the class invocation using static variables
 * 6.0         Prasad Paladugu              03/01/2018       1. Implemented the Never Served Accounts through trigger
 															 2. Moved related implementation from other class to this class for reusability
 */
 public with sharing class LDCAccountTriggerHandler {
    
    public list<DASR_Request__c> oodasrlst;
    public LDCAccountTriggerHandler(){
        
    }
    
    public void updateLDCIndividualInfo(set<id> ldcset){
        set<id> accset = new set<id>();
        for(ldc_account__c ldc : [select id,account__c,account__r.business_account__c from ldc_account__c where id IN : ldcset]){
            if(ldc.account__r.business_account__c != null)
                accset.add(ldc.account__r.business_account__c);
            else
                accset.add(ldc.account__c);
        }
        if(!accset.isempty()){
            LDCInfo ldc = new LDCinfo(accset);
            Database.executeBatch(ldc,1000);
        }
    }
    
    public void processOptOut(set<id> ldcset){
    	oodasrlst = new list<DASR_Request__c>();
    	string query ='Select LDC_Account__c, DASR_Type__c, Most_Recent_GAAD__c, Contract__c, Integration_Status__C, LDC_Account__r.LDC_Account_Status__c, LDC_Account__r.opt_out__c, LDC_Account__r.LDC_Vendor__r.Service_State__c, change_effective_date__c from DASR_Request__c where LDC_Account__r.opt_out__c = true and LDC_Account__r.LDC_Vendor__r.Service_State__c LIKE \'%IL%\' and change_effective_date__c != null and (Integration_Status__C = \'Complete\' or Integration_Status__C = \'Waiting For Response\') and DASR_Type__c = \'GAAE\' and ldc_account__c IN : ldcset';
    	system.debug('Query : '+query);
    	oodasrlst = database.query(query);
    	string init = 'Trigger';
    	generateGAADDasr(oodasrlst,init);
    }
    
    public void generateGAADDasr(list<dasr_request__c> oodasrlst, string init){
    	Map<string, DASR_Request__c>dasrRecMap = new Map<string, DASR_Request__c>();
        Map<string, LDC_Account__c>ldcAccountMap = new Map<string, LDC_Account__c>();
        set<string> ldcAccountIdSet = new set<string>();
        set<string> checkForAccountStatus = new set<string>();
        Map<string, boolean>boolMap = new Map<string, boolean>();
        set<string>addaccountId = new set<string>();
        List<DASR_Request__c> accountIdForAccountStatus = new List<DASR_Request__c>();
        for(dasr_request__c dasr : oodasrlst){
            ldcAccountIdSet.add(String.valueOf(dasr.get('LDC_Account__c')));
            if(String.valueOf(dasr.get('DASR_Type__c')) == 'GAAE'){
                checkForAccountStatus.add(String.valueOf(dasr.get('LDC_Account__c')));
            }
        }
        List<LDC_Account__c> ldcAccountList = [select id, opt_out__c, LDC_Account_Status__c from LDC_Account__c where id in: ldcAccountIdSet];
        List<DASR_Request__c> DASRtyGAADList = [select id, ldc_Account__c, LDC_Account__r.LDC_Account_Status__c, Drop_Date__c from DASR_Request__c where LDC_Account__c in: ldcAccountIdSet and DASR_Type__c ='GAAD'];
           
        for(LDC_Account__c ldc : ldcAccountList){
            ldcAccountMap.put(ldc.id,ldc);
        }
        
        for(DASR_Request__c dar : DASRtyGAADList){
            boolMap.put(dar.Ldc_Account__c,true);
        }
        
        List<DASR_Request__c> dasrList = new List<DASR_Request__c>();
        DASR_Request__c dasrObj;
        
        for(dasr_request__c dasr : oodasrlst){
            if(!boolMap.containskey(String.valueOf(dasr.get('LDC_Account__c')))){
                if(!addaccountId.contains(String.valueOf(dasr.get('LDC_Account__c')))){
                    if(ldcAccountMap.get(String.valueOf(dasr.get('LDC_Account__c'))).opt_out__c == true && (String.valueOf(dasr.get('Integration_Status__C')) == 'Waiting For Response' || String.valueOf(dasr.get('Integration_Status__C')) == 'Complete') && String.valueOf(dasr.get('DASR_Type__c')) == 'GAAE'){
                        Date dt = date.today();
                        Date dt1 = date.valueOf(dasr.get('change_effective_date__c'));
                        Integer dte = dt.daysBetween(dt1);
                        addaccountId.add(String.valueOf(dasr.get('LDC_Account__c')));
                        if(dte >= 5 && init == 'Trigger'){
                        	dasrObj = new DASR_Request__c();
                        	dasrObj.DROP_Transaction_Type__c = 'EC';
                        }
                        
                        if(dte >= 5 && init == 'Batch'){
                        	dasrObj = new DASR_Request__c();
                            dasrObj.DROP_Transaction_Type__c = 'EC';
                        }
                        else if(dte < 5 && init == 'Batch'){
                        	dasrObj = new DASR_Request__c();
                            dasrObj.DROP_Transaction_Type__c ='DR';
                        }
                        
                        if(dasrobj != null){
                        	dasrObj.DASR_Type__c = 'GAAD'; 
	                        dasrObj.LDC_Account__c = String.valueOf(dasr.get('LDC_Account__c'));
	                        dasrObj.Contract__c = String.valueOf(dasr.get('Contract__c'));
	                        dasrObj.DASR_Submit_Date__c = system.now();
	                        dasrObj.Drop_Date__c= system.today();
	                        dasrObj.billing_Entity__c ='Dynegy';
	                        dasrObj.Dynegy_Initiated__c = true;
                        	dasrList.add(dasrObj);  
	                        system.debug('dasrObj : '+dasrObj);
                        }
                    }
                }
            } 
        }
        if(!dasrList.isempty())database.insert(dasrList);
    }
}

/*********** OLD CODE  LINE 14***********/
        /*ldcset.clear();
        aggregateresult ar = [select count(id) from ldc_account__c where account__c IN : accset or account__r.business_account__c IN : accset];
        system.debug('aggregateresult : '+ar);
        Integer LDCCount = Integer.valueof(ar.get('expr0'));
        if(LDCCount <= 10000){
            for(ldc_account__c ldc : [select id from ldc_account__c where account__c IN : accset or account__r.business_account__c IN : accset]){
                ldcset.add(ldc.id);
            }
            
            if(!ldcset.isempty()){
                LDCInfo ldc = new LDCinfo(ldcset);
                Database.executeBatch(ldc,1000);
            }
        }
        else{*/