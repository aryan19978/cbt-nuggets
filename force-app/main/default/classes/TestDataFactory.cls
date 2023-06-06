@IsTest
public class TestDataFactory {
    public static HTTPCalloutConfiguration__mdt createHTTPCalloutConfiguration(String Name,String Method, String Endpoint, Integer Timeout) {
        HTTPCalloutConfiguration__mdt config = new HTTPCalloutConfiguration__mdt(
            DeveloperName  = Name,
            MasterLabel    = Name,
            Method__c      = Method,
            Endpoint__c    = Endpoint,
            Timeout__c     = Timeout
        );
        return config;
    }
    
    public static HTTPEndpointConfiguration__mdt createHTTPEndpointConfiguration(String Name,String value) {
        HTTPEndpointConfiguration__mdt config = new HTTPEndpointConfiguration__mdt(
            DeveloperName  = Name,
            MasterLabel    = Name,
            Value__c      = value
        );
        return config;
    }
    
    Public static Case CreateNewCase(){
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Priority = 'Normal';
        testCase.Origin = 'Live Chat - Online';
        testCase.Supplied_Email__c = 'case.newcase@test.biz';
        testCase.Subject = 'Test New Case';
        testCase.Description = 'Test New Case';
        return testCase;
    }
    
    Public static Case CreateWorkingCase(){
        Case testCase2 = new Case();
        testCase2.Status = 'Working';
        testCase2.Priority = 'Normal';
        testCase2.Origin = 'Live Chat - Online';
        testCase2.Supplied_Email__c = 'case.workingcase@test.biz';
        testCase2.Subject = 'Test Working Case';
        testCase2.Description = 'Working Test';
        return testCase2;
    }
    
    Public static Case CreateOnHoldCase(){
        Case testCase3 = new Case();
        testCase3.Status = 'On Hold';
        testCase3.Priority = 'Normal';
        testCase3.Origin = 'Live Chat - Online';
        testCase3.Supplied_Email__c = 'case.onholdcase@test.biz';
        testCase3.Subject = 'Test On Hold Case';
        testCase3.Description = 'Test On Hold Case';
        return testCase3;
    }
    
    Public static Case CreateOnWaitingonCustomerCase(){
        Case testCase4 = new Case();
        testCase4.Status = 'Waiting on Customer';
        testCase4.Priority = 'Normal';
        testCase4.Origin = 'Live Chat - Online';
        testCase4.Supplied_Email__c = 'case.waitingcase@test.biz';
        testCase4.Subject = 'Test Waiting on Customer Case';
        testCase4.Description = 'Test Waiting on Customer Case';
        return testCase4;
    }
    
    Public static Case CreateCase(){
        Case testCase5 = new Case();
        testCase5.Status = 'New';
        testCase5.Priority = 'Normal';
        testCase5.Origin = 'Sales';
        testCase5.Subject = 'Refund Request - Case Helper Update';
        testCase5.Description = 'Request Refund';
        return testCase5;
    }
    
    
    Public static Lead CreateLead(){
        Lead newLead = new Lead();
        newLead.FirstName = 'John';
        newLead.LastName = 'Doe';
        newLead.Company = 'Acme Inc.';
        newLead.Email = 'demolead@cbtnuggets.com';
        newLead.Phone = '555-555-5555';
        newLead.Street = 'Starbucks Drive-thru';
        newLead.City = 'Conifer';
        newLead.State = 'CO';
        newLead.PostalCode = '80433';
        newLead.Country = 'United States';
        return newLead;
    }
    
    Public static Account CreateAccount(){
        Id SalesRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'My Account';
        acc.Phone = '123-456-7890';
        acc.Website = 'https://www.example.com';
        acc.Industry = 'Technology';
        acc.RecordTypeId = SalesRecordTypeId;
        acc.BillingStreet = 'Starbucks Drive-thru';
        acc.BillingCity = 'Conifer';
        acc.BillingState = 'CO';
        acc.BillingPostalCode = '80433';
        acc.BillingCountry  = 'United States';
        acc.Billing_Email__c  = 'demoraj@cbtnuggets.com'; 
        return acc;
    }
    
    Public static Contact CreateContact(String AccId){
        Contact con = new Contact();
        con.FirstName = 'John';
        con.LastName = 'Doe';
        con.Email = 'demoCon@cbtnuggets.com';
        con.Phone = '123-456-7890';
        con.AccountId = AccId;
        con.MailingStreet = 'Starbucks Drive-thru';
        con.MailingCity ='Conifer';
        con.MailingState ='CO';
        con.MailingPostalCode ='80433';
        con.MailingCountry ='United States';
        con.Admin__c = true;
        con.Owner__c = true;
        con.Primary_Contact__c =true;
        return con;
    }
    
    Public static Opportunity CreateOpportunity(String AccId){
        Opportunity opp = new Opportunity();
        opp.Name = 'New Opportunity';
        opp.AccountId = AccId;
        opp.StageName = 'Open';
        opp.CloseDate = Date.today().addDays(30);
        opp.CloseDate = Date.today().addDays(30);
        opp.CloseDate = Date.today().addDays(30);
        opp.License_Type__c =  'Yearly';
        opp.License_Count__c =  10;
        opp.Start_Date__c = Date.today().addDays(5);
        opp.End_Date__c = Date.today().addDays(60);
        opp.Amount = 50000.00;
        return opp;
    }
    
    Public Static Quote CreateQuote(String oppID){
        Quote quoteRec = new Quote(); 
        
        Opportunity oppRec = [SELECT Id, Bill_to_Account__c,AccountId,Account.Name,
                              SyncedQuoteId,License_Count__c,License_Type__c,Term__c,Start_Date__c,
                              End_Date__c,Account.Billing_Email__c,Bill_to_Account__r.Name,
                              Bill_to_Account__r.BillingStreet,Bill_to_Account__r.BillingCity,
                              Bill_to_Account__r.BillingState,Bill_to_Account__r.BillingPostalCode,
                              Bill_to_Account__r.BillingCountry,
                              Account.BillingStreet, Account.BillingCity,
                              Account.BillingState, Account.BillingPostalCode, 
                              Account.BillingCountry,
                              Account.ShippingStreet, Account.ShippingCity, 
                              Account.ShippingState, Account.ShippingPostalCode,
                              Account.ShippingCountry
                            FROM Opportunity WHERE Id =:  oppID];
           
        if(oppRec != null){

            if(oppRec.Bill_to_Account__c != null){
                quoteRec.BillingStreet                  = oppRec.Bill_to_Account__r.BillingStreet;
                quoteRec.BillingCity 					= oppRec.Bill_to_Account__r.BillingCity;
                quoteRec.BillingState                   = oppRec.Bill_to_Account__r.BillingState;
                quoteRec.BillingPostalCode              = oppRec.Bill_to_Account__r.BillingPostalCode;
                quoteRec.BillingCountry                 = oppRec.Bill_to_Account__r.BillingCountry;

                quoteRec.Billing_Email__c               = oppRec.Bill_to_Account__r.Billing_Email__c;
                quoteRec.BillingName                    = oppRec.Bill_to_Account__r.Name;
            }
            else{
                quoteRec.BillingStreet                  = oppRec.Account.BillingStreet;
                quoteRec.BillingCity                    = oppRec.Account.BillingCity;
                quoteRec.BillingState                   = oppRec.Account.BillingState;
                quoteRec.BillingPostalCode              = oppRec.Account.BillingPostalCode;
                quoteRec.BillingCountry                 = oppRec.Account.BillingCountry;

                quoteRec.Billing_Email__c               = oppRec.Account.Billing_Email__c;
                quoteRec.billingName                    = oppRec.Account.Name;

            }
            quoteRec.Name                     			= 'Test Quote';
            quoteRec.ShippingStreet                     = oppRec.Account.ShippingStreet;
            quoteRec.ShippingCity                       = oppRec.Account.ShippingCity;
            quoteRec.ShippingState                      = oppRec.Account.ShippingState;
            quoteRec.ShippingPostalCode                 = oppRec.Account.ShippingPostalCode;
            quoteRec.Shippingcountry                    = oppRec.Account.ShippingCountry;
            
            quoteRec.License_Count__c                   = oppRec.License_Count__c;
            quoteRec.License_Type__c                    = oppRec.License_Type__c;
            quoteRec.Billing_Terms__c                   = oppRec.Term__c;
            quoteRec.Start_Date__c                      = oppRec.Start_Date__c;
			quoteRec.End_Date__c                        = oppRec.End_Date__c;
            quoteRec.OpportunityId 						= oppRec.Id;
            List<Contact> contactList = [select Id,Email,Phone from Contact 
                                         where Primary_Contact__c =: true
                                         and AccountId =: oppRec.AccountId];
            
            if (contactList.size() > 0){
                quoteRec.ContactId 						= contactList[0].Id;
                quoteRec.Email 							= contactList[0].Email;
            }
        }
        return quoteRec;
        
    }
    
    Public Static Product2 Createproduct()
    {
    	Product2 product = new Product2();
        product.Name = 'Annual - CBT Nuggets Subscription';
        product.ProductCode = '100';
        product.IsActive = true;
        product.Description = 'Sample description';
        return product;
    }
    
    Public Static Product2 CreateproductProrationDiscount()
    {
    	Product2 product = new Product2();
        product.Name = 'Proration Discount';
        product.ProductCode = '915';
        product.IsActive = true;
        product.Description = 'Proration discount for a mid term add on';
        return product;
    }
    
    Public Static QuoteLineItem CreateQuoteLineItem(String quoteRecordId,String productId)
    {
        QuoteLineItem quoteLineItem = new QuoteLineItem();
        quoteLineItem.QuoteId = quoteRecordId;
        quoteLineItem.Product2Id = productId; 
        quoteLineItem.Quantity = 10;
        quoteLineItem.UnitPrice = 100;
        return quoteLineItem;
    }
    
    Public Static PricebookEntry CreatePricebookEntry(String ProductID) {
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
        
        // Create a new PricebookEntry and relate it to the Standard Pricebook and Product2 records
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = standardPricebook.Id;
        pricebookEntry.Product2Id = ProductID;
        pricebookEntry.UnitPrice = 100;
        pricebookEntry.IsActive = true;
        return pricebookEntry;
    }
    
    Public Static PricebookEntry CreatePricebookEntry2(String ProductID) {
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
        
        // Create a new PricebookEntry and relate it to the Standard Pricebook and Product2 records
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = standardPricebook.Id;
        pricebookEntry.Product2Id = ProductID;
        pricebookEntry.UnitPrice = 100;
        pricebookEntry.IsActive = true;
        return pricebookEntry;
    }
    
}