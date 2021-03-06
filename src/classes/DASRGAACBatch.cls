/* 
 * Name: DASRGAACBatch
 * Type: Apex Class
 * Test Class: DASRGAACBatchTest
 * Description:  This batch job is to work on change request from utilty and responses from utility. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Prasad Paladugu         06/16/2016       1. Initial Version created
 * 2.0         Prasad Paladugu         07/22/2016       1. Automate the Process based on change effective date
 * 3.0         Prasad Paladugu         10/10/2017       1. Upgrade the process for more effeciency
 * 4.0		   Prasad Paladugu		   01/10/2018		1. Upgraded the process for error handling efficiency and mail
 * 5.0		   Prasad Paladugu		   02/15/2018		1. Modified the process to only work on dates and not activating contract ldcs
 														2. Handling the Comed GAAC DASRs instantly
 */
 
 global class DASRGAACBatch implements Database.Batchable < sObject > {

    global DASRGAACBatch() {

    }
    String q;
    /**
     * @description gets invoked when the batch job starts
     * @param context contains the job ID
     * @returns the record set as a QueryLocator object that will be batched for execution
     */
    global Database.QueryLocator start(Database.BatchableContext context) {


        q = 'select id,ldc_account__c,contract__c,ldc_account__r.service_territory__c,Integration_Status__c From DASR_Request__c  where Dynegy_Initiated__c = true AND Accepted__c = true '+
            'AND ((Integration_Status__c = \'Complete\' AND most_recent_gaad__c = true) OR Integration_Status__c = \'Manually Fulfilled\') AND '+
            'Dasr_type__c = \'GAAC\' and DASR_Activated__c= false AND change_effective_date__c = today'; // and lastmodifieddate = today and lastmodifiedby.name like \'%Integration%\'

        system.debug('>>>>>>>>>>>>>>>>>*******' + q);

        return Database.getQueryLocator(q);
    }

    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */
    global void execute(Database.BatchableContext context, List<DASR_Request__c> scope) {


        list<DASR_Request__c> lDASR = (list<DASR_Request__c>) scope;
        list<DASR_Request__c> updateDASRList = new list<DASR_Request__c>();
        system.debug('>>>>>>>>>>>>>>>>>*******' + scope);
        
        list<Id> idList = new list<Id> ();
        list<LDC_Account__c> lLA = new list<LDC_Account__c> ();
        map<id, LDC_Account__c> ldcmap = new map<id, LDC_Account__c> ();
        set<id> ldcSet = new set<id> ();
        set<id> cntSet = new set<id>();
        LDC_Account__c tLA = new LDC_Account__c();
        map<string,id> cldcmap = new map<string,id>();
        
        for(DASR_Request__C dasrRequest : lDASR) {
            if(dasrRequest.Integration_Status__c == 'Complete')
                idList.add(dasrRequest.Id);
                
            if(dasrRequest.Integration_Status__c == 'Manually Fulfilled' && dasrRequest.ldc_account__r.service_territory__c == 'ComEd-IL')
                idList.add(dasrRequest.Id);
                
            ldcSet.add(dasrRequest.ldc_account__c);
            cntSet.add(dasrRequest.contract__c);
        }
        system.debug('>>>>>>>>>>>>>>>>>*******' + idList);

        for(Dasr_request__c dasrRequest :[select id, name, Contract__c, Contract__r.Bill_Method__c, DASR_Activated__c,Most_recent_gaad__c, Contract__r.Interval_Usage__c, Contract__r.Rate_Code__c, LDC_Account__c, LDC_Account__r.LDC_Account_Status__c, LDC_Account__r.Bill_Method__c, LDC_Account__r.Interval_Usage__c, LDC_Account__r.Rate_Code__c From DASR_Request__c where Id IN :idList])
        {
            if(dasrRequest.LDC_Account__r.LDC_Account_Status__c == 'PENDING_FINAL'  ||  dasrRequest.LDC_Account__r.LDC_Account_Status__c == 'FINAL'  ){
                //Removing Pending_final/Final Ldcs DASRs from the list before processing for activation.
                for(Integer j=0;j<idList.size();j++)
                {
                    if(dasrRequest.id==idList.get(j))
                    {
                        system.debug('Removing Id:' + idList.get(j) );
                        idList.remove(j);
                        break;
                    }
                }
                dasrRequest.DASR_Activated__c = true;
                dasrRequest.Most_recent_gaad__c = false;
                updateDASRList.add(dasrRequest);
                continue;
            }
            
            dasrRequest.LDC_Account__r.Bill_Method__c = dasrRequest.Contract__r.Bill_Method__c;
            dasrRequest.LDC_Account__r.Interval_Usage__c = dasrRequest.Contract__r.Interval_Usage__c;
            dasrRequest.LDC_Account__r.Rate_Code__c = dasrRequest.Contract__r.Rate_Code__c;
            ldcmap.put(dasrRequest.LDC_Account__r.id, dasrRequest.LDC_Account__r);
            dasrRequest.DASR_Activated__c = false;
            dasrRequest.Most_recent_gaad__c = false;
            updateDASRList.add(dasrRequest);
        }
        
        system.debug('>>>>>>>>>>>>>>>>>*******Final Ids:' + idList);
        Flow_SetActiveContractLDC.setActiveContractFromDASR(idList);
        
        
        for(contract_ldc__c cldc : [select id,ldc_account__c,contract__c from contract_ldc__c where ldc_account__c IN : ldcset and contract__c IN : cntset order by createddate]){
            cldcmap.put(cldc.ldc_account__c+''+cldc.contract__c,cldc.id);
        }
        if(!cldcmap.isempty()){ 
            Flow_SetAccountLDCAcctTypeCode.SetAccountLDCInfoFROMContractLDC(cldcmap.values());
            Flow_DeactivateNonApplicableContracts.DeactivateNonActiveContractLDCRecs(cldcmap.values());
        }
        
        system.debug('>>>>>>>>>>>>>>>>>*******' + ldcmap);
        lLA = ldcmap.values();
        system.debug('lLA : ' + lLA);
        if (!lLA.isempty()) update lLA;
        if (!updateDASRList.isempty()) update updateDASRList;

    }

    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */
    global void finish(Database.BatchableContext context) {

    }


}