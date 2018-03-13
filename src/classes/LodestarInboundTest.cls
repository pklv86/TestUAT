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
private class LodestarInboundTest {
    
    static Supplier__c supplier;
    static Account acc;
    static Ldc_account__c ldc1;
    static Ldc_account__c ldc2;
    static Contract_ldc__c cldc1;
    static Contract_ldc__c cldc2;
    static Contract_ldc__c cldc3;
    static Contract_ldc__c cldc4;
    static Contract_ldc__c cldc5;
    static contract ct1;
    static contract ct2;
    static contract ct3;

    @testsetup static void setupdata(){
        
        supplier = new Supplier__c();
        supplier.NAme ='Test supplier';
        supplier.Master_DUNS__c  ='1223';
        supplier.Supplier_DUNS__c ='999';
        supplier.Active__c = true;
        insert supplier;
        
        acc = new Account();
        acc.name = 'Test Acc';
        acc.Supplier__c = supplier.Id;
        acc.Billing_Entity__c='Dynegy';
        insert acc;
        
        ldc1 = new LDC_Account__c();
        ldc1.name  ='Test LDC acc1';
        ldc1.Account__c = acc.id;
        ldc1.LDC_Account_Number__c = '25365447541215';
        
        ldc2 = new LDC_Account__c();
        ldc2.name  ='Test LDC acc2';
        ldc2.Account__c = acc.id;
        ldc2.LDC_Account_Number__c = '25357976432534';
        
        insert new list<ldc_account__c>{ldc1,ldc2};
        
        ct1=new Contract(Name='Test Contract1',StartDate=Date.today(),Status='Draft',AccountId=acc.Id, Rate_Code__c ='DM01', Bill_Method__c ='DUAL', Interval_Usage__c ='Summary');
        
        ct2=new Contract(Name='Test Contract2',StartDate=Date.today(),Status='Draft',AccountId=acc.Id, Rate_Code__c ='DM02', Bill_Method__c ='RATE READY', Interval_Usage__c ='Summary');
        
        ct3 = new Contract(Name='Test Contract3',StartDate=Date.today(),Status='Draft',AccountId=acc.Id, Rate_Code__c ='DM03', Bill_Method__c ='BILL READY', Interval_Usage__c ='Summary');
        
        insert new list<contract>{ct1,ct2,ct3};
        
        cldc1 = new Contract_LDC__c();
        cldc1.Contract__c = ct1.Id;
        cldc1.LDC_Account__c = ldc1.Id;
        cldc1.issynchronized__c = true;
        cldc1.active__c = true;
        
        cldc2 = new Contract_LDC__c();
        cldc2.Contract__c = ct2.Id;
        cldc2.LDC_Account__c = ldc1.Id;
        cldc2.issynchronized__c = true;
        cldc2.active__c = false;
        
        cldc3 = new Contract_LDC__c();
        cldc3.Contract__c = ct3.Id;
        cldc3.LDC_Account__c = ldc1.Id;
        cldc3.issynchronized__c = true;
        cldc3.active__c = false;
        
        cldc4 = new Contract_LDC__c();
        cldc4.Contract__c = ct2.Id;
        cldc4.LDC_Account__c = ldc2.Id;
        cldc4.issynchronized__c = true;
        cldc4.active__c = true;
        
        cldc5 = new Contract_LDC__c();
        cldc5.Contract__c = ct3.Id;
        cldc5.LDC_Account__c = ldc2.Id;
        cldc5.issynchronized__c = true;
        cldc5.active__c = false;
        
        insert new list<contract_ldc__c>{cldc1,cldc2,cldc3,cldc4,cldc5};
    }

    @istest static void myUnitTest1() {
        // TO DO: implement unit test
        
        LodestarInbound.LSInboundRequest lsreq = new LodestarInbound.LSInboundRequest();
        list<LodestarInbound.AccountInfo> lstAInfo = new list<LodestarInbound.AccountInfo>();
        
        ldc_account__c ldc1 = [select id,ldc_account_number__c from ldc_account__c where ldc_account_number__c = '25365447541215'];
        ldc_account__c ldc2 = [select id,ldc_account_number__c from ldc_account__c where ldc_account_number__c = '25357976432534'];
        
        Contract ct1 = [select id ,contractnumber from contract where name = 'Test Contract1'];
        Contract ct2 = [select id ,contractnumber from contract where name = 'Test Contract2'];
        Contract ct3 = [select id ,contractnumber from contract where name = 'Test Contract3'];
        
        LodestarInbound.AccountInfo Ainfo1 = new LodestarInbound.AccountInfo();
        Ainfo1.AccountID = ldc1.ldc_account_number__c;
        Ainfo1.CRMID = '';
        Ainfo1.ContractID = ct1.contractnumber;
        Ainfo1.ErrorMessage = '';
        Ainfo1.LstarIdentifier = 'FGWIFDGIWLWA8U';
        Ainfo1.Shortcode = 'CUS1';
        Ainfo1.UniqueTimer = '10/11/2017 2:28:00 PM';
        
        LodestarInbound.AccountInfo Ainfo2 = new LodestarInbound.AccountInfo();
        Ainfo2.AccountID = ldc1.ldc_account_number__c;
        Ainfo2.CRMID = '';
        Ainfo2.ContractID = ct2.contractnumber;
        Ainfo2.ErrorMessage = 'ERROR : BRE - Contract Item stop before start';
        Ainfo2.LstarIdentifier = 'HGDDDH8943JDD';
        Ainfo2.Shortcode = 'CUS1';
        Ainfo2.UniqueTimer = '10/11/2017 2:29:00 PM';
        
        LodestarInbound.AccountInfo Ainfo3 = new LodestarInbound.AccountInfo();
        Ainfo3.AccountID = ldc1.ldc_account_number__c;
        Ainfo3.CRMID = '';
        Ainfo3.ContractID = ct3.contractnumber;
        Ainfo3.ErrorMessage = 'Done';
        Ainfo3.LstarIdentifier = 'FEU9025JHD73JH3';
        Ainfo3.Shortcode = 'CUS1';
        Ainfo3.UniqueTimer = '10/11/2017 2:30:00 PM';
        
        LodestarInbound.AccountInfo Ainfo4= new LodestarInbound.AccountInfo();
        Ainfo4.AccountID = ldc2.ldc_account_number__c;
        Ainfo4.CRMID = '';
        Ainfo4.ContractID = ct2.contractnumber;
        Ainfo4.ErrorMessage = 'Done';
        Ainfo4.LstarIdentifier = 'HGDDDH8943JDD';
        Ainfo4.Shortcode = 'CUS2';
        Ainfo4.UniqueTimer = '10/11/2017 2:31:00 PM';
        
        LodestarInbound.AccountInfo Ainfo5 = new LodestarInbound.AccountInfo();
        Ainfo5.AccountID = ldc2.ldc_account_number__c;
        Ainfo5.CRMID = '';
        Ainfo5.ContractID = ct3.contractnumber;
        Ainfo5.ErrorMessage = 'Account type code is not matching';
        Ainfo5.LstarIdentifier = 'FEU9025JHD73JH3';
        Ainfo5.Shortcode = 'CUS2';
        Ainfo5.UniqueTimer = '10/11/2017 2:32:00 PM';
        
        LodestarInbound.AccountInfo Ainfo6 = new LodestarInbound.AccountInfo();
        Ainfo6.AccountID = ldc1.ldc_account_number__c;
        Ainfo6.CRMID = '';
        Ainfo6.ContractID = ct1.contractnumber;
        Ainfo6.ErrorMessage = 'DONE';
        Ainfo6.LstarIdentifier = 'FGWIFDGIWLWA8U';
        Ainfo6.Shortcode = 'CUS1';
        Ainfo6.UniqueTimer = '10/11/2017 2:33:00 PM';
        
        LodestarInbound.AccountInfo Ainfo7 = new LodestarInbound.AccountInfo();
        Ainfo7.AccountID = ldc2.ldc_account_number__c;
        Ainfo7.CRMID = '';
        Ainfo7.ContractID = ct3.contractnumber;
        Ainfo7.ErrorMessage = 'Done';
        Ainfo7.LstarIdentifier = 'FEU9025JHD73JH3';
        Ainfo7.Shortcode = 'CUS2';
        Ainfo7.UniqueTimer = '10/11/2017 2:34:00 PM';
        
        LodestarInbound.AccountInfo Ainfo8 = new LodestarInbound.AccountInfo();
        Ainfo8.AccountID = ldc1.ldc_account_number__c;
        Ainfo8.CRMID = '';
        Ainfo8.ContractID = ct2.contractnumber;
        Ainfo8.ErrorMessage = 'Bill Cycle Missing';
        Ainfo8.LstarIdentifier = 'HGDDDH8943JDD';
        Ainfo8.Shortcode = 'CUS1';
        Ainfo8.UniqueTimer = '10/11/2017 2:35:00 PM';
        
        LodestarInbound.AccountInfo Ainfo9 = new LodestarInbound.AccountInfo();
        Ainfo9.AccountID = ldc1.ldc_account_number__c;
        Ainfo9.CRMID = '';
        Ainfo9.ContractID = ct2.contractnumber;
        Ainfo9.ErrorMessage = 'AccountType is not Matching';
        Ainfo9.LstarIdentifier = 'HGDDDH8943JDD';
        Ainfo9.Shortcode = 'CUS1';
        Ainfo9.UniqueTimer = '10/11/2017 2:35:00 PM';
        
        lstAInfo.add(Ainfo1);
        lstAInfo.add(Ainfo2);
        lstAInfo.add(Ainfo3);
        lstAInfo.add(Ainfo4);
        lstAInfo.add(Ainfo5);
        
        lsreq.Account_Info = lstAInfo;
        
        LodestarInbound.processrequest(lsreq);
        
        lstAInfo.clear();
        lstAInfo.add(Ainfo6);
        lstAInfo.add(Ainfo7);
        lstAInfo.add(Ainfo8);
        lstAInfo.add(Ainfo9);
        lsreq.Account_Info = lstAInfo;
        
        LodestarInbound.processrequest(lsreq);
        
    }
    
    @istest static void myunittest2(){
        LodestarInbound.processrequest(null);
    }
}