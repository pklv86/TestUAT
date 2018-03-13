/*****************************************Dynegy*************************************************************************************
 * Name: Contracttrigger                                                                                                     *
 * Type: Apex Trigger                                                                                                                 *
 * Test Class:contracttrigger_test                                                                                                  *
 * Description:  This process is used for creating Contract Terms when the contract is Activated.                                   *                                            
 * Change History:                                                                                                                  *
 *==================================================================================================================================*
 * Version     Author                       Date             Description                                                            *
 * 1.0         Mounika Duggirala            02/26/2017      Initial Version created                                                 *
 * 2.0         Chaitanya Kurra              07/21/2017      Inserting Opco from account if it is null at contract          *
 * 3.0       Nanda Eluru          09/21/2017      Contract Level Validation                               *                           
 ************************************************************************************************************************************/
trigger contracttrigger on Contract (before insert,before update, after update) 
{
    
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
        if(trigger.isbefore){
            if(trigger.isInsert){
                set<id> accountset = new set<id>();
                map<id,account> accountmap;
                
                for (contract CN : trigger.new){
                    accountset.add(CN.accountid);
                }
                if(accountset.size()>0)
                    accountmap = new map<id,account>([Select id,supplier__c from account where id =:accountset]);
                
                System.debug('******Accountmap****'+accountmap.values());
                
                for(contract CN: trigger.new){
                    if((CN.Supplier__c == null) && string.isblank(CN.Supplier__c) && accountmap.containskey(cn.accountid)){
                        CN.supplier__c = accountmap.get(CN.accountid).supplier__c;
                        system.debug('*****ContractOpco****'+CN.Supplier__c);
                    }
                }               
            }
            if(trigger.isupdate){
                /*for(Contract ct : Trigger.new){
                    if(trigger.oldmap.get(ct.id).status != ct.status && (ct.status == 'Activated' ))// || ct.status == 'Expired'
                        ct.validation__C = 'Modified'; 
                }*/
                list<Contract_Term__c> insertlist = new list<Contract_Term__c>();
                Contracttriggerhandler  CTH=new Contracttriggerhandler();  
                list<Contract> c = trigger.new;
             //   string cId = c[0].id;
                string query = ConstantUtility.getObjectFieldsQuery('Contract')+ ',Opportunity__r.Referral_Broker__r.description,Contract.Account.Industry, Retail_Quote__r.Contract_Energy_On_PK__c,Retail_Quote__r.Contract_Energy_Off_PK__c from contract where id = :c';
                list<contract> cnt = Database.query(query);
                for (Contract cont: cnt){
                    if ((Trigger.newMap.get(cont.Id).status)=='Activated'&&Trigger.oldMap.get(cont.Id).status!= Trigger.newMap.get(cont.Id).status){                                               
                        if(cont.product_name__c=='FP-ONE'){
                           insertlist.addall(CTH.createcontracttermsforFP_ONE(cont));
                        }
                        else if(cont.product_name__c=='FP-ONE-PT-C'){
                            insertlist.addall(CTH.createcontracttermsforFP_ONE_PT_C(cont));
                        }
                        else if(cont.product_name__c=='FP-MULT'){
                             insertlist.addall(CTH.createcontracttermsforFP_MULT(cont));
                        }
                        else if(cont.product_name__c=='FP-MULT-PT-C'){
                             insertlist.addall(CTH.createcontracttermsforFP_MULT_PT_C(cont));
                        } 
                        else if(cont.product_name__c=='FP-MULT-PT-L'){
                             insertlist.addall(CTH.createcontracttermsforFP_MULT_PT_L(cont));
                        }
                        else if(cont.product_name__c=='FP-MULT-PT-T'){
                            insertlist.addall(CTH.createcontracttermsforFP_MULT_PT_T(cont));
                        }
                        else if(cont.product_name__c=='FP-MULT-PT-CL'){
                            insertlist.addall(CTH.createcontracttermsforFP_MULT_PT_CL(cont));
                        }
                        else if(cont.product_name__c=='FP-MULT-PT-CLT'){
                             insertlist.addall(CTH.createcontracttermsforFP_MULT_PT_CLT(cont));
                        }
                        else if(cont.product_name__c=='FP-MULT-PT-LT'){
                             insertlist.addall(CTH.createcontracttermsforFP_MULT_PT_LT(cont));
                        }
                        else if(cont.product_name__c=='FP-MULT-PT-CT'){
                             insertlist.addall(CTH.createcontracttermsforFP_MULT_PT_CT(cont));
                        }
                        else if(cont.product_name__c=='FP-ONOFF'){
                             insertlist.addall(CTH.createcontracttermsforFP_ONOFF(cont));
                        }
                        else if(cont.product_name__c=='FP-ONOFF-PT-C'){
                             insertlist.addall(CTH.createcontracttermsforFP_ONOFF_PT_C(cont));
                        }
                        else if(cont.product_name__c=='FP-ONOFF-PT-L'){
                             insertlist.addall(CTH.createcontracttermsforFP_ONOFF_PT_L(cont));
                        }
                        else if(cont.product_name__c=='FP-ONOFF-PT-T'){
                             insertlist.addall(CTH.createcontracttermsforFP_ONOFF_PT_T(cont));
                        }
                        else if(cont.product_name__c=='FP-ONOFF-PT-CL'){
                             insertlist.addall(CTH.createcontracttermsforFP_ONOFF_PT_CL(cont));
                        }
                        else if(cont.product_name__c=='FP-ONOFF-PT-CLT'){
                             insertlist.addall(CTH.createcontracttermsforFP_ONOFF_PT_CLT(cont));
                        }
                        else if(cont.product_name__c=='FP-ONOFF-PT-LT'){
                             insertlist.addall(CTH.createcontracttermsforFP_ONOFF_PT_LT(cont));
                        }
                        else if(cont.product_name__c=='FP-ONOFF-PT-CT'){
                             insertlist.addall(CTH.createcontracttermsforFP_ONOFF_PT_CT(cont));
                        }
                    }
                }
                if(insertlist.size()>0){  
                  TriggerHandler.contractValidation = false;              
                insert insertlist;
                }  
            }
        }
        set<Id> contractSetId = new set<Id>();
        if(Trigger.isAfter){
            If(Trigger.isUpdate){               
                for(contract con : Trigger.new){
                    if(((Trigger.oldMap.get(con.id).validation__c != con.validation__c && (con.validation__c == 'Modified' 
                        || (Trigger.oldMap.get(con.id).validation__c == 'Modified' && con.validation__c == 'Validated'))) 
                        || (Trigger.oldMap.get(con.id).Unsync_Contract_LDCs__c != con.Unsync_Contract_LDCs__c && con.Unsync_Contract_LDCs__c == true)) && !system.isBatch()){
                        
                        contractSetId.add(con.id);     
                    }
                }
            }
        }
        if(contractSetId.size()>0){
            AccountTriggerHandler.setLDCNotSynchronized(contractSetId,'ContractLDC');
            list<contract> cntlst = new list<contract>();
            for(contract ct : [select id,Unsync_Contract_LDCs__c from contract where id IN : contractSetId]){
        if(ct.Unsync_Contract_LDCs__c){
          ct.Unsync_Contract_LDCs__c = false;
          cntlst.add(ct);
        }
            }
            update cntlst;
        }
    } 
}