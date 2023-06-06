@IsTest
public class DeactivateInvoiceExternalCalloutTest {
    @isTest
    static void testmakeDeactivateInvoiceCalloutHandler() {
        // Set up test data
        DeactivateInvoiceExternalCallout.InputVariables input = new DeactivateInvoiceExternalCallout.InputVariables();
        input.invoiceId = '11000098';
        input.calloutType = 'DeactivateInvoice';
        List<DeactivateInvoiceExternalCallout.InputVariables> inputs = new List<DeactivateInvoiceExternalCallout.InputVariables>();
        inputs.add(input);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        List<DeactivateInvoiceExternalCallout.OutputVariables> result1 = DeactivateInvoiceExternalCallout.makeDeactivateInvoiceCalloutHandler(inputs);
        System.assertEquals(1, result1.size());
        DeactivateInvoiceExternalCallout.OutputVariables output1 = result1[0];
        System.assertEquals('success', output1.responseType);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplError());
        List<DeactivateInvoiceExternalCallout.OutputVariables> result2 = DeactivateInvoiceExternalCallout.makeDeactivateInvoiceCalloutHandler(inputs);
        System.assertEquals(1, result2.size());
        DeactivateInvoiceExternalCallout.OutputVariables output2 = result2[0];
        System.assertEquals('warning', output2.responseType);
        test.stopTest();
    }
    
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            DeactivateInvoiceCalloutHandler.DeactivateInvoiceResponseWrapper mockResponse = new DeactivateInvoiceCalloutHandler.DeactivateInvoiceResponseWrapper();
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
            DeactivateInvoiceCalloutHandler.DeactivateInvoiceResponseWrapper mockResponse = new DeactivateInvoiceCalloutHandler.DeactivateInvoiceResponseWrapper();
            //mockResponse.invoiceId = '11000098';
            mockResponse.success =  true;
            String jsonString = JSON.serialize(mockResponse);
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
}