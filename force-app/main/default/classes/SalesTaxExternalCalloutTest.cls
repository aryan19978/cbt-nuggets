@IsTest
public class SalesTaxExternalCalloutTest {
    @isTest
    static void testmakeSalesTaxExternalCallout() {
        
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
        
        // Set up test data
        SalesTaxExternalCallout.InputVariables input = new SalesTaxExternalCallout.InputVariables();
        input.quoteId = quoRec.Id;
        input.calloutType = 'GetSalesTax';
        List<SalesTaxExternalCallout.InputVariables> inputs = new List<SalesTaxExternalCallout.InputVariables>();
        inputs.add(input);
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        List<SalesTaxExternalCallout.OutputVariables> result1 = SalesTaxExternalCallout.makeSalesTaxExternalCallout(inputs);
        System.assertEquals(1, result1.size());
        SalesTaxExternalCallout.OutputVariables output1 = result1[0];
        //System.assertEquals('success', output1.responseType);
       
    }
    
    private class HttpCalloutMockImpl implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            SalesTaxCalloutHandler.validatedAddressWrapper validatedAdd = new SalesTaxCalloutHandler.validatedAddressWrapper();
            validatedAdd.line1 = 'Starbucks Drive-thru';
            validatedAdd.line2 = '';
            validatedAdd.city = 'Conifer';
            validatedAdd.state = 'CO';
            validatedAdd.countryCode = 'US';
            validatedAdd.postalCode = '80433';
            
            SalesTaxCalloutHandler.lineItemsWrapper lineItems1 = new SalesTaxCalloutHandler.lineItemsWrapper();
            lineItems1.productId = '100';
            lineItems1.productFamilyId = 'dcbf3492-7ec1-452d-8f17-4a74da3d472e';
            lineItems1.quantity = 10;
            lineItems1.percentDiscount = 0;
            lineItems1.unitPrice = 599;
            lineItems1.startDate = '2023-04-03';
            lineItems1.endDate = '2024-04-02T00:00:00.000Z';
            lineItems1.description = '';
            
            
            SalesTaxCalloutHandler.lineItemsWrapper lineItems2 = new SalesTaxCalloutHandler.lineItemsWrapper();
            lineItems2.productId = '915';
            lineItems2.productFamilyId = 'dcbf3492-7ec1-452d-8f17-4a74da3d472e';
            lineItems2.quantity = 1;
            lineItems2.percentDiscount = 0;
            lineItems2.unitPrice = -3993.3;
            lineItems2.startDate = '2023-04-03';
            lineItems2.endDate = '2024-04-02T00:00:00.000Z';
            lineItems2.description = 'PRO-RATED DISCOUNT';
            
            SalesTaxCalloutHandler.lineItemsWrapper lineItems3 = new SalesTaxCalloutHandler.lineItemsWrapper();
            lineItems3.productId = '998';
            lineItems3.productFamilyId = 'dcbf3492-7ec1-452d-8f17-4a74da3d472e';
            lineItems3.quantity = 1;
            lineItems3.unitPrice = 79.3;
            lineItems3.startDate = '2023-04-03';
            lineItems3.endDate = '2024-04-02T00:00:00.000Z';
            lineItems3.description = 'PRO-RATED DISCOUNT';
            
            List<SalesTaxCalloutHandler.lineItemsWrapper> lineItemsList =  new List<SalesTaxCalloutHandler.lineItemsWrapper>();
            lineItemsList.add(lineItems1);
            lineItemsList.add(lineItems2);
            lineItemsList.add(lineItems3);
            
            SalesTaxCalloutHandler.PurchaseDetailWrapper purchaseDet = new SalesTaxCalloutHandler.PurchaseDetailWrapper();
            purchaseDet.lineItems = lineItemsList;
    
            
            SalesTaxCalloutHandler.SalesTaxResponseWrapper mockResponse = new SalesTaxCalloutHandler.SalesTaxResponseWrapper();
            mockResponse.quoteType =  'Renewal';
            mockResponse.validatedAddress = validatedAdd;
            mockResponse.purchaseDetails = purchaseDet;
            
            String jsonString = JSON.serialize(mockResponse);
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;
        }
    }
    
}