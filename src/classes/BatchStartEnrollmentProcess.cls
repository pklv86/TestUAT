/* 
 * Name: BatchStartEnrollmentProcess
 * Type: Apex Class
 * Test Class: BatchSetEnrollmentProcessTest
 * Description:  This batch job populates the Enrollment Date on LDC Accounts when contracts are set to Process. 
 * Change History: Bindu: modified to send batch statistics to send thru mail
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Kartheek Akkineni         02/05/2016       1. Initial Version created
 * 2.0         Chaitanya Kurra           08/04/2017       2. Introduced Controller to handle Evergreen
 */
global class BatchStartEnrollmentProcess implements Database.Batchable<sObject>,Database.Stateful {
    
     global String query;
     
     global final set<Id> IdstoEnroll;
     global boolean IsMuniAgg;
     global final Map<Id,Contract> enrollCntrctMap;
     global final set<id> contractID;
     global Integer dasrListcount;
     global Integer LDCListcount;
     global map<String,String> LDCBillErrorMap;
     global integer LDCProcessCount;
     global final boolean evergreen;
     public static set<id> conID;
     global set<id> remainingcon = new set<id>();
     global set<id> noldcforcon = new set<id>();
     global final list<sendemailcontainer>  sec1;
     global list<sendemailcontainer> sec2 = new list<sendemailcontainer>();
     global list<sendemailcontainer> secIL = new list<sendemailcontainer>();
     global list<sendemailcontainer> secOH = new list<sendemailcontainer>();
     //global final set<string> LDC_STATUS =new Set<string> {'NEW_ACCOUNT','ACTIVE'};
    public BatchStartEnrollmentProcess(){}
    global BatchStartEnrollmentProcess(Set<id> enrollIds, Boolean IsMuni, Map<Id,Contract> cntrctMap) {
        enrollCntrctMap=cntrctMap;
        IdstoEnroll=enrollIds;
        IsMuniAgg=IsMuni;
        evergreen = false;
    }
    
    
    global BatchStartEnrollmentProcess(set<id> contractids, list<sendemailcontainer> listsec)
        {
            sec2.addall(listsec);
            system.debug('**********Printsendemailcontainer starting*****'+sec2);
            system.debug('*********'+contractids);
            //remainingcon.clear();
            //contractID.clear();
            system.debug('*********'+contractID);
            system.debug('******Remain after clear*****'+remainingcon);
            contractID =  contractids;
            string conid1;
            evergreen = true ;
            IsMuniAgg = false;
            ID contractid1;
                //conID = contract;
                remainingcon = contractID;
                boolean noLDCtoenroll;
                noLDCtoenroll = true;
                    for (ID con: contractID)
                        {
                            if(noLDCtoenroll)
                                {
                                    Contractid1 = con;
                                    conid1 = con;
                                         
                                        Set<Id> cniIds=new Set<id>();
                                       system.debug('******cntrctId****'+conid1);
                                        string cntrctquery=EnrollmentHandler.CONTRCT_ENROLL_QUERY;
                                        if(conid1!=null && conid1.trim() !=''){
                                            cntrctquery+=' and Id =: conid1 ';
                                        }
                                        system.debug('******cntrctquery****'+cntrctquery);
                                        List<Contract> cntrctList=Database.query(cntrctquery);
                                        Map<id,Contract> cntrctMap=new Map<id,Contract>() ; 
                                        for(Contract ct:CntrctList)
                                            {
                                               
                                                if(ct.Account.RecordType.Name==ConstantUtility.CUST_CNI_REC_TYPE ){
                                                    cniIds.add(ct.Opportunity__c);
                                                }
                                                cntrctMap.put(ct.AccountId,ct);
                                            }
                                
                                        if(!cniIds.isEmpty()){
                                            Set<id> oppLdcIds=new set<Id>();
                                            for(Opportunity_LDC__c ldcOpp:[Select id,LDC_Account__c,Opportunity__c from Opportunity_LDC__c where Opportunity__c in :cniIds ])
                                                oppLdcIds.add(ldcOpp.LDC_Account__c);
                                            if(!oppLdcIds.isEmpty()){
                                                IdstoEnroll=oppLdcIds;
                                                enrollCntrctMap = cntrctMap;
                                                noLDCtoenroll = false;
                                                }
                                             else 
                                             {
                                                noLDCtoenroll = true;                                               
                                                    Sendemailcontainer sectemp = new sendemailcontainer();
                                                    sectemp.contractnumber1 = cntrctMap.values().ContractNumber;
                                                    if(cntrctMap.values()!= null && cntrctMap.values().Service_Territory__c!= null && cntrctMap.values().Service_Territory__c.contains('-IL'))
                                                        sectemp.state = 'IL';
                                                    else 
                                                        sectemp.state ='OH';
                                                    sectemp.LDCBillErrorMap1 = null;
                                                    sectemp.dasrListcount1 = 0;
                                                    sectemp.LDCListcount1 =0;
                                                    sectemp.LDCProcessCount1 = 0;
                                                    sec2.add(sectemp);
                                             }
                                             
                                            }                                   
                                                                    
                                }
                            if(noLDCtoenroll){
                            noldcforcon.add(con);
                            remainingcon.remove(con);
                            }
                            else{
                                remainingcon.remove(con);
                                System.debug('******After Removing*****'+remainingcon);
                                 break;
                            }
                           
                                                                            
                        }
  
        }
        
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        query=EnrollmentHandler.LDC_ENROLL_QUERY;
        system.debug('Test : '+enrollCntrctMap+' : '+IdstoEnroll);
        
        if(enrollCntrctMap != null && IdstoEnroll != null ){
        if(IsMuniAgg){
            
            query+=' Where Opt_Out__c=false and Account__r.Business_Account__c in :IdstoEnroll and (contract__c!=null or contract__c != \'\')';//and LDC_Account_Status__c in : LDC_STATUS 
        }else{
            
            query+=' Where Id in :IdstoEnroll';
        }
        system.debug('Query : '+query);
        
        return Database.getQueryLocator(query);
        }
        
        else 
        return Database.getquerylocator([Select id from ldc_account__c where id = 'a0B000000000000']);
        
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        set<string> cntset = new set<string>();
        string cntsetstr = '(\'';
        for(Contract cnt : enrollCntrctMap.values()){
            cntset.add(cnt.contractnumber);
            cntsetstr += cnt.contractnumber+'\',\'';
        }
        cntsetstr = cntsetstr.substring(0,cntsetstr.length()-2);
        cntsetstr += ')';
        system.debug('Contract set : '+cntset+' : '+cntsetstr);
        
        List<LDC_Account__c> Lst=(List<LDC_Account__c>)scope; 
        system.debug('Before LDC : '+Lst.size());
        List<LDC_Account__c> ldcList = new list<LDC_Account__c>();
        if(IsMuniAgg){
            for(Ldc_account__c ldc : Lst){
                if(cntset.contains(ldc.contract__c)){
                    ldcList.add(ldc);
                }
            }
        }
        else{
            ldcList.addAll(Lst);
        }
        //system.debug('After LDC : '+ldcList.size());
        EnrollmentHandler.DASRBillErrorListSend dasrListBillError=new EnrollmentHandler.DASRBillErrorListSend();
        
        dasrListBillError = EnrollmentHandler.CreateDASRRequestforLDCs(ldcList,enrollCntrctMap);
        List<DASR_Request__c> dasrList=new List<DASR_Request__c>();
        dasrList.addall(dasrListBillError.dasrsList);
        
        if(dasrListcount==null)
            dasrListcount=0;
        if(LDCListcount==null)
            LDCListcount=0;
        if(LDCBillErrorMap==null)
            LDCBillErrorMap = new map<String,String>();
        if(LDCProcessCount==null)
            LDCProcessCount = 0;
   
        dasrListcount+= (integer)dasrList.size();
        LDCListcount+=ldcList.size();
        LDCBillErrorMap.putall(dasrListBillError.LDCToBillCycleErrorMap);
        LDCProcessCount+=dasrListBillError.LDCsProcessedCount;
        if(!dasrList.isEmpty())
            Database.Upsert(dasrList);

        for(contract ct:enrollCntrctMap.values()){
            ct.Enrollment_Stage__c='Processed';
            
        }
        Database.update(enrollCntrctMap.values());
        
        if(IsMuniAgg){
            List<ldc_account__c> ldclst=new List<ldc_account__c>();
            set<id> ldcset =new set<id>();
            if(!dasrList.isEmpty()){
                for(dasr_request__c dasr : dasrList){
                    ldcset.add(dasr.ldc_account__c);
                }
            }
            if(!ldcset.isempty()){
                for(ldc_account__c ldc : [select id,name,contract__c,Opt_out__c from ldc_account__c where id IN : ldcset]){
                    ldc.contract__c = '';
                    ldc.opt_out__c = false;
                    ldclst.add(ldc);
                }
            }
            if(!ldclst.isempty()) update ldclst;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        if(evergreen){ system.debug('******Remaining1*****'+remainingcon);
            if(enrollCntrctMap != null)
            {
                if(enrollCntrctMap.size()>0)
                {           
                        Sendemailcontainer sectemp = new sendemailcontainer();
                            if(enrollCntrctMap != null)
                            sectemp.contractnumber1 = enrollCntrctMap.values().ContractNumber;
                                if(enrollCntrctMap.values()!= null && enrollCntrctMap.values().Service_Territory__c!= null && enrollCntrctMap.values().Service_Territory__c.contains('-IL'))
                                        sectemp.state = 'IL';
                                else 
                                        sectemp.state ='OH';
                            sectemp.dasrListcount1 = dasrListcount;
                            sectemp.LDCListcount1 =LDCListcount;
                            sectemp.LDCBillErrorMap1 = LDCBillErrorMap;
                            sectemp.LDCProcessCount1 = LDCProcessCount;
                            sec2.add(sectemp);
                            system.debug('**********Printsendemailcontainer after finish*****'+sec2);     
                }
            }
                if(!remainingcon.isempty())
                    {
                         
                        //System.enqueueJob(new EnrollEvergreen(remainingcon));
                        system.debug('******Remaining3*****'+remainingcon);
                        //contractID.clear();
                        set<id> newset = new set<id>();
                        newset = remainingcon;
                        system.debug('********'+contractID);
                        BatchStartEnrollmentProcess CNIBatch= new BatchStartEnrollmentProcess(remainingcon,sec2);
                            if(!BatchUtility.IsconcurrentjobsRunning())
                                {
                                    Database.executebatch(CNIBatch,200);
                                }
                            else
                                {
                                    System.scheduleBatch(CNIBatch, 'Re-Scheduled BatchCNIEnrollmentProcess @ '+Datetime.now(), 5);
                                }
               
                    }
                else
                    {
                        for(Sendemailcontainer sec : sec2){
                            
                            if(sec.state == 'IL')
                                secIL.add(sec);
                            else
                                secOH.add(sec); 
                        }
                        
                        if(secIL.size()>0)
                        sendemail1(secIL,'IL');
                        if(secOH.size()>0)
                            sendemail1(secOH,'OH');
                    }
                
                
                
         }
        
        else
            {
                    
                //BatchUtility.sendAsyncApexJobExceptionEmails( BC.getJobId());
                system.debug('@@@@@@ Finishing Batch'); 
                system.debug('@@@@@@ ldc size'+LDCListcount); 
                system.debug('@@@@@@ dasr size'+dasrListcount);
                String billErrorMsg;
                if(LDCBillErrorMap.size()>0)
                {
                    billErrorMsg = 'Please note for below LDC accounts ContractLDC/DASR not created as Bill Cycle key not found'+'\n\t '+'Count : '+LDCBillErrorMap.size()+'\n\t ';
                    for(String LDCNumber: LDCBillErrorMap.Keyset())
                    {
                    billErrorMsg+=LDCNumber+' : '+LDCBillErrorMap.get(LDCNumber)+'\n\t';
                    }
                }
                else
                {
                    billErrorMsg = '';
                }   
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject('Enrollment Batch Completion Intimation');
                mail.setTargetObjectId(userinfo.getuserid());
                mail.setsaveAsActivity(false); 
        
        
                mail.setPlainTextBody('Dear '+UserInfo.getName()+','
                                        + '\n\nYour Enrollment batch for contract Number:'+ enrollCntrctMap.values().ContractNumber+' has been completed successfully.'
                                        +'\n\tPlease note below key stats from process:'
                                        +'\n\t Total LDC records picked by Job:'+ LDCListcount
                                        +'\n\t Total LDC records picked for Processing : '+ LDCProcessCount
                                        +'\n\t Total DASR/ContractLDC created:' + dasrListcount
                                        + '\n\t'+billErrorMsg);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
            }
        }
        
        public static void sendemail1(list<sendemailcontainer> sectemp1,string State){
        string res ='';
        String EDRecord = '';
        string EDContent = '';
        String EDfilebody = '';
        Blob EDcsvBlob;
        String EDCSVName = ''; 
        string errormap =''; 
        list<Sendemailcontainer> sec12 = new list<Sendemailcontainer>();
        
        sec12 = sectemp1;
      
        String EDOutboundHeader = 'Contract Number,LDC Picked Count,LDC Processed Count,DASR/Contract LDC Created,Bill_Msg Error \r\n';
        res='\n\t\t<b> Todays Evergreen Contracts Mark for Enrollment is completed - '+date.today().format()+' </b>\n\n';
        list<Messaging.EmailFileAttachment> Attlst = new list<Messaging.EmailFileAttachment>();
        
        
        if(sec12.size()>0)
        {
        
            for (sendemailcontainer sec :sec12)
                {
                    errormap = '';
                    map<String,String> LDCBillErrortemp = new map<string,string>();
                    LDCBillErrortemp = sec.LDCBillErrorMap1;
                     if(LDCBillErrortemp != null && LDCBillErrortemp.size()>0)
                         {
                            for(String LDCNumber: LDCBillErrortemp.Keyset())
                                {
                                errormap+=LDCNumber+' : '+LDCBillErrortemp.get(LDCNumber)+'\n\t';
                                }
                         }
                    EDRecord = '"'+sec.contractnumber1+'","'+sec.LDCListcount1+'","'+sec.LDCProcessCount1+'","'+sec.dasrListcount1+'","'+errormap+'","'+'",""\r\n';
                    EDContent+= EDRecord.replaceall('null',''); 
                
                }
        
        }
        
        
        
        
        string mailerslst;
        mailerslst = label.Evergreen_mailersIL;
        if(state == 'IL')
         mailerslst = label.Evergreen_mailersIL;
        else
          mailerslst = label.Evergreen_mailersOH;
        
        list<string> mailerstr = mailerslst.split(';');
        list<user> usr = [select id,name,email from user where name IN : mailerstr];
        list<string> mailers = new list<string>();
        for(User U : Usr){
            mailers.add(u.email);
        }
        
              if(!string.isempty(EDcontent)){
            EDfilebody = EDOutboundHeader + EDContent;
            EDcsvBlob = Blob.valueof(EDfilebody);
            EDCSVName = ''+'EverGreen Enrollment-'+string.valueof(date.today().format())+'.csv';            
            Messaging.EmailFileAttachment EDCSVAtt = new Messaging.EmailFileAttachment();
            EDCSVAtt.setFileName(EDCSVName);
            EDCSVAtt.setBody(EDcsvBlob);
            Attlst.add(EDCSVAtt);
        }
        

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(mailers);
        mail.setSubject('Evergreen Mark For Enrollment Job Result - '+date.today().format()+'  Run');
        mail.setTargetObjectId(userinfo.getuserid());
        mail.setsaveAsActivity(false); 
        mail.setHtmlBody('Hello,'
                        +'\n\nEvergreen Mark for Enrollmetn Job @<b>'+date.today().format()+' </b> results : <br/>\n\n'+res);
        mail.setFileAttachments(Attlst);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
    
    global class Sendemailcontainer {

     public Integer dasrListcount1 {get;set;}
     public Integer LDCListcount1 {get;set;}
     public map<String,String> LDCBillErrorMap1 {get;set;}
     public integer LDCProcessCount1 {get;set;}
     public string contractnumber1 {get;set;}
     public string state {get;set;}

    }
        
        
}