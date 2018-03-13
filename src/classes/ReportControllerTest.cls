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
@isTest (SeeAllData=false)
public class ReportControllerTest {

    static testMethod void ReportYearly() {
        // TO DO: implement unit test
        
        Supplier__c supp = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',Organization_Identifier_Code__c = 'TESTSUP',
        									Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST',Active__c = true);
        insert supp;
        
        Product2 pro = new Product2(name='FP-Test',isactive=true);
        insert pro;
        
        LDC_Vendor__c Ven = new LDC_Vendor__c(Name='Test Vendor',DUNS__c = DynegyCommonUtils.generateRandomString(8),Legacy_ID__c = 'TVNDR',Service_Territory__c = 'AEPOHIO',
                                                     Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        insert Ven;
        
        Integer recCreate = math.round(math.random() * 200);
        list<account> acclst = new list<account>();
        for(Integer i=0;i<recCreate;i++){
        	Account a = new Account();
        	a.name = 'Test Account '+i;
        	a.billing_entity__c = 'Dynegy';
        	a.Customer_Type__c = 'C&I';
        	a.Sales_Region__c = 'Central';
        	a.Supplier__c = supp.id;
        	acclst.add(a);
        }
        insert acclst;
        
        recCreate = math.round(math.random() * 200);
        list<Opportunity> opplst = new list<Opportunity>();
        for(Integer i=0;i<recCreate;i++){
        	Opportunity o = new Opportunity();
        	o.name = 'Test Opportunity '+i;
        	o.AccountId = acclst[0].id;
        	o.Type = 'C&I';
        	o.service_territory__c = 'AEPOHIO';
        	o.Opportunity_Type__c = 'New Business';
        	o.closedate = date.today();
        	o.stageName = 'New';
        	o.Pricing_Due_Date__c = date.today();
        	opplst.add(o);
        }
        insert opplst;
        
        recCreate = math.round(math.random() * 200);
        list<Contract> cntlst = new list<Contract>();
        for(Integer i=0;i<recCreate;i++){
        	Contract c = new Contract();
        	c.name = 'Test Contract '+i;
        	c.AccountId = acclst[0].id;
        	c.opportunity__c = opplst[0].id;
        	c.ContractTerm = 12;
        	c.StartDate = date.today();
        	cntlst.add(c);
        }
        insert cntlst;
        for(Contract ct :cntlst){
        	ct.status='Activated';
        }
        update cntlst;
        
        recCreate = math.round(math.random() * 200);
        list<Retail_Quote__c> rqlst = new list<Retail_Quote__c>();
        for(Integer i=0;i<recCreate;i++){
        	Retail_Quote__c rq = new Retail_Quote__c();
        	rq.opportunity__c = opplst[0].id;
        	rq.Term__c = 12;
        	rq.Payment_Terms__c = '21';
        	rq.Start_Term__c = date.today();
        	rq.ContractType__c = 'Large Stable Contract';
        	rq.Utility_Settlement_Zone__c = 'AEPOHIO_RESID_AGG';
        	rq.Product__c = pro.id;
        	rq.Margin__c = 0.3694;
        	rq.Energy_Fixed__c = 7.96;
        	rq.Index_Margin__c = 1.5435;
        	rqlst.add(rq);
        }
        insert rqlst;
        
        recCreate = math.round(math.random() * 200);
        list<LDC_Account__c> ldclst = new list<LDC_Account__c>();
        for(Integer i=0;i<recCreate;i++){
        	LDC_Account__c l = new LDC_Account__c();
        	l.account__c = acclst[0].id;
        	l.name = 'Test LDC Account '+i;
        	l.ldc_account_number__c = '0925527520'+i;
        	l.ldc_type__c = 'Commercial';
        	l.service_territory__c = 'AEPOHIO';
        	l.ldc_vendor__c = ven.id;
        	ldclst.add(l);
        }
        insert ldclst;
        
        recCreate = math.round(math.random() * 200);
        list<DASR_Request__c> dasrlst = new list<DASR_Request__c>();
        for(Integer i=0;i<recCreate;i++){
        	DASR_Request__c d = new DASR_Request__c();
        	d.contract__c = cntlst[0].id;
        	d.billing_entity__c = 'Dynegy';
        	d.ldc_account__c = ldclst[0].id;
        	d.dasr_type__c = 'GAAE';
        	d.dynegy_initiated__c = true;
        	d.dasr_submit_date__c = date.today();
        	d.change_effective_date__c = date.today().adddays(15);
        	dasrlst.add(d);
        }
        insert dasrlst;
        
        recCreate = math.round(math.random() * 200);
        list<Contract_LDC__c> cldclst = new list<Contract_LDC__c>();
        for(Integer i=0;i<recCreate;i++){
        	Contract_LDC__c cldc = new Contract_LDC__c();
        	cldc.contract__c = cntlst[0].id;
        	cldc.ldc_account__c = ldclst[0].id;
        	cldc.Name = 'Test CLDC '+i;
        	cldc.Bill_Method__c = 'Rate Ready';
        	cldclst.add(cldc);
        }
        insert cldclst;
        
        //DataStorageMockImpl mockRes = new DataStorageMockImpl(200,'Complete','[{"Max":"6654453","Remaining":"24342"}]',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new DataStorageMockImpl());
        ReportController rc = new ReportController();
        rc.switchToYearly();
        Test.stopTest();
    }
    
    static testMethod void ReportDaily() {
        // TO DO: implement unit test
        
        Supplier__c supp = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',Organization_Identifier_Code__c = 'TESTSUP',
        									Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST',Active__c = true);
        insert supp;
        
        Product2 pro = new Product2(name='FP-Test',isactive=true);
        insert pro;
        
        LDC_Vendor__c Ven = new LDC_Vendor__c(Name='Test Vendor',DUNS__c = DynegyCommonUtils.generateRandomString(8),Legacy_ID__c = 'TVNDR',Service_Territory__c = 'AEPOHIO',
                                                     Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        insert Ven;
        
        Integer recCreate = math.round(math.random() * 200);
        list<account> acclst = new list<account>();
        for(Integer i=0;i<recCreate;i++){
        	Account a = new Account();
        	a.name = 'Test Account '+i;
        	a.billing_entity__c = 'Dynegy';
        	a.Customer_Type__c = 'C&I';
        	a.Sales_Region__c = 'Central';
        	a.Supplier__c = supp.id;
        	acclst.add(a);
        }
        insert acclst;
        
        recCreate = math.round(math.random() * 200);
        list<Opportunity> opplst = new list<Opportunity>();
        for(Integer i=0;i<recCreate;i++){
        	Opportunity o = new Opportunity();
        	o.name = 'Test Opportunity '+i;
        	o.AccountId = acclst[0].id;
        	o.Type = 'C&I';
        	o.service_territory__c = 'AEPOHIO';
        	o.Opportunity_Type__c = 'New Business';
        	o.closedate = date.today();
        	o.stageName = 'New';
        	o.Pricing_Due_Date__c = date.today();
        	opplst.add(o);
        }
        insert opplst;
        
        recCreate = math.round(math.random() * 200);
        list<Contract> cntlst = new list<Contract>();
        for(Integer i=0;i<recCreate;i++){
        	Contract c = new Contract();
        	c.name = 'Test Contract '+i;
        	c.AccountId = acclst[0].id;
        	c.opportunity__c = opplst[0].id;
        	c.ContractTerm = 12;
        	c.StartDate = date.today();
        	cntlst.add(c);
        }
        insert cntlst;
        for(Contract ct :cntlst){
        	ct.status='Activated';
        }
        update cntlst;
        
        recCreate = math.round(math.random() * 200);
        list<Retail_Quote__c> rqlst = new list<Retail_Quote__c>();
        for(Integer i=0;i<recCreate;i++){
        	Retail_Quote__c rq = new Retail_Quote__c();
        	rq.opportunity__c = opplst[0].id;
        	rq.Term__c = 12;
        	rq.Payment_Terms__c = '21';
        	rq.Start_Term__c = date.today();
        	rq.ContractType__c = 'Large Stable Contract';
        	rq.Utility_Settlement_Zone__c = 'AEPOHIO_RESID_AGG';
        	rq.Product__c = pro.id;
        	rq.Margin__c = 0.3694;
        	rq.Energy_Fixed__c = 7.96;
        	rq.Index_Margin__c = 1.5435;
        	rqlst.add(rq);
        }
        insert rqlst;
        
        recCreate = math.round(math.random() * 200);
        list<LDC_Account__c> ldclst = new list<LDC_Account__c>();
        for(Integer i=0;i<recCreate;i++){
        	LDC_Account__c l = new LDC_Account__c();
        	l.account__c = acclst[0].id;
        	l.name = 'Test LDC Account '+i;
        	l.ldc_account_number__c = '0925527520'+i;
        	l.ldc_type__c = 'Commercial';
        	l.service_territory__c = 'AEPOHIO';
        	l.ldc_vendor__c = ven.id;
        	ldclst.add(l);
        }
        insert ldclst;
        
        recCreate = math.round(math.random() * 200);
        list<DASR_Request__c> dasrlst = new list<DASR_Request__c>();
        for(Integer i=0;i<recCreate;i++){
        	DASR_Request__c d = new DASR_Request__c();
        	d.contract__c = cntlst[0].id;
        	d.billing_entity__c = 'Dynegy';
        	d.ldc_account__c = ldclst[0].id;
        	d.dasr_type__c = 'GAAE';
        	d.dynegy_initiated__c = true;
        	d.dasr_submit_date__c = date.today();
        	d.change_effective_date__c = date.today().adddays(15);
        	dasrlst.add(d);
        }
        insert dasrlst;
        
        recCreate = math.round(math.random() * 200);
        list<Contract_LDC__c> cldclst = new list<Contract_LDC__c>();
        for(Integer i=0;i<recCreate;i++){
        	Contract_LDC__c cldc = new Contract_LDC__c();
        	cldc.contract__c = cntlst[0].id;
        	cldc.ldc_account__c = ldclst[0].id;
        	cldc.Name = 'Test CLDC '+i;
        	cldc.Bill_Method__c = 'Rate Ready';
        	cldclst.add(cldc);
        }
        insert cldclst;
        
        //DataStorageMockImpl mockRes = new DataStorageMockImpl(200,'Complete','[{"Max":"6654453","Remaining":"24342"}]',null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new DataStorageMockImpl());
        ReportController rc = new ReportController();
        rc.switchToDaily();
        Test.stopTest();
    }
    
    public class DataStorageMockImpl implements HttpCalloutMock  {
    	/*protected Integer code;
		protected String status;
		protected String bodyAsString;
		protected Blob bodyAsBlob;
		protected Map<String, String> responseHeaders;

		public DataStorageMockImpl(Integer code, String status, String body,Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsString = body;
			this.bodyAsBlob = null;
			this.responseHeaders = responseHeaders;
		}

		public DataStorageMockImpl(Integer code, String status, Blob body,Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsBlob = body;
			this.bodyAsString = null;
			this.responseHeaders = responseHeaders;
		}

	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }*/
	    public HTTPResponse respond(HTTPRequest req) {
		    // Optionally, only send a mock response for a specific endpoint
		    // and method.
		    System.assertEquals(system.URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v41.0/limits', req.getEndpoint());
		    System.assertEquals('GET', req.getMethod());
		    
		    // Create a fake response
		    HttpResponse res = new HttpResponse();
		    res.setHeader('Content-Type', 'application/json');
		    res.setBody('{"DataStorageMB" : {"Max" : 61803,"Remaining" : 6223}}');
		    res.setStatusCode(200);
		    return res;
	    }
    } 
}