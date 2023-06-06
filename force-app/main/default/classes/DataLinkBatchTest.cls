@IsTest
    public class DataLinkBatchTest {
        
        @IsTest
        public static void testDataLinkBatch() {
            // Create test Account
            Account testAccount = new Account();
            testAccount.Name = 'Test Account';
            testAccount.Old_Account_Id__c = 'A001';
            insert testAccount;
            
            // Create test Contacts
            Contact testContact1 = new Contact();
            testContact1.FirstName = 'John';
            testContact1.LastName = 'Doe';
            testContact1.Old_Account_Id__c = 'A001';
            insert testContact1;
            
            Contact testContact2 = new Contact();
            testContact2.FirstName = 'Jane';
            testContact2.LastName = 'Smith';
            testContact2.Old_Account_Id__c = 'A002';  // Contact with different Old_Account_Id__c
            insert testContact2;
            
            // Start the batch
            Test.startTest();
            DataLinkBatch batch = new DataLinkBatch(200); // Pass the desired limit
            Database.executeBatch(batch);
            Test.stopTest();
            
            // Verify that the Account is linked to the Contact
            Contact updatedContact1 = [SELECT Id, AccountId FROM Contact WHERE Id = :testContact1.Id];
            System.assertEquals(testAccount.Id, updatedContact1.AccountId, 'Account should be linked to the Contact.');
            
            // Verify that the Contact with different Old_Account_Id__c is not linked
            Contact updatedContact2 = [SELECT Id, AccountId FROM Contact WHERE Id = :testContact2.Id];
            System.assertEquals(null, updatedContact2.AccountId, 'Contact with different Old_Account_Id__c should not be linked to any Account.');
        }
    }