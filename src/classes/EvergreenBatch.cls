/****************************************************************************************************************************
*                                                                                                                           *
*    Name : EvergreenBatch                                                                                                  *             
*    Purporse : Main Purpose of this class is to get all the quotes and then trigger the batch job to create new contracts  *
*    Type : Apex Batch Class                                                                                                *
*    Author : Chaitanya Kurra <Chaitanya.Kurra@dynegy.com>,<Chaitanyasfdev@gmail.com>                                       * 
*    Version : 1.0                                                                                                          *      
*    Test Class : EvergreenBatchTest                                                                                        *
*                                                                                                                           * 
*****************************************************************************************************************************
*                                                Change History                                                             *               
*                                                                                                                           *     
*    Version        Author                Date            Description                                                       *                     
*    1.0            Chaitanya Kurra       07/27/2017      Initial Version Created                                           *
*                                                                                                                           *             
*                                                                                                                           *         
*===========================================================================================================================*
*****************************************************************************************************************************/



global class EvergreenBatch implements Database.Batchable < sObject >,Database.stateful,Database.AllowsCallouts  {

    global final set<id> quotes;
    global set<id> pickedquotes;
    
   
    global set<id> Contract_nullratecodes = new set<id>();
    global set<id> ActivatecontractidIL = new set<id>();
    global set<id> ActivatecontractidOH = new set<id>();
    global set<id> Contract_nullratecodesOH = new set<id>();
    global set<id> Contract_nullratecodesIL =new set<id>();
    global set<id> AllContractids = new set<id>();
    global set<id> Updateconsucid = new set<id>();
    global list<BatchStartEnrollmentProcess.sendemailcontainer> seclist= new List<BatchStartEnrollmentProcess.sendemailcontainer>();
    
    public evergreenbatch(){}
    
    public EvergreenBatch(set<id> quoteids) {
        
    quotes = quoteids;
    system.debug('********quoteids********'+quoteids);
        system.debug('********quotes********'+quotes);
    }
  
    global String q;
    /**
     * @description gets invoked when the batch job starts
     * @param context contains the job ID
     * @returns the record set as a QueryLocator object that will be batched for execution
     */
    global Database.QueryLocator start(Database.BatchableContext context) {
        
        if(quotes == null || quotes.isEmpty()){
        system.debug('*** Nothing to process');
            return Database.getQueryLocator([Select Id from Retail_Quote__C where Id='a0M000000000000']);
        
        }
        
        else{

            Final set<string> stagename = new set<string>{'Closed Won','Closed Lost','Closed NA'};
            Final set<string> pricingtype = new set<string>{'Renewal Evergreen','Renewal MTM'};
            q = ConstantUtility.getObjectFieldsQuery('Retail_Quote__c') + ',Opportunity__r.account.recordtype.name,Opportunity__r.Contract.id,Opportunity__r.Account.Supplier__C,Opportunity__r.Contract.Bill_Method__c,Opportunity__r.Account.BillingPostalCode,Opportunity__r.Account.BillingCountry,Opportunity__r.Account.BillingCity,Opportunity__r.Account.BillingState,Opportunity__r.Contract.Rate_code__c,Opportunity__r.Account.BillingStreet From Retail_Quote__c where id IN :quotes and Recordtype.name =\'Executable\' and  Opportunity__C != null and Opportunity__r.Recordtype.name = \'Amendment\' and Opportunity__r.stagename != :stagename and Opportunity__r.Pricing_Type__c = :pricingtype  Order by Opportunity__c,name asc';

        system.debug('>>>>>>>>>>>>>>>>>*******' + q);

        return Database.getQueryLocator(q);}
    }

    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */
    global void execute(Database.BatchableContext context, List<Retail_Quote__c> scope) {


        List<Id> Quoteids = new List<Id> ();
        set<id> OpportunityID = new set<id>();
        list<decimal> quoteprice =  new list<decimal>();
        list<string> serviceterritory = new list<string>();
        list<Retail_Quote__c> Quotelist= (list<Retail_Quote__c>) scope;
        list<Rate_code__C> Ratecodelist;
        Map<String,Map<decimal,string>> Ratecodemap = new map<string,Map<decimal,string>>();
        set<id> contractid = new set<id>();
        set<id> Activatecontractid = new set<id>();
        system.debug('>>>>>>>Quote ids>>>>>>>>>>*******' +Quoteids);
        
        List<Retail_Quote__c> Quoteslistfinal = new list<Retail_quote__c>();
        
        system.debug('>>>>>>>>Scope>>>>>>>>>*******' +scope);
        
        
        for (Retail_Quote__c  quote1: quotelist) {
           if(!OpportunityID.contains(quote1.Opportunity__c)){
           OpportunityID.add(quote1.Opportunity__c);
           Quoteids .add(quote1.id);
           Quoteslistfinal.add(quote1);
           if(quote1.Quote_Price_KWH__c != null)
           quoteprice.add(quote1.Quote_Price_KWH__c);
           if(quote1.Opportunity__r.Service_Territory__c != null)
           serviceterritory.add(quote1.Opportunity__r.Service_Territory__c);           
           
           }
        }
        system.debug('>>>>>>>Quote ids>>>>>>>>>>*******' +Quoteids);
        system.debug('>>>>>>>Quote List final>>>>>>>>>>*******' +Quoteslistfinal);
        system.debug('>>>>>>>Opportunity ids>>>>>>>>>>*******' +OpportunityID);
        
         
        if((quoteprice.size()> 0) && (Serviceterritory.size()>0))
        Ratecodelist  = new list<Rate_code__c>([Select id,name,Price__c,Service_Territory__c from rate_code__c where Price__c=:quoteprice and Service_Territory__c =:Serviceterritory]);
        
        
        
        if(Ratecodelist != null && Ratecodelist.size()>0){
        for (Rate_code__C RC1 : Ratecodelist)
            {
            
                
                if(Ratecodemap.containskey(RC1.Service_Territory__c))
                    {   
                        map<decimal,string> tempmap1 = new map<decimal,string>();
                        tempmap1 = Ratecodemap.get(RC1.Service_Territory__c);
                        if(!tempmap1.containskey(RC1.price__C)){
                        tempmap1.put(RC1.price__C,RC1.name);
                        Ratecodemap.put(RC1.Service_Territory__c,tempmap1);
                        }  
                        
                    }
               else
                   { 
                       system.debug('****Firsttime*****');
                       map<decimal,string> tempmap2 = new map<decimal,string>();
                        tempmap2.put(RC1.price__C,RC1.name);
                        Ratecodemap.put(RC1.Service_Territory__c,tempmap2);
                        system.debug('*********RatecodeMap*******'+ Ratecodemap );
                   }
            }
        }
        
        system.debug('*********RatecodeMap*******'+ Ratecodemap );
        contractid = (CreateContractEvergreen(Quoteslistfinal,ratecodemap));
        
        List<Contract> newinsertcon = new list<contract>([Select id,rate_code__C,Service_Territory__c from contract where id =:contractid]);
        
        for(Contract con1: newinsertcon){
        if((con1.Rate_code__c != null) && !string.isblank(con1.Rate_code__c))
        {
            Activatecontractid.add(con1.id);
            
            if((Con1.Service_territory__c != null) && !string.isblank(Con1.Service_territory__c)  && Con1.Service_territory__c.contains('-IL'))
            ActivatecontractidIL.add(con1.id);
            else
            ActivatecontractidOH.add(con1.id);
            //AllContractids.add(con1.id);
            
        }
        else
        {
            Contract_nullratecodes.add(Con1.id);
             if((Con1.Service_territory__c != null) && !string.isblank(Con1.Service_territory__c)  && Con1.Service_territory__c.contains('-IL'))
            Contract_nullratecodesIL.add(con1.id);
            else
            Contract_nullratecodesOH.add(con1.id);
             //AllContractids.add(con1.id);
        }
        }
        
        if(Activatecontractid.size()>0){
           
           Database.SaveResult[] res1 = ActivateContract(Activatecontractid);
          // Iterate through each returned result          
            for (Database.SaveResult sr : res1) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    AllContractids.add(sr.getid());
                    System.debug('Successfully updated  Contract ID: ' + sr.getId());
                    System.debug('Successfully inserted  Contract record: ' + sr);
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Contract fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        
            system.debug('********Contractswith null Ratecode******'+Contract_nullratecodes);
            system.debug('********Contractswith  Ratecode******'+AllContractids);
    }

    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */
    global void finish(Database.BatchableContext context) {
    system.debug('********Contractswith null Ratecode******'+Contract_nullratecodes);
    system.debug('********Contractswith null Ratecode******'+AllContractids);
    system.debug('********quotesinitially Recieved******'+quotes);
    if(!AllContractids.isempty())
    {
        set<id> newcon1 = new set<id>();
        newcon1.addall(AllContractids);
     BatchStartEnrollmentProcess CNIBatch= new BatchStartEnrollmentProcess(newcon1,seclist);
                if(!BatchUtility.IsconcurrentjobsRunning()){
                    Database.executebatch(CNIBatch,200);
                }
                else{
                    System.scheduleBatch(CNIBatch, 'Re-Scheduled BatchCNIEnrollmentProcess @ '+Datetime.now(), 5);}
    
    if(!ActivatecontractidIL.isempty())
    sendemail(ActivatecontractidIL,false,'IL');
     if(!ActivatecontractidOH.isempty())
    sendemail(ActivatecontractidOH,false,'OH');
    }
    if(!Contract_nullratecodes.isempty())
    {
        if(!Contract_nullratecodesIL.isempty())
    sendemail(Contract_nullratecodesIL,true,'IL');
    if(!Contract_nullratecodesOH.isempty())
    sendemail(Contract_nullratecodesOH,true,'OH');
    }
    }

    Public Static set<id> CreateContractEvergreen(List<Retail_quote__c> Quotelist,map<string,map<decimal,string>> Ratemap){
    
    List<Retail_quote__c> quotesforcontracts = new list<Retail_quote__c>();
    quotesforcontracts = quotelist;
    List<Contract> Contractinsert = new List<Contract>();
    set<id> contractids = new set<id>();
    list<Retail_Quote__c> updatequote = new list<Retail_Quote__c>();
    List<Opportunity> UpdateOpportunity = new list<Opportunity>();
    //map<id,contract> oldcontractmap = new map<id,contract>();
    map<string,map<decimal,string>> ratecodemap1;
    ratecodemap1 = Ratemap;
    
    for (Retail_quote__c recQuote : quotesforcontracts)
        {
         contract quoteContract = new contract();
         Opportunity QuoteOpportunity = new opportunity();
            quoteContract.Name = 'Contract';
            
            
            
            Map<String, Schema.SObjectField> mapRetQtDescribe = schema.SObjectType.Retail_Quote__c.fields.getMap();
            Map<String, Schema.SObjectField> mapContractDescribe = schema.SObjectType.Contract.fields.getMap();
            
             for(String retQtField : mapRetQtDescribe.KeySet()){
                Schema.DescribeFieldResult describersult = mapRetQtDescribe.get(retQtField).getDescribe();
                if(!describersult.isCustom() || !describersult.isCreateable() || describersult.isCalculated()){
                    continue;
                }
                else if(mapContractDescribe.containsKey(retQtField))
                {
                    system.debug('Test : '+retQtField+' : '+recQuote.get(retQtField));
                    quoteContract.put(retQtField, recQuote.get(retQtField));
                }
            }
            
            if(ratecodemap1.size()>0){  
            if((recQuote.Opportunity__r.Service_Territory__c != null) && (recQuote.Quote_Price_KWH__c != null))
                {   
                     if(ratecodemap1.containskey(recQuote.Opportunity__r.Service_Territory__c)){      
                    map<decimal,string> tempmap = ratecodemap1.get(recQuote.Opportunity__r.Service_Territory__c);
                    
                    if(tempmap.size()>0)
                        {
                        for (Decimal price1 : tempmap.keyset())
                            {
                                if(Price1 == recQuote.Quote_Price_KWH__c)
                                  quoteContract.Rate_Code__c = tempmap.get(price1);
                            }
                        }
                     }
                    }
                    }
                
                if((recQuote.Opportunity__r.Service_Territory__c != null) && (recQuote.Opportunity__r.Service_Territory__c == 'ComEd-IL'))
               quoteContract.Bill_Method__C = 'Bill Ready';
               else if((recQuote.Opportunity__r.Service_Territory__c != null) && (recQuote.Opportunity__r.Service_Territory__c != 'ComEd-IL'))
               quoteContract.Bill_Method__C = 'Rate Ready';
                
                
            
            //quoteContract.Quote_Index_Adder_Total_Per_KWH__c = recQuote.Quote_Index_Adder_Total_Per_KWH__c;
            quoteContract.ALL_IN_Price__c= recQuote.Total_Priced_KWH__c;
            quoteContract.Total_Priced_MWH__c= recQuote.Total_Priced_MWH__c;
            quoteContract.Quote_Index_Name__c= recQuote.Quote_Index_Name__c;
            quoteContract.Contract_Type__c = recQuote.ContractType__c ;
            quoteContract.Parent_Contract__c = recQuote.Opportunity__r.Contract.id;
            quoteContract.StartDate = recQuote.Start_Term__c;
            quoteContract.ContractTerm = recQuote.Term__c.intValue();
            quoteContract.Product_Name__c = recQuote.Product__r.Name;
            quoteContract.Retail_Quote__c=recQuote.id;
            quoteContract.Opportunity__c = recQuote.Opportunity__c;
            
            
            
            quoteContract.Service_Territory__c=recQuote.Opportunity__r.Service_Territory__c;
            quoteContract.AccountId=recQuote.Opportunity__r.Account.id;
            quoteContract.BillingStreet=recQuote.Opportunity__r.Account.BillingStreet;
            quoteContract.BillingCity=recQuote.Opportunity__r.Account.BillingCity;
            quoteContract.BillingState=recQuote.Opportunity__r.Account.BillingState;
            quoteContract.BillingCountry=recQuote.Opportunity__r.Account.BillingCountry;
            quoteContract.BillingPostalCode=recQuote.Opportunity__r.Account.BillingPostalCode;
            quoteContract.Contract_Broker_Fee__c = recQuote.Contract_Broker_Fee__c;
            quoteContract.Contract_Index_Margin__c = recQuote.Contract_Index_Margin__c;
            quoteContract.Contract_Margin__c = recQuote.Contract_Margin__c;
            quoteContract.Contract_Marketing_Cost__c = recQuote.Contract_Marketing_Cost__c;
            quoteContract.Contract_Municipality_Fee__c = recQuote.Contract_Municipality_Fee__c;
            quoteContract.Referral_Broker__c = recQuote.Opportunity__r.Referral_Broker__c;
            quoteContract.Supplier__c = recQuote.Opportunity__r.Account.Supplier__C;
            quoteContract.Contract_Counter_Signed_Date__c = Datetime.now();
            quoteContract.Activity__c = 'No Action';
            recQuote.Request_Status__c = 'Contract Signed';
            
            
            QuoteOpportunity.id = recQuote.Opportunity__c;
            QuoteOpportunity.stagename = 'Closed Won';
            
            updatequote.add(recQuote);
            UpdateOpportunity.add(QuoteOpportunity);
            Contractinsert.add(quoteContract);
            
            //contract contractold = new contract();
           //contractold.id = recQuote.Opportunity__r.Contract.id;
            //Contractold.Activity__c = 'No Action';
           // oldcontractmap.put(contractold.id,contractold);
            
            }
            system.debug('>>>>>>>>>>updatequoteList>>>>>>>*******' +updatequote);
            system.debug('>>>>>>>>>>UpdateOpportunity>>>>>>>*******' +UpdateOpportunity);
            system.debug('>>>>>>>>>>Contractinsert>>>>>>>*******' +Contractinsert);
            
            //update updatequote;
            //update UpdateOpportunity;
            
            Database.SaveResult[] quotesrlist = Database.update(updatequote, false);
            Database.SaveResult[] oppsrlist = Database.update(UpdateOpportunity, false);
            Database.SaveResult[] consrList = Database.insert(Contractinsert, false);  
            //update oldcontractmap.values();
    

        // Iterate through each returned result
        for (Database.SaveResult sr : consrList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                contractids.add(sr.getid());
                System.debug('Successfully inserted account. Contract ID: ' + sr.getId());
                System.debug('Successfully inserted account. Contract record: ' + sr);
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Contract fields that affected this error: ' + err.getFields());
                }
            }
        }
     
    
    return contractids;
    }
    
    
    Public static Database.SaveResult[] ActivateContract(set<id> Contractids){
    
    set<id> contractidset = new set<id>();
    contractidset = contractids;
    
    List<Contract> updatecontract = new list<contract>();
     
     for (ID Contractid : Contractidset)
     {

         contract contract1 = new contract();
         contract1.id = Contractid ;
         contract1.status = 'Activated';
         //contract1.Activity__c = 'No Action';
         contract1.Enrollment_Stage__c = 'Ready to Enroll';
         updatecontract.add(contract1);
     
     }
    //update updatecontract;
     Database.SaveResult[] updatecontractres = Database.update(updatecontract, false);

    return updatecontractres ;
    
    }
    
    public static void sendemail(set<id> contract,boolean v1,string state){
        string res ='';
        String EGRecord = '';
        string EGContent = '';
        String EGfilebody = '';
        Blob EGcsvBlob;
        String EGCSVName = '';
        set<id> contractidforemail = new set<id>();
        contractidforemail = contract;
        boolean v2 = v1;
        String EGOutboundHeader = 'Contract Number,Name,Contract Status,Service Territory,Account Name,Opportunity Name,Retail Quote Number,Parent Contract,Contract ID,Account ID,Contract Type \r\n';//Retail Quote ID,Opportunity ID,Parent Contract ID,
        list<Messaging.EmailFileAttachment> Attlst = new list<Messaging.EmailFileAttachment>();
        if(!contractidforemail.isempty()){

            for(Contract CN : [SELECT Id,ContractNumber,Name,status,Service_Territory__c,Opportunity__c,AccountId,Parent_Contract__c,Retail_Quote__c,contract_type__C,account.name,Opportunity__r.name,parent_Contract__r.ContractNumber,Retail_quote__r.name FROM Contract where id = :contractidforemail])                                
                {
                
                    EGRecord = '"'+CN.ContractNumber+'","'+CN.name+'","'+CN.Status+'","'+CN.Service_Territory__c+'","'+CN.Account.Name+'","'+CN.Opportunity__r.Name+'","'+CN.Retail_quote__r.name+'","'+CN.parent_Contract__r.ContractNumber+'","'+CN.id+'","'+CN.accountid+'","'+CN.contract_type__C+'","'+'",""\r\n';
                    EGContent+= EGRecord.replaceall('null','');
                }
            
            res = '\n\n\t\t<b> Attached are the list of Contract Created today '+date.today().format()+'  </b>\n\n';
        }    
        else{
            res='\n\n\t\t<b> No Contracts were created today '+date.today().format()+'  </b>\n\n';
        }
        string mailerslst;
        mailerslst = label.Evergreen_mailersIL;
        if(state == 'IL')
         mailerslst = label.Evergreen_mailersIL;
        else
          mailerslst = label.Evergreen_mailersOH;
        if(v2){
         //mailerslst = label.Evergreen_mailers_sales;
        res  = '\n\n\t\t<b> Attached are the list of Contracts having blank Rate codes.These contracts are not Activated '+date.today().format()+'  </b>\n\n';
        }
        
        else {
         //mailerslst = label.Evergreen_mailers;
        }
        
        
        list<string> mailerstr = mailerslst.split(';');
        list<user> usr = [select id,name,email from user where name IN : mailerstr];
        list<string> mailers = new list<string>();
        for(User U : Usr){
            mailers.add(u.email);
        }
        if(!string.isempty(EGcontent)){
            EGfilebody = EGOutboundHeader + EGContent;
            EGcsvBlob = Blob.valueof(EGfilebody);
            EGCSVName = ''+'EverGreen All Contracts-'+string.valueof(date.today().format())+'.csv';
            if(v2)
            EGCSVName = ''+'EverGreen RateCodeNull Contracts-'+string.valueof(date.today().format())+'.csv';
            
            Messaging.EmailFileAttachment EGCSVAtt = new Messaging.EmailFileAttachment();
            EGCSVAtt.setFileName(EGCSVName);
            EGCSVAtt.setBody(EGcsvBlob);
            Attlst.add(EGCSVAtt);
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(mailers);
        mail.setSubject('Evergreen Contract Creation Job result - '+date.today().format()+'  Run');
        if(v2)
        mail.setSubject('Evergreen Blank Rate Code Contracts - '+date.today().format()+'  Run');
        mail.setTargetObjectId(userinfo.getuserid());
        mail.setsaveAsActivity(false); 
        mail.setHtmlBody('Hello,'
                        +'\n\nEvergreen Contract Creation job @<b>'+date.today().format()+'</b> results  : <br/>'+res);
        if(v2)
        mail.setHtmlBody('Hello,'
                        +'\n\nEvergreen Contract Creation job with blank rate code contract @<b>'+date.today().format()+'</b> results  : <br/>'+res);
        mail.setFileAttachments(Attlst);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }  

}