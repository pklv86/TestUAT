/* 
 * Name: insertDASRRequestGAAD
 * Type: Apex Class
 * Test Class: insertDASRRequestGAAD_Test
 * Description:  This batch class is to automate Drops for Enrollments. 
 * Change History:
 *=====================================================================================================================================================
 * Version     Author                   Date             Description 
 * 1.0         Nanda Eluru              04/28/2017       1. Initial Version created
 * 2.0         Nanda Eluru	            07/27/2017       1. Updated the class to requirement
 * 3.0         Prasad Paladugu          03/01/2018       1. Enhanced functionality for Never Served customers
 														 2. Moved the original code to trigger handler class
 */
 global class insertDASRRequestGAAD implements Database.batchable<sObject>{
    String query;
    global insertDASRRequestGAAD(){}
    global insertDASRRequestGAAD(String q) {
       query = q;
   }
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'Select LDC_Account__c, DASR_Type__c, Most_Recent_GAAD__c, Contract__c, Integration_Status__C, LDC_Account__r.LDC_Account_Status__c, LDC_Account__r.opt_out__c, LDC_Account__r.LDC_Vendor__r.Service_State__c, change_effective_date__c from DASR_Request__c where (LDC_Account__r.opt_out__c = true and LDC_Account__r.LDC_Vendor__r.Service_State__c LIKE \'%IL%\' and change_effective_date__c != null and (Integration_Status__C = \'Waiting For Response\' or Integration_Status__C = \'Complete\') and DASR_Type__c = \'GAAE\')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<DASR_Request__c> oodasrlst = (list<DASR_Request__c>) scope;
        string init ='Batch';
        LDCAccountTriggerHandler ldchandler = new LDCAccountTriggerHandler();
        ldchandler.generateGAADDasr(oodasrlst,init);
    }   
    global void finish(Database.BatchableContext BC){
    }   
}