public class ProcessOrderCalloutHandler {
    
    public static String makeHttpCallout(Map<String, String> inputData){
        HttpCalloutService service = new HTTPCalloutService(inputData.get('calloutType'));
        system.debug('Input Request' + createInputRequest(inputData));
        service.setRequestBody(createInputRequest(inputData));
        HTTPResponse res = service.sendRequest();
        system.debug(res.getBody());
        try{
            ProcessOrderResponseWrapper jsonStrToWrapper=  (ProcessOrderResponseWrapper) System.JSON.deserialize(res.getBody(), ProcessOrderResponseWrapper.class);
            ProcessOrderResponseWrapper response = (ProcessOrderResponseWrapper)jsonStrToWrapper;
            system.debug('response' + response);
            
            try{
                Opportunity oppRec = [select id,StageName,Universal_Payment_Link__c,AccountId,
                                      Invoice_Id__c,Subscription_Id__c,Adept_Customer_Id__c,
                                      Status__c,Process_Order_Date__c from Opportunity where id = : inputData.get('oppId')];
                oppRec.StageName = 'Closed Pending';
                oppRec.Universal_Payment_Link__c = response.universalPaymentLink;
                oppRec.Invoice_Id__c = response.invoiceId;
                oppRec.Subscription_Id__c = response.subscriptionId;
                oppRec.Adept_Customer_Id__c = response.endCustomerAdeptId;
                oppRec.Status__c = response.message;
                oppRec.Process_Order_Date__c = Date.today();
                update oppRec;
                
                // check if renewal opportunity exist
                List<opportunity> renewalOppLst = [select id,AccountId from opportunity 
                                                   where AccountId =: oppRec.AccountId
                                                   and Type =: 'Renewal' order by CreatedDate Desc];
                if(renewalOppLst.size()>0){
                    // renewal opp exist
                    Quote newQuote = new Quote();
                    newQuote.OpportunityId	 = renewalOppLst[0].id;
                    //newQuote.AccountId	 	 = renewalOppLst[0].AccountId;
                    newQuote.Start_Date__c   = Date.today();
                    newQuote.End_Date__c     = Date.today()+15;
                    newQuote.Manually_Created__c      = true;
                    insert  newQuote;
                    
                    renewalOppLst[0].SyncedQuoteId = newQuote.id;
                    update renewalOppLst[0];
                }
                else{
                    opportunity newOpp = new opportunity();
                    newOpp.AccountId = oppRec.AccountId;
                    newOpp.StageName = 'Open';
                    newOpp.Type = 'Renewal';
                    newOpp.CloseDate = Date.today()+30;
                    insert newOpp;
                }
            }
            Catch(Exception ex){
                return ex.getMessage() + ' ProcessOrderCalloutHandler' + 'Line No ' + ex.getLineNumber()+' ' + ex.getCause();
            }
            system.debug(response.message);
            return response.message;
        }
        Catch(Exception ex){
            return res.getBody();
        }
    }
    
    public static String createInputRequest(Map<String, String> inputData){
        
        
        Quote[] quoteList = [select id,Tax ,Opportunity.Tax_Exempt__c,
                             Start_Date__c,Billing_Terms__c, (select id,Product2.productcode,Quantity,
                                                                        Discount,UnitPrice,Start_Date__c,
                                                                        Do_Not_Sync_Original_Price__c,Original_Price__c
                                                                        from  QuoteLineItems)
                             from Quote where OpportunityId =: inputData.get('oppId') and
                             IsSyncing = true];
        
        ContractDetailWrapper contractDetailData = new ContractDetailWrapper();
        List<lineItemWrapper> lineItemDataList = new List<lineItemWrapper>();
        
        if(quoteList.size()>0){
            for(QuoteLineItem qliRec : quoteList[0].QuoteLineItems){
                lineItemWrapper lineItemData = new lineItemWrapper();
                lineItemData.productId = qliRec.Product2.productcode;
                lineItemData.productFamilyId = 'dcbf3492-7ec1-452d-8f17-4a74da3d472e';
                lineItemData.quantity = qliRec.Quantity;
                lineItemData.percentDiscount = qliRec.Discount;
                lineItemData.unitPrice = qliRec.Original_Price__c ;
                lineItemData.startDate = String.valueof(qliRec.Start_Date__c);
                
                lineItemDataList.add(lineItemData);
            }
            
            /*
            lineItemWrapper lineItemData1 = new lineItemWrapper();
            lineItemData1.productId = '990';
            lineItemData1.productFamilyId = 'dcbf3492-7ec1-452d-8f17-4a74da3d472e';
            lineItemData1.quantity = 50;
            lineItemData1.percentDiscount = 0;
            lineItemData1.unitPrice = -1;
            lineItemData1.startDate = '2023-09-08T14:07:24.450Z';
            
            lineItemWrapper lineItemData2 = new lineItemWrapper();
            lineItemData2.productId = '100';
            lineItemData2.productFamilyId = 'dcbf3492-7ec1-452d-8f17-4a74da3d472e' ;
            lineItemData2.quantity = 5 ;
            lineItemData2.percentDiscount = 0.1;
            lineItemData2.unitPrice = 1000 ;
            lineItemData2.startDate = '2023-09-08T14:07:24.450Z';
            */
            //lineItemDataList.add(lineItemData1);
            //lineItemDataList.add(lineItemData2);
            
            lineItemWrapper lineItemData3 = new lineItemWrapper();
            lineItemData3.productId = '998';
            lineItemData3.productFamilyId = 'TAX' ;
            lineItemData3.quantity = 1 ;
            lineItemData3.percentDiscount = null;
            lineItemData3.unitPrice = quoteList[0].Tax ;
            lineItemData3.startDate = String.valueof(quoteList[0].Start_Date__c);
            
            lineItemDataList.add(lineItemData3);
            
            contractDetailData.paymentTerm = quoteList[0].Billing_Terms__c ;
            contractDetailData.isUniversalPayment = true;
            contractDetailData.lineItems = lineItemDataList;
        }
        
        
        
        
        Opportunity oppdata = [select id , AccountId, Bill_to_Account__c,Account.Name,
                                 Bill_to_Account__r.Name, Bill_to_Account__r.Billing_Email__c,
                                 Bill_to_Account__r.Phone, Bill_to_Account__r.BillingStreet,
                                 Bill_to_Account__r.BillingCity, Bill_to_Account__r.BillingState,
                                 Bill_to_Account__r.BillingPostalCode, Bill_to_Account__r.BillingCountry,
                                 Account.ShippingStreet, Account.ShippingCity,
                                 Account.ShippingState, Account.ShippingPostalCode,
                                 Account.ShippingCountry
                                 from opportunity where id =: inputData.get('oppId') ];
        
        BillToWrapperRequest billToData = new BillToWrapperRequest();
        ShipToWrapperRequest shipToData = new ShipToWrapperRequest();
        OwnerWrapper ownerData = new OwnerWrapper();
        
        if(oppdata != null)
        {
            Contact[] conList =  [Select id ,firstName, LastName, Email from Contact
                               where AccountId = : oppdata.AccountId and Owner__c =: true];
            
            if(conList.size()>0){
                ownerData.firstName = conList[0].firstName;
                ownerData.lastName = conList[0].LastName;
                ownerData.company = 'dylans company';
                ownerData.email = conList[0].Email;
            }
            AddressWrapper addressDataShip = new AddressWrapper();
            addressDataShip.line1 = oppdata.Account.ShippingStreet;
            addressDataShip.city = oppdata.Account.ShippingCity;
            addressDataShip.state = oppdata.Account.ShippingState;
            addressDataShip.postalCode = oppdata.Account.ShippingPostalCode;
            addressDataShip.countryCode = oppdata.Account.ShippingCountry;
            
            
            shipToData.sfId = '0015200000zKkY6AAK';//oppdata.AccountId;
            shipToData.accountName = oppdata.Account.Name;
            shipToData.company = '';
            shipToData.email = '';
            shipToData.address = addressDataShip;
            
            AddressWrapper addressDataBill = new AddressWrapper();
            addressDataBill.line1 = oppdata.Bill_to_Account__r.BillingStreet;
            addressDataBill.city = oppdata.Bill_to_Account__r.BillingCity;
            addressDataBill.state = oppdata.Bill_to_Account__r.BillingState;
            addressDataBill.postalCode = oppdata.Bill_to_Account__r.BillingPostalCode;
            addressDataBill.countryCode = oppdata.Bill_to_Account__r.BillingCountry;
            
            
            billToData.sfId = '0015200000zKkY6AAK'; //oppdata.Bill_to_Account__c;
            billToData.accountName =oppdata.Bill_to_Account__r.Name;
            billToData.firstName = '';
            billToData.lastName = '';
            billToData.email = oppdata.Bill_to_Account__r.Billing_Email__c;
            billToData.phone = oppdata.Bill_to_Account__r.Phone;
            billToData.company = '';
            billToData.address = addressDataBill;
        }
        ProcessOrderRequestWrapper data = new ProcessOrderRequestWrapper();
        data.apiKey = HttpCalloutUtility.getValueCustomMetadata('apiKey');
        data.opportunityId = 'fake';        
        data.billTo = billToData;
        data.shipTo = shipToData;
        data.owner = ownerData;
        data.contractDetails = contractDetailData;
        
        String jsonStr = JSON.serializePretty(data);
        return jsonStr;
    }
    
    Public class ProcessOrderResponseWrapper{
        Public String universalPaymentLink;
        Public String invoiceId;
        Public String endCustomerAdeptId;
        Public String subscriptionId;
        Public String message;
    }
    
    Public class ProcessOrderRequestWrapper{
        Public string apiKey;
        Public string opportunityId;
        Public BillToWrapperRequest billTo;
        Public ShipToWrapperRequest shipTo;
        Public OwnerWrapper owner;
        Public ContractDetailWrapper contractDetails;
    }
    
    public class ContractDetailWrapper{
        Public string paymentTerm;
        Public boolean isUniversalPayment;
        Public List<lineItemWrapper> lineItems;
    }
    
    public class lineItemWrapper{
        Public string productId;
        Public string productFamilyId;
        Public Decimal quantity;
        Public Decimal percentDiscount;
        Public Decimal unitPrice;
        Public string startDate;
    }
    
    
    public class OwnerWrapper{
        Public string firstName;
        Public string lastName;
        Public string company;
        Public string email;
        
    }
    
    public class BillToWrapperRequest{
        public string sfId;
        public string accountName;
        public string firstName;
        public string lastName;
        public string email;
        public string phone;
        public string company;
        public AddressWrapper address;
    }
    
    
    public class ShipToWrapperRequest{
        public string sfId;
        public string accountName;
        public string company;
        public string email;
        public AddressWrapper address;
    }
    
    public class AddressWrapper{
        public string line1;
        public string city;
        public string state;
        public string postalCode;
        public string countryCode;
    }
}