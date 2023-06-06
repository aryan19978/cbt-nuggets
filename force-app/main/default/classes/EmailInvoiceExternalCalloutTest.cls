@IsTest
public class EmailInvoiceExternalCalloutTest {
    @isTest
    static void testmakeEmailInvoiceExternalCallout() {
        // Set up test data
        EmailInvoiceExternalCallout.InputVariables input = new EmailInvoiceExternalCallout.InputVariables();
        input.invoiceId = '11000098';
        input.calloutType = 'ActivateInvoice';
        List<EmailInvoiceExternalCallout.InputVariables> inputs = new List<EmailInvoiceExternalCallout.InputVariables>();
        inputs.add(input);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        List<EmailInvoiceExternalCallout.OutputVariables> result1 = EmailInvoiceExternalCallout.makeEmailInvoiceExternalCallout(inputs);
        System.assertEquals(1, result1.size());
        EmailInvoiceExternalCallout.OutputVariables output1 = result1[0];
        System.assertEquals('success', output1.responseType);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplError());
        List<EmailInvoiceExternalCallout.OutputVariables> result2 = EmailInvoiceExternalCallout.makeEmailInvoiceExternalCallout(inputs);
        System.assertEquals(1, result2.size());
        EmailInvoiceExternalCallout.OutputVariables output2 = result2[0];
        System.assertEquals('warning', output2.responseType);
        test.stopTest();
    }
    
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            EmailInvoiceCalloutHandler.EmailInvoiceResponseWrapper mockResponse = new EmailInvoiceCalloutHandler.EmailInvoiceResponseWrapper();
            mockResponse.success =  true;
            String jsonString = JSON.serialize(mockResponse);
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
    private class HttpCalloutMockImplError implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            EmailInvoiceCalloutHandler.EmailInvoiceResponseWrapper mockResponse = new EmailInvoiceCalloutHandler.EmailInvoiceResponseWrapper();
            mockResponse.success =  false;
            String jsonString = JSON.serialize(mockResponse);
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
}