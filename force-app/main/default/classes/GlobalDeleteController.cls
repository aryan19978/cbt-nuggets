public class GlobalDeleteController {
    
    @AuraEnabled(cacheable=true)
    public static List<GlobalDeleteWrapperClass> fetchWrapperData(){
        List<GlobalDeleteWrapperClass> wrapperList = new List<GlobalDeleteWrapperClass>();
        for(Account acc : [SELECT Id, Name FROM Account WHERE Name != '' LIMIT 10]){
            wrapperList.add(new GlobalDeleteWrapperClass(acc.id,acc.name,'Account'));
        }
        for(Contact con : [SELECT Id, Name FROM Contact WHERE Name != '' LIMIT 10]){
            wrapperList.add(new GlobalDeleteWrapperClass(con.id,con.name,'Contact'));
        }
        for(Opportunity opp : [SELECT Id, Name FROM Opportunity WHERE Name = 'Demo Raj Account - Opp - 00203' LIMIT 10]){
            wrapperList.add(new GlobalDeleteWrapperClass(opp.id,opp.name,'Opportunity'));
        }
        return wrapperList;
    }
    
    @AuraEnabled
    public static List<GlobalDeleteWrapperClass> deleteSelectedRows(List<String> recIdList){
        system.debug(recIdList);
        list<sObject> lstDeleteRecords = new list<sObject>();
        for(sObject acc : [SELECT Id, Name FROM Account WHERE id in: recIdList]){
            lstDeleteRecords.add(acc);
        }
        for(sObject con : [SELECT Id, Name FROM Contact WHERE id in: recIdList]){
            lstDeleteRecords.add(con);
        }
        for(sObject opp : [SELECT Id, Name FROM Opportunity WHERE id in: recIdList]){
            lstDeleteRecords.add(opp);
        }
        system.debug(lstDeleteRecords.size());
        //lstDeleteRecords.sort();
        
        if(lstDeleteRecords.size()>0){
            try{
                system.debug(lstDeleteRecords);
                delete lstDeleteRecords;        
            }
            catch (Exception exp) {
                throw new AuraHandledException(exp.getMessage());
            }
        }
        return fetchWrapperData();
    }
    
    public class GlobalDeleteWrapperClass{
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String objType;
        
        public GlobalDeleteWrapperClass(String id,String name,String objType){
            this.id = id;
            this.name = name;
            this.objType = objType;
        }
    }
}