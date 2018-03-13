/**
 * the purpose of this class is to provide methods that can be used in the 
 * AccountTrigger.
 *
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 * @version 1.1 Prasad Paladugu Modified for solving 101 SOQL Queries
 * @vesrion 1.2 Prasad Paladugu Created a bacth class handler for requirement
 * @version 1.3 Nanda Eluru Appended another batch class to same class handler 
 * @version 1.4 Nanda Eluru Worked for 10001 DML 
 **/
global class AccountTriggerHandler {

    global static Boolean parentAccountUpdateToChildAcctUpdateRun = false;

    public static void SetChildAccountsToNotSynchronized(Set<Id> parentAccountId,String runJob){
        //first we need to make sure this has not run already
        if(!AccountTriggerHandler.parentAccountUpdateToChildAcctUpdateRun){
            //List<Account> childAccountsToUpdate = new List<Account>();
            AccountTriggerHandler.parentAccountUpdateToChildAcctUpdateRun = true;
            //now grab all of the Child Account Records of the selected Parents and set them to 'Not Synchronized'
            system.debug(' RUN JOB : '+runJob);
            if(runJob == 'Person'){
                AccountTriggerHandlerBatch childAccBatch = new AccountTriggerHandlerBatch(parentAccountId,runJob);
                if(!BatchUtility.IsconcurrentjobsRunning()){
                    Database.executebatch(childAccBatch,1000);
                }
                else{
                    System.scheduleBatch(childAccBatch, 'Re-Scheduled AccountTriggerBatch @ '+Datetime.now(), 5,1000);
                }
            }
        }
    }

 
    public static void setLDCNotSynchronized(Set<Id> accountId,String runJob) {    //, boolean runJob2
    	system.debug('>>>>>>>>>>>>>>>>>*******' + accountId);
        if(!accountId.isempty() && accountId.size() > 0){
            AccountTriggerHandlerBatch childAccBatch = new AccountTriggerHandlerBatch(accountId,runJob);
            system.debug('=========childAccBatch============='+childAccBatch); 
            if(!BatchUtility.IsconcurrentjobsRunning()){
                Database.executebatch(childAccBatch,1000);
            }
            else{
                System.scheduleBatch(childAccBatch, 'Re-Scheduled AccountTriggerBatch @ '+Datetime.now(), 5,1000);
            }
        }
    }
 } 
    
    /*Commented out by Nanda for DML 10001
        for (Contract_LDC__c contractLDC :[SELECT Id,Term_Start_Date__c, IsSynchronized__c,Contract__c,Contract__r.Account.id, LDC_Account__r.Account__r.id FROM Contract_LDC__c
                                           WHERE Contract__r.Account.id IN :accountId or LDC_Account__r.Account__r.id IN :accountId order by Term_Start_Date__c ASC ]) {
             
            system.debug(contractLDC.Contract__r.Account.id);
            if (contractLDC.Contract__r.Account.id != null){
                //cmap.put(contractLDC.Contract__r.Account.id, contractLDC);
                system.debug(contractLDC.LDC_Account__r.Account__r.id);
                if (contractLDC.LDC_Account__r.Account__r.id != null){
                    system.debug('insider main condition');
                    cmap.put(contractLDC.LDC_Account__r.Account__r.id, contractLDC);
                }
            }
        }
        system.debug(cmap);
        lclc = cmap.values();
            
        system.debug('>>>>>>>>>>>>>>>>>*******' + cmap);
        system.debug('>>>>>>>>>>>>>>>>>*******' + lclc);
        for (Contract_LDC__c clc : lclc) {
            clcmap.put(clc.id, clc);
        }
            
        lclc = clcmap.values();
    
        for (Contract_LDC__c clc : lclc) {
            if (clc.IsSynchronized__c != false){
                clc.IsSynchronized__c = false;
                //for SCR:1186 To upadte only modified records
                finalUpdateCLdc.add(clc);
            }
        }
       
       system.debug('=====finalupdateCLdc================'+finalUpdateCLdc);
       if (!finalUpdateCLdc.isempty()) update finalUpdateCLdc; 
   }
}*/

/* OLD CODE Commented Out for 101 SOQL Queries
for(Account a : acc){
    a.LodeStar_Integration_Status__c = 'Not Synchronized';
    childAccountsToUpdate.add(a);
}
if(!childAccountsToUpdate.isEmpty()) {
    if(childAccountsToUpdate.size() >= 1000){
    //list<AsyncApexJob> runningjob = [SELECT ApexClass.name,ExtendedStatus,Id,JobItemsProcessed,JobType,MethodName,Status FROM AsyncApexJob where ApexClass.name='AccountTriggerHandlerBatch' and Status= 'Processing'];
    /*system.debug(' RUN JOB : '+runJob);
    if(runJob){
        AccountTriggerHandlerBatch childAccBatch = new AccountTriggerHandlerBatch(parentAccountId);
        if(!BatchUtility.IsconcurrentjobsRunning()){
            Database.executebatch(childAccBatch,1000);
        }
        else{
            System.scheduleBatch(childAccBatch, 'Re-Scheduled BatchCNIEnrollmentProcess @ '+Datetime.now(), 5,1000);
        }
        runJob = false;
    }*/