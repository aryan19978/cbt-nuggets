public with sharing class updatePrimaryContact implements Database.Batchable<Sobject> {

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id, (SELECT Id FROM Contacts) FROM Account]);
    }

    public void execute(Database.BatchableContext context, List<Account> scope) {

        Map<Id, Integer> accountContactCountMap = new Map<Id, Integer>();

        for (Account acc : scope) {
            accountContactCountMap.put(acc.Id, acc.Contacts.size());
        }

        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : scope) {
            if (accountContactCountMap.containsKey(acc.Id) && accountContactCountMap.get(acc.Id) == 1) {
                accountsToUpdate.add(acc);
            }
        }

        list<contact> contacts = [select id,primary_contact__c from contact where accountid IN :accountsToUpdate AND primary_contact__c = false];

        for(contact con :contacts)
        {
            con.primary_contact__c = true;
        }
        update contacts;
    }

    public void finish(Database.BatchableContext context) {
        // Optional: Add any post-processing logic here
    }
}