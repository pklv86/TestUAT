/* 
 * Name: FRMDeleter
 * Type: Apex Class
 * Test Class: FRMReportTest
 * Description:  This batch job is to remove the records going to ENDUR/TMF. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Prasad Paladugu         05/30/2017       1. Initial Version created
 * 2.0         Prasad Paladugu         07/22/2017       1. Updated the functionality to not remove from SF but only on report
 * 3.0         Prasad Paladugu         08/01/2017       1. Added new process to report missing records from previous
 * 4.0         Prasad Paladugu         12/10/2017       1. Upgrade the process for notifying through mail
 														2. Added label for list of mailers
 */
global class FRMDeleter implements system.schedulable,Database.Batchable<sObject> {
    
    public FRMDeleter(){
        
    }
    
    global void execute(SchedulableContext SC){
        
        FRMDeleter frmdel = new FRMDeleter();
        Database.executeBatch(frmdel,2000);
        
    }
    
    global Database.QueryLocator Start(Database.BatchableContext bc){
        Datetime dt =system.now().addhours(-2);
        string frmQuery = 'select id From frm_report__c where lastmodifieddate != today';//< :dt
        system.debug('Query : '+frmQuery);
        return Database.getQueryLocator(frmQuery);
    }
    
    global void execute(Database.BatchableContext bc,list<sObject> scope){ 
        list<frm_report__c> frmlst = (list<frm_report__c>)scope;
        for(frm_report__c frm : frmlst){
            frm.Reconcile__c = true;
        }
        update frmlst;
        //delete frmlst;
    }
    
     global void finish(Database.BatchableContext bc){
        
        string res='<table border="1"><tr><th>Id</th><th>Name</th><th>Contract</th><th>Customer</th><th></th></tr><br/>';
        for(FRM_Report__History frmh : [SELECT CreatedDate,Field,Id,NewValue,OldValue,ParentId,Parent.Name,Parent.Contr_Agree_Num__c,Parent.Cust_Name__c 
                                            FROM FRM_Report__History WHERE Field = 'Reconcile__c' AND CreatedDate = Yesterday and Parent.Reconcile__c = true]){
            res+='<tr><td>'+frmh.parentid+'</td><td>'+frmh.parent.name+'</td><td>'+frmh.Parent.Contr_Agree_Num__c+'</td><td>'+frmh.Parent.Cust_Name__c+'</td></tr><br/>';                                       
        }
        res+='</table>';
        string mailerslst = label.Team_Mail;
        list<string> mailerstr = mailerslst.split(';');
        list<user> usr = [select id,name,email from user where name IN : mailerstr];
        list<string> mailers = new list<string>();
        for(User U : Usr){
            mailers.add(u.email);
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(mailers);
        mail.setSubject('TMF Reconcile Report for '+system.now().format('dd-MMM yyyy'));
        //mail.setTargetObjectId(userinfo.getuserid());
        mail.setsaveAsActivity(false); 
        mail.setHtmlBody('The FRM Reconcile Report is Updated with following and we will be removed from original report \n<br/>'+res+'<br/> ');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });           
     }
}