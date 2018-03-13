public class ReportController{

    public Map<string,List<Data>> oData {get;set;}
    public List<pData> pieData {get;set;}
    public list<sData> StorageData {get;Set;}
    public set<string> Data1 {get;set;}
    public set<string> Data2 {get;set;}
    public set<string> Data3 {get;set;}
    public boolean showpb {get;set;}
    public double UsedStorage {get;Set;}
    public string MaxLimit {get;Set;}
    public string UsedLimit {get;Set;}
    public string RemLimit {get;Set;}
    public string PerLimit {get;Set;}
    public Organization org {get;set;}
    
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
        
        string stdobj= Label.Standard_Storage_Objects;
        list<string> stdlst = stdobj.split(';');
        system.debug('stdobj : '+stdlst);
        sobjlst.addAll(stdlst);
        sobjlst.sort();
        
        string createfilter='';
        Date filterdate;
        if(showpb){
            createfilter='LAST_N_MONTHS:12';
            filterdate = date.today().addyears(-1).adddays(1);
        }
        else{
            createfilter='LAST_N_DAYS:30';
            filterdate = date.today().adddays(-30);
        }
        system.debug('showpb : '+showpb+' createfilter : '+createfilter+' filterdate : '+filterdate);
        
        Map<string,List<Data>> oD = new Map<string,List<Data>>();
        map<string,double> sMap = new map<string,double>();
        Double d=0.0;
        pieData = new list<pdata>();
        storageData = new list<sdata>();
        for(string s : sobjlst){
            list<data> dlst = new list<data>();
            system.debug('Selected obj : '+s);
            Integer rCount =0;
            if(showpb){
                for(AggregateResult result : Database.query('SELECT COUNT(Id),calendar_year(createddate),calendar_month(createddate) FROM '+s+' where createddate >= : filterdate group by calendar_year(createddate),calendar_month(createddate) order by calendar_year(createddate),calendar_month(createddate)')){
                    System.debug('No of records are: '+result);
                    //cData = new Data();
                    string Mth = (dateTime.newInstance(Integer.valueof(result.get('Expr1')),Integer.valueof(result.get('Expr2')),1)).format('MMMM');
                    string mName = string.valueof(result.get('Expr1'))+'_'+Mth;
                    Integer recCount = Integer.valueof(result.get('Expr0'));
                    Integer Year = Integer.valueof(result.get('Expr1'));
                    String Month = Mth;
                    system.debug('mName : '+mName +' recCount : '+recCount+' Year : '+Year+' Month : '+Month);  
                    dlst.add(new Data(mName,recCount,Year,Month));
                    rCount+=recCount;
                    
                    if(sMap.containskey(mName)){
                        d=sMap.get(mName)+((Double.valueof(recCount)*2)/(1024*1024));
                        sMap.put(mName,d);
                    }
                    else{
                        d= (Double.valueof(recCount)*2)/(1024*1024);
                        sMap.put(mName,d);
                    }
                }
            }
            else{
                for(AggregateResult result : Database.query('SELECT COUNT(Id),calendar_month(createddate),DAY_IN_MONTH(createddate) FROM '+s+' where createddate >= : filterdate group by calendar_month(createddate),DAY_IN_MONTH(createddate) order by calendar_month(createddate),DAY_IN_MONTH(createddate)')){
                    System.debug('No of records are: '+result);
                    //cData = new Data();
                    string Mth = (dateTime.newInstance(Date.today().year(),Integer.valueof(result.get('Expr1')),1)).format('MMMM');
                    string mName = Mth+'_'+string.valueof(result.get('Expr2'));
                    Integer recCount = Integer.valueof(result.get('Expr0'));
                    Integer Year = Integer.valueof(result.get('Expr1'));
                    String Month = String.valueof(result.get('Expr2'));
                    system.debug('mName : '+mName +' recCount : '+recCount+' Year : '+Year+' Month : '+Month);                    
                    dlst.add(new Data(mName,recCount,Year,Month));
                    rCount+=recCount;
                    
                    if(sMap.containskey(mName)){
                        d=sMap.get(mName)+((Double.valueof(recCount)*2)/(1024*1024));
                        sMap.put(mName,d);
                    }
                    else{
                        d= (Double.valueof(recCount)*2)/(1024*1024);
                        sMap.put(mName,d);
                    }
                }
            }
            if(!dlst.isempty()){
                oD.put(s,dlst);
                pieData.add(new PData(s,rCount));
            }
        }
        
        double totald =0.0;
        list<string> datalst = new list<string>();
        for(string st : sMap.keyset()){
            system.debug('Data Map :'+st+' : '+sMap.get(st));
            totald+=sMap.get(st);
            //datalst.add(st);
        }
        //datalst.sort();
        
        
 
        if(showpb){
            date dd = system.today().addMonths(-13);
            datetime dt = dateTime.newInstance(dd.year(),dd.month(),dd.day());
            string Mth = dt.format('yyyy')+'_'+dt.format('MMMM');
            system.debug('Mth : '+Mth);
            dd = dd.addMonths(1);
            storageData.add(new sData(Mth,(UsedStorage-totald)));
            system.debug('date : '+dd);
            for(Integer i=-12;i<=0;i++){
                dt = dateTime.newInstance(dd.year(),dd.month(),dd.day());
                Mth = dt.format('yyyy')+'_'+dt.format('MMMM');
                system.debug('Mth : '+Mth);
                dd = dd.addMonths(1);
                datalst.add(Mth);
            }
        }
        else{
            date dd = system.today().adddays(-31);
            datetime dt = dateTime.newInstance(dd.year(),dd.month(),dd.day());
            string Mth = dt.format('MMMM')+'_'+dt.format('d');
            system.debug('Mth : '+Mth);
            dd = dd.adddays(1);
            storageData.add(new sData(Mth,(UsedStorage-totald)));
            system.debug('date : '+dd);
            for(Integer i=-30;i<=0;i++){
                dt = dateTime.newInstance(dd.year(),dd.month(),dd.day());
                Mth = dt.format('MMMM')+'_'+dt.format('d');
                system.debug('Mth : '+Mth);
                dd = dd.adddays(1);
                datalst.add(Mth);
            }
        }
        system.debug('List : '+datalst);
        totald = UsedStorage-totald;

        for(string st : datalst){
            totald+= smap.get(st)!=null ? smap.get(st) : 0.0 ;
            storageData.add(new sData(st,totald));
            system.debug('Data Map 2 :'+st+' : '+totald);
        }
        system.debug('List : '+storageData);
        
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
    
    public ReportController(){
        showpb = false;
        oData = new Map<string,List<Data>>(); 
        Data1 = new set<string>();
        Data2 = new set<string>();
        Data3 = new set<string>();
        datausage();       
        oData =  ObjData();
    }
    
    public void switchToDaily(){
        showpb = false;
        oData.clear();
        Data1.clear();
        Data2.clear();
        Data3.clear();
        datausage();
        oData =  ObjData();
    }
    
    public void switchToYearly(){
        showpb = true;
        oData.clear();
        Data1.clear();
        Data2.clear();
        Data3.clear();
        datausage();
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
    
    public class PData {
        public String name { get; set; }
        public Integer recCount { get; set; }
        public PData(){}
        public PData(String name, Integer recCount) {
            this.name = name;
            this.recCount = recCount;
        }
    }
    
    public class SData {
        public String name { get; set; }
        public Double recCount { get; set; }
        public SData (){}
        public SData (String name, Double recCount) {
            this.name = name;
            this.recCount = recCount;
        }
    }
    
    public void datausage(){
        Map<String, Object> dataMap = new Map<String, Object>();
        getservice g = new getservice();
        dataMap = g.result();
        system.debug('DataMap : '+dataMap);
        UserLicense ul = [SELECT Id,MasterLabel,Name,Status,TotalLicenses,UsedLicenses,UsedLicensesLastUpdated FROM UserLicense WHERE Name = 'Salesforce'];
        Double dataMaxlimit = (Double.valueof(dataMap.get('Max'))-(20*ul.TotalLicenses))/1024;
        Maxlimit = string.valueof(decimal.valueof(dataMaxlimit).setscale(4))+' GB';
        system.debug('Data limit : '+dataMaxlimit+' : '+maxlimit);
        dataMaxlimit = (Double.valueof(dataMap.get('Max'))-Double.valueof(dataMap.get('Remaining'))-(20*ul.TotalLicenses))/1024;
        UsedStorage = decimal.valueof(dataMaxlimit).setscale(6);
        Usedlimit = string.valueof(decimal.valueof(dataMaxlimit).setscale(4))+' GB';
        system.debug('Data limit : '+dataMaxlimit+' : '+Usedlimit);
        dataMaxlimit = Double.valueof(dataMap.get('Remaining'))/1024;
        Remlimit = string.valueof(decimal.valueof(dataMaxlimit).setscale(4))+' GB';
        system.debug('Data limit : '+dataMaxlimit+' : '+Remlimit);
        dataMaxlimit = ((Double.valueof(dataMap.get('Max'))-Double.valueof(dataMap.get('Remaining')))/Double.valueof(dataMap.get('Max')))*100;
        perlimit = string.valueof(decimal.valueof(dataMaxlimit).setscale(4))+'%';
        system.debug('Data limit : '+dataMaxlimit+' : '+perlimit);
        
        org= new Organization();
        org=[SELECT Id,InstanceName,IsSandbox,Name,OrganizationType FROM Organization];
       // return null;
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