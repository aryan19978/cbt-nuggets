@IsTest
public class ActivateInvoiceExternalCalloutTest {
    @isTest
    static void testMakeActivateInvoiceCalloutHandler() {
        // Set up test data
        ActivateInvoiceExternalCallout.InputVariables input = new ActivateInvoiceExternalCallout.InputVariables();
        input.invoiceId = '11000098';
        input.calloutType = 'ActivateInvoice';
        List<ActivateInvoiceExternalCallout.InputVariables> inputs = new List<ActivateInvoiceExternalCallout.InputVariables>();
        inputs.add(input);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        List<ActivateInvoiceExternalCallout.OutputVariables> result1 = ActivateInvoiceExternalCallout.makeActivateInvoiceCalloutHandler(inputs);
        System.assertEquals(1, result1.size());
        ActivateInvoiceExternalCallout.OutputVariables output1 = result1[0];
        System.assertEquals('success', output1.responseType);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplError());
        List<ActivateInvoiceExternalCallout.OutputVariables> result2 = ActivateInvoiceExternalCallout.makeActivateInvoiceCalloutHandler(inputs);
        System.assertEquals(1, result2.size());
        ActivateInvoiceExternalCallout.OutputVariables output2 = result2[0];
        System.assertEquals('warning', output2.responseType);
        test.stopTest();
    }
    
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            ActivateInvoiceCalloutHandler.ActivateInvoiceResponseWrapper mockResponse = new ActivateInvoiceCalloutHandler.ActivateInvoiceResponseWrapper();
            mockResponse.invoiceId = '11000098';
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
            ActivateInvoiceCalloutHandler.ActivateInvoiceResponseWrapper mockResponse = new ActivateInvoiceCalloutHandler.ActivateInvoiceResponseWrapper();
            //mockResponse.invoiceId = '11000098';
            mockResponse.success =  true;
            String jsonString = JSON.serialize(mockResponse);
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
}