@isTest
private class CreateLeadFromEmailTest {
    static testMethod void validateCreateLeadFromEmail() {
        Test.startTest();
        lead lrec = new lead ();
        lrec.lastname= 'Demo';
        lrec.company='Test';
        lrec.Status= 'New';
        lrec.email= 'info@untangle-it.com';
        insert lrec;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject= 'Test Subject';
        email.plainTextBody= 'Create Lead From Email';
        env.fromAddress='info@untangle-it.com';
        Test.stopTest();
        CreateLeadFromEmail cl = new CreateLeadFromEmail();
        cl.handleInboundEmail(email, env );
    }
}