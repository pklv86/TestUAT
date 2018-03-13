@RestResource(urlMapping='/GetService/*')  
global with sharing class getservice1
{      
     @HttpPost    
     global static String postRestMethod()     
     {          
          System.debug('Response returened');
          return 'Hi, You have invoked getservice1 created using Apex Rest and exposed using REST API';        
     }
}