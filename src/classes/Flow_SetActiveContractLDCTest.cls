/**
 * The purpose of this class is to provide code coverage for the Flow_SetActiveContractLDCTest
 * class
 * 
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 **/
@isTest
public class Flow_SetActiveContractLDCTest {
    /**
     * This method creates test data for this class to execute
     * test methods on.
     **/
    private static void SetupTestData(){
        //first we need to create a test Account
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        //we need to create a test operating company
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
        LDC_Vendor__c testVendor = new LDC_Vendor__c(
                                                        Name='Test Vendor',
                                                        DUNS__c = 'U698DWJ9',
                                                        Legacy_ID__c = 'TVNDR',
                                                        Service_Territory__c = 'AEPOHIO',
                                                        Utility_Code__c = 'TST',
                                                        Vendor_Type__c = 'LDC',
                                                        Service_State__c = 'OH'
                                                    );
        insert testVendor;
        Account testAcct = new Account(
                                        Name='Test CnI',
                                        Supplier__c = testOperatingCompany.Id,
                                        BillingStreet = '2114 Bates Brothers Road',
                                        BillingCity = 'Westerville',
                                        BillingState = 'OH',
                                        BillingPostalCode = '43081',
                                        Billing_Entity__c='Dynegy'
                                        );
        insert testAcct;
        
        
        //create test Contract
        Contract testContract = new Contract(
                                                AccountId=testAcct.Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                  //            Contract_Type__c = 'COST_BASED',
                                                Supplier__C = testOperatingCompany.Id,
                                                Service_Territory__c='AEPOHIO'
                                            );
        insert testContract;
        //activate the Contract
        testContract.Status = 'Activated';
        testContract.Contract_Counter_Signed_Date__c = datetime.now();
        update testContract;
        
        Contract testContract1 = new Contract(
                                                AccountId=testAcct.Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 24,
                                                Bill_Method__c = 'RateReady',
                                                Rate_Code__c = 'TEST123',
                                  //            Contract_Type__c = 'COST_BASED',
                                                Supplier__C = testOperatingCompany.Id,
                                                Service_Territory__c='AEPOHIO'
                                            );
        insert testContract1;
        //activate the Contract
        testContract1.Status = 'Activated';
        testContract1.Contract_Counter_Signed_Date__c = datetime.now();
        update testContract1;
        
        billing_group__c bg = new billing_group__c(account__c =testacct.id,contract__c = testcontract.id,Group_Address_Line1__c='Add1');
        insert bg;
        
        LDC_Account__c ldcTestAccount = new LDC_Account__c(
                                                            Name = DynegyCommonUtils.generateRandomString(10),
                                                            Account__c=testAcct.Id,
                                                            LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                            Service_Street_1__c = '4048 Vineyard Drive',
                                                            Service_City__c = 'Solon',
                                                            Service_State__c = 'OH',
                                                            Service_Postal_Code__c = '44139',
                                                            billing_group__c = bg.id
                                                            );
        insert ldcTestAccount;
        
        Billing_Group_Ldc__c bgldc = new Billing_Group_Ldc__c(Billing_Group__c = bg.id,ldc_account__c = ldcTestAccount.id,Billing_Start_Date__c=system.now().addmonths(-2),
                                                                Billing_Stop_Date__c=system.now().addyears(2),Synchronized__c=true);
        insert bgldc;
        
        //create Contract LDC Record
        Contract_LDC__c testContractLDC = new Contract_LDC__c(
                                                                LDC_Account__c=ldcTestAccount.Id,
                                                                Contract__c = testContract.Id,
                                                                issynchronized__c = true
                                                              );
        insert testContractLDC;
        
        Contract_LDC__c testContractLDC1 = new Contract_LDC__c(
                                                                LDC_Account__c=ldcTestAccount.Id,
                                                                Contract__c = testContract1.Id,
                                                                issynchronized__c = true,active__c= false,TERM_Start_Date__c=null
                                                              );
        insert testContractLDC1;
        //create DASR Record for enrollment
        DASR_Request__c testRequest = new DASR_Request__c(
                                                            Contract__c = testContract.Id,
                                                            LDC_Account__c = ldcTestAccount.Id,
                                                            DASR_Type__c = 'GAAE',
                                                            DASR_Submit_Date__c = Datetime.now(),
                                                            Integration_Status__c = 'Pending',
                                                            Change_Effective_Date__c = Date.today(),
                                                            Billing_Entity__c='Dynegy'
                                                        );
        insert testRequest;
        
        DASR_Request__c testRequest1 = new DASR_Request__c(
                                                            Contract__c = testContract1.Id,
                                                            LDC_Account__c = ldcTestAccount.Id,
                                                            DASR_Type__c = 'GAAE',
                                                            DASR_Submit_Date__c = Datetime.now(),
                                                            Integration_Status__c = 'Pending',
                                                            Change_Effective_Date__c = Date.today(),
                                                            Billing_Entity__c='Dynegy'
                                                        );
        insert testRequest1;
    }
    
    /**
     * Testing the Main mathod in the class - setActiveContractFromDASR
     **/
    @isTest
    public static void setActiveContractFromDASR(){
        SetupTestData();
        list<DASR_Request__c> testRequest = [SELECT Id FROM DASR_Request__c];
        
        List<Id> idList = new List<Id>();
        idList.add(testRequest[0].Id);
        idList.add(testRequest[1].Id);
        
        Test.startTest();
        
        Flow_SetActiveContractLDC.setActiveContractFromDASR(idList);
        
        Test.stopTest();
    }
}