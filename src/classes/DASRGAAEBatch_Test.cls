/**
 * This class is designed to provide code coverage for the 
 * DASRGAAEBatch class.
 *
 * @
 * @version 1.0
 **/

@isTest
public class DASRGAAEBatch_Test{
    
    public static testmethod void DASRGAAEBatch_Test(){
        
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        //we need to create a test operating company
        Supplier__c testOperatingCompany = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',
                                           Organization_Identifier_Code__c = 'TESTSUP',Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST', Active__c = true);
        insert testOperatingCompany;
        
        LDC_Vendor__c testVendor = new LDC_Vendor__c(Name='Test Vendor',DUNS__c = 'U698DWJ9',Legacy_ID__c = 'TVNDR',
                                   Service_Territory__c = 'AEPOHIO',Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        insert testVendor;
        
        Account testAcct = new Account(Name='Test CnI',Supplier__c = testOperatingCompany.Id,BillingStreet = '2114 Bates Brothers Road',
                           BillingCity = 'Westerville',BillingState = 'OH',BillingPostalCode = '43081',Billing_Entity__c='Dynegy');
        insert testAcct;
        
        LDC_Account__c ldcTestAccount1 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4048 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());
        insert ldcTestAccount1;
        LDC_Account__c ldcTestAccount2 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4050 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());
        insert ldcTestAccount2;
        LDC_Account__c ldcTestAccount3 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4050 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today(),LDC_Account_Status__c='PENDING_FINAL');
        insert ldcTestAccount3;
        
        //create test Contract
        Contract testContract1 = new Contract(AccountId=testAcct.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = 'DK98',Service_Territory__c='AEPOHIO');        //Contract_Type__c = 'COST_BASED',
        insert testContract1;
        Contract testContract2 = new Contract(AccountId=testAcct.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = '0611R3732',Service_Territory__c='AEPOHIO');        //,Contract_Type__c = 'COST_BASED'
        insert testContract2;
        
        //activate the Contract
        testContract1.Status = 'Activated';
        testContract1.Contract_Counter_Signed_Date__c = datetime.now();
        update testContract1;
        testContract2.Status = 'Activated';
        testContract2.Contract_Counter_Signed_Date__c = datetime.now();
        update testContract2;
        //create Contract LDC Record
        
        Contract_LDC__c testContractLDC1 = new Contract_LDC__c(LDC_Account__c=ldcTestAccount1.Id,Contract__c = testContract1.Id,Active__c=true,IsSynchronized__c=true);
        insert testContractLDC1;
        Contract_LDC__c testContractLDC2 = new Contract_LDC__c(LDC_Account__c=ldcTestAccount2.Id,Contract__c = testContract2.Id);
        insert testContractLDC2;
        //create DASR Record for enrollment
        
        DASR_Request__c testRequest = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount2.Id,DASR_Type__c = 'GAAE',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',most_recent_gaad__c =true, Change_Effective_Date__c = Date.today(),
                                      Accepted__c=true,Dynegy_Initiated__c=true,Billing_Entity__c='Dynegy');
        insert testRequest;
        
        DASR_Request__c testRequest2 = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount3.Id,DASR_Type__c = 'GAAE',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',most_recent_gaad__c = true,Change_Effective_Date__c = Date.today(),
                                      Accepted__c=true,Dynegy_Initiated__c=true,Billing_Entity__c='Dynegy');
        insert testRequest2;
        
        ldcTestAccount3.ldc_end_date__c=date.today();
        update ldcTestAccount3;
        
        system.schedule('Test DASR GAAE', '0 0 17 * * ?', new DASRGAAEBatchScheduler());

        DASRGAAEBatch dASRGAAEBatch = new DASRGAAEBatch();
        testContractLDC2.active__c = false;
        update testContractLDC2;
        
        dASRGAAEBatch = new DASRGAAEBatch();
        Database.executeBatch(dASRGAAEBatch, 20);
    }
    
    public static testmethod void DASRGAAEBatch_Activate(){
        
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        //we need to create a test operating company
        Supplier__c testOperatingCompany = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',
                                           Organization_Identifier_Code__c = 'TESTSUP',Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST', Active__c = true);
        insert testOperatingCompany;
        
        LDC_Vendor__c testVendor = new LDC_Vendor__c(Name='Test Vendor',DUNS__c = 'U698DWJ9',Legacy_ID__c = 'TVNDR',
                                   Service_Territory__c = 'AEPOHIO',Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        insert testVendor;
        
        Account testAcct = new Account(Name='Test CnI',Supplier__c = testOperatingCompany.Id,BillingStreet = '2114 Bates Brothers Road',
                           BillingCity = 'Westerville',BillingState = 'OH',BillingPostalCode = '43081',Billing_Entity__c='Dynegy');
        insert testAcct;
        
        LDC_Account__c ldcTestAccount1 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4048 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());
        insert ldcTestAccount1;
        LDC_Account__c ldcTestAccount2 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4050 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());
        insert ldcTestAccount2;
        LDC_Account__c ldcTestAccount3 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4050 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today(),LDC_Account_Status__c='PENDING_FINAL');
        insert ldcTestAccount3;
        
        //create test Contract
        Contract testContract1 = new Contract(AccountId=testAcct.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = 'DK98',Service_Territory__c='AEPOHIO');        //Contract_Type__c = 'COST_BASED',
        insert testContract1;
        Contract testContract2 = new Contract(AccountId=testAcct.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = '0611R3732',Service_Territory__c='AEPOHIO');        //,Contract_Type__c = 'COST_BASED'
        insert testContract2;
        
        //activate the Contract
        testContract1.Status = 'Activated';
        testContract1.Contract_Counter_Signed_Date__c = datetime.now();
        update testContract1;
        testContract2.Status = 'Activated';
        testContract2.Contract_Counter_Signed_Date__c = datetime.now();
        update testContract2;
        //create Contract LDC Record
        
        Contract_LDC__c testContractLDC1 = new Contract_LDC__c(LDC_Account__c=ldcTestAccount1.Id,Contract__c = testContract1.Id,Active__c=true,IsSynchronized__c=true);
        insert testContractLDC1;
        Contract_LDC__c testContractLDC2 = new Contract_LDC__c(LDC_Account__c=ldcTestAccount2.Id,Contract__c = testContract2.Id);
        insert testContractLDC2;
        //create DASR Record for enrollment
        
        DASR_Request__c testRequest = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount2.Id,DASR_Type__c = 'GAAE',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',most_recent_gaad__c =false, Change_Effective_Date__c = Date.today(),
                                      Accepted__c=true,Dynegy_Initiated__c=true,Billing_Entity__c='Dynegy');
        
        DASR_Request__c testRequest2 = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount3.Id,DASR_Type__c = 'GAAE',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',most_recent_gaad__c = false,Change_Effective_Date__c = Date.today(),
                                      Accepted__c=true,Dynegy_Initiated__c=true,Billing_Entity__c='Dynegy');
        
        DASR_Request__c testRequest3 = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount3.Id,DASR_Type__c = 'GAAC',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',most_recent_gaad__c = false,Change_Effective_Date__c = Date.today(),
                                      Accepted__c=false,Dynegy_Initiated__c=false,Billing_Entity__c='Dynegy');
        insert new list<dasr_request__c>{testRequest,testRequest2,testRequest3};
        
        Account_Exception__c ae = new Account_Exception__c(ldc_account__c  = ldcTestAccount3.Id,dasr_request__c = testRequest3.Id,Reason_Code__c='DTM150',Most_Recent__c = true);
        insert ae;
        
        system.schedule('Test FCLDC', '0 0 17 * * ?', new FlagContractLDC());

        testContractLDC2.active__c = false;
        update testContractLDC2;
        
        FlagContractLDC fcldc = new FlagContractLDC();
        Database.executeBatch(fcldc,20);        
    }
    
}