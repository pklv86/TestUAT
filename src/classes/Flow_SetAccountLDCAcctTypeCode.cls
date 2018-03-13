/**
 * This class is designed to host an Invocable Action and can be called from the Process Builder
 * Its purpose is to set the LDC_Account__r.Account_Type_Code__c value based on the Contract.Bill_Type__c,
 * and the LDC_Account__r.LDC_Vendor__r.DUNS__c on the Contract_LDC__c record that has been marked as Active.
 * 
 * @version 1.1 - CJG - 03/21/2016 - Updated the functionality to also update the Rate_Code__c
 *                                   on the Account_LDC from the Contract_LDC
 * @version 1.2 - CJG - 03/31/2016 - Updated the functionality to also update the Contract_Type__c
 *                                   on the related Contract record
 * @version 1.3 - CJG - 04/14/2016 - Updated functionality not to Set Contract Type Any longer.
 * @version 1.4 - CJG - 04/14/2016 - Change to obtaining AccountTypeCode__c - now determined By Contract Type and Service Territory.
 * @version 1.5 - PP  - 10/15/2016 - Added functionality check billmethod also
 * @version 1.5 - PP  - 01/20/2017 - Added functionality to skip billing group if thery are active on it
 * @version 1.5 - PP  - 05/30/2017 - Updated the mapping functionality for MA sites in order to pull multiple from map<String,map<String,Account_Type_Settings__c>> 
 										to map<String,map<String,map<string,list<Account_Type_Settings__c>>>>
 * @version 1.5 - PP  - 10/15/2017 - Updated the mapping functionality for PA Sites to look state values and default checks
 									 Changed custom settings to custom objects to hold values
 * @version 1.5 - PP  - 12/28/2017 - Upgraded the functionality and performance for map
 **/
public class Flow_SetAccountLDCAcctTypeCode {
    @InvocableMethod(label='Set Account LDC' description='Set the Related LDC Account Type Code from the Contract LDC if marked as active.')
    public static void SetAccountLDCInfoFROMContractLDC(List<Id> contractLDCId){
        list<id> cldcId = new list<id>();
        set<string> ldcST = new set<string>();
        list<contract_ldc__c> cldclst = new list<contract_ldc__c>();
        for(Contract_LDC__c cntrct:[SELECT Id, Name, Contract__c, LDC_Account__c,LDC_Account__r.Service_Territory__c,LDC_Account__r.Utility_Rate_Class__c,
                                        Contract__r.Contract_Type__c,Contract__r.Bill_Method__c,ldc_account__r.Account_Type_Code__c FROM Contract_LDC__c 
                                        WHERE Id IN :contractLDCId]){
            if(cntrct.ldc_account__r.Account_Type_Code__c != 'RETAIL_FRIEND'){
                cldcId.add(cntrct.id);
                ldcST.add(cntrct.LDC_Account__r.Service_Territory__c);
            }                                       
        }
        if(!cldcId.isempty()){
            map<Id,String> ldcAccountIdToAccountTypeMap = new map<Id,String>();
            map<String,map<String,map<string,list<Account_Type_Settings__c>>>> settingsMap = ObtainAccountTypeSettingMapByAlternateKey(ldcST);
            for(Contract_LDC__c cntrct:[SELECT Id, Name, Contract__c, LDC_Account__c,LDC_Account__r.Service_Territory__c,LDC_Account__r.Utility_Rate_Class__c,
                                            Contract__r.Contract_Type__c,Contract__r.Bill_Method__c,Account_Type_Code__c FROM Contract_LDC__c WHERE Id IN :cldcId]){
                                                    
                map<String,map<string,list<Account_Type_Settings__c>>> contractTypeMap = settingsMap.get(cntrct.LDC_Account__r.Service_Territory__c);
                if(contractTypeMap != null && cntrct.Contract__r.Contract_Type__c != null){
                    system.debug('contractTypeMap : '+contractTypeMap);
                    map<string,list<Account_Type_Settings__c>> billMethodMap = contractTypeMap.get(cntrct.Contract__r.Contract_Type__c);
                    if(billMethodMap != null){
                        system.debug('billMethodMap : '+billMethodMap);
                        list<Account_Type_Settings__c> atslst = billMethodMap.get(cntrct.Contract__r.Bill_Method__c);
                        Account_Type_Settings__c acctTypeSetting;
                        if(atslst != null){
                            if(atslst.size() > 1){
                                string rateclassStr = '';
                                Account_Type_Settings__c tempats;
                                
                                for(Account_Type_Settings__c ats : atslst){
                                    system.debug('LDC UTILITY RATE CLASS : '+cntrct.LDC_Account__r.Utility_Rate_Class__c);
                                    if(cntrct.LDC_Account__r.Utility_Rate_Class__c != null){
                                        if(ats.rate_class__c != 'DEFAULT'){
                                            rateclassStr= ats.rate_class__c;
                                        } 
                                        else if(ats.rate_class__c == 'DEFAULT')
                                            tempats=ats;
                                        
                                        if(rateclassStr.contains(cntrct.LDC_Account__r.Utility_Rate_Class__c))
                                            acctTypeSetting = ats;
                                    }
                                    else{
                                        if(ats.rate_class__c == 'DEFAULT')
                                            tempats = ats;
                                    }
                                }
                                if(acctTypeSetting == null)
                                    acctTypeSetting = tempats;
                            }
                            else
                                acctTypeSetting = atslst[0];
                        }
                        else{
                            atslst = billMethodMap.get(null);
                            if(atslst != null)
                                acctTypeSetting = atslst[0];
                        }
                        /***************** COMMENTED FOR T-001944   ********************************/
                        /*if(billMethodMap.size() > 1){
                            for(AccountTypeSetting__c ats : billMethodMap.values()){
                                system.debug('test inner : '+ats.Bill_Method__c +' : '+cntrct.Contract__r.Bill_Method__c);
                                if(ats.Bill_Method__c.equalsIgnorecase(cntrct.Contract__r.Bill_Method__c) && ats.Bill_Method__c != null)
                                     atslst = billMethodMap.get(ats.Bill_Method__c);
                                    // acctTypeSetting = billMethodMap.get(ats.Bill_Method__c);
                            }
                        }
                        else{
                            atslst = billMethodMap.get(cntrct.Contract__r.Bill_Method__c);
                            //AccountTypeSetting__c ats1 = billMethodMap.get(cntrct.Contract__r.Bill_Method__c);
                            system.debug('test ats1 : '+ats1);
                            if(ats1 != null && ats1.Contract_Type__c.equalsIgnorecase(cntrct.Contract__r.Contract_Type__c))
                                acctTypeSetting = ats1;
                            else
                                acctTypeSetting = billMethodMap.get(null);
                        }*/
                        if(acctTypeSetting != null) ldcAccountIdToAccountTypeMap.put(cntrct.LDC_Account__c,acctTypeSetting.Account_Type_Code__c);
                    }
                    else{
                        if(billMethodMap == null && billMethodMap.size()>0){
                            list<Account_Type_Settings__c> atslst = billMethodMap.get(null);
                            Account_Type_Settings__c acctTypeSetting;
                            if(atslst.size()>1){
                                
                            }
                            else if(!atslst.isempty()){
                                acctTypeSetting = atslst[0];
                            }
                        }
                    }
                }
                if(ldcAccountIdToAccountTypeMap.get(cntrct.LDC_Account__c) != null){
                    cntrct.Account_Type_Code__c = ldcAccountIdToAccountTypeMap.get(cntrct.LDC_Account__c);
                    cldclst.add(cntrct);
                }
            }
            List<LDC_Account__c> ldcsToUpdate = new List<LDC_Account__c>();
            for(LDC_Account__c ldcAcct:[SELECT Id, Account_Type_Code__c FROM LDC_Account__c WHERE Id IN :ldcAccountIdToAccountTypeMap.keySet()]){
                ldcAcct.Account_Type_Code__c = ldcAccountIdToAccountTypeMap.get(ldcAcct.Id);
                ldcsToUpdate.add(ldcAcct);
            }
            if(!ldcsToUpdate.isEmpty()) update ldcsToUpdate;
            if(!cldclst.isEmpty()) update cldclst;
        }
    }
    /**
     * Simply returns the AccounTypeSetting__c records in a Map of Maps with the first key being
     * ServiceTerritory__c and the Second Key being the Contract_Type__c.
     *
     * @return Map<String,Map<String,AccountTypeSetting__c>>  - the Map to return
     **/
    public static map<String,map<String,map<string,list<Account_Type_Settings__c>>>> ObtainAccountTypeSettingMapByAlternateKey(set<string> sTerritory){
        Map<String,Account_Type_Settings__c> settingMap = new Map<String,Account_Type_Settings__c>(); //AccountTypeSetting__c.getAll();
        for(Account_Type_Settings__c ats : [select id,name,Account_Type_Code__c,Bill_Method__c,Contract_Code__c,Contract_Type__c,Rate_Class__c,Service_Territory__c,
                                            State__c,key__c from Account_Type_Settings__c where Service_Territory__c IN : sTerritory order by Service_Territory__c,Contract_Type__c]){
            settingMap.put(ats.Name,ats);
        }
        
        map<String,map<String,map<string,list<Account_Type_Settings__c>>>> returnMap = new map<String,map<String,map<string,list<Account_Type_Settings__c>>>>();
        for(Account_Type_Settings__c setting:settingMap.values()){
            
            map<String,map<string,list<Account_Type_Settings__c>>> tempMap = new map<String,map<string,list<Account_Type_Settings__c>>>();
            map<string,list<Account_Type_Settings__c>> tempMap2 = new map<String,list<Account_Type_Settings__c>>();
            list<Account_Type_Settings__c> atslst = new list<Account_Type_Settings__c>();
            
            if(returnMap.containsKey(setting.Service_Territory__c)){
                tempMap = returnMap.get(setting.Service_Territory__c);
                system.debug('tempMap : '+tempmap.size()+' : '+tempmap.keyset());
                for(string st : tempMap.keyset()){
                    if(tempMap.containsKey(setting.Contract_Type__c)){
                        tempMap2 = tempMap.get(setting.Contract_Type__c);
                        for(string str : tempMap2.keyset()){
                        	if(tempMap2.containskey(setting.Bill_Method__c)){
	                            atslst = tempmap2.get(setting.Bill_Method__c);
	                        }
                        }
                    }
                }
            }
            atslst.add(setting);
            tempMap2.put(setting.Bill_Method__c,atslst);
            tempMap.put(setting.Contract_Type__c,tempMap2);
            returnMap.put(setting.Service_Territory__c,tempMap);
        }
        return returnMap;
    }
}