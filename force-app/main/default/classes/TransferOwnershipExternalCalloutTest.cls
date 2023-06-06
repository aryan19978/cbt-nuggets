@IsTest
public class TransferOwnershipExternalCalloutTest {
    @isTest
    static void testMakeActivateInvoiceCalloutHandler() {
        // Set up test data
        TransferOwnershipExternalCallout.InputVariables input = new TransferOwnershipExternalCallout.InputVariables();
        input.email = 'demo@cbtnuggets.com';
        input.firstName = 'Untaggle';
        input.lastName = 'Demo';
        input.adeptCustomerId = '10000079';
        input.calloutType = 'TransferOwner';
        List<TransferOwnershipExternalCallout.InputVariables> inputs = new List<TransferOwnershipExternalCallout.InputVariables>();
        inputs.add(input);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        List<TransferOwnershipExternalCallout.OutputVariables> result1 = TransferOwnershipExternalCallout.makeTransferOwnershipExternalCallout(inputs);
        System.assertEquals(1, result1.size());
        TransferOwnershipExternalCallout.OutputVariables output1 = result1[0];
        System.assertEquals('success', output1.responseType);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplError());
        List<TransferOwnershipExternalCallout.OutputVariables> result2 = TransferOwnershipExternalCallout.makeTransferOwnershipExternalCallout(inputs);
        System.assertEquals(1, result2.size());
        TransferOwnershipExternalCallout.OutputVariables output2 = result2[0];
        System.assertEquals('warning', output2.responseType);
        test.stopTest();
    }
    
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            TransferOwnershipCalloutHandler.TransferOwnershipResponseWrapper mockResponse = new TransferOwnershipCalloutHandler.TransferOwnershipResponseWrapper();
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
            TransferOwnershipCalloutHandler.TransferOwnershipResponseWrapper mockResponse = new TransferOwnershipCalloutHandler.TransferOwnershipResponseWrapper();
            mockResponse.success =  false;
            String jsonString = JSON.serialize(mockResponse);
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
}