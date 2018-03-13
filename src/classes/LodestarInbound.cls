/**********************************************************
Class :  LodestarInbound
Version Date    Author
1.0 
***********************************************************/
global class LodestarInbound {
    
    global class LSInboundRequest{
        Webservice list<AccountInfo> Account_Info {get; set;}
    }
    
    global class AccountInfo{
        Webservice String AccountID;
        Webservice String CRMID;
        Webservice String ContractID;
        Webservice String ErrorMessage;
        Webservice String LstarIdentifier;
        Webservice String Shortcode;
        Webservice String UniqueTimer;
    }
    
    global class response{
        webservice String Status;
        webservice string MessageDesc;
    }
    
    webservice static response processrequest(LSInboundRequest lsreq){
        response res = new response();
        if(lsreq == null){
            res.status=ConstantUtility.STATUS_SUCCESS;
            res.MessageDesc = 'No request Found'; 
           return res;  
        }
        
        set<string> ldcset = new set<string>();
        set<string> cntset = new set<string>();
        if(lsreq != null && lsreq.account_info != null){
            for(AccountInfo acinfo : lsreq.account_info){
                if(!ldcset.contains(acinfo.accountID)){
                    ldcset.add(acinfo.accountID);
                }
                if(!cntset.contains(acinfo.ContractID)){
                    cntset.add(acinfo.ContractID);
                }
            }
        }
        
        map<string,map<string,string>> cldcmap = new map<string,map<string,string>>();
        list<ldc_account__c> ldclst = [select id,name,ldc_account_number__c,Last_LS_Response__c,LodeStar_Response__c,Lodestar_History__c from ldc_account__c where Ldc_account_number__c IN : ldcset];
        map<string,ldc_account__c> ldcmap = new map<string,ldc_account__c>();
        
        /*********************** DECODING THE EXISTING MESSAGE  ********************************/
        map<string,list<string>> ldclsmsg = new map<string,list<string>>();
        for(ldc_account__c ldc : Ldclst){
            ldcmap.put(ldc.ldc_account_number__c,ldc);
            if(ldc.LodeStar_Response__c != null){
            	list<string> parseStr = new list<string>();
            	list<string> strlst = ldc.LodeStar_Response__c.split('</tr>');
            	for(Integer i=0;i<strlst.size();i++){
            		system.debug('SPLIT ROW : '+strlst[i]);
            		if(i == 0){
				        list<string> innerstr = strlst[0].split('</th>');
				        string s1='';
				        for(string is : innerstr)
				            s1+=is+'@';
				        system.debug('First row : '+s1.stripHtmlTags());
				        s1=s1.stripHtmlTags();
				        parseStr.add(s1);
				    }
				    else if(i != 0 && i < strlst.size()-1){
				        list<string> innerstr = strlst[i].split('</td>');
				        string s1='';
				        for(integer j=0;j<innerstr.size();j++){
				        	s1+=innerstr[j];
				        	if(j != innerstr.size()-1)
				        		s1+='@';
				        	if(innerstr[j].contains('SUCCESS')){
				        		s1 = s1.substringBeforeLast('@');
			            		break;
				        	}
				        }
				        system.debug('Remaining Middle rows : '+s1.stripHtmlTags());
				        s1=s1.stripHtmlTags();
				        parseStr.add(s1);
				    }
				    else{
				    	system.debug('Last row : '+strlst[i]);
				    }
            	}
            	ldclsmsg.put(ldc.ldc_account_number__c,parseStr);
            }
            else
            	ldclsmsg.put(ldc.ldc_account_number__c,new list<string>());
        }
        system.debug('LDCLode* MSG : '+ldclsmsg.size()+' : '+ldclsmsg);
        
        /*********************** PREPARING TO READ THE RESPONSE  ********************************/
        if(lsreq != null && lsreq.account_info != null){
            string msg = '';
            string uniqueTr ='';
            for(AccountInfo acinfo : lsreq.account_info){
            	
            	uniqueTr = acinfo.UniqueTimer+'@'+acinfo.contractID;
            	msg = acinfo.UniqueTimer+'@<i>'+acinfo.contractID+'</i>@';
            	system.debug('Test : '+uniqueTr+' <==> '+msg);
                if(string.isBlank(acinfo.ErrorMessage) || acinfo.ErrorMessage == null || acinfo.ErrorMessage == 'DONE')
                    msg+='<font color="green">SUCCESS</font>@';
                else
                    msg+='<font color="red">ERROR</font>@'+acinfo.errormessage;
                
                /*********************** GATHERING FOR Contract LDC  ********************************/
                map<string,string> tempcntmap;
                string resstr='';
                if(cldcmap.containskey(acinfo.accountID)){
                	tempcntmap = cldcmap.get(acinfo.accountID);
                	if(!tempcntmap.containskey(acinfo.contractID)){
                		resstr = (string.isBlank(acinfo.ErrorMessage) || acinfo.ErrorMessage == null || acinfo.ErrorMessage == 'DONE') ? 'SUCCESS' : 'ERROR' ;
                		tempcntmap.put(acinfo.contractID,resstr);
                	}
                }
                else{
                	tempcntmap = new map<string,string>();
                	resstr = (string.isBlank(acinfo.ErrorMessage) || acinfo.ErrorMessage == null || acinfo.ErrorMessage == 'DONE') ? 'SUCCESS' : 'ERROR' ;
                	tempcntmap.put(acinfo.contractID,resstr);
                }
                cldcmap.put(acinfo.accountID,tempcntmap);
                
                /*********************** PUSHING OLD MESSAGE TO HISTORY  ********************************/    
                if(ldcmap.containskey(acinfo.accountID) && ldclsmsg.containskey(acinfo.accountID)){
                	ldc_account__c ldc = ldcmap.get(acinfo.accountID);
                	list<string> strlst = ldclsmsg.get(acinfo.accountID);
                	boolean dupFound = false;
                	for(integer i=strlst.size()-1; i >=0 ; --i){
                		system.debug('STR Loop : '+strlst[i]);
                		if(!strlst[i].contains(uniqueTr)){
	                		string hisstr = '';
	                		if(strlst[i].contains(acinfo.contractID)){
	                			dupFound = false;
	                			hisstr = strlst[i].stripHtmlTags()+'\n';
	                			hisstr = hisstr.replace('@','-->');
	                			if(ldc.Lodestar_History__c != Null)
	                				ldc.Lodestar_History__c = hisstr+ldc.Lodestar_History__c;
	                			else
	                				ldc.Lodestar_History__c = hisstr;
	                			strlst.remove(i);
	                		}
                		}
                		else{
                			dupFound = true;
                			break;
                		}
                	}
                	if(!dupFound){
                		if(strlst.size() == 0)
                			strlst.add('Response Time@Contract@Message@Error Description');
                		strlst.add(msg);
                	}
                	ldc.LodeStar_Response__c ='';
                	system.debug('STR Before LodeStar_Response__c : '+ldc.LodeStar_Response__c);
                	
                	/*********************** FORMATTING THE MESSAGE  ********************************/
                	for(Integer i=0; i<strlst.size();i++){
                		system.debug('Current Str : '+strlst[i]);
                		string str='';
                		string s = strlst[i];
                		system.debug('Str--------- : '+s);
                		list<string> innerstr = s.split('@');
                		system.debug('Inner Str : '+innerstr.size()+' : '+innerstr);
            			if(i == 0){
            				str = '<table border="1"><tr>';
            				str+='<th>'+innerstr[0]+'</th><th>'+innerstr[1]+'</th><th>'+innerstr[2]+'</th><th>'+innerstr[3]+'</th></tr>';
            			}
            			else if(i != 0 && i < strlst.size()){
            				str='<tr><td>'+innerstr[0]+'</td><td>'+innerstr[1]+'</td>';
            				system.debug('innerstr[2]'+innerstr[2]);
            				if(!innerstr[2].contains('SUCCESS'))
            					str+='<td><font color="red">'+innerstr[2]+'</font></td><td>'+innerstr[3]+'</td></tr>';
        					else
        						str+='<td><font color="green">'+innerstr[2]+'</font></td><td></td></tr>';
            			}
                		if(i == strlst.size())
                			str+='</table>';
                		ldc.LodeStar_Response__c+= str;
                	}
                	system.debug('STR After LodeStar_Response__c : '+ldc.LodeStar_Response__c);
                	system.debug('STR Lodestar_History__c : '+ldc.Lodestar_History__c);
                	ldcmap.put(acinfo.accountID,ldc);
                	ldc.Last_LS_Response__c=system.now();
                }
            }
        }
        
        ldclst = new list<ldc_account__c>();
        for(string str : ldcmap.keyset()){
            ldclst.add(ldcmap.get(str));
        }
        
        list<contract_ldc__c> cldclst = new list<contract_ldc__c>();
        for(contract_ldc__c cldc : [select id,LS_Response_Message__c,ldc_account__r.ldc_account_number__c,contract__r.contractnumber from contract_ldc__c 
        								where ldc_account__r.ldc_account_number__c IN : ldcset and contract__r.contractnumber IN : cntset]){
			system.debug('LDC : '+cldc.ldc_account__r.ldc_account_number__c+' CONTRACT : '+cldc.contract__r.contractnumber);
			if(cldcmap.containskey(cldc.ldc_account__r.ldc_account_number__c)){
				map<string,string> tempcntmap = cldcmap.get(cldc.ldc_account__r.ldc_account_number__c);
				system.debug('CLDC INNER MAP :'+tempcntmap);
				if(tempcntmap.containskey(cldc.contract__r.contractnumber)){
					cldc.LS_Response_Message__c = tempcntmap.get(cldc.contract__r.contractnumber);
					cldclst.add(cldc);
					system.debug('CLDC MSG :'+cldc.LS_Response_Message__c);
				}
			}
		}
		try{
            List<String> errList = new List<String>();
            if(!ldclst.isempty()){
            	TriggerHandler.LSresponse = false;
                Database.SaveResult[] srLDCList = database.update(ldclst, false);
                errList.addAll(IntegrationUtil.collectErrors(srLDCList));
            }
            
            if(!cldclst.isempty()){
            	TriggerHandler.LSresponse = false;
                Database.SaveResult[] srLDCList = database.update(cldclst, false);
                errList.addAll(IntegrationUtil.collectErrors(srLDCList));
            }
            
            res.status= errList != null && !errList.isEmpty() ? ConstantUtility.STATUS_Failure : ConstantUtility.STATUS_SUCCESS;
            res.MessageDesc = errList != null && !errList.isEmpty() ? 'Response Failed:' : 'Response Processed Successfully:'; 
            res.MessageDesc += errList;
        }
        catch(Exception e){
            res.status=ConstantUtility.STATUS_Failure;
            res.MessageDesc = 'Exception'+e.getMessage();
        }
        return res;
    }
    
}