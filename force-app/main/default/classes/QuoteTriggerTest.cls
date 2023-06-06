@IsTest
private class QuoteTriggerTest {
    @IsTest
    static void testQuoteAcceptedStatus() {
        Account accRec = TestDataFactory.CreateAccount();
        Insert accRec;
        Contact conRec = TestDataFactory.CreateContact(accRec.id);
        Insert conRec;
        Opportunity oppRec = TestDataFactory.CreateOpportunity(accRec.id);
        Insert oppRec;
        Product2 prdRec = TestDataFactory.Createproduct();
        insert prdRec;
        PricebookEntry pbeRec = TestDataFactory.CreatePricebookEntry(prdRec.Id);
        insert pbeRec;
        Product2 prdRec2 = TestDataFactory.CreateproductProrationDiscount();
        insert prdRec2;
        PricebookEntry pbeRec2 = TestDataFactory.CreatePricebookEntry(prdRec2.Id);
        insert pbeRec2;
        Quote quoRec = TestDataFactory.CreateQuote(oppRec.id);
        Insert quoRec;
        
        // Update Quote status to "Quote Accepted"
        quoRec.Status = 'Quote Accepted';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        update quoRec;
        Test.stopTest();
    }
    
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            ProcessOrderCalloutHandler.ItemsResponseWrapper ItemsRes = new ProcessOrderCalloutHandler.ItemsResponseWrapper();
            ItemsRes.productFamilyId ='dcbf3492-7ec1-452d-8f17-4a74da3d472e';
            ItemsRes.unitPrice=598;
            ItemsRes.quantity=18;
            ItemsRes.productId='100';
            ItemsRes.freeTrial=false;
            ItemsRes.endDate='2023-04-30T00:00:00.000Z';
            ItemsRes.durationOverride=0;
            ItemsRes.priceId='unknown';
            ItemsRes.startDate='2023-04-12T00:00:00.000Z';
            List<ProcessOrderCalloutHandler.ItemsResponseWrapper> ItemsResList = new List<ProcessOrderCalloutHandler.ItemsResponseWrapper>();
            ItemsResList.add(ItemsRes);
            
            ProcessOrderCalloutHandler.AttrsResponseWrapper AttrsRes= new  ProcessOrderCalloutHandler.AttrsResponseWrapper();
            AttrsRes.autorenew = true;
            AttrsRes.renewDate = '2023-04-30T00:00:00.000Z';
            AttrsRes.items = ItemsResList;
            AttrsRes.billTo = '10000079-billing';
            AttrsRes.shipTo = '10000079-shipping';
            
            ProcessOrderCalloutHandler.SubscriptionResponseWrapper SubscriptionRes = new ProcessOrderCalloutHandler.SubscriptionResponseWrapper();
            SubscriptionRes.subid = '1843eab9-ed29-44fd-91b5-23c0cc7ea8b3';
            SubscriptionRes.custId = '10000079';
            SubscriptionRes.endCustId = '10000079';
            SubscriptionRes.renewalPeriod = 'CUSTOM';
            SubscriptionRes.created = '2023-04-03T07:36:07.878Z';
            SubscriptionRes.updated = '2023-04-24T13:13:13.927Z';
            SubscriptionRes.attrs = AttrsRes;
            
            ProcessOrderCalloutHandler.RenewalItemsResponseWrapper RenewalItemsRes = new ProcessOrderCalloutHandler.RenewalItemsResponseWrapper();
            RenewalItemsRes.unitPrice = 598;
            RenewalItemsRes.productFamilyId = 'dcbf3492-7ec1-452d-8f17-4a74da3d472e';
            RenewalItemsRes.quantity = 18;
            RenewalItemsRes.productId = '100';
            RenewalItemsRes.endDate = '2023-04-30T00:00:00.000Z';
            RenewalItemsRes.startDate = '2023-04-12T00:00:00.000Z';
            List<ProcessOrderCalloutHandler.RenewalItemsResponseWrapper> RenewalItemsResList = new List<ProcessOrderCalloutHandler.RenewalItemsResponseWrapper>();
            RenewalItemsResList.add(RenewalItemsRes); 
            
            ProcessOrderCalloutHandler.RenewalDetailsResponseWrapper RenewalDetailsRes = new ProcessOrderCalloutHandler.RenewalDetailsResponseWrapper();
            RenewalDetailsRes.renewalDate = '2023-04-30T00:00:00.000Z'; 
            RenewalDetailsRes.renewalPeriod = 'CUSTOM';
            RenewalDetailsRes.items = RenewalItemsResList;
            
            ProcessOrderCalloutHandler.ProcessOrderResponseWrapper mockResponse = new ProcessOrderCalloutHandler.ProcessOrderResponseWrapper();
            mockResponse.invoiceId = '11000098';
            mockResponse.universalPaymentLink =  'https://www.qanuggets.com/invoice/56818b4d-6a47-4ab4-837c-922cadfea138';
            mockResponse.endCustomerAdeptId = '10000079';
            mockResponse.subscription = SubscriptionRes;
            mockResponse.renewalDetails = RenewalDetailsRes;
            mockResponse.message = 'Subscription activated';
            String jsonString = JSON.serialize(mockResponse);
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
}