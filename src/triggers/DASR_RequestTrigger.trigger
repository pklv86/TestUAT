/**
 * The purpose of this trigger is to provide an entry point to all triggerable operations 
 * for the DASR_Request__c object
 * 
 * @author Chris Gary<cgary@cloudperformer.com>
 * @version 1.0
 *@Version 2.0 Chaitanya Duns field logic
 *@version 2.1 Chaitanya PA Changes for Tax Exemption.
 **/
trigger DASR_RequestTrigger on DASR_Request__c(before insert,before update,after insert,after update){
    //before logic
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
        if(Trigger.isBefore){
            //Before insert logic goes here
            if(Trigger.isInsert){
            set<id> contractset = new set<id>();
            set<id> LDCset = new set<id>();
            map<id,LDC_Account__c> LDCmap;
            map<id,contract> contractmap;
            List<Account_Supplement__c> Aslist;
            map<id,Account_Supplement__c> AsMap = new map<id,Account_Supplement__c>();
            System.debug('******Userinfo****'+UserInfo.getName());
            system.debug('*****DASRbypass label****'+System.label.DASRBypass);
            if(UserInfo.getName() != System.label.DASRBypass)
                {
                System.debug('******Userinfo entered****'+UserInfo.getName());
                    for(DASR_Request__c DASR: trigger.new)
                    
                    {                           
                        contractset.add(DASR.Contract__c);
                        LDCset.add(DASR.LDC_Account__c);
                    }
                    
                    if(contractset.size()>0)
                    contractmap = new map<id,contract>([Select id,name,Supplier__r.Supplier_DUNS__c,Supplier__r.Name,Supplier__r.Id,Bill_Method__c,Contract_Counter_Signed_Date__c,
                                                                            End_Date__c,Interval_Usage__c,Rate_Code__c,StartDate from contract where id = :contractset]);
                                                                            
                    system.debug('******Contractmap******'+contractmap.values());                                                        
                   
                    if(LDCset.size()>0){
                    LDCmap = new map<id,LDC_account__c>([Select id,Account__c,LDC_Account_Number__c, Account__r.Name,Sales_Excempt__c,LDC_Vendor__r.DUNS__c,LDC_Vendor__r.Service_State__c,LDC_Vendor__r.Name,LDC_Vendor__c,Account__r.Recordtype.Name from LDC_Account__C where id =:LDCset]);
                    
                    Aslist = new list<Account_Supplement__c>([Select id,Percentage__c,ldc_account__c from Account_Supplement__c where LDC_Account__c =:LDCset and Start_Date__c != null and End_Date__c != null and Recordtype.name = 'Tax Exemption' and Percentage__c != null and active__c = true ]);
                    }
                    
                    if(Aslist != null && Aslist.size()>0)
                    {
                        for(Account_Supplement__c As1 :  Aslist)
                            {
                                AsMap.put(As1.LDC_Account__c, As1);
                            }
                    }   

                    system.debug('******LDCmap******'+ldcmap.values());
                    system.debug('******AsMap******'+AsMap.values());
                    
                    
                    for (DASR_request__c DASR : trigger.new)
                            {
                                if(DASR.Dynegy_initiated__c)
                                    {
                                    System.debug('*****entered1*********');
                                        //Populate Operating Company and Contract details to DASR Record from Contract.
                                        if(DASR.Contract__C != null && contractmap.containskey(DASR.Contract__c))
                                            {
                                            System.debug('*****Contract not null*********');
                                                DASR.Originating_DUNS__c =contractmap.get(DASR.Contract__c).Supplier__r.Supplier_DUNS__c ;
                                                DASR.Originating_Name__c = contractmap.get(DASR.Contract__c).Supplier__r.Name;
                                                DASR.SupplierID__c = contractmap.get(DASR.Contract__c).Supplier__r.Id;
                                                DASR.Contract_BillMethod__c = contractmap.get(DASR.Contract__c).Bill_Method__c;
                                                DASR.Contract_CounterSigned_Date__c = contractmap.get(DASR.Contract__c).Contract_Counter_Signed_Date__c;
                                                DASR.Contract_EndDate__c = contractmap.get(DASR.Contract__c).End_Date__c;
                                                DASR.Contract_IntervalUsage__c = contractmap.get(DASR.Contract__c).Interval_Usage__c;
                                                DASR.Contract_RateCode__c = contractmap.get(DASR.Contract__c).Rate_Code__c ;
                                                DASR.Contract_startdate__C = contractmap.get(DASR.Contract__c).StartDate ;
                                            }
                                        //Populate Vendor details and Customer ID to the DASR Record from LDC Account.  
                                        if(DASR.LDC_Account__C != null && LDCmap.containskey(DASR.LDC_Account__C))
                                            {
                                            System.debug('*****LDC not null*********');
                                                DASR.CustomerID__c = LDCmap.get(DASR.LDC_Account__c).Account__c;
                                                DASR.RecipientDUNS__c = LDCmap.get(DASR.LDC_Account__c).LDC_Vendor__r.DUNS__c;
                                                 DASR.LDC_Account_Number__c = LDCmap.get(DASR.LDC_Account__c).LDC_Account_Number__c;
                                                 Dasr.Customer_Name__c= LDCmap.get(DASR.LDC_Account__c).Account__r.Name ;
                                                 DASR.RecipientName__c = LDCmap.get(DASR.LDC_Account__c).LDC_Vendor__r.Name;
                                                DASR.VendorID__c = LDCmap.get(DASR.LDC_Account__c).LDC_Vendor__c;
                                                if ((DASR.Tax_Exemption_Percentage__c == null) && (LDCmap.get(DASR.LDC_Account__c).LDC_Vendor__r.Service_State__c) != null &&((LDCmap.get(DASR.LDC_Account__c).LDC_Vendor__r.Service_State__c).containsignorecase('PA'))){
                                                
                                                    if(AsMap.containskey(DASR.LDC_Account__C))
                                                    DASR.Tax_Exemption_Percentage__c = AsMap.get(DASR.LDC_Account__C).Percentage__c;
                                                    else if(LDCmap.get(DASR.LDC_Account__c).Account__r.Recordtype.Name == 'C&I Customer')
                                                    DASR.Tax_Exemption_Percentage__c = 0;
                                                    else if ((LDCmap.get(DASR.LDC_Account__c).Account__r.Recordtype.Name == 'Muni Agg Individual Customer') || (LDCmap.get(DASR.LDC_Account__c).Account__r.Recordtype.Name == 'Mass Market Individual Customer'))
                                                    DASR.Tax_Exemption_Percentage__c = 1;
                                                }
                                            }
                                    }
                            }
                }
                
                else{
                    set<id> dasrldcset = new set<id>();
                    list<dasr_request__c> dasrgaad = new list<dasr_request__c>();
                    for(dasr_request__c dasr: Trigger.new){
                        if(dasr.dasr_type__c == 'gaad' && dasr.Most_Recent_GAAD__c == true ){
                            dasrldcset.add(dasr.ldc_account__c); 
                            dasrgaad.add(dasr);                     
                        }
                    }
                    system.debug('=====dasrldc====='+dasrldcset);
                    map<id,list<dasr_request__c>> dasrmapgaae = new map<id, list<dasr_request__c>>();
                    if(!dasrldcset.isempty()){
                        list<dasr_request__c> dasrgaae = [select id, dasr_type__c, ldc_account__r.ldc_account_status__c, most_recent_gaad__c, change_effective_date__c, originating_duns__c, accepted__c, ldc_account__c, originator_duns__c from dasr_request__c where ldc_account__c in :dasrldcset and dasr_type__c = 'GAAE' and integration_status__C in ('Complete','waiting for response')];
                        list<dasr_request__c> dasrlst;
                        for(dasr_request__c dasrrec:dasrgaae){
                            dasrlst = dasrmapgaae.get(dasrrec.ldc_account__c);
                            if(dasrlst == null){
                                dasrlst = new list<dasr_request__c>();
                            }
                            dasrlst.add(dasrrec);
                            dasrmapgaae.put(dasrrec.ldc_account__c,dasrlst);
                        }
                        system.debug('===dasrgaae====='+dasrmapgaae);
                    }
                    if(!dasrmapgaae.isempty()){
                        list<dasr_request__c> ldcdasr;
                        list<dasr_request__c> updatedasr = new list<dasr_request__c>();
                        for(dasr_request__c dasrobj: dasrgaad){
                            ldcdasr = dasrmapgaae.get(dasrobj.ldc_account__c);
                            if(ldcdasr != null){   
                                for(dasr_request__c dasrldclst : ldcdasr){    
                                    if(dasrldclst.originating_duns__c !=  dasrobj.originating_duns__c && dasrobj.drop_reason__c == 'Customer Changed to another Service Provider'){
                                        dasrobj.Most_recent_gaad__C = false;
                                    }
                                    else if(dasrldclst.change_effective_date__c >= dasrobj.change_effective_date__c && dasrldclst.originating_duns__c == dasrobj.originating_duns__c && dasrldclst.most_recent_gaad__c){
                                        dasrldclst.most_recent_gaad__c = false;
                                        updatedasr.add(dasrldclst);
                                    }
                                }
                            }
                        }
                        update updatedasr;
                    }
                }
            
             //after insert logic goes here
            /**
             * this section of code will look at DASR_Request__c records of type GAAC that do not 
             * have a change reason, in a pending status, that is Dynegy Initiated, with a related LDC_Account__c
             * and a Contract__c record, to determine if a change has occured between
             * the Rate_Code__c, Bill_Method__c, and/or Interval_Usage__c values.
             * it will compare the Values from the LDC_Account__c (containing the old data),
             * and the Contract__c (containing the new data) and write to corresponding Change Reason.
             * If more than one change reason is found, it will clone the original DASR_Request__c record
             * and write a new one for every different change reason.
             *
             * FYI - This logic should go into a handler for future refactoring. CJG - 03/23/2016
             *
             * BEGIN DASR_CHANGE_COMPARISON *
             **/
             if(!DASR_RequestTriggerHandler.hasTriggerExecuted){
                 DASR_RequestTriggerHandler.hasTriggerExecuted = true;
                 List<DASR_Request__c> qualifyingDASRList = new List<DASR_Request__c>();
                 Set<Id> qualifyingContractIdSet = new Set<Id>();
                 Set<Id> qualifyingLDCAccountIdSet = new Set<Id>();
                 for(DASR_Request__c dasrRequest:Trigger.new){
                     if(dasrRequest.DASR_Type__c == 'GAAD' && dasrRequest.DROP_Transaction_Type__c == null){
                            dasrRequest.DROP_Transaction_Type__c = 'DR';
                     }
                     if(dasrRequest.DASR_Type__c == 'GAAC' &&
                        String.isBlank(dasrRequest.Change_Reason__c) &&
                        dasrRequest.Dynegy_Initiated__c &&
                        dasrRequest.Integration_Status__c == 'Pending' &&
                        dasrRequest.Contract__c != null &&
                        dasrRequest.LDC_Account__c != null){
                            qualifyingDASRList.add(dasrRequest);
                            qualifyingContractIdSet.add(dasrRequest.Contract__c);
                            qualifyingLDCAccountIdSet.add(dasrRequest.LDC_Account__c);
                        }
                 }
                 system.debug('Test : '+qualifyingDASRList+' CNT : '+qualifyingContractIdSet+' LDC : '+qualifyingLDCAccountIdSet);
                 //get the associated Contracts and the LDC_Account__c records into corresponding Maps.
                 Map<Id,Contract> contractIdToContractMap = new Map<Id,Contract>([SELECT Id, Rate_Code__c,Bill_Method__c, Interval_Usage__c
                                                                                    FROM Contract WHERE Id IN :qualifyingContractIdSet]);
                 Map<Id,LDC_Account__c> ldcAccountIdToldcAccountMap = new Map<Id,LDC_Account__c>([SELECT Id, Rate_Code__c,Bill_Method__c, Interval_Usage__c
                                                                                                    FROM LDC_Account__c  WHERE Id IN :qualifyingLDCAccountIdSet]);
                 //loop through the DASR_Request__c records and after comparions, determine the change reason
                 List<DASR_Request__c> dasrRequestListToUpsert = new List<DASR_Request__c>();
                 for(DASR_Request__c dasrRequest:qualifyingDASRList){
                     //get contract Info and LDC Account Info
                     Contract c = contractIdToContractMap.get(dasrRequest.Contract__c);
                     LDC_Account__c ldc = ldcAccountIdToldcAccountMap.get(dasrRequest.LDC_Account__c);
                     if(c != null && ldc != null){
                         //evaluate Rate Code
                         if(c.Rate_Code__c != ldc.Rate_Code__c){
                             if(String.isBlank(dasrRequest.Change_Reason__c)){
                                 dasrRequest.Change_Reason__c = 'Change ESP Rate Code';
                             } else {
                                 DASR_Request__c newRateCodeDASR = dasrRequest.clone(false,true,false,false);
                                 newRateCodeDASR.Change_Reason__c = 'Change ESP Rate Code';
                                 dasrRequestListToUpsert.add(newRateCodeDASR);
                             }
                         }
                         //evaluate Bill Method
                         else if(c.Bill_Method__c != ldc.Bill_Method__c){
                            if(String.isBlank(dasrRequest.Change_Reason__c)){
                                dasrRequest.Change_Reason__c = 'Change Billing Type (Billing Option)';
                            } else {
                                DASR_Request__c newBillingTypeDASR  = dasrRequest.clone(false,true,false,false);
                                newBillingTypeDASR.Change_Reason__c = 'Change Billing Type (Billing Option)';
                                dasrRequestListToUpsert.add(newBillingTypeDASR);
                            }
                         }
                         //evaluate Interval Usage
                         else if(c.Interval_Usage__c != ldc.Interval_Usage__c){
                             if(String.isBlank(dasrRequest.Change_Reason__c)){
                                 dasrRequest.Change_Reason__c = 'Change Service Indicator (Summary or Detail Interval Data)';
                             } else {
                                 DASR_Request__c newBillingSummaryDASR = dasrRequest.clone(false,true,false,false);
                                 newBillingSummaryDASR.Change_Reason__c = 'Change Service Indicator (Summary or Detail Interval Data)';
                                 dasrRequestListToUpsert.add(newBillingSummaryDASR);
                             }
                         }
                         //finally add in the updated one if the Change reason is there
                         //if(String.isNotBlank(dasrRequest.Change_Reason__c)) dasrRequestListToUpsert.add(dasrRequest);
                     }
                 }
                 //if we have DASRs to upsert - send them on!
                 if(!dasrRequestListToUpsert.isEmpty()) insert dasrRequestListToUpsert;
             }
             /** END DASR_CHANGE_COMPARISON **/
            } else if(Trigger.isUpdate){
            //before update logic goes here    
            
            }
        } else {
            //after logic
            if(Trigger.isInsert){
                       
            }
            else if(Trigger.isUpdate){              
            //after update logic goes here
            if(!TriggerHandler.EDIUpdate){
                Set<Id> DasrreqIdset = new Set<Id>();
                boolean isPLC,isNSPLC;
                List<Dasr_Request__c>DasrRequestList = new List<Dasr_Request__c>();
                Dasr_Request__c DasrRequestObj = new Dasr_Request__c();
                Peak_Load_Information__c peakLoadinfo = new Peak_Load_Information__c(); 
                Peak_Load_Information__c peakLoadinfo2 = new Peak_Load_Information__c();  
             // Map<id, dasr_request__c>dasrMap = new Map<id, dasr_request__c>([select id, LDC_Account__c, change_Effective_Date__c, Capacity_Obligation__c, Transmission_Obligation_Quantity__c, DASR_Type__c from dasr_request__c where id in: Trigger.new and DASR_Type__c = 'GAAE']);         
                List<Peak_Load_Information__c>peakLoadinfoListIns = new List<Peak_Load_Information__c>();
                for (DASR_Request__c dasareqobj: Trigger.new) {
                    if(dasareqobj.DASR_Type__c == 'GAAE' && dasareqobj.Accepted__c == true && dasareqobj.change_effective_date__c != null){
                        DasrreqIdset.add(dasareqobj.LDC_Account__C);
                    }
                }
                system.debug('=============DasrreqIdset=============='+DasrreqIdset);
                map<id,List<Peak_Load_Information__c>> mapLDCPeak_Load_Information = new map<id,List<Peak_Load_Information__c>>();
                
                // get Peak_Load_Information
                for(Peak_Load_Information__c peakLoadInfoList : [select id,name,start_date__c,EndDate__c,Dasr_Request__c,Load_value__c,Load_Type__C,LDC_Account__C FROM Peak_Load_Information__c WHERE LDC_Account__C IN: DasrreqIdset AND (Load_Type__c ='PLC' or Load_Type__c = 'NSPLC')]){
                    if(mapLDCPeak_Load_Information.containsKey(peakLoadInfoList.LDC_Account__C)){
                        List<Peak_Load_Information__c> lstobj = mapLDCPeak_Load_Information.get(peakLoadInfoList.LDC_Account__C);
                        lstobj.add(peakLoadInfoList);
                        mapLDCPeak_Load_Information.put(peakLoadInfoList.LDC_Account__C,lstobj);
                    }
                    else{
                        List<Peak_Load_Information__c> lstobj = new List<Peak_Load_Information__c>();
                        lstobj.add(peakLoadInfoList);
                        mapLDCPeak_Load_Information.put(peakLoadInfoList.LDC_Account__C,lstobj);
                    }
                }
                system.debug('=============mapLDCPeak_Load_Information=============='+mapLDCPeak_Load_Information); 
                for(DASR_Request__c dasrobj : Trigger.new){ 
                    if(dasrobj.DASR_Type__c == 'GAAE' && dasrobj.change_effective_date__c != null && dasrobj.Accepted__c == true){
                        peakLoadinfo = new Peak_Load_Information__c();
                        peakLoadinfo2 = new Peak_Load_Information__c();
                        isPLC= false;
                        isNSPLC = false;
                        // check if LDC account has the Peak_Load_Information
                        if(mapLDCPeak_Load_Information.containsKey(dasrobj.LDC_Account__C)){
                            // get filtered list for LDC account
                            List<Peak_Load_Information__c> lstpeakLoadInfo = mapLDCPeak_Load_Information.get(dasrobj.LDC_Account__C);                           
                            for(Peak_Load_Information__c peakLoadInfoObj : lstpeakLoadInfo){
                                if(peakLoadInfoObj.Load_Type__C == 'PLC' ){
                                    if(((dasrobj.LDC_Account__C ==  peakLoadInfoObj.LDC_Account__C) && (dasrobj.change_Effective_Date__c == peakLoadInfoObj.start_date__c)) || ((dasrobj.LDC_Account__C ==  peakLoadInfoObj.LDC_Account__C) && (dasrobj.change_Effective_Date__c > peakLoadInfoObj.start_date__c) && (dasrobj.change_Effective_Date__c < peakLoadInfoObj.Enddate__c))){
                                        isPLC= true;                                   
                                    }                     
                                }
                                if(peakLoadInfoObj.Load_Type__C == 'NSPLC'){
                                    if(((dasrobj.LDC_Account__C ==  peakLoadInfoObj.LDC_Account__C) && (dasrobj.change_Effective_Date__c == peakLoadInfoObj.start_date__c)) || ((dasrobj.LDC_Account__C ==  peakLoadInfoObj.LDC_Account__C) && (dasrobj.change_Effective_Date__c > peakLoadInfoObj.start_date__c) && (dasrobj.change_Effective_Date__c < peakLoadInfoObj.Enddate__c))){
                                        isNSPLC = true;                                  
                                    } 
                                }
                            }
                        }
                        system.debug('=============isPLC=============='+isPLC);
                        if(!isPLC){
                             if(Trigger.oldMap.get(dasrobj.id).Capacity_Obligation__c != Trigger.newMap.get(dasrobj.id).Capacity_Obligation__c){       
                                if(dasrobj.Capacity_Obligation__c != null && dasrobj.Capacity_Obligation__c != 0){
                                    //peakLoadInfo.start_date__C = dasrobj.change_Effective_Date__c;                         
                                    peakLoadInfo.Load_Type__C = 'PLC';                          
                                    if(dasrobj.change_Effective_Date__c.month()>5 ){
                                        string start1= (dasrobj.change_Effective_Date__c.year())+'0601';
                                        peakLoadInfo.Start_Date__c = IntegrationUtil.convertStringToDate(start1);   
                                        String end1 = (peakLoadInfo.start_date__C.year() + 1)+'0531';
                                        peakLoadInfo.EndDate__c = IntegrationUtil.convertStringToDate(end1);   
                                    }
                                    else{
                                        string start2= (dasrobj.change_Effective_Date__c.year()-1)+'0601';
                                        peakLoadInfo.Start_Date__c = IntegrationUtil.convertStringToDate(start2);   
                                        String end2 = dasrobj.change_Effective_Date__c.year()+'0531';
                                        peakLoadInfo.EndDate__c = IntegrationUtil.convertStringToDate(end2);
                                    }
                                    peakLoadinfo.Load_value__c = dasrobj.Capacity_Obligation__c;
                                    peakLoadInfo.LDC_Account__C = dasrobj.LDC_Account__C;
                                    peakLoadinfo.Dasr_request__c = dasrobj.id;
                                    peakLoadinfoListIns.add(peakLoadinfo);
                                }
                                system.debug('============peakLoadinfo==========='+peakLoadinfo);
                             }
                        }
                        system.debug('=============isNSPLC=============='+isNSPLC);
                        if(!isNSPLC){
                            if(Trigger.oldMap.get(dasrobj.id).Transmission_Obligation_Quantity__c != Trigger.newMap.get(dasrobj.id).Transmission_Obligation_Quantity__c){
                               if(dasrobj.Transmission_Obligation_Quantity__c != null && dasrobj.Transmission_Obligation_Quantity__c != 0){
                                    //peakLoadInfo2.start_date__C = dasrobj.change_Effective_Date__c;
                                    peakLoadInfo2.Load_Type__C = 'NSPLC';
                                    if(dasrobj.change_Effective_Date__c.month()>=1 ){
                                        string start3= (dasrobj.change_Effective_Date__c.year())+'0101';
                                        peakLoadInfo2.Start_Date__c = IntegrationUtil.convertStringToDate(start3);
                                        String end3 = peakLoadInfo2.start_date__C.year()+'1231';
                                        peakLoadInfo2.EndDate__c = IntegrationUtil.convertStringToDate(end3);
                                    }
                                    else{ 
                                    }
                                    peakLoadinfo2.Load_value__c = dasrobj.Transmission_Obligation_Quantity__c;
                                    peakLoadInfo2.LDC_Account__C = dasrobj.LDC_Account__C;
                                    peakLoadinfo2.Dasr_request__c = dasrobj.id;
                                    peakLoadinfoListIns.add(peakLoadinfo2);
                                } 
                                system.debug('============peakLoadinfo==========='+peakLoadinfo2);                                                      
                            }                   
                        }                                     
                    }   
                }
                system.debug('=============peakLoadinfoListIns=========='+peakLoadinfoListIns);
                if(peakLoadinfoListIns.size()>0)
                    upsert peakLoadinfoListIns;
                    
               /* system.debug('Entering After Update for CES');
                set<id> ldcset = new set<id>();
                list<ldc_account__c> ldclst = new list<ldc_account__c>();
                list<dasr_request__c> dasrlst = [select id,name,ldc_account__c,ldc_account__r.LDC_Account_Status__c,ldc_account__r.Enrolled__c,ldc_account__r.Enrollment_Date__c,Change_Effective_Date__c,
                                                    ldc_account__r.Enrollment_Sent_Date__c,ldc_account__r.Enrollment_Status__c,Integration_Status__c,Accepted__c,Billing_Entity__c,DASR_Submit_Date__c,
                                                    rejected__c from dasr_request__c where id IN : Trigger.new and Billing_Entity__c = 'CES'];
                for(Dasr_request__c dasr : dasrlst){
                    dasr.ldc_account__r.Enrollment_Date__c = dasr.Change_Effective_Date__c;
                    dasr.ldc_account__r.Enrollment_Sent_Date__c = Date.valueof(dasr.DASR_Submit_Date__c);
                    if(dasr.Integration_Status__c == 'Complete' || dasr.Accepted__c == true){
                        dasr.ldc_account__r.Enrollment_Status__c = 'Accepted';
                        dasr.ldc_account__r.Enrolled__c = true;
                        dasr.ldc_account__r.LDC_Account_Status__c = 'ACTIVE';
                    }
                    else if(dasr.Integration_Status__c == 'Failed' || dasr.Rejected__c == true){
                        dasr.ldc_account__r.Enrollment_Status__c = 'Error';
                        dasr.ldc_account__r.LDC_Account_Status__c = 'REJECTED';
                    }
                    else if(dasr.Integration_Status__c == 'Waiting For Response'){
                        dasr.ldc_account__r.Enrollment_Status__c = 'Sent';
                        dasr.ldc_account__r.LDC_Account_Status__c = 'PENDING_ENROLLMENT';
                    }
                    if(!ldcset.contains(dasr.ldc_account__c)){
                        ldcset.add(dasr.ldc_account__c);
                        ldclst.add(dasr.ldc_account__r);
                    }
                }
                if(!ldclst.isempty()) update ldclst;*/
                }
            }
        }
    }
}