public class UpdatePrimaryContactBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, AccountId, Primary_Contact__c  FROM Contact WHERE accountid !=NULL and  Primary_Contact__c = false GROUP BY Id, AccountId, Primary_Contact__c HAVING COUNT(Id) = 1 LIMIT 2000';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Contact> scope) {
        try{
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for (Contact contact : scope) {
            contact.Primary_Contact__c = true;
            contactsToUpdate.add(contact);
        }
        
        update contactsToUpdate;
    }
    catch(exception ex){

    }
}
        public void finish(Database.BatchableContext context) {
            // Optional: Add any post-processing logic here
        }
}