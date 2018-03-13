@RestResource(urlMapping='/services/data/v41.0/limits/*')  
global with sharing class getservice3
{      
     @HttpGet    
     global static String getRestMethod()     
     {          
          System.debug('Response returened');
          return 'Hi, You have invoked getservice1 created using Apex Rest and exposed using REST API';        
     }
}