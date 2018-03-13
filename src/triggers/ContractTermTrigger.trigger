/* 
 * Name: ContarctTermTrigger
 * Type: Apex Trigger
 * Test Class: Covered under the respective main classes
 * Description:  This class contains the logic to handle terms insertion, deletion
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Nanda Eluru               10/10/2017       1. Initial Version created
 */
trigger ContractTermTrigger on Contract_Term__c (after insert, after delete) {
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
        set<id> ctid = new set<id>();
        list<contract> contlist = new list<contract>();
        if(trigger.isAfter){            
            //AfterInsert Logic
            if(trigger.isInsert && TriggerHandler.contractValidation){        
                for(contract_term__C cterm:trigger.new){
                    ctid.add(cterm.contract__C);
                } 
            }
            //AfterDelete logic
            if(trigger.isDelete){
                for(contract_term__C cterm:trigger.old){
                    ctid.add(cterm.contract__C);
                }
            }  
        }
        if(ctid.size()>0){  
            list<contract> ctlist = [select id, validation__C from contract where id in:ctid AND (status != 'Draft' OR status != 'Cancelled')];      
            for(contract ct:ctlist){
                if(ct.validation__C != 'Modified'){
                    ct.validation__C = 'Modified';
                    contlist.add(ct);
                }
            }
        } 
        if(contlist.size()>0)
            update contlist;    
    }
}