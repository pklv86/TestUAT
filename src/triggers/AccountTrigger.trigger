trigger AccountTrigger on Account(before insert, before update, after insert, after update) {
    
    Boolean hasAccess = true;
    String Usr = Label.Bypass_Users;
    list<string> UsrLst = Usr.split(';');
    for(string str : UsrLst){
        if(UserInfo.getName() == str){
            hasAccess = false;
            system.debug('------------------------ Bypassed User ------------------------');
        }
    }
    
    if(hasAccess && TriggerHandler.LSresponse){ 
        Set<Id> accountIdSet1 = new Set<Id> ();
        // Added by Sneha on 03/17/2016, to populate the short code on Account
        for (Account acc : Trigger.new) {
            if (((Trigger.isBefore && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate)) && String.isBlank(acc.Short_Code__c)) {
                acc.Short_Code__c = DynegyCommonUtils.generateRandomString(15);
            }         
        }
    
        //Added by Sneha on 03/17/2016, to populate the operating company field on individual customer record type  
        Map<id,RecordType> recMap = new Map<id,RecordType>();   
        if(recMap.isEmpty() && Trigger.isBefore){
        for(RecordType rt : [select id,name from RecordType where name in ('Mass Market Individual Customer','Muni Agg Individual Customer')]){
            recmap.put(rt.id,rt);
          }
        }
        
        set<id> personAcctid = new set<id>();
        Set<id> businessAccLst = new Set<Id> ();
        list<account> acclst2 = new list<account>();
        for (Account acc : Trigger.new) {
            if (acc.Business_Account__c != null){
                personAcctid.add(acc.id);
                businessAccLst.add(acc.Business_Account__c);            
            }
        }
        
        Map<id,Account> accMap = new Map<Id,Account>();
        if(!businessAccLst.isEmpty()  && Trigger.isBefore){
            for(Account a : [select id,Supplier__c,muni_agg_type__c,Aggregator_Code__c from Account where id=:businessAccLst]){       
                accMap.put(a.id,a);
            } 
        }
           
        //Added to null Muni Agg Type and Aggregator Code for DEOHIO and when recordtype is Mass Market Individual Customer 
        map<id,ldc_account__c> mapaccldc = new map<id, ldc_account__c>();
        RecordType rectype;
        ldc_account__c ldcacc = new ldc_account__c();
        if(personAcctid.size()>0){    
            if(trigger.isBefore && trigger.isUpdate){
                list<ldc_account__C> ldclst = [select id, service_territory__C, account__c, account__r.recordtype.name from ldc_account__c where account__c in :personAcctid];              
                if(ldclst.size()>0){
                    for(ldc_account__c lacc : ldclst){
                        mapaccldc.put(lacc.account__c, lacc);
                    }
                }
            }
        }
        for (Account acc : Trigger.new) {
            if ((Trigger.isBefore && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate)) {
                if (acc.Business_Account__c != null && recMap != null && recMap.containskey(acc.recordTypeid) && accMap != null && accMap.containsKey(acc.Business_Account__c)){
                    acc.Supplier__c = accMap.get(acc.Business_Account__c).Supplier__c;       
                    if (Trigger.isBefore && Trigger.isUpdate){
                        if((Trigger.oldMap.get(acc.id).business_account__c != acc.business_account__c) || (trigger.oldMap.get(acc.id).recordtypeid != acc.recordtypeid)){
                            ldcacc = mapaccldc.get(acc.id);
                            rectype = recMap.get(acc.recordtypeid);
                            if(ldcacc != null && (ldcacc.service_territory__c == 'DEOHIO' || (rectype != null && rectype.name != 'Muni Agg Individual Customer'))) {
                                acc.muni_agg_type__c = '';
                                acc.Aggregator_Code__c = '';                            
                            }
                            else {
                                acc.muni_agg_type__c = accMap.get(acc.Business_account__c).muni_agg_type__c;
                                acc.Aggregator_Code__c = accMap.get(acc.Business_account__c).Aggregator_Code__c;
                            }                         
                        }
                    } 
                }
            }   
        }
    
        //Added by CJG - 04/20/2016 - in order to handle Account updates where account has children associated with it,
        //                            if the parent Account is updated, the child account needs to be resent to lodestar
        //                            with the new data.
        system.debug('EDIUpdate : '+TriggerHandler.EDIUpdate);
        if (Trigger.isAfter && Trigger.isUpdate) {
          Set<Id> accountIdSet = new Set<Id> ();
            for (Account a : Trigger.new) {
                if (Trigger.oldMap.get(a.Id).Short_Code__c != a.Short_Code__c ||
                    Trigger.oldMap.get(a.Id).BillingStreet != a.BillingStreet || Trigger.oldMap.get(a.Id).BillingState != a.BillingState ||
                    Trigger.oldMap.get(a.Id).BillingCity != a.BillingCity || Trigger.oldMap.get(a.Id).BillingPostalCode != a.BillingPostalCode) {            //Trigger.oldMap.get(a.Id).Name != a.Name 
                      accountIdSet.add(a.Id);
                }
                if (a.LodeStar_Integration_Status__c != null && a.LodeStar_Integration_Status__c.equalsIgnoreCase('Not Synchronized') && Trigger.oldMap.get(a.id).LodeStar_Integration_Status__c != Trigger.newMap.get(a.id).LodeStar_Integration_Status__c && !system.isBatch() && TriggerHandler.EDIUpdate) {       
                    accountIdSet1.add(a.Id);
                }
            }
            if(accountIdSet1.size() > 0)
              AccountTriggerHandler.setLDCNotSynchronized(accountIdSet1,'ConLDC');
            if(accountIdSet.size() > 0)
              AccountTriggerHandler.SetChildAccountsToNotSynchronized(accountIdSet,'Person');
        }
    }
}