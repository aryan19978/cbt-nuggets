public class GlobalDeleteController {
 
    @AuraEnabled(cacheable=true)
    public static List<GlobalDeleteWrapperClass> fetchWrapperData(){
        List<GlobalDeleteWrapperClass> wrapperList = new List<GlobalDeleteWrapperClass>();
        for(Account acc : [SELECT Id, Name FROM Account WHERE Name != '' LIMIT 100]){
            wrapperList.add(new GlobalDeleteWrapperClass(acc.name));
        }
        return wrapperList;
    }
 
    public class GlobalDeleteWrapperClass{
        @AuraEnabled
        public String name;
        
        public GlobalDeleteWrapperClass(String name){
            this.name = name;
        }
    }
}