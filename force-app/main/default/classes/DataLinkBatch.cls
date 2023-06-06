public class DataLinkBatch implements Database.Batchable<sObject> {
    
    private Integer batchSize;
    
    public DataLinkBatch(Integer batchSize) {
        this.batchSize = batchSize;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Old_Account_Id__c FROM Contact WHERE Old_Account_Id__c != null AND AccountId = NULL';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Contact> contacts) {
        try{
        Map<String, Id> accountIdsMap = new Map<String, Id>();
        
        for (Contact contact : contacts) {
            accountIdsMap.put(contact.Old_Account_Id__c, null);
        }
        
        List<Account> accounts = [SELECT Id, Old_Account_Id__c FROM Account WHERE Old_Account_Id__c IN :accountIdsMap.keySet()];
        
        for (Account account : accounts) {
            accountIdsMap.put(account.Old_Account_Id__c, account.Id);
        }
        
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for (Contact contact : contacts) {
            if (accountIdsMap.containsKey(contact.Old_Account_Id__c)) {
                contact.AccountId = accountIdsMap.get(contact.Old_Account_Id__c);
                contactsToUpdate.add(contact);
            }
        }
        
        database.update(contactsToUpdate,false);
    }
    catch(exception  ex){

    }
    }
    
    public void finish(Database.BatchableContext context) {
        // Perform any post-processing operations if needed
    }
}