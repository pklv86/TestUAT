/* 
 * Name: EvergreenScheduleTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the EverGreenSchedule Apex  Class.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Chaitanya Kurra           08/07/201       1. Initial Version created
 */
@isTest
public class EvergreenScheduleTest {
     
    
     Static  void EvergreenSchedule_unittest()
        
        {
            ID optyRecAmndId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Amendment').RecordTypeId;
            ID CustRecCIId = Schema.SObjectType.Account.RecordTypeInfosByName.get('C&I Customer').RecordTypeId;
            RecordType rtExec = [select id,name from RecordType where name='Executable' and sobjectType='Retail_Quote__c' limit 1];
            
          Supplier__c testOperatingCompany = new Supplier__c(
                                                        Name='Test Supplier',
                                                        Supplier_DUNS__c = 'DUNSTEST',
                                                        Legacy_ID__c = 'TEST',
                                                        Master_DUNS__c = 'DUNSTEST',
                                                        Organization_Identifier_Code__c = 'TESTSUP',
                                                        Supplier_Code__c = 'TEST',
                                                        ESP_Account_Number__c = 'TEST',
                                                        Active__c = true
                                                      );
             insert testOperatingCompany;
            
             LDC_Vendor__c testVendor1 = new LDC_Vendor__c(Name='Test Vendor1',DUNS__c = 'U698DWJ5',Legacy_ID__c = 'TVNDR1',
                                   Service_Territory__c = 'DAYTON',Utility_Code__c = 'TST1',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
             LDC_Vendor__c testVendor2 = new LDC_Vendor__c(Name='Test Vendor2',DUNS__c = 'U698DWJ6',Legacy_ID__c = 'TVNDR2',
                                   Service_Territory__c = 'Ameren-IL',Utility_Code__c = 'TST2',Vendor_Type__c = 'LDC',Service_State__c = 'IL');
             LDC_Vendor__c testVendor3 = new LDC_Vendor__c(Name='Test Vendor3',DUNS__c = 'U698DWJ7',Legacy_ID__c = 'TVNDR3',
                                   Service_Territory__c = 'ComEd-IL',Utility_Code__c = 'TST3',Vendor_Type__c = 'LDC',Service_State__c = 'IL');
             LDC_Vendor__c testVendor4 = new LDC_Vendor__c(Name='Test Vendor4',DUNS__c = 'U698DWJ8',Legacy_ID__c = 'TVNDR4',
                                   Service_Territory__c = 'DEOHIO',Utility_Code__c = 'TST4',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
            
            insert new list<LDC_Vendor__c>{testVendor1,testVendor2,testVendor3,testVendor4};
            
           Utility_Business_Rules__c setting1 = new Utility_Business_Rules__c(Name=testVendor1.Service_Territory__c,Window_Days__c=7,Days_in_Window__c=7,Days_Out_Window__c=-5,Days_up_to_Window__c =0);
           Utility_Business_Rules__c setting2 = new Utility_Business_Rules__c(Name=testVendor2.Service_Territory__c,Window_Days__c=7,Days_in_Window__c=7,Days_Out_Window__c=-5,Days_up_to_Window__c =0);
            Utility_Business_Rules__c setting3 = new Utility_Business_Rules__c(Name=testVendor3.Service_Territory__c,Window_Days__c=7,Days_in_Window__c=7,Days_Out_Window__c=-5,Days_up_to_Window__c =0);
            Utility_Business_Rules__c setting4 = new Utility_Business_Rules__c(Name=testVendor4.Service_Territory__c,Window_Days__c=7,Days_in_Window__c=7,Days_Out_Window__c=-5,Days_up_to_Window__c =0);
             
            insert new list<Utility_Business_Rules__c>{setting1,setting2,setting3,setting4};
            
          List<Bill_Cycle_Date__c> Billcycletest = new list<Bill_Cycle_Date__c>();
            
           
                
           Bill_Cycle_Date__c bcd1=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor1.Id,Meter_Read_Date__c=Date.today(),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
           Bill_Cycle_Date__c bcd11=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor1.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(-1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
           Bill_Cycle_Date__c bcd111=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor1.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(+1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
           Bill_Cycle_Date__c bcd121=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor1.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(+2).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd131=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor1.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            
           Bill_Cycle_Date__c bcd2=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor2.Id,Meter_Read_Date__c=Date.today(),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd22=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor2.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(-1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd222=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor2.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(+1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd212=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor2.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(+2).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd221=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor2.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            
            Bill_Cycle_Date__c bcd3=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor3.Id,Meter_Read_Date__c=Date.today(),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd33=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor3.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(-1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd333=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor3.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(+1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd313=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor3.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(+2).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd323=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor3.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            
            Bill_Cycle_Date__c bcd4=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor4.Id,Meter_Read_Date__c=Date.today(),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd44=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor4.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(-1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd444=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor4.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(+1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd414=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor4.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(+2).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            Bill_Cycle_Date__c bcd424=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=testVendor4.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
            
            insert new list<Bill_Cycle_Date__c>{bcd1,bcd2,bcd3,bcd4,bcd11,bcd111,bcd22,bcd222,bcd33,bcd333,bcd44,bcd444,bcd414,bcd424,bcd313,bcd323,bcd212,bcd221,bcd121,bcd131};
                
                
            list<account> newaccounts = new list<account>();
            
            for(integer i=0; i<5 ; i++)
                {
                    newaccounts.add(new Account(Name='Test Account '+i,Billing_Entity__c='Dynegy',RecordtypeID = CustRecCIId,Supplier__c = testOperatingCompany.Id));
                    
                } 
            
                insert newaccounts;
           
            list<Contract> ParentContracts = new list<contract>();
            for(integer i=0; i<5;i++)
                {
                    contract con = new contract();
                    con.Name='Test Contract '+i;
                    con.Service_Territory__c= 'DAYTON';
                    if(i==2)
                     con.Service_Territory__c= 'Ameren-IL';
                    else if(i==3)
                     con.Service_Territory__c= 'ComEd-IL';
                    else if(i==4)
                        con.Service_Territory__c= 'DEOHIO';
                    con.StartDate=Date.today().addmonths(-1);
                    con.Status='Draft';
                    con.AccountId=newaccounts[i].Id;
                    con.contractTerm=12;
                    
                    ParentContracts.add(con);
                }
            
                insert ParentContracts;
            
            
            for (integer i=0; i<5;i++){
                
                ParentContracts[i].status ='Activated';
                ParentContracts[i].Contract_Counter_Signed_Date__c = datetime.now();
                ParentContracts[i].Enrollment_Stage__c='Ready to Enroll';
                
            }
            
            update ParentContracts;
                
           list<Opportunity> opptest = new list<Opportunity>();
            for(integer i=0; i<5;i++){
                Opportunity opp = new Opportunity();
                opp.Name='Test Opty '+i;
                opp.Service_Territory__c='DAYTON';
                if(i==2)
                     opp.Service_Territory__c= 'Ameren-IL';
                    else if(i==3)
                     opp.Service_Territory__c= 'ComEd-IL';
                    else if(i==4)
                        opp.Service_Territory__c= 'DEOHIO';
                opp.AccountId=newaccounts[i].Id;
                opp.Contractid=ParentContracts[i].id;
                opp.RecordTypeId=optyRecAmndId;
                opp.CloseDate = date.today().addDays(7);
                opp.stagename ='New';
                if(i==2)
                     opp.stagename ='Hold';
                opp.Pricing_Type__c ='Renewal Evergreen';
                opptest.add(opp);
            }
             insert opptest;
            
             product2 Fp_pro=new product2();
            Fp_pro.name='FP-ONE';
            Fp_pro.IsActive=true;
            insert Fp_pro;
            
            list<Retail_Quote__c> RQinserttest = new list<Retail_Quote__c>();
            for (integer i=0;i<5;i++)
            {
                
                for (integer j=0;j<3;j++)
                    
                {
                    Retail_Quote__c rq = new Retail_Quote__c();
                    rq.Opportunity__c=opptest[i].id;
                    rq.RecordTypeId=rtExec.id;
                    rq.Start_Term__c = Date.today();
                    rq.Request_Status__c = 'Pricing Complete';
                    rq.Quote_Price_KWH__c=0.00501;
                    rq.Product__c =Fp_pro.id;
                    rq.Term__c=12;
                    rq.ContractType__c='Small Stable Contract - Evergreen';
                    if(j==1)
                        rq.Term__c=24; 
                    if(j==2)
                        rq.Term__c=36;
                    rq.Utility_Settlement_Zone__c = 'DAY_RESID_AGG';
                    if(i==1)rq.Quote_Price_KWH__c=0.01551;
                    if(i==2){
                        rq.Utility_Settlement_Zone__c= 'AMIL.AEM.IL';
                        rq.ContractType__c='Small Stable Contract - Evergreen';}
                    else if(i==3){
                        rq.Utility_Settlement_Zone__c= 'COMED';
                        rq.ContractType__c='Small Stable Contract - MTM Renewal';}
                    else if(i==4){
                        rq.Utility_Settlement_Zone__c= 'DEOK_RESID_AGG';
                        rq.ContractType__c='UCBPOR';
                        rq.Quote_Price_KWH__c=0.01551;
                        }
                    rq.Pricing_Valid_Date_Time__c = system.now();
                    rq.Margin__c=12;
                    rq.Margin_Allocation__c='Lump Sum';
                    rq.Energy_Fixed__c=12;
                    rq.Index_Margin__c=12;
                    rq.Index_Margin_Allocation__c='Lump Sum';
                    rq.Broker_Fee__c=0.00;
                    rq.Broker_Fee_Allocation__c='Lump Sum';
                    rq.Municipality_Fee__c=0.00;
                    rq.Municipality_Fee_Allocation__c='Lump Sum';
                    rq.Marketing_Cost__c=0.00;
                    rq.Marketing_Cost_Allocation__c='Lump Sum';
                    RQinserttest.add(rq);
                    
                }
                
            }
            insert RQinserttest;

                
            Rate_Code__c tstRCRec1 = new Rate_Code__c(Name='TSTRC001',Price__c=0.00501,Service_Territory__c='DAYTON');
            Rate_Code__c tstRCRec6 = new Rate_Code__c(Name='TSTRC001',Price__c=0.01551,Service_Territory__c='DAYTON');
            Rate_Code__c tstRCRec2 = new Rate_Code__c(Name='TSTRC002',Price__c=0.00501,Service_Territory__c='ComEd-IL');
            Rate_Code__c tstRCRec3 = new Rate_Code__c(Name='TSTRC003',Price__c=0.00501,Service_Territory__c='DEOHIO');
            Rate_Code__c tstRCRec4 = new Rate_Code__c(Name='TSTRC004',Price__c=0.00501,Service_Territory__c='FEOHIO');
            Rate_Code__c tstRCRec5 = new Rate_Code__c(Name='TSTRC005',Price__c=0.00501,Service_Territory__c='Ameren-IL');
            Insert new list<Rate_code__c>{tstRCRec1,tstRCRec2,tstRCRec3,tstRCRec4,tstRCRec5,tstRCRec6};
            
                integer m =0;
                list<LDC_account__C> ldctestinsert = new list<LDC_Account__c>();
                for (integer i=0;i<5;i++){
                    
                    for (integer j=0;j<100;j++)
                    {
                        
                        LDC_account__C newldc = new ldc_account__C();
                        
                            newldc.Name='Test LDC Account CCQ002';
                            newldc.Account__c=newaccounts[i].Id;
                            newldc.Service_Territory__c='DAYTON';
                            newldc.LDC_Vendor__c=testVendor1.Id;
                                if(i==2){
                            newldc.Service_Territory__c= 'Ameren-IL';
                            newldc.LDC_Vendor__c=testVendor2.Id;}
                            else if(i==3){
                            newldc.Service_Territory__c= 'ComEd-IL';
                            newldc.LDC_Vendor__c=testVendor3.Id;}
                            else if(i==4){
                            newldc.Service_Territory__c= 'DEOHIO';
                            newldc.LDC_Vendor__c=testVendor4.Id;}
                            newldc.Bill_Cycle__c='7';
                            newldc.LDC_Account_Number__c='TSTCCQ0002'+m;   
                            newldc.Ldc_Account_Status__c='New Account';
                            if(J==3 ||J==5||J==7 ||J==9 )
                            newldc.Ldc_Account_Status__c='ACTIVE';
                            m++;
                            ldctestinsert.add(newldc);
                            
                    }
                    
                }
                 insert ldctestinsert;
            
            List<Opportunity_LDC__c> OppLDCinserttest =  new List<Opportunity_LDC__c>();
             integer k =0;
            for (integer i =0; i<5 ; i++){

                for(Integer j =0 ;j<100;j++){  
                    if(k<199 || k > 299){
                    Opportunity_LDC__c ldcOpp= new Opportunity_LDC__c();
                    ldcOpp.LDC_Account__c = ldctestinsert[k].id;
                    ldcOpp.Opportunity__c = opptest[i].id;
                    
                    OppLDCinserttest.add(ldcOpp);
                      
                    }  
                    k++;
                }
                
                
            }
            insert OppLDCinserttest;
             
            
        }
            

        Static testmethod void EvergreenSchedule_unittest2(){
                 Test.startTest();
                EvergreenSchedule_unittest();
                time t =datetime.now().time();
        system.debug(''+t+' : '+t.minute()+' : '+t.hour());
        String schTime = '0 0 '+t.hour()+' * * ?';
            EvergreenSchedule sch1 = new EvergreenSchedule();
            System.schedule('testevergreenschedule',schTime,sch1);
             sch1.execute(null);  
            //List<AsyncApexJob> pending = New list<AsyncApexJob>([select id from AsyncApexJob where apexClass.Name = 'BatchStartEnrollmentProcess']);
            //integer i = pending.size();
            
            //for (integer j =0 ; j<i-2; j++){
            //    system.abortJob(pending[j].id);}
            Test.stopTest();   
            
           
        }
     Static testmethod void EvergreenSchedule_unittest1()
         {
            Test.startTest();
             EvergreenSchedule_unittest();
             list<Retail_Quote__c> updatequote = new list<Retail_Quote__c>();
             List<Retail_Quote__c> retailids;
             retailids = new List<Retail_Quote__c>([Select id from Retail_Quote__c]);
             for(Retail_Quote__c ID1 :retailids )
                {
                    Retail_Quote__c Rq1 = new Retail_Quote__c();
                    Rq1.id = ID1.id;
                    Rq1.Pricing_Valid_Date_Time__c = system.now().adddays(4);
                    updatequote.add(Rq1);
                }  
            Update updatequote;
           time t =datetime.now().time();
            system.debug(''+t+' : '+t.minute()+' : '+t.hour());
            String schTime = '0 0 '+t.hour()+' * * ?';
            EvergreenSchedule sch1 = new EvergreenSchedule();
            System.schedule('testevergreenschedule',schTime,sch1);
             sch1.execute(null);  
            Test.stopTest();
              
        }
    
}