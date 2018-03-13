/**
 * The purpose if this class is to Host an Invocable Method that can be called
 * from the Process Builder. Its purpose is to set the Term_Stop_Date__c on the
 * Contract_LDC__c records that are related to the DASR_Request__c records by
 * Contract__c and LDC_Account__c. It should also de-activate the Contract_LDC__c
 * Record.
 *
 * 
 * @author Chris Gary<cgary@cloudperformer.com>
 * @version 1.0
 * @version 1.1 Modified for the production issue SCR #1325 -Chaitanya Kurra
 * @Version 1.2 Added functionality for billing groups to work on sync with contract ldcs -prasad
 * @Version 1.3 Updated the functionality to sync only currently active billing groups as per lodestar -prasad
 * @Version 1.4 updated the class to only update dates of contract ldc not deactivating until change effective date -prasad
 **/
 public class Flow_EndContractLDC{
  @InvocableMethod(label='Terminate Active Contracts' description='Set a Term End Date and set Contract Active to False')
    public static void TerminateActiveContractsByDASR(List<Id> dasrID){
        //convert the list passed in into a set of Ids
        Set<Id> dasrIdSet = new Set<Id>();
        set<id> acctid =new set<id>();
        set<id> ldcNeverServedSet = new set<id>();
        set<id> ldcServiceGap = new set<id>();
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> presentContractLDC = new set<id>();
        Set<Id> ldcAccountIdSet = new Set<Id>();
        map<id,id> ldcbgmap = new map<id,id>();
        
        map<id,date> ldcfinalset = new map<id,date>();
        map<Id,Contract_LDC__c> tempContractMap;
        map<id,id> presentContractldcMap = new map<id,id>();
        map<id,Map<Id,Contract_LDC__c>> EmptyLDCAccountIdSet = new Map<Id,Map<id,Contract_LDC__c>>();
        map<id,contract_ldc__c> previousCLDCMap = new map<id,contract_ldc__c>();
        map<id,datetime> previousLDCendDateMap = new map<id,datetime>();        
        map<id,datetime> presentCLDCStartDateMap;
        Map<Id,Contract_LDC__c> contractLDCMap;
        list<Billing_Group_Ldc__c> bgldclst = new list<Billing_Group_Ldc__c>();
        Map<Id,Map<Id,Billing_Group_Ldc__c>> ldcbgset = new Map<Id,Map<Id,Billing_Group_Ldc__c>>();
        list<Contract_LDC__c> contractLDCListToUpdate = new List<Contract_LDC__c>();
        list<LDC_Account__c> LDClisttoUpdate = new List<LDC_Account__c>();
        dasrIdSet.addAll(dasrID);
        
        datetime presentstartdate;
        Integer counter = 0;
        string cntId='';
        
        //get the DASR_Requests__c and find the related Contract_LDC__c records
        List<DASR_Request__c> dasrList = [SELECT 
                                            Id, Contract__c, LDC_Account__c, drop_transaction_type__c,drop_reason_code__c,ldc_account__r.ldc_vendor__r.Service_State__c,
                                            Change_Effective_Date__c, ldc_account__r.ldc_start_date__C
                                          FROM DASR_Request__c 
                                          WHERE id IN :dasrIdSet];
        
        for(DASR_Request__c dasrRequest:dasrList){
            contractIdSet.add(dasrRequest.Contract__c);
            if(dasrRequest.LDC_Account__c != null)
                ldcAccountIdSet.add(dasrRequest.LDC_Account__c);
            if(dasrRequest.drop_transaction_type__c == 'EC' || (dasrRequest.drop_reason_code__c == 'EB3' && dasrRequest.ldc_account__r.ldc_vendor__r.Service_State__c == 'OH')){
                if( dasrRequest.change_effective_date__C <= dasrRequest.ldc_account__r.ldc_start_date__C )
                    ldcNeverServedSet.add(dasrRequest.LDC_Account__c);
                else
                    ldcServiceGap.add(dasrRequest.LDC_Account__c);  
            }
            ldcfinalset.put(dasrRequest.LDC_Account__c,dasrRequest.Change_Effective_Date__c);
        }
        
        system.debug('\n    ldcNeverServedSet   :\n'+ldcNeverServedSet);
        system.debug('\n    ldcServiceGap   :\n'+ldcServiceGap);
        
        list <contract_ldc__c> contractLDCList = [select Id, Term_Stop_Date__c, term_start_date__c, 
                                                        Active__c,Contract__c, LDC_Account__c 
                                                  FROM Contract_LDC__c 
                                                  WHERE LDC_Account__c IN :ldcAccountIdSet and term_start_date__C != null order by term_stop_Date__C DESC];
        
        for(Contract_LDC__c contractLDC:contractLDCList){
            if(!EmptyLDCAccountIdSet.containsKey(contractLDC.ldc_account__c)){
                presentCLDCStartDateMap = new map<id,datetime>();
                tempContractMap = new Map<Id,Contract_LDC__c>();
                presentCLDCStartDateMap.put(contractLDC.ldc_account__c, contractLDC.term_start_date__C);
                tempContractMap.put(contractLDC.contract__c,contractLDC);   
                EmptyLDCAccountIdSet.put(contractLDC.ldc_account__c,tempContractMap);
            }
            else{
                presentstartdate = presentCLDCStartDateMap.get(contractLDC.ldc_account__c);
                if(contractLDC.term_stop_date__C < presentstartdate && contractLDC.term_start_date__C != contractLDC.term_stop_date__C ){
                    if(!previousLDCendDateMap.containskey(contractLDC.ldc_account__c)){
                        previousLDCendDateMap = new map<id,datetime>();
                        previousLDCendDateMap.put(contractLDC.ldc_account__c, contractLDC.term_stop_date__C);
                    }
                }
            }
        }
        system.debug('\n    tempContractMap     :\n'+tempContractMap);
        system.debug('\n    EmptyLDCAccountIdSet    :\n'+EmptyLDCAccountIdSet);
        system.debug('\n    presentCLDCStartDateMap     :\n'+presentCLDCStartDateMap);
        system.debug('\n    previousLDCendDateMap   :\n'+previousLDCendDateMap);
        
        //Adding same logic as contract_ldc_c deactive on change effective date to billing group ldcs also
        
        for(Billing_Group_Ldc__c bgldc : [select id,name,Billing_Start_Date__c,Billing_Stop_Date__c,Active__c,Synchronized__c,Billing_Group__c,Billing_Group__r.contract__c, 
                          ldc_account__c from Billing_Group_Ldc__c where ldc_account__c IN : ldcAccountIdSet AND Billing_Group__r.contract__c IN : contractIdSet]){
      
            Map<Id,Billing_Group_Ldc__c> tempbgldcMap;
            if(ldcbgset.containsKey(bgldc.billing_group__r.Contract__c)){
                tempbgldcMap = ldcbgset.get(bgldc.billing_group__r.Contract__c);
            } else {
                tempbgldcMap = new Map<Id,Billing_Group_Ldc__c>();
            }
            tempbgldcMap.put(bgldc.LDC_Account__c,bgldc);
            ldcbgset.put(bgldc.billing_group__r.Contract__c,tempbgldcMap);
        }
        
        for(DASR_Request__c dasrRequest:dasrList){
            contractLDCMap = EmptyLDCAccountIdSet.get(dasrRequest.ldc_account__C);  
            Contract_LDC__c chosenContractLDC= new Contract_LDC__c();       
            if(contractLDCMap != null ){
                if(dasrRequest.contract__c != null && contractLDCMap.containsKey(dasrRequest.contract__c)){ 
                    chosenContractLDC = contractLDCMap.get(dasrRequest.contract__C);
                }
                else{
                    for(contract_ldc__c cldc : contractLDCList){
                        if(cldc.ldc_account__c == dasrRequest.ldc_account__c && !acctid.contains(cldc.ldc_account__c)){
                            counter++;  
                            acctid.add(cldc.ldc_account__c);
                            cntId = cldc.contract__c;
                        }
                    }
                    chosenContractLDC = contractLDCMap.get(cntId);
                }
                chosenContractLDC.Active__c = false;
                if(ldcNeverServedSet.contains(dasrRequest.ldc_account__c) || ldcServiceGap.contains(dasrRequest.ldc_account__c)){
                    chosenContractLDC.Term_Start_Date__c = DateTime.newInstance(dasrRequest.Change_Effective_Date__c,Time.newInstance(0,0,0,0));
                    system.debug('\n term start date :'+chosenContractLDC.Term_Start_Date__c);
                }
                chosenContractLDC.Term_Stop_Date__c = DateTime.newInstance(dasrRequest.Change_Effective_Date__c,Time.newInstance(0,0,0,0));
                system.debug(' Test Date : '+ chosenContractLDC.Term_Stop_Date__c);
                contractLDCListToUpdate.add(chosenContractLDC);
            }
            
            Map<Id,Billing_Group_Ldc__c> tempbgldcMap = ldcbgset.get(dasrRequest.Contract__c);
            if(tempbgldcMap != null && tempbgldcMap.containsKey(dasrRequest.LDC_Account__c)){
                Billing_Group_Ldc__c bgldc = tempbgldcMap.get(dasrRequest.LDC_Account__c);
                bgldc.Active__c = false;
                bgldc.synchronized__c = false;
                bgldc.Billing_Stop_Date__c = DateTime.newInstance(dasrRequest.Change_Effective_Date__c,Time.newInstance(0,0,0,0));
                bgldclst.add(bgldc);
                ldcbgmap.put(bgldc.ldc_account__c,bgldc.Billing_Group__c);
                system.debug(' Test Date : '+ bgldc.Billing_Stop_Date__c);
            }
            
        }
                
        system.debug('******' +ldcfinalset);
        // Modified for Deactivating all the LDC accounts on the change effective date SCR 1325.
        if(ldcfinalset.size()>0){
           for(id ldc1 : ldcfinalset.keyset()){
               system.debug('******' +ldc1);
               LDC_Account__c LDCNEW = new LDC_Account__c();
               LDCNEW.id = ldc1;
               if(ldcNeverServedSet.contains(ldc1)){
                   LDCNEW.LDC_Account_Status__c ='NEVER_SERVED';
                   LDCNEW.LDC_Start_date__C = NULL;
                   LDCNEW.LDC_End_Date__c  = NULL;
               }
               else{
                   LDCNEW.LDC_Account_Status__c ='FINAL';
                   if(ldcServiceGap.contains(ldc1) && previousLDCendDateMap.containsKey(ldc1))
                    LDCNEW.LDC_End_Date__c  = previousLDCendDateMap.get(ldc1).date();
                   else
                    LDCNEW.LDC_End_Date__c  = ldcfinalset.get(ldc1);
               }
               LDClisttoUpdate.add(LDCNEW);
           }
        }
        /*if(!ldcbgset.isempty()){
          for(id ldcid : ldcbgset.keyset()){
            ldc_account__c ldc = new ldc_account__c();
            ldc.id = ldcid;
            ldc.billing_group__c = '';
            LDClisttoUpdate.add(ldc);
          }
        }*/
        system.debug('******' +LDClisttoUpdate);
        if(!LDClisttoUpdate.isempty()) update LDClisttoUpdate;
        
        if(!contractLDCListToUpdate.isEmpty()) update contractLDCListToUpdate;
    }
 }