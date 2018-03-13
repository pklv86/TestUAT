/*****************************************Dynegy*************************************************************************************
 * Name: contracttrigger_test                                                                                                     *                                                                                                               *
 * Test Class:contracttrigger_test                                                                                                  *
 * Description:  This test class is used to provide test coverage for Contracttrigger and contracttriggerhandler class                                 *                                            
 * Change History:                                                                                                                  *
 *==================================================================================================================================*
 * Version     Author                       Date             Description                                                            *
 * 1.0         Mounika Duggirala            02/26/2017      Initial Version created                                                 *                            
 ************************************************************************************************************************************/
@isTest
public class contracttrigger_test
{
    static testmethod void contracttriggertestmethod()
    {
        
        Account a = new account();
        a.name = 'Test broker';
        a.Billing_Entity__c = 'Dynegy';
        insert a;
        
        list<id> retailid = new list<id>();
        list<string> prod_lst = new list<string>{'FP-ONE','FP-MULT','FP-ONE-PT-C','FP-MULT-PT-C','FP-MULT-PT-L','FP-MULT-PT-T','FP-MULT-PT-CL','FP-MULT-PT-CLT','FP-MULT-PT-LT','FP-MULT-PT-CT','FP-ONOFF','FP-ONOFF-PT-C','FP-ONOFF-PT-L','FP-ONOFF-PT-T','FP-ONOFF-PT-CL','FP-ONOFF-PT-CLT','FP-ONOFF-PT-LT','FP-ONOFF-PT-CT'};
        list<contract> cont = new list<contract>();
        list<contract> ct = new list<contract>();
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id accid=testutility.createaccount();
        
        for(Integer i=1;i<19;i++){
            id retailquote = testutility.createnecessaryrecords();
            retailid.add(retailquote);
        }
        
        for(Integer i=1;i<19;i++){
            cont.add(new contract(StartDate=system.today(),
                                        ContractTerm=5,
                                        status='draft',
                                        accountid=accid,
                                        Referral_Broker__c = accid,
                                        product_name__c=prod_lst[i-1],
                                        Retail_Quote__c=retailid[i-1],
                                        Service_Territory__c ='DAYTON',
                                        Bill_Method__c= 'Rate Ready',
                                        ISO_NITS__c = 123,
                                        Tax__c = 123,
                                        Vol_Rec__c = 123,
                                        Broker_Fee__c=123,
                                        Contract_Broker_Fee__c = 123,
                                        Contract_Municipality_Fee__c= 123,
                                        Municipality_Fee__c=123,
                                        Marketing_Cost__c=123,
                                        Default_Risk__c=123,
                                        Holding_Cost__c=123));      
        }        
        insert cont;
        
        for(Integer i=1;i<19;i++){
            cont[i-1].status='Activated';
            ct.add(cont[i-1]);
        }   
        update ct;  
    }
    
    public static testmethod void contractTiggertestmethod3(){
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        Schema.RecordTypeInfo massMarketRecType = acctRecTypeMap.get('Mass Market Offer');
        Schema.RecordTypeInfo massMarketIndRecType = acctRecTypeMap.get('Mass Market Individual Customer');
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
        //create a test vendor
        LDC_Vendor__c testVendor = new LDC_Vendor__c(
                                                        Name='Test Vendor',
                                                        DUNS__c = DynegyCommonUtils.generateRandomString(8),
                                                        Legacy_ID__c = 'TVNDR',
                                                        Service_Territory__c = 'AEPOHIO',
                                                        Utility_Code__c = 'TST',
                                                        Vendor_Type__c = 'LDC',
                                                        Service_State__c = 'OH'
                                                    );
        insert testVendor;
        List<Account> testAcctList = new List<Account>();
        testAcctList.add(new Account(
                                        Name='Test MM Offer',
                                        Supplier__c = testOperatingCompany.Id,
                                        RecordTypeId = massMarketRecType.getRecordTypeId(),
                                        LodeStar_Integration_Status__c = 'Not Synchronized',
                                        Billing_Entity__c='Dynegy'
                                        ));
        testAcctList.add(new Account(
                                        RecordTypeId = massMarketIndRecType.getRecordTypeId(),
                                        FirstName = 'TestMass',
                                        LastName = 'MarketIndividualAcct',
                                        PersonMailingStreet = '4171 Still Street',
                                        PersonMailingPostalCode = '45819',
                                        PersonMailingCity = 'Buckland',
                                        PersonMailingState = 'OH',
                                        PersonEmail='test@test.com',
                                        PersonHomePhone='419-657-2441',
                                        LodeStar_Integration_Status__c = 'Not Synchronized',
                                        Billing_Entity__c='Dynegy'  //Validation__c = 'Validated'
                                    ));
        insert testAcctList;
        testAcctList[1].Business_Account__c = testAcctList[0].Id;
        LDC_Account__c ldcTestAccount = new LDC_Account__c(
                                                Name = 'Test LDC MM1',
                                                Account__c=testAcctList[1].Id,
                                                LDC_Account_Number__c = 'LDCMM000001',
                                                Service_Street_1__c = '4048 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_Status__c = 'Active',
                                                Crm_Id__c ='HH321J45JOL321',
                                                Enrolled__c = true
                                            );
        insert ldcTestAccount;
        Contract testContract = new Contract(
                                                AccountId=testAcctList[0].Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'Bill Ready',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'COST_BASED',
                                                Service_Territory__c='AEPOHIO',
                                                Validation__c = 'In Progress'
                                            );
        insert testContract;
        Contract_LDC__c testContractLDC = new Contract_LDC__c(
                                                                LDC_Account__c=ldcTestAccount.Id,
                                                                Contract__c = testContract.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                isSynchronized__c = true
                                                              );
        insert testContractLDC;
        testContract.status = 'Activated';
        testContract.validation__c = 'Modified';
        update testContract;
    }
}    
    
    /*static testmethod void contracttriggertestmethod()
    {
        
        Account a = new account();
        a.name = 'Test broker';
        a.Billing_Entity__c = 'Dynegy';
        insert a;
        
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
    
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONE';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        cont.Bill_Method__c='Rate Ready';
        cont.Referral_Broker__c = a.id;
        cont.Contract_Broker_Fee__c=123;
        cont.Contract_Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Vol_Rec__c=123;
        cont.ISO_NITS__c=123;
        cont.Tax__c=123;
        cont.Holding_Cost__c=123;
        
        insert cont;
        cont.status='Activated';
        update cont;
        
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
        CTH.createcontracttermsforFP_ONE(cont);
        CTH.createcontracttermsforFP_ONE_PT_C(cont);
        CTH.createcontracttermsforFP_MULT(cont);
        CTH.createcontracttermsforFP_MULT_PT_C(cont);
        CTH.createcontracttermsforFP_MULT_PT_L(cont);
        CTH.createcontracttermsforFP_MULT_PT_T(cont);
        CTH.createcontracttermsforFP_MULT_PT_CL(cont);
        CTH.createcontracttermsforFP_MULT_PT_CLT(cont);
        CTH.createcontracttermsforFP_MULT_PT_LT(cont);
        CTH.createcontracttermsforFP_MULT_PT_CT(cont);
        CTH.createcontracttermsforFP_ONOFF(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_C(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_L(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_T(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_CL(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_CLT(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_LT(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_CT(cont);
       
        contract cont1=new contract();
        cont1.StartDate=system.today();
        cont1.ContractTerm=5;
        cont1.status='draft';
        cont1.accountid=accid;
        cont1.product_name__c='FP_ONE_PT_C';
        cont1.Retail_Quote__c=retailid;
        cont1.Service_Territory__c ='Comed-IL';
        cont1.Bill_Method__c='Rate Ready';
        cont1.Referral_Broker__c = a.id;
        cont1.Contract_Broker_Fee__c=123;
        cont1.Contract_Municipality_Fee__c=123;
        cont1.Marketing_Cost__c=123;
        cont1.Default_Risk__c=123;
        cont1.Vol_Rec__c=123;
        cont1.ISO_NITS__c=123;
        cont1.Tax__c=123;
        cont1.Holding_Cost__c=123;
         
        insert cont1;
        cont1.status='Activated';
        update cont1;
        
        Contracttriggerhandler  CTH1=new Contracttriggerhandler();  
        CTH1.createcontracttermsforFP_ONE_PT_C(cont1);
        
        contract contOH=new contract();
        contOH.StartDate=system.today();
        contOH.ContractTerm=5;
        contOH.status='draft';
        contOH.accountid=accid;
        contOH.product_name__c='FP_MULT';
        contOH.Retail_Quote__c=retailid;
        contOH.Service_Territory__c ='DAYTON';
        contOH.Bill_Method__c='Bill Ready';
        contOH.Referral_Broker__c = a.id;
        contOH.Contract_Broker_Fee__c=123;
        contOH.Contract_Municipality_Fee__c=123;
        contOH.Marketing_Cost__c=123;
        contOH.Default_Risk__c=123;
        contOH.Vol_Rec__c=123;
        contOH.ISO_NITS__c=123;
       
           
        contOH.Tax__c=123;
        contOH.Holding_Cost__c=123;
        contOH.Broker_Fee__c = -100;
        contOH.Municipality_Fee__c = -100;
        contOH.Contract_Marketing_Cost__c = 100;
        insert contOH;
        contOH.status='Activated';
        update contOH;
        
        Contracttriggerhandler  CTHOH=new Contracttriggerhandler();  
        CTHOH.createcontracttermsforFP_ONE(contOH);
        CTHOH.createcontracttermsforFP_ONE_PT_C(contOH);
        CTHOH.createcontracttermsforFP_MULT(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_C(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_L(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_T(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_CL(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_CLT(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_LT(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_CT(contOH);
        CTHOH.createcontracttermsforFP_ONOFF(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_C(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_L(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_T(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_CL(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_CLT(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_LT(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_CT(contOH);
        
        contract contOH1=new contract();
        contOH1.StartDate=system.today();
        contOH1.ContractTerm=5;
        contOH1.status='draft';
        contOH1.accountid=accid;
        contOH1.product_name__c='FP_MULT';
        contOH1.Retail_Quote__c=retailid;
        contOH1.Service_Territory__c ='DAYTON';
        contOH1.Bill_Method__c='Bill Ready';
        contOH1.Referral_Broker__c = a.id;
        contOH1.Contract_Broker_Fee__c=123;
        contOH1.Contract_Municipality_Fee__c=123;
        contOH1.Marketing_Cost__c=123;
        contOH1.Vol_Rec__c=123;
        contOH1.ISO_NITS__c=123;
        contOH1.Tax__c=123;
        contOH1.Holding_Cost__c=123;
        contOH1.Broker_Fee__c = -100;
        contOH1.Municipality_Fee__c = -100;
        insert contOH1;
        contOH1.status='Activated';
        update contOH1;
         
    }*/

    
 /*   public static testmethod void contracttriggertestmethod2()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONE-PT-C';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod3()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod4()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-C';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();   
    }
    public static testmethod void contracttriggertestmethod5()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();      
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-L';
        cont.Service_Territory__c ='Comed-IL';
        cont.Retail_Quote__c=retailid;
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod6()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();      
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-T';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod7()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();      
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-CL';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod8()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();       
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-CLT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod9()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();       
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-LT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod10()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-CT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod11()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod12()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();       
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-C';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod13()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-L';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod14()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-T';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod15()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-CL';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
     public static testmethod void contracttriggertestmethod22()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-CLT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod16()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-LT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod17()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();       
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-CT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod18()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();      
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='PCTG-PT-L';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();        
    }
    public static testmethod void contracttriggertestmethod19()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='PCTG-PT-LT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler(); 
    }
    public static testmethod void contracttriggertestmethod20()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='PCTG-PT-CL';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler(); 
    }
    public static testmethod void contracttriggertestmethod21()
    {
         contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();        
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.Service_Territory__c='AEPOHIO';
        cont.accountid=accid;
        cont.product_name__c='PCTG-PT-CLT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        Cont.Retail_Quote__r.Contract_Energy_Off_PK__c= '123';
        Cont.Retail_Quote__r.Contract_Energy_On_PK__c= '456';
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler(); 
    }*/