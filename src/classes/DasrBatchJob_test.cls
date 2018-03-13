/**
 * This class is designed to provide code coverage for the 
 * AccountTrigger and AccountTriggerHandlerBatch classes.
 *
 * @CreatedBy Prasad Paladugu
 * @version 1.0
 **/

@isTest
public class DasrBatchJob_test{
    
    public static testmethod void DasrBatchJob_Test1(){
        
        ID CIid = Schema.SObjectType.Account.RecordTypeInfosByName.get('C&I Customer').RecordTypeId;
        ID MAId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Muni Agg Customer').RecordTypeId;
        ID MAIndvId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Muni Agg Individual Customer').RecordTypeId;
        //we need to create a test operating company
        Supplier__c testOperatingCompany = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',
                                           Organization_Identifier_Code__c = 'TESTSUP',Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST', Active__c = true);
        insert testOperatingCompany;
        
        LDC_Vendor__c testVendor = new LDC_Vendor__c(Name='Test Vendor',DUNS__c = 'U698DWJ9',Legacy_ID__c = 'TVNDR',
                                   Service_Territory__c = 'AEPOHIO',Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        insert testVendor;
        
        Account testAcct = new Account(Name='Test CnI',Supplier__c = testOperatingCompany.Id,BillingStreet = '2114 Bates Brothers Road',
                           BillingCity = 'Westerville',BillingState = 'OH',BillingPostalCode = '43081',Billing_Entity__c='Dynegy',RecordtypeId=CIid);
        
        Account testAcct1 = new Account(Name='Test MA',Supplier__c = testOperatingCompany.Id,BillingStreet = '2982 Shawns Street',
                           BillingCity = 'Westerville',BillingState = 'OH',BillingPostalCode = '43081',Billing_Entity__c='Dynegy',RecordtypeId=MAId);
        
        Account testAcct2 = new Account(LastName='Test MA Indv',Supplier__c = testOperatingCompany.Id,BillingStreet = '2995 Shawns Street',
                           BillingCity = 'Westerville',BillingState = 'OH',BillingPostalCode = '43081',Billing_Entity__c='Dynegy',RecordtypeId=MAIndvId);
                           
        insert new list<account>{testAcct,testAcct1,testAcct2};
        
        testAcct2.business_account__c = testAcct1.id;
        update testAcct2;
        
        LDC_Account__c ldcTestAccount1 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4048 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());

        LDC_Account__c ldcTestAccount2 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4050 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());

        LDC_Account__c ldcTestAccount3 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,LDC_Account_Status__c='Final',
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4050 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());
        
        LDC_Account__c ldcTestAccount4 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct2.Id,LDC_Account_Status__c='Final',
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4050 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());
        
        insert new list<ldc_account__c>{ldcTestAccount1,ldcTestAccount2,ldcTestAccount3,ldcTestAccount4};
        
        //create test Contract
        Contract testContract1 = new Contract(AccountId=testAcct.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = 'DK98',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO');

        Contract testContract2 = new Contract(AccountId=testAcct.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = '0611R3732',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO');
        
        Contract testContract3 = new Contract(AccountId=testAcct.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = '0611R3732',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO');
        
        insert new list<contract>{testContract1,testContract2,testContract3};
        
        //activate the Contract
        testContract1.Status = 'Activated';
        testContract1.Contract_Counter_Signed_Date__c = datetime.now();
        testContract2.Status = 'Activated';
        testContract2.Contract_Counter_Signed_Date__c = datetime.now();
        testContract3.Status = 'Activated';
        testContract3.Contract_Counter_Signed_Date__c = datetime.now();
        update new list<contract>{testContract1,testContract2,testContract3};
        //create Contract LDC Record
        
        Contract_LDC__c testContractLDC1 = new Contract_LDC__c(LDC_Account__c=ldcTestAccount1.Id,Contract__c = testContract1.Id,Active__c=true,IsSynchronized__c=true);
        Contract_LDC__c testContractLDC2 = new Contract_LDC__c(LDC_Account__c=ldcTestAccount2.Id,Contract__c = testContract2.Id);
        Contract_LDC__c testContractLDC3 = new Contract_LDC__c(LDC_Account__c=ldcTestAccount4.Id,Contract__c = testContract3.Id);
        insert new list<contract_ldc__c>{testContractLDC1,testContractLDC2,testContractLDC3};
        //create DASR Record for enrollment
        
        DASR_Request__c testRequest = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount2.Id,DASR_Type__c = 'GAAC',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',Change_Effective_Date__c = Date.today(),
                                      Accepted__c=true,Dynegy_Initiated__c=true,DASR_Activated__c = false,Billing_Entity__c='Dynegy',Most_recent_gaad__c = true);
        
        DASR_Request__c testRequest1 = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount2.Id,DASR_Type__c = 'GAAC',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',Change_Effective_Date__c = date.valueof('2016-06-26'),
                                      Accepted__c=true,Dynegy_Initiated__c=true,DASR_Activated__c = false,Billing_Entity__c='Dynegy',Most_recent_gaad__c = true);
        
        DASR_Request__c testRequest3 = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount3.Id,DASR_Type__c = 'GAAC',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',Change_Effective_Date__c = date.valueof('2016-06-26'),
                                      Accepted__c=true,Dynegy_Initiated__c=true,DASR_Activated__c = false,Billing_Entity__c='Dynegy',Most_recent_gaad__c = true);
        
        DASR_Request__c testRequest4 = new DASR_Request__c(Contract__c = testContract3.Id,LDC_Account__c = ldcTestAccount4.Id,DASR_Type__c = 'GAAC',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',Change_Effective_Date__c = Date.today(),
                                      Accepted__c=true,Dynegy_Initiated__c=true,DASR_Activated__c = false,Billing_Entity__c='Dynegy',Most_recent_gaad__c = true);
        
        insert new list<dasr_request__c>{testRequest,testRequest1,testRequest3,testRequest4};
        
       /* testRequest.Accepted__c = true;
        testRequest.Integration_Status__c = 'Complete';
        update testRequest;*/
        
        Date dt = date.today();
        time t =datetime.now().time();
        String schTime = '0 0 '+t.hour()+' * * ?';
        DasrBatchJob dasrjobsch = new DasrBatchJob();
        system.schedule('Test DASR', schTime, dasrjobsch);
        Database.executeBatch(dasrjobsch);
        //DasrBatchJob dasrjobcons = new DasrBatchJob();
        //testContractLDC2.active__c = false;
        //update testContractLDC2;
        
        DASR_Request__c testRequest2 = new DASR_Request__c(Contract__c = testContract2.Id,LDC_Account__c = ldcTestAccount2.Id,DASR_Type__c = 'GAAC',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',Change_Effective_Date__c = Date.today(),
                                      Accepted__c=true,Dynegy_Initiated__c=true,DASR_Activated__c = false,Billing_Entity__c='Dynegy');
        insert testRequest2;
        string query = ConstantUtility.getObjectFieldsQuery('DASR_Request__c') + ' From DASR_Request__c  where Dynegy_Initiated__c = true AND Accepted__c = true AND Integration_Status__c = \'Complete\'';
        Query += 'AND createdby.name != \'Integration User\' AND DASR_Type__c = \'GAAC\' AND DASR_Activated__c = false AND Change_Effective_Date__c = : DatetoProcess';
        DasrBatchJob dasrjob = new DasrBatchJob(dt,1,new set<id>());
        Database.executeBatch(dasrjob);
    }
    
    public static testmethod void DasrBatchJob_Test2(){
        
        ID CIid = Schema.SObjectType.Account.RecordTypeInfosByName.get('C&I Customer').RecordTypeId;
        ID MAId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Muni Agg Customer').RecordTypeId;
        ID MAIndvId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Muni Agg Individual Customer').RecordTypeId;
        //we need to create a test operating company
        Supplier__c testOperatingCompany = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',
                                           Organization_Identifier_Code__c = 'TESTSUP',Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST', Active__c = true);
        insert testOperatingCompany;
        
        LDC_Vendor__c testVendor = new LDC_Vendor__c(Name='Test Vendor',DUNS__c ='U698DWJ9',Legacy_ID__c = 'TVNDR',
                                   Service_Territory__c = 'AEPOHIO',Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        insert testVendor;
        
        Account testAcct = new Account(Name='Test CnI',Supplier__c = testOperatingCompany.Id,BillingStreet = '2114 Bates Brothers Road',
                           BillingCity = 'Westerville',BillingState = 'OH',BillingPostalCode = '43081',Billing_Entity__c='Dynegy',RecordtypeId=CIid);
        
        Account testAcct1 = new Account(Name='Test MA',Supplier__c = testOperatingCompany.Id,BillingStreet = '2982 Shawns Street',
                           BillingCity = 'Westerville',BillingState = 'OH',BillingPostalCode = '43081',Billing_Entity__c='Dynegy',RecordtypeId=MAId);
        
        Account testAcct2 = new Account(LastName='Test MA Indv',Supplier__c = testOperatingCompany.Id,BillingStreet = '2995 Shawns Street',
                           BillingCity = 'Westerville',BillingState = 'OH',BillingPostalCode = '43081',Billing_Entity__c='Dynegy',RecordtypeId=MAIndvId);
                           
        insert new list<account>{testAcct,testAcct1,testAcct2};
        
        testAcct2.business_account__c = testAcct1.id;
        update testAcct2;
        
        
        LDC_Account__c ldcTestAccount1 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct2.Id,LDC_Account_Status__c='Active',
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4050 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());
        
        LDC_Account__c ldcTestAccount2 = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct2.Id,LDC_Account_Status__c='Active',
                                        LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),Service_Street_1__c = '4050 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today(),Service_territory__c='ComEd-IL');
        
        insert new list<ldc_account__c>{ldcTestAccount1,ldcTestAccount2};
        
        //create test Contract
        Contract testContract1 = new Contract(AccountId=testAcct.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = '0611R3732',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO');
        
        insert new list<contract>{testContract1};
        
        //activate the Contract
        testContract1.Status = 'Activated';
        testContract1.Contract_Counter_Signed_Date__c = datetime.now();
        update new list<contract>{testContract1};
        //create Contract LDC Record
        
        Contract_LDC__c testContractLDC1 = new Contract_LDC__c(LDC_Account__c=ldcTestAccount1.Id,Contract__c = testContract1.Id,Active__c=true,IsSynchronized__c=true);
        insert new list<contract_ldc__c>{testContractLDC1};
        //create DASR Record for enrollment
        
        DASR_Request__c testRequest = new DASR_Request__c(Contract__c = testContract1.Id,LDC_Account__c = ldcTestAccount1.Id,DASR_Type__c = 'GAAC',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Complete',Change_Effective_Date__c = Date.today(),
                                      Accepted__c=true,Dynegy_Initiated__c=true,DASR_Activated__c = false,Billing_Entity__c='Dynegy',Most_recent_gaad__c = true);
        
        DASR_Request__c testRequest1 = new DASR_Request__c(Contract__c = testContract1.Id,LDC_Account__c = ldcTestAccount2.Id,DASR_Type__c = 'GAAC',
                                      DASR_Submit_Date__c = Datetime.now(),Integration_Status__c = 'Manually Fulfilled',Change_Effective_Date__c = Date.today(),
                                      Accepted__c=true,Dynegy_Initiated__c=true,DASR_Activated__c = false,Billing_Entity__c='Dynegy',Most_recent_gaad__c = true);
        
        insert new list<dasr_request__c>{testRequest,testRequest1};
        
        Date dt = date.today();
        time t =datetime.now().time();
        String schTime = '0 0 '+t.hour()+' * * ?';
        DasrBatchJob dasrjobsch = new DasrBatchJob();
        system.schedule('Test DASR', schTime, dasrjobsch);
        Database.executeBatch(dasrjobsch);
        
        DASRBatchJobAuto DJobAuto = new DASRBatchJobAuto();
        //Database.executeBatch(DJobAuto);
    }
    
}