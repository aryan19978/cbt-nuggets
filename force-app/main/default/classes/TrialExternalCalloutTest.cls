@IsTest
public class TrialExternalCalloutTest {
    @isTest
    static void testmakeTrialCallout() {
        // Set up test data
        Account acc = TestDataFactory.CreateAccount();
        Insert acc;
        Contact con = TestDataFactory.CreateContact(acc.id);
        Insert con;
        Opportunity opp = TestDataFactory.CreateOpportunity(acc.id);
        Insert Opp;
        TrialExternalCallout.TrialInputVariables input = new TrialExternalCallout.TrialInputVariables();
        input.OppId = opp.Id;
        input.durationOverride = '10';
        input.adminEmail = 'demoadmin@cbtnuggets.com';
        input.adminName = 'Admin Demo';
        input.licenseCount = '10';
        input.licenseType = 'Yearly';
        input.startDate = 'April 23, 2023';
        input.calloutType = 'CreateTrial';
        List<TrialExternalCallout.TrialInputVariables> inputs = new List<TrialExternalCallout.TrialInputVariables>();
        inputs.add(input);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        List<TrialExternalCallout.TrialOutputVariables> result1 = TrialExternalCallout.makeTrialCallout(inputs);
        System.assertEquals(1, result1.size());
        TrialExternalCallout.TrialOutputVariables output1 = result1[0];
        System.assertEquals('success', output1.responseType);
     
        test.stopTest();
    }
    
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String mockResponse = '{"message": "Subscription activated","adeptContactId": "10000079","adeptCustomerId": "10000079","subscriptionId": "1843eab9-ed29-44fd-91b5-23c0cc7ea8b3"}';
            res.setBody(mockResponse);
            res.setStatusCode(200);
            return res;
        }
    } 
}