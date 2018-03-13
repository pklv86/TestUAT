/**********************************************************
Class :  FlagContractLDC
Test Class : DASRGAAEBatch_Test.DASRGAAEBatch_Activate,DASRGAACBatchTest.DASRGAACBatch_Activate
Version     Date            Author
1.0         11/29/2017      Prasad Paladugu 
***********************************************************/
global class FlagContractLDC implements system.schedulable,database.Batchable<sObject>,database.Stateful{
    
    public FlagContractLDC(){
    }
    
    global set<id> aeIDSet;
    global list<Account_Exception__c> aelst;
    
    global void execute(schedulableContext sc){
        system.debug('Schedule Run Start >>>>>>>>');
        FlagContractLDC fcldc = new FlagContractLDC();
        database.executebatch(fcldc,100);
    }
    
    global database.QueryLocator Start (database.BatchableContext bc){
        
        aeIDSet = new set<id>();
        aelst = new list<Account_Exception__c>();
        for(Account_Exception__c ae : [select id,name,change_effective_date__c,dasr_request__c from Account_Exception__c where Reason_Code__c='DTM150' and Most_Recent__c = true]){
            aeIDSet.add(ae.dasr_request__c);
            aelst.add(ae);
        }
        
        string q='select id, dasr_type__c, dynegy_initiated__c,ldc_account__c,contract__c, LDC_Account__r.LDC_Account_Status__c From DASR_Request__c  where'+ 
                 '((Dynegy_Initiated__c = true AND Change_Effective_Date__c != null AND dasr_activated__c = false AND Most_recent_gaad__c = false AND ((Accepted__c = true AND '+
                 'Integration_Status__c = \'Complete\' and Dasr_type__c = \'GAAE\' and lastmodifieddate >= '+label.dasr_gaae+') OR (Dasr_type__c = \'GAAC\' and '+
                 'lastmodifieddate >= '+label.dasr_gaae+' and (Integration_Status__c = \'Complete\' OR (Integration_Status__c = \'Manually Fulfilled\' '+
                 'and ldc_account__r.service_territory__c = \'ComEd-IL\'))))) OR (ID IN: aeIDSet)) AND Change_Effective_Date__c <= Today order by Change_Effective_Date__c';
        return database.getQueryLocator(q);     
    }
    
    global void execute(database.BatchableContext bc,list<dasr_request__c> scope){
        
        list<dasr_request__c> dasrlst = (list<dasr_request__c>)scope;
        set<string> dasrESet = new set<string>();
        set<string> dasrCSet = new set<string>();
        list<contract_ldc__c> cldclst = new list<contract_ldc__c>();
        list<dasr_request__c> dasrUPlst = new list<dasr_request__c>();
        list<id> cldcEId = new list<id>();
        list<id> cldcCId = new list<id>();
        set<id> ldcset = new set<id>();
        set<id> cntset = new set<id>();
        set<id> ldcActSet = new set<id>();
        set<id> cldcActSet = new set<id>();
        
        for(dasr_request__c dasr : dasrlst){
            ldcset.add(dasr.ldc_account__c);
            if(dasr.contract__c != null)
                cntset.add(dasr.contract__c);
            
            if(dasr.dasr_type__c == 'GAAE')
                dasrESet.add(dasr.ldc_account__c+''+dasr.contract__c);
            else if(dasr.dasr_type__c == 'GAAC')
                dasrCSet.add(dasr.ldc_account__c+''+dasr.contract__c);
            
            dasr.dasr_activated__c = true;
            dasrUPlst.add(dasr);
        }
        
        for(contract_ldc__c cldc : [select id,Name,ldc_account__c,contract__c from contract_ldc__c where ldc_account__c IN : ldcset and contract__c IN : cntset order by createddate]){
            cldc.active__c = true;
            if(dasrESet.contains(cldc.ldc_account__c+''+cldc.contract__c))
                cldcEId.add(cldc.id);
            else if(dasrCSet.contains(cldc.ldc_account__c+''+cldc.contract__c)){
                cldcCId.add(cldc.id);
                ldcActSet.add(cldc.ldc_account__c);
                cldcActSet.add(cldc.id);
            }
            cldclst.add(cldc);
        }
        
        system.debug('LDC SET : '+ldcActSet);
        system.debug('CLDC SET : '+cldcCId);
        
        list<Billing_Group_Ldc__c> bgldclst = new list<Billing_Group_Ldc__c>();
        for(Billing_Group_Ldc__c bgldc : [select id,active__c from Billing_Group_Ldc__c where ldc_account__c IN : ldcset and Billing_Group__r.contract__c IN : cntset]){
            bgldc.active__c = true;
            bgldclst.add(bgldc);
        }
        
        cntset.clear();
        
        //for only GAAC dasrs specifically as they move from one to other contract and reenrollment is not considered as there might be gap in service
        //Flow_DeactivateNonApplicableContracts.DeactivateNonActiveContractLDCRecs(cldcCId);
        for(contract_ldc__c cldc : [select id,ldc_account__c,contract__c,active__c from contract_ldc__c where ldc_account__c IN : ldcActSet and active__c = true AND Id NOT IN : cldcCId]){
            system.debug(' Current Contract LDC : '+cldc);
            if(cldc.Active__c = true  && !cldcActset.contains(cldc.id)){
                cldc.active__c = false;
                cldclst.add(cldc);
                cntset.add(cldc.contract__c);
            }
        }
        
        for(Billing_Group_Ldc__c bgldc : [select id,active__c from Billing_Group_Ldc__c where ldc_account__c IN : ldcset and Billing_Group__r.contract__c IN : cntset]){
            bgldc.active__c = false;
            bgldclst.add(bgldc);
        }
        
        cldcEId.addAll(cldcCId);
        Flow_ReparentAccountfromContractLDC.ReparentAccount(cldcEId);
        
        if(!bgldclst.isempty()) update bgldclst;
        if(!cldclst.isempty()) update cldclst;
        if(!dasrUPlst.isempty()) database.update(dasrUPlst,false);
    }
    
    global void finish(database.BatchableContext bc){
        for(Account_Exception__c ae : aelst){
            ae.Most_Recent__c = false;
        }
        if(!aelst.isempty()) update aelst;
    }
}