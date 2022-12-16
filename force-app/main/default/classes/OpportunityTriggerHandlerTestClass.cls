@isTest
public class OpportunityTriggerHandlerTestClass {
    
    @testSetup
    public static void testData()
        {
            Account acc = new Account();
            acc.Name = 'Test';
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.CloseDate = date.today();
            opp.StageName = 'New';
            opp.Name = 'test';
            insert opp;
            
            ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            content.origin = 'H';
            insert content;
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=opp.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
        	insert contentlink;
        }
    
    @istest
    public static void main()
    {
        Test.startTest();
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        update opp;
        Test.stopTest();
    }

}