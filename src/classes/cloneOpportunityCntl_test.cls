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
private class cloneOpportunityCntl_test {

    static testMethod void cloneCIWOLDC() {
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        Account acc = new Account();
        acc.name = 'Test Acc';
        acc.Billing_Entity__c='Dynegy';
        insert acc;
       
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opp';
        opp.StageName = 'New';
        opp.CloseDate = date.today().addDays(5);
        opp.Accountid = acc.id;
        opp.RecordTypeId = rec.id;
        opp.type = 'C&I';
        insert opp;
        
        LDC_Vendor__c testVendor1 = new LDC_Vendor__c(Name='Test Vendor OH',DUNS__c = 'U698DWJ9',Legacy_ID__c = 'TVNDROH',Service_Territory__c = 'PPL - PA',
                                                     Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'PA');
        insert new list<ldc_vendor__c>{testVendor1};
        
        List<ldc_account__c> ldclist = new List<ldc_account__c>();
        ldclist.add(new ldc_account__c(Name='Test MM OH 1',ldc_account_number__c='MM826598252559',account__c=acc.id,Service_Territory__c='PPL - PA',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='DS0',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=23.235,NSPL2_KW__c=398.238598,
                                       Off_Pk_Kwh__c=25.346,On_Pk_Kwh__c=238.232));
        
        ldclist.add(new ldc_account__c(Name='Test MM OH 2',ldc_account_number__c='MM2348259825',account__c=acc.id,Service_Territory__c='PPL - PA',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='DS0',Utility_Rate_Class__c='OE-84AEP',Utility_Zone__c='AEP',Acct_ADU__c=235.253,NSPL2_KW__c=33.525,
                                       Off_Pk_Kwh__c=2435.223,On_Pk_Kwh__c=235.323));
        insert ldclist;
        
        List<opportunity_ldc__c> oldclist = new List<opportunity_ldc__c>();
        oldclist.add(new opportunity_ldc__c(ldc_account__c = ldclist[0].id, opportunity__c = opp.id));
        oldclist.add(new opportunity_ldc__c(ldc_account__c = ldclist[1].id, opportunity__c = opp.id));
        
        insert oldclist;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        cloneOpportunityCntl cntrl = new cloneOpportunityCntl(sc);
        cntrl.getsellist();
        cntrl.selectedoption='YES';
        cntrl.saveopp();
        cntrl.createoppldc();
        cntrl.savenewopp();
        cntrl.Cancel();
        
    }
    
    static testMethod void cloneCIWOOLDC() {
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        Account acc = new Account();
        acc.name = 'Test Acc';
        acc.Billing_Entity__c='Dynegy';
        insert acc;
       
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opp';
        opp.StageName = 'New';
        opp.CloseDate = date.today().addDays(5);
        opp.Accountid = acc.id;
        opp.RecordTypeId = rec.id;
        opp.type = 'C&I';
        opp.Pricing_Due_Date__c=date.today().adddays(-10);
        insert opp;
        
        LDC_Vendor__c testVendor1 = new LDC_Vendor__c(Name='Test Vendor OH',DUNS__c = 'U698DWJ9',Legacy_ID__c = 'TVNDROH',Service_Territory__c = 'PPL - PA',
                                                     Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'PA');
        insert new list<ldc_vendor__c>{testVendor1};
        
        List<ldc_account__c> ldclist = new List<ldc_account__c>();
        ldclist.add(new ldc_account__c(Name='Test MM OH 1',ldc_account_number__c='MM826598252559',account__c=acc.id,Service_Territory__c='PPL - PA',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='DS0',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=23.235,NSPL2_KW__c=398.238598,
                                       Off_Pk_Kwh__c=25.346,On_Pk_Kwh__c=238.232));
        
        ldclist.add(new ldc_account__c(Name='Test MM OH 2',ldc_account_number__c='MM2348259825',account__c=acc.id,Service_Territory__c='PPL - PA',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='DS0',Utility_Rate_Class__c='OE-84AEP',Utility_Zone__c='AEP',Acct_ADU__c=235.253,NSPL2_KW__c=33.525,
                                       Off_Pk_Kwh__c=2435.223,On_Pk_Kwh__c=235.323));
        insert ldclist;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        cloneOpportunityCntl cntrl = new cloneOpportunityCntl(sc);
        cntrl.getsellist();
        cntrl.saveopp();
        cntrl.createoppldc();
        cntrl.savenewopp();
        cntrl.Cancel();
        
    }
    
    static testMethod void cloneMM() {
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        Account acc = new Account();
        acc.name = 'Test Acc';
        acc.Billing_Entity__c='Dynegy';
        insert acc;
       
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opp';
        opp.StageName = 'New';
        opp.CloseDate = date.today().addDays(5);
        opp.Accountid = acc.id;
        opp.RecordTypeId = rec.id;
        opp.type = 'Muni-Agg';
        insert opp;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        cloneOpportunityCntl cntrl = new cloneOpportunityCntl(sc);
        cntrl.getsellist();
        cntrl.saveopp();
        cntrl.createoppldc();
        cntrl.savenewopp();
        cntrl.Cancel();
        
    }
}