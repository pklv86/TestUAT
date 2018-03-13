/****************************************************************************************************************************
*                                                                                                                           *
*    Name : EvergreenSchedule                                                                                               *             
*    Purporse : Main Purpose of this class is to get all the quotes and then trigger the batch job to create new contracts  *
*    Type : Apex Schedulable Class                                                                                          *
*    Author : Chaitanya Kurra <Chaitanya.Kurra@dynegy.com>,<Chaitanyasfdev@gmail.com>                                       * 
*    Version : 1.0                                                                                                          *      
*    Test Class : EvergreenScheduleTest                                                                                     *
*                                                                                                                           * 
*****************************************************************************************************************************
*                                                Change History                                                             *               
*                                                                                                                           *     
*    Version        Author                Date            Description                                                       *                     
*    1.0            Chaitanya Kurra       07/25/2017      Initial Version Created                                           *
*    2.0            Chaitanya Kurra       09/19/2017      Splitting the email based on States                               *
*                                                                                                                           *             
*                                                                                                                           *         
*===========================================================================================================================*
*****************************************************************************************************************************/
public class EvergreenSchedule implements system.Schedulable, Database.stateful, Database.AllowsCallouts{

    public static String query;
    public static Set<id> QuoteID = new set<id>(); //to store the QuoteID which are processed
    public static Set<id> Retailquotespicked = new set<id>();
    Public static set<id> OpportunityID = new set<id>(); // to store the Opportunity ID which are processed
    public static set<id> OldContractID = new set<id>(); // to store the old contract id for setting the new contract with old contract
    public static set<id> NewContractID = new set<id>(); // tp store the new contract ids which are being created by this process
    public static list<Retail_Quote__c> Quotelist = new list<Retail_Quote__c>(); // to store all the list of retail quotes
    Public static list<Retail_Quote__c> finalQuotelist = new list<Retail_Quote__c>(); //to store only final list of quotes where we need to process them for creating contracts
    public static list<Retail_Quote__c> UpdateQuotelist = new list <Retail_Quote__C>(); // to store all the list of retail quotes for updating once after creating the contracts
    Public static list<Contract> NewContract = new list<Contract>(); // to store the list of contracts which this process will create from retail quotes
    Public static map<id,Contract> OldContract = new map<id,contract>(); // to store the old contract values
        
    public void execute (schedulableContext SC)
        {
        
            getretailquotes(); // Method is to get all the quotes where contracts needs to be created
            
            //EvergreenBatch createcontracts = new EvergreenBatch(Retailquotespicked);
            system.debug('*****Retailquotespicked******'+Retailquotespicked);
            
            if(Retailquotespicked.size()>0)
            Database.executebatch(new EvergreenBatch(Retailquotespicked),5);
        
        }

    public static void getretailquotes()
        {
            List <Retail_Quote__c> RQ = new list<Retail_Quote__c>();
            string D1 = date.today().format();
            system.debug('********D1******'+D1);
            datetime  d2 = system.now();
            date d3 = date.newinstance(d2.year(), d2.month(), d2.day());
            system.debug('********D2******'+D2);
            system.debug('********D3******'+D3);
            Final set<string> stagename = new set<string>{'Closed Won','Closed Lost','Closed NA'};
            FInal set<string> pricingtype = new set<string>{'Renewal Evergreen','Renewal MTM'};
            query = ConstantUtility.getObjectFieldsQuery('Retail_Quote__c') + ',Opportunity__r.account.recordtype.name,Opportunity__r.Contract.Bill_Method__c,Opportunity__r.Contract.Rate_code__c From Retail_Quote__c where Recordtype.name =\'Executable\' and  Opportunity__C != null and Opportunity__r.Recordtype.name = \'Amendment\' and Opportunity__r.stagename != :stagename and Opportunity__r.Pricing_Type__c = :pricingtype and Opportunity__r.Contractid != null and Opportunity__r.account.recordtype.name = \'C&I Customer\' Order by Opportunity__c,name asc LIMIT 49500';
            system.debug ('*****Query*****'+Query);
            Quotelist = database.query(query);
            System.debug ('****List of Quotes*******'+Quotelist);
            
            For(Retail_Quote__C Q1 : Quotelist)
                {
                   if (!OpportunityID.contains(Q1.opportunity__c))
                       {
                           RQ.add(Q1);
                           OpportunityID.add(Q1.Opportunity__c);
                       }                  
                }
                
           System.debug ('********* First Quote for Opportunity **************'+RQ);
                
          for(Retail_Quote__c Q2: RQ)
              {
                //if((q2.Request_Status__c).equalsignorecase('Pricing Complete'))
                    //{
                      if((q2.Pricing_Valid_Date_Time__c != null))
                      {
                        date d4 = date.newinstance((q2.Pricing_Valid_Date_Time__c).year(), (q2.Pricing_Valid_Date_Time__c).month(), (q2.Pricing_Valid_Date_Time__c).day());
                        system.debug('******pricing_valid_date_time'+q2.Pricing_Valid_Date_Time__c);
                         system.debug('********D3******'+D3);
                          system.debug('********D3******'+D3.adddays(1));
                        system.debug('*********D4*******'+d4); 
                            if(d4 <=  D3.adddays(1))
                                {
                                                    
                                    finalQuotelist.add(Q2);
                                    Retailquotespicked.add(Q2.ID);
                                } 
                      // }
                   }
              }
         System.debug ('*********Final Pricing Complete quote**************'+finalQuotelist);
        
        sendemail(Retailquotespicked);
       
        }
        
        public static void sendemail(set<id> Retailquotespicked){

        string stateOH = 'OH';
        string StateIL = 'IL';
        set<id> RetailquotespickedOH = new set<id>();
        set<id> RetailquotespickedIL = new set<id>();
        List<Messaging.SingleEmailMessage> mail = new List<Messaging.SingleEmailMessage>();
         Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
          Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
          
        if(!Retailquotespicked.isempty()){
        
        for(Retail_Quote__c RQ : finalQuotelist)                                
                {
                    if(RQ.Opportunity__r.Service_Territory__c.contains('-IL'))
                    {
                        RetailquotespickedIL.add(RQ.id);
                    
                    }
                    else
                    RetailquotespickedOH.add(RQ.id);
                }
        
        mail1 = Buildemail(RetailquotespickedOH,StateOH);
        mail2 = Buildemail(RetailquotespickedIL,StateIL);
        }
        else{
        mail1 = Buildemail(RetailquotespickedOH,StateOH);
        mail2 = Buildemail(RetailquotespickedIL,StateIL);
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1,mail2 });
        }  
    
     public static Messaging.SingleEmailMessage Buildemail(set<id> Retailquotespicked1,string state){
    
        string res ='';
       // string res1='';
        //string res2='';
        String EGRecord = '';
        string EGContent = '';
        String EGfilebody = '';
        Blob EGcsvBlob;
        String EGCSVName = '';
        string mailerslst ;
        String EGOutboundHeader = 'Retail Quote Number,Opportunity Name,Retail Quote Status,Retail Quote ID,Opportunity ID,Opportunity Service Territory,Opportunity Pricing Type,Pricing Valid Date Time,Opportunity Status \r\n';
        list<Messaging.EmailFileAttachment> Attlst = new list<Messaging.EmailFileAttachment>();
        if(!Retailquotespicked1.isempty()){
            Datetime dt = Datetime.newInstance(Date.today(),Time.newInstance(datetime.now().time().hour(),0,0,0));
     
            for(Retail_Quote__c RQ : finalQuotelist)                                
                {
                    if(Retailquotespicked1.contains(RQ.id)){
                    
                    EGRecord = '"'+RQ.Name+'","'+RQ.Opportunity__r.name+'","'+RQ.Request_Status__c+'","'+RQ.ID+'","'+RQ.Opportunity__c+'","'+RQ.Opportunity__r.Service_Territory__c+'","'+RQ.Opportunity__r.Pricing_Type__c+'","'+RQ.Pricing_Valid_Date_Time__c+'","'+RQ.Opportunity__r.stagename+'","'+'",""\r\n';
                    EGContent+= EGRecord.replaceall('null','');
                    }
                }           
            res = '\n\t\t<b> Attached are the list of Retail quotes that are picked for creating contracts for '+state+' - '+date.today().format()+'  </b>\n\n';
        }    
        else{
            res='\n\t\t<b> No Retail quotes have been picked for todays '+state+' job - '+date.today().format()+' </b>\n\n';
        }
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
        if(!string.isempty(EGcontent)){
            EGfilebody = EGOutboundHeader + EGContent;
            EGcsvBlob = Blob.valueof(EGfilebody);
            EGCSVName = 'Ever Green Renewals'+'-'+string.valueof(system.now())+'.csv';
            
            Messaging.EmailFileAttachment EGCSVAtt = new Messaging.EmailFileAttachment();
            EGCSVAtt.setFileName(EGCSVName);
            EGCSVAtt.setBody(EGcsvBlob);
            Attlst.add(EGCSVAtt);
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(mailers);
        mail.setSubject('Evergreen Schedule Job Result - '+date.today().format()+'  Run');
        mail.setTargetObjectId(userinfo.getuserid());
        mail.setsaveAsActivity(false); 
        mail.setHtmlBody('Hello,'  
                            +'\n\nEvergreen Schedule Job @<b>'+date.today().format()+' </b> results : <br/>'+res);
        mail.setFileAttachments(Attlst);
         
         return mail;

    }
}