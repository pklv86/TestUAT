/* 
 * Name: DASRGAADBatch
 * Type: Apex Class
 * Test Class: DASRGAADBatchTest
 * Description:  This batch job is to work on Drop request from utilty and responses from utility. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Prasad Paladugu         05/05/2017       1. Initial Version created
 * 2.0         Prasad Paladugu         10/10/2017       1. Upgrade the process for more effeciency
 * 3.0		   Mounika Duggirala	   11/10/2017		1. Split the process
 * 4.0		   Nanda Eluru			   12/25/2017		1. Modified the process to only work on dates and not deactivating contract ldcs
 														2. New status of ldc account worked Never_served
 */
global class DASRGAADBatch implements Database.Batchable < sObject > {

    global DASRGAADBatch() {

    }
    String q;
    /**
     * @description gets invoked when the batch job starts
     * @param context contains the job ID
     * @returns the record set as a QueryLocator object that will be batched for execution
     */
    global Database.QueryLocator start(Database.BatchableContext context) {
        list<DASR_GAAD_Batch__c> dropJob = dasr_gaad_batch__C.getall().values();
        set<string> droptype= new set<string>();
        for(DASR_GAAD_Batch__c type:dropJob){
            if(datetime.now().time().hour() == Integer.valueof(type.time__c) && datetime.now().time().minute() >= Integer.valueof(type.minute__c) && datetime.now().time().minute() <= Integer.valueof(type.minute1__c )){  
                system.debug('*******time in Custom Setting*******' +type.time__c);
                droptype.add(type.DASR_Type__c);
            }
        }
        if(droptype.contains('EC'))
           q = 'select id,ldc_account__r.ldc_account_status__C,ldc_account__r.ldc_start_date__C,drop_reason_code__c From DASR_Request__c  where (Dynegy_Initiated__c = False OR Accepted__c = true) AND Integration_Status__c = \'Complete\' AND Change_Effective_Date__c != null and Dasr_type__c = \'GAAD\'  and Most_recent_gaad__C = true and (drop_transaction_type__C = \'EC\' OR (drop_reason_code__c = \'EB3\' AND ldc_account__r.service_territory__C like \'%OH%\')) and lastmodifieddate = today';
        else
            q = 'select id,ldc_account__r.ldc_account_status__C From DASR_Request__c  where (Dynegy_Initiated__c = False OR Accepted__c = true) AND Integration_Status__c = \'Complete\' AND Change_Effective_Date__c != null and Change_Effective_Date__c <= Today and Dasr_type__c = \'GAAD\' and (drop_transaction_type__C = \'DR\' AND drop_reason_code__c != \'EB3\') and Most_recent_gaad__C = true and lastmodifieddate >='+label.DASR_GAAD_Date;//AND (NOT ldc_account__r.service_territory__C like \'%OH%\'))

        system.debug('>>>>>>>>>>>>>>>>>*******' + q);

        return Database.getQueryLocator(q);
    }

    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */
    global void execute(Database.BatchableContext context, List<DASR_Request__c> scope) {


        List<Id> idList = new List<Id> ();
        list<DASR_Request__c> lDASR = (list<DASR_Request__c>) scope;
        list<DASR_Request__c> updateDASRList = new list<DASR_Request__c>();
        system.debug('>>>>>>>>>>>>>>>>>*******' + scope);
        
        for (DASR_Request__C dasrRequest : lDASR) {
            if(dasrRequest.ldc_account__r.ldc_account_status__C.equalsignorecase('FINAL')){
                dasrRequest.Most_recent_gaad__C = false;
                updateDASRList.add(dasrRequest);
            }
            else{
                idList.add(dasrRequest.Id);
                dasrRequest.Most_recent_gaad__C = false;
                updateDASRList.add(dasrRequest);
            }
        }
        system.debug('>>>>>>>>>>>>>>>>>*******' + idList);
        Flow_EndContractLDC.TerminateActiveContractsByDASR(idList);
        system.debug('>>>>>>>>>>>>>>>>>*******' +updateDASRList);
        if (!updateDASRList.isempty()) update updateDASRList;

    }

    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */
    global void finish(Database.BatchableContext context) {

    }


}