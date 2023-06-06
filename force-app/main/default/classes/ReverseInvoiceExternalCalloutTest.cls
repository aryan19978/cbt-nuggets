@IsTest
public class ReverseInvoiceExternalCalloutTest {
    @isTest
    static void testmakeReverseInvoiceExternalCallout() {
        // Set up test data
        ReverseInvoiceExternalCallout.InputVariables input = new ReverseInvoiceExternalCallout.InputVariables();
        input.invoiceId = '11000098';
        input.calloutType = 'ActivateInvoice';
        List<ReverseInvoiceExternalCallout.InputVariables> inputs = new List<ReverseInvoiceExternalCallout.InputVariables>();
        inputs.add(input);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        List<ReverseInvoiceExternalCallout.OutputVariables> result1 = ReverseInvoiceExternalCallout.makeReverseInvoiceExternalCallout(inputs);
        System.assertEquals(1, result1.size());
        ReverseInvoiceExternalCallout.OutputVariables output1 = result1[0];
        System.assertEquals('success', output1.responseType);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplError());
        List<ReverseInvoiceExternalCallout.OutputVariables> result2 = ReverseInvoiceExternalCallout.makeReverseInvoiceExternalCallout(inputs);
        System.assertEquals(1, result2.size());
        ReverseInvoiceExternalCallout.OutputVariables output2 = result2[0];
        System.assertEquals('warning', output2.responseType);
        test.stopTest();
    }
    
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            ReverseInvoiceCalloutHandler.ReverseResponseWrapper mockResponse = new ReverseInvoiceCalloutHandler.ReverseResponseWrapper();
            mockResponse.invoiceId = '11000098';
            mockResponse.success =  true;
            mockResponse.reversalInvoiceId = '11000098';
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
            ReverseInvoiceCalloutHandler.ReverseResponseWrapper mockResponse = new ReverseInvoiceCalloutHandler.ReverseResponseWrapper();
            //mockResponse.invoiceId = '11000098';
            mockResponse.success =  true;
            mockResponse.reversalInvoiceId = '11000098';
            String jsonString = JSON.serialize(mockResponse);
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
}