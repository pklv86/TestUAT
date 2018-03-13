/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class taxValidate_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        //first we need to create a test Account
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        Schema.RecordTypeInfo massMarketRecType = acctRecTypeMap.get('Mass Market Offer');
        Schema.RecordTypeInfo massMarketIndRecType = acctRecTypeMap.get('Mass Market Individual Customer');
        //PA Changes
        Schema.DescribeSObjectResult AS1 = Account_Supplement__c.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> ASRecTypeMap = AS1.getRecordTypeInfosByName();
        Schema.RecordTypeInfo GRTRecType = ASRecTypeMap.get('GRT');
        Schema.RecordTypeInfo TaxexmpRecType = ASRecTypeMap.get('Tax Exemption');
        
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
        testAcctList.add(new Account(
                                        RecordTypeId = massMarketIndRecType.getRecordTypeId(),
                                        FirstName = 'TestMass',
                                        LastName = 'MarketIndividualAcct2',
                                        PersonMailingStreet = '4173 Still Street',
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
        testAcctList[2].Business_Account__c = testAcctList[0].Id;
        update new list<account>{testAcctList[1],testAcctList[2]};
        
        LDC_Account__c ldcTestAccount = new LDC_Account__c(
                                                Name = 'Test LDC Acc 1',
                                                Account__c=testAcctList[1].Id,
                                                LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                Service_Street_1__c = '4048 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_status__c = 'ACTIVE',
                                                Enrolled__c = true
                                            );
        LDC_Account__c ldcTestAccount2 = new LDC_Account__c(
                                                Name = 'Test LDC Acc 2',
                                                Account__c=testAcctList[2].Id,
                                                LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                Service_Street_1__c = '4049 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_status__c = 'ACTIVE',
                                                Enrolled__c = true
                                            );
        
        insert new list<ldc_account__c>{ldcTestAccount,ldcTestAccount2};
        
        Contract testContract = new Contract(
                                                AccountId=testAcctList[0].Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'Small Stable Contract - Evergreen',
                                                Service_Territory__c='AEPOHIO',
                                                LodeStar_Identifier__c = 'FHUHEUJOUFHSFDFS'
                                            );
        Contract testContract2 = new Contract(
                                                AccountId=testAcctList[0].Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'Hybrid',
                                                Service_Territory__c='AEPOHIO',
                                                LodeStar_Identifier__c = 'FHGFEUOOUFHSFDFS'
                                            );
                                            
        insert new list<contract>{testContract,testContract2};
        
        Contract_LDC__c testContractLDC = new Contract_LDC__c(  Name='Test CLDC 1',
                                                                LDC_Account__c=ldcTestAccount.Id,
                                                                Contract__c = testContract.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                IsSynchronized__c = true
                                                              );
        Contract_LDC__c testContractLDC2 = new Contract_LDC__c( Name='Test CLDC 2',
                                                                LDC_Account__c=ldcTestAccount2.Id,
                                                                Contract__c = testContract2.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                IsSynchronized__c = true
                                                              );
        insert new list<contract_ldc__c>{testContractLDC,testContractLDC2};
        
        Account_Supplement__c Tax1 = new Account_Supplement__c (Ldc_account__c = ldcTestAccount.id,Type__c='Tax_Sales_Exemption',Percentage__c=0.5000,RecordTypeId = TaxexmpRecType.getRecordTypeId(),
                                                                        Start_Date__c=Date.today(),End_Date__c= date.today().addMonths(1));
        Account_Supplement__c Tax2 = new Account_Supplement__c (Ldc_account__c = ldcTestAccount.id,Type__c='Tax_Sales_Exemption',Percentage__c=0.5000,RecordTypeId = TaxexmpRecType.getRecordTypeId(),
                                                                        Start_Date__c=Date.today().addmonths(2),End_Date__c= date.today().addMonths(3));
        Account_Supplement__c Tax3 = new Account_Supplement__c (Ldc_account__c = ldcTestAccount2.id,Type__c='Tax_Sales_Exemption',Percentage__c=0.5000,RecordTypeId = TaxexmpRecType.getRecordTypeId(),
                                                                        Start_Date__c=Date.today(),End_Date__c= date.today().addMonths(3));
        Account_Supplement__c Tax4 = new Account_Supplement__c (Ldc_account__c = ldcTestAccount2.id,Type__c='Tax_Sales_Exemption',Percentage__c=0.5000,RecordTypeId = TaxexmpRecType.getRecordTypeId(),
                                                                        Start_Date__c=Date.today().addmonths(4),End_Date__c= date.today().addMonths(6),URL__c= 'https://dynegy.my.salesforce.com/');
        Account_Supplement__c Tax5 = new Account_Supplement__c (Ldc_account__c = ldcTestAccount2.id,Type__c='Tax_Sales_Exemption',Percentage__c=0.5000,RecordTypeId = TaxexmpRecType.getRecordTypeId(),
                                                                        Start_Date__c=Date.today().addmonths(7),End_Date__c= date.today().addMonths(36));
                                                                        
        Account_Supplement__c GRT1 = new Account_Supplement__c (Ldc_account__c = ldcTestAccount.id,Type__c='Tax_GRT_Exemption',Percentage__c=1.0000,RecordTypeId = GRTRecType.getRecordTypeId(),
                                                                        Start_Date__c=Date.today(),End_Date__c= date.today().addMonths(36));
        Account_Supplement__c GRT2 = new Account_Supplement__c (Ldc_account__c = ldcTestAccount2.id,Type__c='Tax_GRT_Exemption',Percentage__c=0.1000,RecordTypeId = GRTRecType.getRecordTypeId(),
                                                                        Start_Date__c=Date.today().adddays(1),End_Date__c= date.today().addMonths(36),URL__c ='https://dynegy.my.salesforce.com/');
        
        insert new list<Account_Supplement__c>{Tax1,Tax2,Tax3,Tax4,Tax5,GRT1,GRT2};

        Tax5.End_Date__c = date.today().addmonths(12);
        update Tax5;
        
    }
}