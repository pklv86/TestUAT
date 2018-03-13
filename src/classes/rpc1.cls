public with sharing class rpc1 {

    // Return a list of data points for a chart
    /*public set<string> getData (){
        Map<string,List<Data>> mData = getObjData();
        oData = new Map<string,List<Data>>();
        oData.putAll(mData);
        system.debug('Map Size : '+oData.size());
        set<string> tempD = new set<string>();
        Data1 = new set<string>();
        Data2 = new set<string>();
        Data3 = new set<string>();
        //tempD = mData.keyset();
        list<string> strlst = new list<string>();
        for(string s : mData.keyset()){
            strlst.add(s);
        }
        system.debug('set size : '+strlst.size());
        for(integer i=0; i< strlst.size(); ){
            system.debug('I1 location : '+i);
            tempD.add(strlst[i]);
            i++;
            if(i<strlst.size()){
                system.debug('I2 location : '+i);
                Data2.add(strlst[i]);
                i++;
            }
            if(i<strlst.size()){
                system.debug('I3 location : '+i);
                Data3.add(strlst[i]);
                system.debug('I4 location : '+i);
                i++;
            }
        }
        Data1.addAll(tempD);
        system.debug('Set Size : '+tempD.size());
        return tempD;
    }*/
    
    public Map<string,List<Data>> oData {get;set;}
    public set<string> Data1 {get;set;}
    public set<string> Data2 {get;set;}
    public set<string> Data3 {get;set;}
    public boolean showpb {get;set;}
    
    public Map<string,List<Data>> ObjData() {
        Map<String, Schema.SObjectType> gd =Schema.getGlobalDescribe();
        system.debug('SObject Map : '+gd);
        list<string> sobjlst = new list<string>();
        for(Schema.SObjectType sobj : gd.values()){
            if(sobj.getDescribe().getName().contains('__c') && !sobj.getDescribe().getName().contains('Conga') && !sobj.getDescribe().getName().contains('Grid') && sobj.getDescribe().isCustomSetting()==false){
                system.debug('Custom Object : '+sobj);
                sobjlst.add(sobj.getDescribe().getName());
            }
        }
        
        string stdobj= 'Lead;Case;Account;Opportunity;Contract;Contact;Task';
        list<string> stdlst = stdobj.split(';');
        system.debug('stdobj : '+stdlst);
        sobjlst.addAll(stdlst);
        sobjlst.sort();
        string createfilter='';
        if(showpb)
            createfilter='LAST_N_MONTHS:12';
        else
            createfilter='LAST_N_DAYS:30';
        system.debug('showpb : '+showpb+' createfilter : '+createfilter);
        Map<string,List<Data>> oD = new Map<string,List<Data>>();
        for(string s : sobjlst){
            list<data> dlst = new list<data>();
            system.debug('Selected obj : '+s);
            if(showpb){
                for(AggregateResult result : Database.query('SELECT COUNT(Id),calendar_year(createddate),calendar_month(createddate) FROM '+s+' where createddate = '+createfilter+' group by calendar_year(createddate),calendar_month(createddate) order by calendar_year(createddate),calendar_month(createddate)')){
                    System.debug('No of records are: '+result);
                    //cData = new Data();
                    string Mth = (dateTime.newInstance(Integer.valueof(result.get('Expr1')),Integer.valueof(result.get('Expr2')),1)).format('MMMM');
                    string mName = string.valueof(result.get('Expr1'))+'_'+Mth;
                    Integer recCount = Integer.valueof(result.get('Expr0'));
                    Integer Year = Integer.valueof(result.get('Expr1'));
                    String Month = Mth;
                    system.debug('mName : '+mName +' recCount : '+recCount+' Year : '+Year+' Month : '+Month);  
                    dlst.add(new Data(mName,recCount,Year,Month));
                }
            }
            else{
                for(AggregateResult result : Database.query('SELECT COUNT(Id),calendar_month(createddate),DAY_IN_MONTH(createddate) FROM '+s+' where createddate = '+createfilter+' group by calendar_month(createddate),DAY_IN_MONTH(createddate) order by calendar_month(createddate),DAY_IN_MONTH(createddate)')){
                    System.debug('No of records are: '+result);
                    //cData = new Data();
                    string Mth = (dateTime.newInstance(Date.today().year(),Integer.valueof(result.get('Expr1')),1)).format('MMMM');
                    string mName = Mth+'_'+string.valueof(result.get('Expr2'));
                    Integer recCount = Integer.valueof(result.get('Expr0'));
                    Integer Year = Integer.valueof(result.get('Expr1'));
                    String Month = String.valueof(result.get('Expr2'));
                    system.debug('mName : '+mName +' recCount : '+recCount+' Year : '+Year+' Month : '+Month);                    
                    dlst.add(new Data(mName,recCount,Year,Month));
                }
            }
            if(!dlst.isempty())
                oD.put(s,dlst);
        }
        
        list<string> strlst = new list<string>();
        for(string s : oD.keyset()){
            strlst.add(s);
        }
        system.debug('set size : '+strlst.size());
        for(integer i=0; i< strlst.size(); ){
            Data1.add(strlst[i]);
            i++;
            if(i<strlst.size()){
                Data2.add(strlst[i]);
                i++;
            }
            if(i<strlst.size()){
                Data3.add(strlst[i]);
                i++;
            }
        }
        return oD;
    }
    
    public rpc1(){
        showpb = true;
        oData = new Map<string,List<Data>>(); 
        Data1 = new set<string>();
        Data2 = new set<string>();
        Data3 = new set<string>();
        oData =  ObjData();       
    }
    
    public void switchToDaily(){
        showpb = false;
        oData.clear();
        Data1.clear();
        Data2.clear();
        Data3.clear();
        oData =  ObjData();
    }
    
    // Wrapper class
    public class Data {
        public String name { get; set; }
        public Integer recCount { get; set; }
        public Integer Year { get; set; }
        public String Month { get; set; }
        public Data(){}
        public Data(String name, Integer recCount, Integer Year, string Month) {
            this.name = name;
            this.recCount = recCount;
            this.Year = Year;
            this.Month = Month;
        }
    }
    
    /*public class OData {
        public String name { get; set; }
        public list<data> datalst { get; set; }
        public OData(){
            
        }
        public OData(String name, list<data> datalst){
            this.name = name;
            this.datalst = datalst;
        }
    }*/
}