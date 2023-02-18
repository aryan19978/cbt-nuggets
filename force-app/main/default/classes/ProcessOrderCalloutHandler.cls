public class ProcessOrderCalloutHandler {
    
    public static Map<String,String> makeHttpCallout(Map<String, String> inputData){
        HttpCalloutService service = new HTTPCalloutService(inputData.get('calloutType'));
        string requestBody = createInputRequest(inputData);
        system.debug('requestBody'+ requestBody);
        
        service.setHeaderParameter('adept-apikey', HttpCalloutUtility.getValueCustomMetadata('apiKey'));
        service.setHeaderParameter('adept-billing-env', HttpCalloutUtility.getValueCustomMetadata('env'));
        service.setHeaderParameter('adept-billing-sfuserid', UserInfo.getUserId());
        
        service.setRequestBody(requestBody);
        HTTPResponse res = service.sendRequest();
		Map<String,String> responseMap = new Map<String,String>();
        try{
            string resGetBody = res.getBody();
            system.debug('resGetBody Process Order' + resGetBody);
            resGetBody = resGetBody.replace('id', 'subId');
            ProcessOrderResponseWrapper jsonStrToWrapper=  (ProcessOrderResponseWrapper) System.JSON.deserialize(resGetBody, ProcessOrderResponseWrapper.class);
            ProcessOrderResponseWrapper response = (ProcessOrderResponseWrapper)jsonStrToWrapper; 
            system.debug('response '+ response);
            
            if(response.invoiceId== Null){
                responseMap.put('result',res.getBody());
                responseMap.put('responseType', 'warning');                 
                return responseMap;
            }
            
            String ResponseMessage='';

            try{
                Opportunity oppRec = [select id,StageName,Universal_Payment_Link__c,AccountId,Description,
                                      Invoice_Id__c,Subscription_Id__c,Adept_Customer_Id__c,Bill_to_Account__c,
                                      Message__c,Reseller__c  from Opportunity where id = : inputData.get('oppId')];

                Account accRec = [select id , Adept_Customer_Id__c,Subscription_Id__c 
                                  from ACCOUNT where Id =: oppRec.AccountId ];

                if(accRec.Adept_Customer_Id__c != null){
                    if(accRec.Adept_Customer_Id__c != response.endCustomerAdeptId){
                       responseMap.put('adeptCustomerIdCheck','Adept Customer Id('+ response.endCustomerAdeptId+') does not match with Account Adept Customer Id('+accRec.Adept_Customer_Id__c+').'); 
                     }
                }

                else{
                    accRec.Adept_Customer_Id__c = response.endCustomerAdeptId;
                    update accRec;
                }
                    
                oppRec.StageName = 'Closed Pending';
                oppRec.Universal_Payment_Link__c = response.universalPaymentLink;
                oppRec.Invoice_Id__c = response.invoiceId;
                oppRec.Subscription_Id__c = response.subscription.subId;
                oppRec.Adept_Customer_Id__c = response.endCustomerAdeptId;
                oppRec.Message__c = response.message;
                update oppRec;
                
                // check if renewal opportunity exist
                List<opportunity> renewalOppLst = [select id,AccountId from opportunity 
                                                   where AccountId =: oppRec.AccountId
                                                   and Type =: 'Renewal' order by CreatedDate Desc];
                
                List<Quote> quoteList = getSyncedQuoteForOpp(inputData.get('oppId'));
                if(renewalOppLst.size()>0){
                    // renewal opp exist
                    Quote newQuote =  QuoteUtility.CloneQuote(quoteList[0].id);
                    Datetime subEnddt = (DateTime)JSON.deserialize('"' + response.subscription.attrs.items[0].endDate + '"', DateTime.class);
                    Date subEnddate = date.newinstance(subEnddt.year(), subEnddt.month(), subEnddt.day());
                    newQuote.Start_Date__c = subEnddate;
                    newQuote.OpportunityId = renewalOppLst[0].id;
                    insert  newQuote;
                    renewalOppLst[0].SyncedQuoteId = newQuote.id;
                    update renewalOppLst[0];
                }
                else{
                    system.debug(quoteList[0]);
                    system.debug('endDate'+ response.subscription.attrs.items[0].endDate);
                    opportunity newOpp = new opportunity();
                    newOpp.AccountId = oppRec.AccountId;
                    newOpp.StageName = 'Open';
                    newOpp.Type = 'Renewal';
                    newOpp.License_Type__c =   quoteList[0].License_Type__c;
                    newOpp.License_Count__c = quoteList[0].License_Count__c;
                    newOpp.Term__c =  quoteList[0].Billing_Terms__c;
                    Datetime dt = (DateTime)JSON.deserialize('"' + response.subscription.attrs.items[0].endDate + '"', DateTime.class);
                    newOpp.Start_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                    newOpp.Bill_to_Account__c = oppRec.Bill_to_Account__c;
                    newOpp.Reseller__c = oppRec.Reseller__c;
                    insert newOpp;
                }
            }
            Catch(Exception ex){
                responseMap.put('result', ex.getMessage() + ' ProcessOrderCalloutHandler' + 'Line No ' + ex.getLineNumber()+' ' + ex.getCause());
                responseMap.put('responseType', 'warning');                 
                return responseMap;
            }
            system.debug('response' + response);
            responseMap.put('result', 'Process Order Successful.');
            responseMap.put('responseType', 'success');                 
            return responseMap;
        }
        Catch(Exception ex){
            HandleExceptionError.LogException('ProcessOrderCalloutHandler','makeHttpCallout',inputData.get('oppId'),ex,requestBody,res.getBody());
            responseMap.put('result', res.getBody());
            responseMap.put('responseType', 'warning');                 
            return responseMap;
        }
    }
    
    public static String createInputRequest(Map<String, String> inputData){
        

        Opportunity oppdata = [ select id , AccountId, Bill_to_Account__c,Account.Name,
                                Bill_to_Account__r.Name, Bill_to_Account__r.Billing_Email__c,
                                Bill_to_Account__r.Phone, Bill_to_Account__r.BillingStreet,
                                Bill_to_Account__r.BillingCity, Bill_to_Account__r.BillingState,
                                Bill_to_Account__r.BillingPostalCode, Bill_to_Account__r.BillingCountry,
                                Account.ShippingStreet, Account.ShippingCity,
                                Account.ShippingState, Account.ShippingPostalCode,
                                Account.ShippingCountry
                                from opportunity where id =: inputData.get('oppId') 
                                ];
        
		List<Quote> quoteList = getSyncedQuoteForOpp(inputData.get('oppId'));

        /**********************Initializing wrappers************* */
        ContractDetailWrapper contractDetailData = new ContractDetailWrapper();
        List<lineItemWrapper> lineItemDataList = new List<lineItemWrapper>();
        BillToWrapperRequest billToData = new BillToWrapperRequest();
        ShipToWrapperRequest shipToData = new ShipToWrapperRequest();
        OwnerWrapper ownerData = new OwnerWrapper();
		accountAdminWrapper adminData = new accountAdminWrapper();
        /******************************************************** */


        
        /***********************seting owner to data ************* */

    
        if(oppdata != null)
        {
            Contact[] conListOwner =  [Select id ,firstName, LastName, Email from Contact
                                where AccountId = : quoteList[0].BillToAccount_Id__c AND (Owner__c = true OR Admin__c = true)];
            if(conListOwner.size()>0){
                ownerData.firstName = conListOwner[0].firstName;
                ownerData.lastName = conListOwner[0].LastName;
                ownerData.company =  quoteList[0].BillingName;
                ownerData.email = conListOwner[0].Email;
            }
        }

        /********************************************************** */

        if(quoteList.size()>0){

            /***********************setting line item data ************* */
            for(QuoteLineItem qliRec : quoteList[0].QuoteLineItems){
                lineItemWrapper lineItemData = new lineItemWrapper();
                lineItemData.productId = qliRec.Product2.productcode;
                lineItemData.productFamilyId = 'dcbf3492-7ec1-452d-8f17-4a74da3d472e';
                lineItemData.quantity = qliRec.Quantity;
                lineItemData.percentDiscount = qliRec.Discount != null ? qliRec.Discount/100 : 0;
                lineItemData.unitPrice = qliRec.Original_Price__c ;
                lineItemData.startDate = String.valueof(qliRec.Start_Date__c);
                lineItemDataList.add(lineItemData);

                //setting up admin data
                adminData.firstName = quoteList[0].Admin_First_Name__c;
                adminData.lastName = quoteList[0].Admin_Last_Name__c;
                adminData.email = quoteList[0].Admin_Email__c;
            }
            /********************************************************** */

            /***********************seting line item data for tax code ************* */

            lineItemWrapper lineItemData3 = new lineItemWrapper();
            lineItemData3.productId = '998';
            lineItemData3.productFamilyId = 'TAX' ;
            lineItemData3.quantity = 1 ;
            lineItemData3.percentDiscount = 0.00;
            lineItemData3.unitPrice = quoteList[0].Tax ;
            lineItemData3.startDate = String.valueof(quoteList[0].Start_Date__c);
            
            lineItemDataList.add(lineItemData3);
            
            /********************************************************** */


            /***********************seting contract data ************* */

            contractDetailData.paymentTerm = quoteList[0].Billing_Terms__c ;
            contractDetailData.isUniversalPayment = true;
            contractDetailData.lineItems = lineItemDataList;

            /********************************************************** */


            /***********************seting bill to data ************* */


            AddressWrapper addressDataBill = new AddressWrapper();

            //setting up billing address
            addressDataBill.line1 = quoteList[0].BillingStreet;
            addressDataBill.city = quoteList[0].BillingCity;
            addressDataBill.state = quoteList[0].BillingState;
            addressDataBill.postalCode = quoteList[0].BillingPostalCode;
            addressDataBill.countryCode = quoteList[0].BillingCountry;

            //setting up billing info
            billToData.sfId = quoteList[0].BillToAccount_Id__c;
            billToData.accountName =quoteList[0].BillingName;
            billToData.email =quoteList[0].Billing_Email__c;
            billToData.company = quoteList[0].BillingName;
            billToData.address = addressDataBill;

            /********************************************************** */


            /***********************seting ship to data ************* */


            //setting up shipping address
            AddressWrapper addressDataShip = new AddressWrapper();
            addressDataShip.line1 =quoteList[0].ShippingStreet;
            addressDataShip.city =quoteList[0].ShippingCity;
            addressDataShip.state =quoteList[0].ShippingState;
            addressDataShip.postalCode =quoteList[0].ShippingPostalCode;
            addressDataShip.countryCode =quoteList[0].ShippingCountry;
            
             //setting up shipping info
            shipToData.sfId =  oppdata.AccountId;
            shipToData.accountName = quoteList[0].BillingName;
            shipToData.address = addressDataShip;

            /********************************************************** */
        } 
        

        ProcessOrderRequestWrapper data = new ProcessOrderRequestWrapper();

        data.opportunityId =  inputData.get('oppId');        
        data.billTo = billToData;
        data.shipTo = shipToData;
        data.owner = ownerData;
        data.contractDetails = contractDetailData;
        if(adminData.lastName!=null && adminData.email !=null)
        {
            data.accountAdmin = adminData;
        }
        
        system.debug(' data.billTo ' +  data.billTo);
        system.debug(' data.shipTo ' +  data.shipTo);

        String jsonStr = JSON.serializePretty(data);

        return jsonStr;
    }
    
    public static List<Quote> getSyncedQuoteForOpp( String oppId){
    
    Quote[] quoteList = [select id,Tax ,Opportunity.Tax_Exempt__c,Start_Date__c,AccountId,Account.Name,BillToAccount_Id__c,Admin_Email__c,Admin_First_Name__c,Admin_Last_Name__c,
                         License_Type__c,License_Count__c,
                         Billing_Email__c,Billing_Terms__c,BillingName,
                         BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,
                         ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,
                         (select id,Product2.productcode,Quantity,Discount,UnitPrice,
                          Start_Date__c,Do_Not_Sync_Original_Price__c,Original_Price__c from  QuoteLineItems)
                         from Quote where OpportunityId =: oppId and IsSyncing = true];
        return quoteList;
    }
    Public class ProcessOrderResponseWrapper{
        Public String universalPaymentLink;
        Public String invoiceId;
        Public String endCustomerAdeptId;
        Public SubscriptionResponseWrapper subscription;
        Public String message;
    }
    
    Public class SubscriptionResponseWrapper{
        Public String subid;
        Public String custId;
        Public String endCustId;
        Public String created;
        Public String updated;
        Public AttrsResponseWrapper attrs;
    }
    
    Public class AttrsResponseWrapper{
        Public Boolean autorenew;
        Public List<ItemsResponseWrapper> items;
        Public String billTo;
        Public String shipTo;
    }
    
    Public class ItemsResponseWrapper{
        Public String productFamilyId;
        Public Decimal unitPrice;
        Public Decimal quantity;
        Public Id productId;
        Public Boolean freeTrial;
        Public String endDate;
        Public Decimal durationOverride;
        Public String priceId;
        Public String startDate;
    }
    
    Public class ProcessOrderRequestWrapper{
        Public string apiKey;
        Public string env;
        Public Id opportunityId;
        Public BillToWrapperRequest billTo;
        Public ShipToWrapperRequest shipTo;
        Public OwnerWrapper owner;
        Public ContractDetailWrapper contractDetails;
        Public accountAdminWrapper accountAdmin;
    }

    public class  accountAdminWrapper{
        public string email;
        public string lastName;
        public string firstName;
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
        public Id sfId;
        public string accountName;
        public string email;
        public string company;
        public AddressWrapper address;
    }
     
    public class ShipToWrapperRequest{
        public Id sfId;
        public string accountName;
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