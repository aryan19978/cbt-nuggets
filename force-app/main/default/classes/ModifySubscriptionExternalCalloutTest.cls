@IsTest
public class ModifySubscriptionExternalCalloutTest {
    @isTest
    static void testmakeModifySubscriptionCalloutHandler1() {
        // Set up test data
        ModifySubscriptionExternalCallout.InputVariables input = new ModifySubscriptionExternalCallout.InputVariables();
        input.SubscriptionModification = 'SET SUBSCRIPTION DETAILS';
        input.startDate = 'April 23, 2023';
        input.endDate = 'April 30, 2023';
        input.quantity = '8';
        input.endCustomerAdeptId = '10000079';
        input.autoRenew = 'Yes';
        input.newStartDate = 'April 24, 2023';
        input.calloutType = 'ModifySubscription';
        List<ModifySubscriptionExternalCallout.InputVariables> inputs = new List<ModifySubscriptionExternalCallout.InputVariables>();
        inputs.add(input);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        List<ModifySubscriptionExternalCallout.OutputVariables> result1 = ModifySubscriptionExternalCallout.makeModifySubscriptionCalloutHandler(inputs);
        System.assertEquals(1, result1.size());
        ModifySubscriptionExternalCallout.OutputVariables output1 = result1[0];
        System.assertEquals('success', output1.responseType);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplError());
        List<ModifySubscriptionExternalCallout.OutputVariables> result2 = ModifySubscriptionExternalCallout.makeModifySubscriptionCalloutHandler(inputs);
        System.assertEquals(1, result2.size());
        ModifySubscriptionExternalCallout.OutputVariables output2 = result2[0];
        System.assertEquals('warning', output2.responseType);
        test.stopTest();
    }
    
    @isTest
    static void testmakeModifySubscriptionCalloutHandler2() {
        // Set up test data
        ModifySubscriptionExternalCallout.InputVariables input = new ModifySubscriptionExternalCallout.InputVariables();
        input.SubscriptionModification = 'SET AUTORENEW DETAILS';
        input.startDate = 'April 23, 2023';
        input.endDate = 'April 30, 2023';
        input.quantity = '8';
        input.endCustomerAdeptId = '10000079';
        input.autoRenew = 'Yes';
        input.newStartDate = 'April 24, 2023';
        input.calloutType = 'ModifySubscription';
        List<ModifySubscriptionExternalCallout.InputVariables> inputs = new List<ModifySubscriptionExternalCallout.InputVariables>();
        inputs.add(input);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        List<ModifySubscriptionExternalCallout.OutputVariables> result1 = ModifySubscriptionExternalCallout.makeModifySubscriptionCalloutHandler(inputs);
        System.assertEquals(1, result1.size());
        ModifySubscriptionExternalCallout.OutputVariables output1 = result1[0];
        System.assertEquals('success', output1.responseType);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplError());
        List<ModifySubscriptionExternalCallout.OutputVariables> result2 = ModifySubscriptionExternalCallout.makeModifySubscriptionCalloutHandler(inputs);
        System.assertEquals(1, result2.size());
        ModifySubscriptionExternalCallout.OutputVariables output2 = result2[0];
        System.assertEquals('warning', output2.responseType);
        test.stopTest();
    }
    
    @isTest
    static void testmakeModifySubscriptionCalloutHandler3() {
        // Set up test data
        ModifySubscriptionExternalCallout.InputVariables input = new ModifySubscriptionExternalCallout.InputVariables();
        input.SubscriptionModification = 'SET RENEWAL DATE';
        input.startDate = 'April 23, 2023';
        input.endDate = 'April 30, 2023';
        input.quantity = '8';
        input.endCustomerAdeptId = '10000079';
        input.autoRenew = 'Yes';
        input.newStartDate = 'April 24, 2023';
        input.calloutType = 'ModifySubscription';
        List<ModifySubscriptionExternalCallout.InputVariables> inputs = new List<ModifySubscriptionExternalCallout.InputVariables>();
        inputs.add(input);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        List<ModifySubscriptionExternalCallout.OutputVariables> result1 = ModifySubscriptionExternalCallout.makeModifySubscriptionCalloutHandler(inputs);
        System.assertEquals(1, result1.size());
        ModifySubscriptionExternalCallout.OutputVariables output1 = result1[0];
        System.assertEquals('success', output1.responseType);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplError());
        List<ModifySubscriptionExternalCallout.OutputVariables> result2 = ModifySubscriptionExternalCallout.makeModifySubscriptionCalloutHandler(inputs);
        System.assertEquals(1, result2.size());
        ModifySubscriptionExternalCallout.OutputVariables output2 = result2[0];
        System.assertEquals('warning', output2.responseType);
        test.stopTest();
    }
    
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            ModifySubscriptionCalloutHandler.ModifySubscriptionResponseWrapper mockResponse = new ModifySubscriptionCalloutHandler.ModifySubscriptionResponseWrapper();
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
            ModifySubscriptionCalloutHandler.ModifySubscriptionResponseWrapper mockResponse = new ModifySubscriptionCalloutHandler.ModifySubscriptionResponseWrapper();
            mockResponse.success =  false;
            String jsonString = JSON.serialize(mockResponse);
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
}