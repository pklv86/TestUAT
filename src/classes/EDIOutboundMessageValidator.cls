public class EDIOutboundMessageValidator 
{
    //public final static String DASR_ENROLLMENT = 'GAAE';
    //public final static String DASR_DROP = 'GAAD';
    //public final static String DASR_CHANGE = 'GAAC';
    //public final static String DASR_REINSTATEMENT = 'GAAR';
    
    public static List<String> isValLDCFromSFDCEnrolMsg(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor, List<Meter__c> lstMeter,Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        if(ldcAccount == null || dasrReq == null)
        {
            lstErrors.add(Label.EDI_Invalid_Request);
            return lstErrors;
        }
        //Enrollment
        if(dasrReq.DASR_Type__c == EDIConstantUtil.DASR_TYPE_ENROL)
        {
            lstErrors.addAll(validateCommonFields( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            //lstErrors.addAll(validateAddress( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            
        }
        //Check for contract Counter signed date
        if(dasrReq.Contract_CounterSigned_Date__c == null)
        {
            lstErrors.add(Label.EDI_Invalid_Contract_Counter_Signed_Date);
        }
        //Check for future contract start date
        if(dasrReq.Contract_CounterSigned_Date__c != null && dasrReq.Contract_CounterSigned_Date__c > system.today().addDays(1))
        {
            lstErrors.add(Label.EDI_Invalid_Future_Contract_Counter_Signed_Date);
        }
        
        //Check for contract start date
        if(dasrReq.Contract_StartDate__c  == null)
        {
            lstErrors.add(Label.EDI_Invalid_Contract_Effective_Date);
        }
        
        //Check for rate code
        if(dasrReq.Contract_RateCode__c  == null || String.isEmpty(dasrReq.Contract_RateCode__c))
        {
            //lstErrors.add(Label.EDI_Invalid_Rate_Code);
        }
        System.Debug('*****ldcAccount.ldc_vendor__r.name*****'+ldcAccount.ldc_vendor__r.name);
        system.Debug('*******Contract_Ratecode__C******'+dasrReq.Contract_Ratecode__c);
        // Check Rate Ready Comed Enrollment and don't send them
        if(dasrReq.Contract_BillMethod__c == null || string.isempty(dasrReq.Contract_BillMethod__C))
        {
            lstErrors.add(Label.EDI_Invalid_Bill_Method);
        }
        
        if((dasrReq.Contract_BillMethod__c == 'Rate Ready') && (ldcAccount.ldc_vendor__r.name == 'ComEd'))
        {
            system.debug('****entered ratecode check****');
            lstErrors.add(Label.EDI_Invalid_ComEd);
        }
        
        Bill_Method__c tBM = dasrReq.Contract_BillMethod__c != null ?  BillMethodUtil.getBillMethodByName(dasrReq.Contract_BillMethod__c) : null;
        
        //Check for bill presenter 
        if(tBM == null || tBM.Bill_Presenter__c == null || tBM.Bill_Presenter__c == '')
        {
            lstErrors.add(Label.EDI_Invalid_Bill_Presenter);   
        }     
        
        //Check for bill calculator
        
        if(dasrReq.Contract_BillMethod__c != null){
        if(tBM == null || tBM.Bill_Calculator__c == null || tBM.Bill_Calculator__c == '')
        {
            lstErrors.add(Label.EDI_Invalid_Bill_Calculator);   
        } 
        }
        //system.debug('ldc : '+ldcAccount.Account__r.Muni_Agg_Type__c+' Account : '+customer.Business_Account__r.Muni_Agg_Type__c+' STerritory : '+ldcaccount.service_territory__c+' Utility : '+ldcaccount.LDC_Vendor__r.Utility_Code__c); 
        if(dasrReq.CustomerID__c != null){
        if(ldcAccount.account__r.RecordType.name == 'Muni Agg Individual Customer' || customer.Business_Account__r.RecordType.name == 'Muni Agg Customer'){
            if(ldcaccount.Account__r.Muni_Agg_Type__c == 'GAG' || customer.Business_Account__r.Muni_Agg_Type__c == 'GAG'){
                if((ldcaccount.service_territory__c == 'DAYTON' && ldcaccount.LDC_Vendor__r.Utility_Code__c == 'DPL')||(ldcaccount.service_territory__c == 'AEPOHIO')){
                    if(ldcAccount.account__r.Aggregator_Code__c != customer.Business_Account__r.Aggregator_Code__c) {
                        lstErrors.add(Label.EDI_Invalid_Aggregator_Code); 
                    }
                    else if(ldcAccount.account__r.Aggregator_Code__c == null || customer.Business_Account__r.Aggregator_Code__c == null) {
                        lstErrors.add('Aggregator Code is Required'); 
                    }
                }
                else if(customer.Business_Account__r.Aggregator_Code__c != null ){
                    if(ldcAccount.account__r.Aggregator_Code__c == null){
                        lstErrors.add('Aggregator code is not populated on person customer');
                    }
                    else if(ldcAccount.account__r.Aggregator_Code__c != customer.Business_Account__r.Aggregator_Code__c) {
                        lstErrors.add(Label.EDI_Invalid_Aggregator_Code); 
                    }
                }
            }
           /* else if(ldcaccount.Account__r.Muni_Agg_Type__c == null || customer.Business_Account__r.Muni_Agg_Type__c == null){
                lstErrors.add('Aggregator/Muni-agg Type is Required');
            }*/
        }
        }
        return lstErrors;
    }
    
    public static List<String> isValLDCFromSFDCDropMsg(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor, List<Meter__c> lstMeter,Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        if(ldcAccount == null || dasrReq == null)
        {
            lstErrors.add(Label.EDI_Invalid_Request);
        }
        //Drop 
        if(dasrReq.DASR_Type__c == EDIConstantUtil.DASR_TYPE_DROP)
        {
            lstErrors.addAll(validateCommonFields( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            //Check for drop reason
            //Below condition is Addded for IL since it does not send the drop reason
            if(ldcAccount != null ){
                if(!ldcAccount.Service_territory__c.contains('-IL')){
                    if(String.isBlank(dasrReq.Drop_Reason__c))
                    {
                        lstErrors.add(Label.Invalid_Drop_Reason);
                    }
                    //Check for drop date date
                    if(dasrReq.Drop_Date__c == null)
                    {
                        lstErrors.add(Label.EDI_Invalid_Contract_End_Date);
                    }  
                }
                
                if(ldcVendor!= null && ldcVendor.Service_state__c!= null && ldcVendor.Service_state__c.containsignorecase('PA')){
                system.debug('enter********');
                string alloweddrop = label.PADropsAllowed;
                list<string> alloweddroplabel =  alloweddrop.split(';');
                set<string> dropallowed = new set<string>();
                  system.debug('*****'+dropallowed);
                dropallowed.addAll(alloweddroplabel );
                system.debug('*****'+dropallowed);
               if(!String.isBlank(dasrReq.Drop_Reason__c))
                    {
                if(!dropallowed.contains(dasrReq.Drop_Reason__c))
                    { system.debug('enter2********');
                        lstErrors.add(Label.Invalid_Drop_Reason);
                    }}
            /*String codeVal = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Drop_Reason__c, 'LDC_Account__c');
            if(codeVal != null && codeVal.equalsIgnoreCase('A13') && (dasrReq.Drop_Reason_Description__c == null || String.isEmpty(dasrReq.Drop_Reason_Description__c)))
            {
                lstErrors.add(Label.EDI_Invalid_Reason_Description);
            } */  
                }
            } 


        }
        return lstErrors;
    }
    public static List<String> isValLDCFromSFDCChngMsg(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor, List<Meter__c> lstMeter,Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        if(ldcAccount == null || dasrReq == null)
        {
            lstErrors.add(Label.EDI_Invalid_Request);
        }
        //Change
        if(dasrReq.DASR_Type__c == EDIConstantUtil.DASR_TYPE_CHANGE)
        {
            lstErrors.addAll(validateCommonFields( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            //lstErrors.addAll(validateAddress( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            
            //Check for change reason
            if(String.isBlank(dasrReq.Change_Reason__c))
            {
                lstErrors.add(Label.EDI_Invalid_Change_Reason);
            }
            // Check Rate Ready Comed Change Requests and don't send them
            //System.Debug('*****ldcAccount.ldc_vendor__r.name*****'+ldcAccount.ldc_vendor__r.name);
           if((dasrReq.Contract_BillMethod__c == 'Rate Ready') && (ldcAccount.ldc_vendor__r.name == 'ComEd'))
            {
                lstErrors.add(Label.EDI_Invalid_ComEd);
            }
            // Check Rate Ready PECO Change Requests and don't send them
              if( ldcAccount != null && dasrReq.Bill_Method__c !=null && ldcAccount.ldc_vendor__r.name != null  && (dasrReq.Bill_Method__c == 'Rate Ready') && (ldcAccount.ldc_vendor__r.name == 'PECO Energy Company'))
            {
                lstErrors.add(Label.EDI_Invalid_PECO);
            }
             // Check Rate Ready PECO Change Requests and don't send them
              if( dasrReq.Contract_BillMethod__c != null && (dasrReq.Contract_BillMethod__c == 'Rate Ready') && (ldcAccount.ldc_vendor__r.name == 'PECO Energy Company'))
            {
                lstErrors.add(Label.EDI_Invalid_PECO);
            }
            
            String codeVal = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c, 'LDC_Account__c');
            if(codeVal != null && codeVal.equalsIgnoreCase('A13') && (dasrReq.Reason_Description__c == null || String.isEmpty(dasrReq.Reason_Description__c)))
            {
                lstErrors.add(Label.EDI_Invalid_Reason_Description);
            }
            ChangeReason__c myChngRsn = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
            if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFBLT') && (dasrReq.Contract_BillMethod__c == null || String.isEmpty(dasrReq.Contract_BillMethod__c)))
            {
                lstErrors.add(Label.EDI_Invalid_Bill_Method);
            }
            if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REF17') && (dasrReq.Contract_IntervalUsage__c == null || String.isEmpty(dasrReq.Contract_IntervalUsage__c)))
            {
                lstErrors.add(Label.EDI_Invalid_Interval_Usage );
            }
            if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFRB') && (dasrReq.Contract_RateCode__c == null || String.isEmpty(dasrReq.Contract_RateCode__c))) 
            {
            
                if (dasrReq.RecipientName__c != null){
                 if(!dasrReq.RecipientName__c.containsignorecase('Ameren')){
                lstErrors.add(Label.EDI_Invalid_Rate_Code );
            }   }}         
             
            
        }
        return lstErrors;
    }
    //Added for Dynegy Initiated GAAR
    public static List<String> isValLDCFromSFDCReinstateMsg(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor, List<Meter__c> lstMeter,Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        if(ldcAccount == null || dasrReq == null)
        {
            lstErrors.add(Label.EDI_Invalid_Request);
        }
        //Reinstate
        if(dasrReq.DASR_Type__c == EDIConstantUtil.DASR_TYPE_REINSTAT)
        {
            lstErrors.addAll(validateCommonFields( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            //lstErrors.addAll(validateAddress( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            //check for dasr submit date
            if(dasrReq.DASR_Submit_Date__c==null){
                lstErrors.add(Label.EDI_InValid_DASR_Submit_Date);
            }
            //check for the Dynegy initiated DASR
            if(dasrReq.Dynegy_Initiated__c==false){
                lstErrors.add(Label.EDI_InValid_DASR);
            } 
        }
        return lstErrors;
    }
    
    public static List<String> validateAddress(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor, List<Meter__c> lstMeter,Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        
        //Check for service address
        if(String.isBlank(ldcAccount.Service_Street_1__c))
        {
            lstErrors.add(Label.EDI_Invalid_Service_Address);
        }
        
        //Check for service city
        if(String.isBlank(ldcAccount.Service_City__c))
        {
            lstErrors.add(Label.EDI_Invalid_City);
        }
        //Check for service state
        if(String.isBlank(ldcAccount.Service_State__c))
        {
            lstErrors.add(Label.EDI_Invalid_State);
        }            
        //Check for billing address
        if(String.isBlank(customer.BillingStreet))
        {
            lstErrors.add(Label.EDI_Invalid_Billing_Street);
        }
        
        //Check for billing city
        if(String.isBlank(customer.BillingCity))
        {
            lstErrors.add(Label.EDI_Invalid_Billing_City );
        }
        //Check for billing state
        if(String.isBlank(customer.BillingState))
        {
            lstErrors.add(Label.EDI_Invalid_Billing_State );
        } 
        return lstErrors;
    }
    public static List<String> validateCommonFields(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor, List<Meter__c> lstMeter,Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        System.debug('\n dasrReq='+dasrReq);
        if(ldcAccount == null)
        {
            lstErrors.add(Label.EDI_Invalid_LDC_Account);
            return lstErrors;
        }
        //Check for supplier duns
        if(String.isBlank(dasrReq.Originating_DUNS__c))
        {
            lstErrors.add(Label.EDI_Originator_DUNS);
        }
        
        //Check for vendor duns
        if(String.isBlank(dasrReq.RecipientDUNS__c))
        {
            lstErrors.add(Label.EDI_Vendor_DUNS);
        }
        //check for vendor ID
        if(string.isBlank(dasrReq.VendorID__c))
        {
            lstErrors.add(Label.EDI_Vendor_ID);
        }
        // Check for Contract Supplier.
        if(string.isblank(contract.supplier__c))
        {
            lstErrors.add(Label.EDI_contract);
        }
        //Check for Supplier ID
        if(string.isBlank(dasrReq.SupplierID__c))
        {
            lstErrors.add(Label.EDI_Supplier_ID);
        }
        
        // Check whether DASR vendor is equal to LDC vendor
        if((dasrReq.VendorID__c != ldcAccount.ldc_vendor__C) && !string.isblank(dasrReq.VendorID__c) && !string.isblank(ldcAccount.ldc_vendor__C))
        {
            lstErrors.add(Label.EDI_DASR_vendor);
        }   
        // Check whether DASR Supplier is equal to contract supplier
        if((dasrReq.SupplierID__c != contract.supplier__c) && !string.isblank(dasrReq.SupplierID__c) && !string.isblank(contract.supplier__c))
        {
            lstErrors.add(Label.EDI_DASR_Supplier);
        }
        if(string.isblank(dasrReq.CustomerID__c))
        {
            lstErrors.add(Label.EDI_Customer_ID);
        }
        
        //Check for contract start date
        
        // if(ldcAccount.LDC_Start_Date__c == null)
        // {
        //    lstErrors.add(Label.EDI_Invalid_Start_Date);
        // }
        
        //Check for LDC Number
        if(ldcAccount == null || ldcAccount.LDC_Account_Number__c == null || String.isBlank(ldcAccount.LDC_Account_Number__c))
        {
            lstErrors.add(Label.Invalid_LDC_Number);
        }    
        

        
        return lstErrors;
    }
/**
    public static List<String> validOldMeterNumber(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Maintenance_Code__c != null && tCH.Maintenance_Code__c.equalsIgnoreCase('MX') && (supplier == null || supplier.Supplier_DUNS__c !='006999189'))
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter == null || myMeter.Old_Meter_Number__c == null)
            {
                lstErrors.add(Label.EDI_Invalid_Old_Meter_Number);   
            }
        }
        return lstErrors;
    }
    public static List<String> validLoadProfileDesc(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Maintenance_Code__c != null && tCH.Maintenance_Code__c.equalsIgnoreCase('CH') && tCH.Reason_Code__c == 'REFLO')
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter == null || myMeter.Load_Profile__c == null)
            {
                lstErrors.add(Label.EDI_Invalid_Load_Profile);   
            }
        }
        return lstErrors;
    }
    public static List<String> validLDCRateClass(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Maintenance_Code__c != null && tCH.Maintenance_Code__c.equalsIgnoreCase('CH') && tCH.Reason_Code__c == 'REFNH')
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter == null || myMeter.LDC_Rate_Class__c  == null)
            {
                lstErrors.add(Label.EDI_Invalid_LDC_Rate_Class);   
            }
        }
        return lstErrors;
    }
    public static List<String> validLDCRateSubClass(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Maintenance_Code__c != null && tCH.Maintenance_Code__c.equalsIgnoreCase('CH') && tCH.Reason_Code__c == 'REFPR')
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter == null || myMeter.LDC_Rate_Subclass__c  == null)
            {
                lstErrors.add(Label.EDI_Invalid_LDC_Rate_Subclass );   
            }
        }
        return lstErrors;
    }
    public static List<String> validLDCMeterCycle(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Maintenance_Code__c != null && tCH.Maintenance_Code__c.equalsIgnoreCase('CH') && tCH.Reason_Code__c == 'REFTZ')
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter == null || myMeter.LDC_Meter_Cycle__c  == null)
            {
                lstErrors.add(Label.EDI_Invalid_LDC_Meter_Cycle);   
            }
        }
        return lstErrors;
    }
    public static List<String> validLDCMeterTypeCode(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && (tCH.Maintenance_Code__c != null && (tCH.Maintenance_Code__c.equalsIgnoreCase('MA') ||tCH.Maintenance_Code__c.equalsIgnoreCase('MX') ) || (tCH.Reason_Code__c == 'REFMT' || tCH.Reason_Code__c == 'NM1MQ')))
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter.Meter_Number__c  != null && !myMeter.Meter_Number__c.equalsIgnoreCase('All'))
            {
                lstErrors.add(Label.EDI_Invalid_Meter_Type_Code);   
            }
        }
        return lstErrors;
    }
    public static List<String> validLDCMeterMultiplier(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && (tCH.Maintenance_Code__c != null && (tCH.Maintenance_Code__c.equalsIgnoreCase('MA') ||tCH.Maintenance_Code__c.equalsIgnoreCase('MX') ) || (tCH.Reason_Code__c == 'REF4P' || tCH.Reason_Code__c == 'NM1MQ')))
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter.Meter_Number__c  != null && !myMeter.Meter_Number__c.equalsIgnoreCase('All'))
            {
                lstErrors.add(Label.EDI_Invalid_Meter_Multiplier);   
            }
        }
        return lstErrors;
    }
    public static List<String> validDialsQuantity(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && (tCH.Maintenance_Code__c != null && (tCH.Maintenance_Code__c.equalsIgnoreCase('MA') ||tCH.Maintenance_Code__c.equalsIgnoreCase('MX') ) || (tCH.Reason_Code__c == 'REFIX' || tCH.Reason_Code__c == 'NM1MQ')))
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter.Meter_Number__c  != null && !myMeter.Meter_Number__c.equalsIgnoreCase('All'))
            {
                lstErrors.add(Label.EDI_Invalid_Dials_Quantity );   
            }
        }
        return lstErrors;
    }
    public static List<String> validTimeOfUseMeter(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && (tCH.Maintenance_Code__c != null && (tCH.Maintenance_Code__c.equalsIgnoreCase('MA') ||tCH.Maintenance_Code__c.equalsIgnoreCase('MX') ) || (tCH.Reason_Code__c == 'REFTU' || tCH.Reason_Code__c == 'NM1MQ')))
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter.Meter_Number__c  != null && !myMeter.Meter_Number__c.equalsIgnoreCase('All'))
            {
                lstErrors.add(Label.EDI_Invalid_Time_Of_User  );   
            }
        }
        return lstErrors;
    }
    public static List<String> validServVoltage(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Reason_Code__c == 'REFSV')
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter.Meter_Number__c  == null || myMeter.Meter_Service_Voltage__c  == null)
            {
                lstErrors.add(Label.Invalid_Meter_Service_Voltage  );   
            }
        }
        return lstErrors;
    }
    public static List<String> validDistLossFactor(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Reason_Code__c == 'REFLF')
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter.Meter_Number__c  == null || myMeter.Distribution_Loss_Factor__c   == null)
            {
                lstErrors.add(Label.EDI_Invalid_Distribution_Loass   );   
            }
        }
        return lstErrors;
    }
**/
}