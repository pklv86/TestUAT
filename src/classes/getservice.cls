public class getservice
{
    //public String myresponse{get;set;}
    public map<String, Object> Result(){
        map<String, Object> dataStorage = new map<String, Object>();
        try{
            //String sid = login('prasad.paladugu@dynegy.com.uat', 'Qazwsx!218uidvIGuUHIAZEC7ncb5xDlX');
            string sid = UserInfo.getSessionId();
            system.debug('\n Session : '+sid);
            
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setMethod('GET');
            
            //req.setHeader('content-type', 'text/html');
            //req.setHeader('Content-Length','1024');
            req.setTimeout(120000);
            String url = system.URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v41.0/limits';
            //'https://dynegy--uat.cs64.my.salesforce.com/services/apexrest/GetService'
            system.debug('Response URL'  +url);  
            
            req.setEndpoint(url); 
            req.setHeader('Authorization', 'OAuth '+ sid);
            /*Opportunity Op=[select id,Name,Stagename,Account.Name from opportunity limit 1];
            system.debug('without pretty'+JSON.serialize(Op));
            String JsonString=JSON.serialize(Op);
            req.setBody(JsonString);*/
            HTTPResponse resp = http.send(req);
            /*myresponse=resp.getBody();  
            system.debug('Response body'  +myresponse); 
            system.debug('STATUS: '+ resp.getStatus());
            system.debug('STATUS_CODE:'+ resp.getStatusCode());   */
            
            Map<String, Object> m = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
            dataStorage = (Map<String,Object>)m.get('DataStorageMB');
            System.debug('Current Storage: ' + dataStorage.get('Remaining'));
        }
        catch(System.CalloutException e){
            System.debug('Sorry, You have an error :: ' + e.getMessage());
        }
        return dataStorage;
    }
    
    /*private static final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String NS_SF = 'urn:partner.soap.sforce.com';

    public static String login(String user, String password)
    {
        // As per http://wiki.developerforce.com/page/Enterprise_Login
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');   
        req.setTimeout(60000);
        req.setEndpoint('https://dynegy--uat.cs64.my.salesforce.com/services/Soap/u/41.0');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');        
        req.setHeader('SOAPAction', '""');
        req.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' +user+ '</username><password>' + password + '</password></login></Body></Envelope>');        
        HttpResponse res =  new Http().send(req);
        if(res.getStatusCode() != 200)
        {
            Dom.Document responseDocument = res.getBodyDocument();
            Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
            Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body 
            Dom.Xmlnode faultElm = bodyElm.getChildElement('Fault', NS_SOAP); // soapenv:Fault
            Dom.Xmlnode faultStringElm = faultElm.getChildElement('faultstring', null); // faultstring          
            throw new LoginException(faultStringElm.getText()); 
        }
        // As per http://wiki.developerforce.com/page/Enterprise_Login
        Dom.Document responseDocument = res.getBodyDocument();
        Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
        Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body 
        Dom.Xmlnode loginResponseElm = bodyElm.getChildElement('loginResponse', NS_SF); // loginResponse
        Dom.Xmlnode resultElm = loginResponseElm.getChildElement('result', NS_SF); // result
        Dom.Xmlnode sessionIdElm = resultElm.getChildElement('sessionId', NS_SF); // sessionId
        system.debug('\n sessionIdElm : '+sessionIdElm.getText());
        return sessionIdElm.getText();
    }
    
    public class LoginException extends Exception {}*/

}