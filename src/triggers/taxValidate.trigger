/* 
 * Name: taxValidate
 * Type: Apex Trigger
 * Test Class: Covered under the respective main classes
 * Description:  This class contains the logic to invoke method in handler class
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Prasad Paladugu              10/18/2017       1. Initial Version created
 */
 
trigger taxValidate on Account_Supplement__c (before insert, before update,after insert, after update) {

   Boolean hasAccess = true;
    String Usr = Label.Bypass_Users;
    list<string> UsrLst = Usr.split(';');
    for(string str : UsrLst){
        if(UserInfo.getName() == str){
            hasAccess = false;
            system.debug('------------------------ Bypassed User ------------------------');
        }
    }
    if(hasAccess){
    	set<id> ldcset = new set<id>();
    	for(Account_Supplement__c asupp : trigger.new){
    		ldcset.add(asupp.ldc_account__c);
    	}
        if(trigger.isBefore){
        	map<id,list<Account_Supplement__c>> asmap = new map<id,list<Account_Supplement__c>>();
        	for(Account_Supplement__c asupp : [select id,name,ldc_account__c,Start_Date__c,End_Date__c,Type__c,Percentage__c from Account_Supplement__c 
        										where ldc_account__c IN : ldcset and id not IN : trigger.new]){
        		
        		list<Account_Supplement__c> aslst = new list<Account_Supplement__c>();
        		if(asmap.containskey(asupp.ldc_account__c))
        			aslst = asmap.get(asupp.ldc_account__c);
        		else
        			aslst = new list<Account_Supplement__c>();
    			aslst.add(asupp);
    			asmap.put(asupp.ldc_account__c,aslst);
        	}
        	
        	for(Account_Supplement__c asupp : trigger.new){
        		if(asmap.containskey(asupp.ldc_account__c)){
        			if(trigger.isUpdate && ((Trigger.oldMap.get(asupp.id).Start_Date__c != asupp.Start_Date__c) || (Trigger.oldMap.get(asupp.id).End_Date__c != asupp.End_Date__c)
        				|| (Trigger.oldMap.get(asupp.id).Percentage__c != asupp.Percentage__c))){
	        			
	        			list<Account_Supplement__c> aslst = asmap.get(asupp.ldc_account__c);
	        			for(Account_Supplement__c inneras : aslst){
	        				system.debug('check start : '+asupp.Start_Date__c+':'+inneras.Start_Date__c+':'+inneras.End_Date__c+' : '+(asupp.Start_Date__c <= inneras.Start_Date__c)+' : '+(asupp.Start_Date__c <= inneras.End_Date__c));
	        				system.debug('check End : '+asupp.End_Date__c+':'+inneras.Start_Date__c+':'+inneras.End_Date__c+' : '+(asupp.End_Date__c <= inneras.Start_Date__c)+' : '+(asupp.End_Date__c <= inneras.End_Date__c));
	        				if(asupp.type__c == inneras.type__c  && ((asupp.Start_Date__c <= inneras.Start_Date__c || asupp.Start_Date__c <= inneras.End_Date__c)
	        					|| (asupp.End_Date__c <= inneras.Start_Date__c || asupp.End_Date__c <= inneras.End_Date__c))){
	    						
	    						system.debug('Error because  of conflict with other record : '+inneras.name);
	    						asupp.addError('Error because  of conflict with other record : '+inneras.name);
	    					}
	        			}
        			}
        		}
        	}
        }
        if(trigger.isAfter){
        	set<id> accset = new set<id>();
        	list<account> acclst = new list<account>();
        	list<contract_ldc__c> cldclst = new list<contract_ldc__c>();
        	map<id,contract_ldc__c> cldcaccmap = new map<id,contract_ldc__c>();
        	for(contract_ldc__c cldc : [select id,ldc_account__c,ldc_account__r.account__c,ldc_account__r.account__r.lodestar_integration_status__c,issynchronized__c 
    										from contract_ldc__c where ldc_account__c IN : ldcset and term_start_date__c != null order by createddate]){
 
         		cldcaccmap.put(cldc.ldc_account__c,cldc);
        	}
        	for(ID accid : cldcaccmap.keyset()){
        		if(!accset.contains(cldcaccmap.get(accid).ldc_account__r.account__c)){
	        		account a = new account();
	        		a.id = cldcaccmap.get(accid).ldc_account__r.account__c;
	        		a.lodestar_integration_status__c = 'Not Synchronized';
	        		acclst.add(a);
	        		accset.add(cldcaccmap.get(accid).ldc_account__r.account__c);
        		}
        		
        		contract_ldc__c cldc = cldcaccmap.get(accid);
        		cldc.issynchronized__c = false;
        		cldclst.add(cldc);
        	}
        	TriggerHandler.LSresponse = false;
        	if(!acclst.isempty()) update acclst;
        	if(!cldclst.isempty()) update cldclst;
        }
    } 
}