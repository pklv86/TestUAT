/* 
 * Name: LDCAccountTrigger
 * Type: Apex Trigger
 * Test Class: Covered under the respective main classes
 * Description:  This class contains the logic to invoke method in handler class
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         KPMG                     02/01/2016       1. Initial Version created
 */
trigger LDCAccountTrigger on LDC_Account__c (before insert, before update, after update) {
    
    // Added by Sneha on 03/02/2016, to populate the CRM ID on LDC Account
    Boolean hasAccess = true;
    String Usr = Label.Bypass_Users;
    list<string> UsrLst = Usr.split(';');
    for(string str : UsrLst){
        if(UserInfo.getName() == str){
            hasAccess = false;
            system.debug('------------------------ Bypassed User ------------------------');
        }
    }
    set<id> setAccount = new set<id>();
    set<id> setBusiness = new set<id>();
    //set<id> oldAccSet = new set<id>();
    List<Account> lstBusinessAcc = new List<Account>();
    
    if(hasAccess && TriggerHandler.LSResponse){    
        set<id> ldcset = new set<id>();       
        LDCAccountTriggerHandler ldchandler;
        
        if(Trigger.isbefore && Trigger.isInsert){
            set<id> accid = new set<id>();
            account acct = new account();
            for(ldc_account__c lacc : trigger.new){
                accid.add(lacc.account__c);
            } 
            map<id,account> accmap = new map<id,account>([select id,name,recordtype.name,industry,account.business_account__c from account where id =:accid ]);
            
            for(ldc_account__c lacc : trigger.new){
               if(lacc.account__c != null) 
                    acct = accmap.get(lacc.account__c); 
                
               //Included changes for LDC Type from Customer  T-001529 
               if(acct != null && acct.business_account__c == null && acct.industry != null &&  acct.industry == 'Government'){
                    lacc.ldc_type__c = 'Governmental'; 
                    system.debug('\n LDC Account -- LDC Type : '+lacc.ldc_type__c); 
               }               
            }
        }
         
        for(LDC_Account__c  ldc :Trigger.new){
            if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) && String.isBlank(ldc.CRM_Id__c) ) {
               ldc.CRM_Id__c = DynegyCommonUtils.generateRandomString(15); 
            }
           
            if(Trigger.isBefore && !system.isBatch() ){
                system.debug('pricingUpdate : '+TriggerHandler.pricingUpdate);
                system.debug('EDIUpdate : '+TriggerHandler.EDIUpdate);
                if(Trigger.isInsert){
                    ldcset.add(ldc.id); 
                    ldc.Is_Record_updated__c = true;
                }  
                else if(Trigger.isUpdate) {
                    if(((Trigger.oldMap.get(ldc.Id).Acct_ADU__c != null && Trigger.oldMap.get(ldc.Id).Acct_ADU__c != ldc.Acct_ADU__c) 
                        || (Trigger.oldMap.get(ldc.Id).Capacity_PLC1__c != null && Trigger.oldMap.get(ldc.Id).Capacity_PLC1__c != ldc.Capacity_PLC1__c)
                        || (Trigger.oldMap.get(ldc.Id).NSPL1_KW__c != null && Trigger.oldMap.get(ldc.Id).NSPL1_KW__c != ldc.NSPL1_KW__c)
                        || (Trigger.oldMap.get(ldc.Id).On_PK_Kwh__c != null && Trigger.oldMap.get(ldc.Id).On_PK_Kwh__c != ldc.On_PK_Kwh__c) 
                        || (Trigger.oldMap.get(ldc.Id).Off_PK_Kwh__c != null && Trigger.oldMap.get(ldc.Id).Off_PK_Kwh__c != ldc.Off_PK_Kwh__c)
                        || (Trigger.oldMap.get(ldc.Id).FRM_Profile__c != null && Trigger.oldMap.get(ldc.Id).FRM_Profile__c != ldc.FRM_Profile__c)
                        || (Trigger.oldMap.get(ldc.Id).Utility_Zone__c != null && Trigger.oldMap.get(ldc.Id).Utility_Zone__c != ldc.Utility_Zone__c))
                        && TriggerHandler.pricingUpdate){
                        //if(TriggerHandler.EDIUpdate) 
                            ldcset.add(ldc.id);
                        //else
                            ldc.Is_Record_updated__c = true; 
                    }
                    else if(((Trigger.oldMap.get(ldc.Id).Acct_ADU__c == null && ldc.Acct_ADU__c != null) 
                        || (Trigger.oldMap.get(ldc.Id).Capacity_PLC1__c == null && ldc.Capacity_PLC1__c != null)
                        || (Trigger.oldMap.get(ldc.Id).Capacity_PLC2__c == null && ldc.Capacity_PLC2__c != null)
                        || (Trigger.oldMap.get(ldc.Id).NSPL1_KW__c == null && ldc.NSPL1_KW__c != null)
                        || (Trigger.oldMap.get(ldc.Id).NSPL2_KW__c == null && ldc.NSPL2_KW__c != null)
                        || (Trigger.oldMap.get(ldc.Id).On_PK_Kwh__c == null && ldc.On_PK_Kwh__c != null) 
                        || (Trigger.oldMap.get(ldc.Id).Off_PK_Kwh__c == null && ldc.Off_PK_Kwh__c != null)
                        || (Trigger.oldMap.get(ldc.Id).FRM_Profile__c == null && ldc.FRM_Profile__c != null)
                        || (Trigger.oldMap.get(ldc.Id).Utility_Zone__c == null && ldc.Utility_Zone__c != null))
                        || !TriggerHandler.pricingUpdate ){
                        
                       ldc.Is_Record_updated__c = true;   
                    }
                    /*else if((Trigger.oldmap.get(ldc.id).account__c != null && Trigger.oldmap.get(ldc.id).account__c != ldc.account__c)
                        || (Trigger.oldmap.get(ldc.id).account__r.business_account__c != null && Trigger.oldmap.get(ldc.id).account__r.business_account__c != ldc.account__r.business_account__c)){
                        system.debug('C&I : '+Trigger.oldmap.get(ldc.id).account__c+' Mass/Muni : '+Trigger.oldmap.get(ldc.id).account__r.business_account__c);
                        system.debug('New C&I : '+ldc.account__c+' New Mass/Muni : '+ldc.account__r.business_account__c);
                        ldc.Is_Record_updated__c = true;
                        oldAccSet.add(Trigger.oldmap.get(ldc.id).account__c);
                    }*/
                } 
            } 
            if(Trigger.isAfter){
                if(Trigger.isUpdate){                
                    if(Trigger.oldMap.get(ldc.Id).Capacity_PLC1__c == null && ldc.Capacity_PLC1__c != null ){                   
                        setAccount.add(Trigger.oldMap.get(ldc.Id).account__c);                  
                    }               
                    system.debug('\n====setAccount===='+setAccount);
                }
            }   
            system.debug('LDC Record Update : '+ldc.Is_Record_updated__c);         
        }
        
        if(!setAccount.isempty()){
            for(Account accRec : [SELECT ID, business_account__c, PLC_Change__c, business_account__r.PLC_Change__c FROM Account WHERE Id IN :setAccount and business_account__r.PLC_Change__c = false ]){          
               if(accRec.business_account__c != null){                
                    Account acc = new account();
                    acc.Id = accRec.business_account__c;
                    if(!setBusiness.contains(accRec.Business_account__c)){
                        setBusiness.add(accRec.Business_account__c);
                        acc.PLC_Change__c = true;
                        lstBusinessAcc.add(acc);
                    }
               }
               else{
                    Account acc = new account();
                    acc.Id = accRec.Id;
                    if(!setBusiness.contains(accRec.Id)){
                        setBusiness.add(accRec.Id);
                        acc.PLC_Change__c = true;
                        lstBusinessAcc.add(acc);
                    }
               }               
            }
        }
        system.debug('\n lstBusinessAcc :'+lstBusinessAcc);
        if(!lstBusinessAcc.isEmpty()){
            update lstBusinessAcc;
        }
        system.debug('LDC Set : '+ldcset.size()+' : '+ldcset);
         
        system.debug('LDC Set : '+ldcset.size()+' : '+test.isrunningtest());
        if(!Trigger.isBefore && !Trigger.isInsert)
                TriggerHandler.firstRun = false;
                
        if(!ldcset.isempty()){
            if(!Trigger.isBefore && !Trigger.isInsert)
                TriggerHandler.firstRun = false;
            //ldchandler = new LDCAccountTriggerHandler();
            //ldchandler.updateLDCIndividualInfo(ldcset);
        }
        
        if(Trigger.isAfter && Trigger.isUpdate && TriggerHandler.firstRun && TriggerHandler.pricingUpdate) {
           system.debug('Hitting');
           list<ldc_account__c> ldclst = new list<ldc_account__c>();
           for(ldc_account__c ldc : Trigger.new){
               if((Trigger.oldMap.get(ldc.Id).Acct_ADU__c != null && Trigger.oldMap.get(ldc.Id).Acct_ADU__c != ldc.Acct_ADU__c) 
                    || (Trigger.oldMap.get(ldc.Id).Capacity_PLC1__c != null && Trigger.oldMap.get(ldc.Id).Capacity_PLC1__c != ldc.Capacity_PLC1__c)
                    || (Trigger.oldMap.get(ldc.Id).NSPL1_KW__c != null && Trigger.oldMap.get(ldc.Id).NSPL1_KW__c != ldc.NSPL1_KW__c)
                    || (Trigger.oldMap.get(ldc.Id).On_PK_Kwh__c != null && Trigger.oldMap.get(ldc.Id).On_PK_Kwh__c != ldc.On_PK_Kwh__c) 
                    || (Trigger.oldMap.get(ldc.Id).Off_PK_Kwh__c != null && Trigger.oldMap.get(ldc.Id).Off_PK_Kwh__c != ldc.Off_PK_Kwh__c)
                    || (Trigger.oldMap.get(ldc.Id).FRM_Profile__c != null && Trigger.oldMap.get(ldc.Id).FRM_Profile__c != ldc.FRM_Profile__c)
                    || (Trigger.oldMap.get(ldc.Id).Utility_Zone__c != null && Trigger.oldMap.get(ldc.Id).Utility_Zone__c != ldc.Utility_Zone__c)){
                    
                   ldcset.add(ldc.id);  
                   system.debug('LDC Account : '+ldc);
                   system.debug('OLD MAP : '+Trigger.oldMap.get(ldc.Id));
               }
            }
            if(!ldcset.isempty()){
                ldchandler = new LDCAccountTriggerHandler();
                ldchandler.updateLDCIndividualInfo(ldcset);
            }
        }
        
        if(Trigger.isAfter && Trigger.isUpdate){
        	set<id> ooldcset = new set<id>();
        	for(ldc_account__c ldc : Trigger.new){
        		if(trigger.oldmap.get(ldc.id).opt_out__c != ldc.opt_out__c && ldc.opt_out__c == true){
					ooldcset.add(ldc.id);
        		}
        	}
        	if(!ooldcset.isempty()){
        		ldchandler = new LDCAccountTriggerHandler();
            	ldchandler.processOptOut(ooldcset);
        	}
        }
    }
}