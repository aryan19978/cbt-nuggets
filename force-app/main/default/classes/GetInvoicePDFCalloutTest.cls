@IsTest
public class GetInvoicePDFCalloutTest {
    @isTest
    static void testmakeGetInvoicePDFHandler() {
        // Set up test data
        GetInvoicePDFCallout.InputVariables input = new GetInvoicePDFCallout.InputVariables();
        input.invoiceId = '11000098';
        input.calloutType = 'GetInvoicePDF';
        List<GetInvoicePDFCallout.InputVariables> inputs = new List<GetInvoicePDFCallout.InputVariables>();
        inputs.add(input);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        List<GetInvoicePDFCallout.OutputVariables> result1 = GetInvoicePDFCallout.makeGetInvoicePDFHandler(inputs);
        System.assertEquals(1, result1.size());
        GetInvoicePDFCallout.OutputVariables output1 = result1[0];
        System.assertEquals('success', output1.responseType);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplError());
        List<GetInvoicePDFCallout.OutputVariables> result2 = GetInvoicePDFCallout.makeGetInvoicePDFHandler(inputs);
        System.assertEquals(1, result2.size());
        GetInvoicePDFCallout.OutputVariables output2 = result2[0];
        System.assertEquals('warning', output2.responseType);
        test.stopTest();
    }
    
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            GetInvoicePDFHandler.GetInvoicePDFResponseWrapper mockResponse = new GetInvoicePDFHandler.GetInvoicePDFResponseWrapper();
            mockResponse.signedUrl = 'https://www.qanuggets.com/invoice/56818b4d-6a47-4ab4-837c-922cadfea138';
            mockResponse.message =  'Subscription activated';
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
            GetInvoicePDFHandler.GetInvoicePDFResponseWrapper mockResponse = new GetInvoicePDFHandler.GetInvoicePDFResponseWrapper();
            mockResponse.signedUrl = null;
            mockResponse.message =  '';
            String jsonString = JSON.serialize(mockResponse);
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
}