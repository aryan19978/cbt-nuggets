public class SalesTaxCalloutHandler {
    public static Map<String,String> makeHttpCallout(Map<String, String> inputData){
        string requestBody = createInputRequest(inputData);
        Map<String,String> responseMap = SalesTaxCallout(inputData,requestBody);
        return responseMap;
    }
    
    public static String createInputRequest(Map<String, String> inputData){
        Quote quoteRec = [select id,Tax,AccountId,ShippingStreet,ShippingCity, ShippingState,
                          ShippingPostalCode,ShippingCountry,Early_Renewal__c,
                          End_Date__c,Override_End_Date__c,
                          Account.Adept_Customer_Id__c ,OpportunityId,
                          Opportunity.Tax_Exempt__c,Opportunity.Tax_Exempt_Reason__c,Opportunity.Exemption_No__c,
                          Opportunity.Tax_Exempt_Expiration_Date__c
                          from Quote where Id =: inputData.get('quoteId')];
       
        //Opportunity oppdata = [ select id
        //                        from opportunity where id =: quoteRec.OpportunityId ];
        
        subscriptionlocation  location = new subscriptionlocation();
        location.line1 =    quoteRec.ShippingStreet;
        location.city = quoteRec.ShippingCity;
        location.state = quoteRec.ShippingState;
        location.postalCode = quoteRec.ShippingPostalCode;
        location.countryCode = quoteRec.ShippingCountry;
        
        SubscriptionCustomerDetail customerDetail = new SubscriptionCustomerDetail(); 
        customerDetail.adeptCustomerId = quoteRec.Account.Adept_Customer_Id__c;
        customerDetail.salesforceCustomerId = quoteRec.AccountId;
        customerDetail.location = location;
        
        List<SubscriptionLineItem> lineItems = new List<SubscriptionLineItem>();
        
        List<String> ProductCodeListToInclude = new List<String>{'100','105'};
        List<QuoteLineItem> qliRecList = [select id,UnitPrice,Product2.productcode,Quantity,
                                              Discount,Start_Date__c,End_Date__c,Description,Original_Price__c,
                                          	  Duration__c
                                              FROM QuoteLineItem where QuoteId =: inputData.get('quoteId')
                                              and Product2.productcode in : ProductCodeListToInclude];
        
        for(QuoteLineItem qliRec : qliRecList){
            SubscriptionLineItem lineItem = new SubscriptionLineItem();
            lineItem.productId = qliRec.Product2.productcode;
            lineItem.productFamilyId = System.Label.productFamilyId;
            lineItem.quantity = qliRec.Quantity;
            lineItem.percentDiscount = qliRec.Discount != null ? qliRec.Discount/100 : 0;
            lineItem.unitPrice = qliRec.Original_Price__c ;
            lineItem.startDate = String.valueof(qliRec.Start_Date__c);
            lineItem.description = qliRec.Description;
            if( quoteRec.Override_End_Date__c == true){
                lineItem.durationOverride = qliRec.Duration__c;
            }
            else{
                lineItem.durationOverride = 0;
            }
            
            lineItems.add(lineItem);
        }
        
        SubscriptionPurchaseDetail purchaseDetail = new SubscriptionPurchaseDetail();
        purchaseDetail.lineItems = lineItems;
        
        if(quoteRec.Early_Renewal__c == true){
            purchaseDetail.earlyRenewal = quoteRec.Early_Renewal__c;
        }
        if(quoteRec.Opportunity.Tax_Exempt__c == true && (quoteRec.Opportunity.Tax_Exempt_Expiration_Date__c <= Date.today() || quoteRec.Opportunity.Tax_Exempt_Expiration_Date__c == null) ){
            TaxExemptionWrapper TaxExemptionWrap = new TaxExemptionWrapper();
            TaxExemptionWrap.exemptionNo = quoteRec.Opportunity.Exemption_No__c;
            TaxExemptionWrap.entityUseCode = quoteRec.Opportunity.Tax_Exempt_Reason__c;
            TaxExemptionWrap.expirationDate = quoteRec.Opportunity.Tax_Exempt_Expiration_Date__c;
            purchaseDetail.taxExemption = TaxExemptionWrap;
        }
        if(quoteRec.Override_End_Date__c == true){
            purchaseDetail.newEndDate = quoteRec.End_Date__c;
        }
        subscriptionWrapper data = new subscriptionWrapper();
        data.apiKey = HttpCalloutUtility.getValueCustomMetadata('apiKey');
        data.purchaseDetails = purchaseDetail;
        data.customerDetails = customerDetail;
        String jsonStr = JSON.serialize(data,true); // serialize(Object objectToSerialize, Boolean suppressApexObjectNulls) suppressApexObjectNulls => Type: Boolean If true, remove null values before serializing the JSON object.
        system.debug('Sales Tax Request' + jsonStr);
        return jsonStr;
    }
    
    
    public static Map<String,String> SalesTaxCallout(Map<String, String> inputData, string jsonString){
        HTTPResponse res;
        Map<String,String> responseMap = new Map<String,String>();
        try{
            system.debug('Sales Tax Request' + jsonString);
            HttpCalloutService service = new HTTPCalloutService('GetSalesTax');
            service.setRequestBody(jsonString);
            
            service.setHeaderParameter('adept-apikey', HttpCalloutUtility.getValueCustomMetadata('apiKey'));
            service.setHeaderParameter('adept-billing-env', HttpCalloutUtility.getValueCustomMetadata('env'));
            service.setHeaderParameter('adept-billing-sfuserid', UserInfo.getUserId());
            
            res = service.sendRequest();
            system.debug('Sales Tax Response' + res.getBody());
            
            SalesTaxResponseWrapper jsonStrToWrapper=  (SalesTaxResponseWrapper) System.JSON.deserialize(res.getBody(), SalesTaxResponseWrapper.class);
            try{
                SalesTaxResponseWrapper response = (SalesTaxResponseWrapper)jsonStrToWrapper;
                system.debug(response.quoteType);
                PurchaseDetailWrapper purchaseDetail = (PurchaseDetailWrapper)response.purchaseDetails;
                system.debug(purchaseDetail);
                Decimal taxValue;
                Date startDate;
                Date endDate;
                Map<String, lineItemsWrapper> productCodeLineItemMap = new  Map<String, lineItemsWrapper>();
                
                for(lineItemsWrapper lineItem : purchaseDetail.lineItems){
                    productCodeLineItemMap.put(lineItem.productId,lineItem);
                    // To get Taxvalue from 998 which we will update on Quote
                    if(lineItem.productId == '998'){
                        taxValue = lineItem.unitPrice;
                        startDate = Date.valueof(lineItem.startDate);
                        endDate = Date.valueof(lineItem.endDate);
                    }
                }
                
                Quote quoteRec = [select id,Tax ,End_Date__c,License_Type__c,Pricebook2Id,
                                  Opportunity.Tax_Exempt__c,Opportunity.Tax_Exempt_Reason__c,OpportunityId,
                                  Opportunity.Exemption_No__c,Opportunity.Tax_Exempt_Expiration_Date__c,
                                  (select id,Product2.productcode,Quantity,
                                   Discount,UnitPrice,Start_Date__c,End_Date__c,
                                   Do_Not_Sync_Original_Price__c,Original_Price__c
                                   from  QuoteLineItems)
                                  from Quote where Id =: inputData.get('quoteId')];
                // Update Quote
                system.debug('taxValue' + taxValue);
                quoteRec.Tax = taxValue;
                quoteRec.Quote_Type__c           = response.quoteType;
                quoteRec.Start_Date__c           = startDate;
                quoteRec.End_Date__c             = endDate;
                quoteRec.ShippingStreet          = response.validatedAddress.line1;
                quoteRec.ShippingCity            = response.validatedAddress.city;
                quoteRec.ShippingState           = response.validatedAddress.state;
                quoteRec.ShippingPostalCode      = response.validatedAddress.postalCode;
                quoteRec.ShippingCountry         = response.validatedAddress.countryCode;
                update quoteRec;
                // Update Quote End
                
                // Update Opportunity
                Opportunity oppRec = [select id,Start_Date__c,End_Date__c from Opportunity where id =: quoteRec.OpportunityId];
                oppRec.Start_Date__c = startDate;
                oppRec.End_Date__c = endDate;
                update oppRec;
                    
                list<QuoteLineItem> quoteLineItemListUpdate = new list<QuoteLineItem>();
                list<QuoteLineItem> quoteLineItemListInsert = new list<QuoteLineItem>();
                
                Map<String,QuoteLineItem> qliMap = new Map<String,QuoteLineItem>();
                
                for(QuoteLineItem qliRec : quoteRec.QuoteLineItems){
                    qliMap.put(qliRec.Product2.productcode,qliRec); 
                }
                // Prodcut Code which we have to run logic
                List<String> productCodeList = new List<String>{'915','900','910'};
                    
                    List<PricebookEntry> priceBkEntryList = [SELECT Id, Pricebook2Id, Product2Id, UnitPrice, IsActive,ProductCode
                                                             FROM PricebookEntry 
                                                             where Pricebook2Id =: quoteRec.Pricebook2Id and 
                                                             ProductCode  in:  productCodeList];
                
                Map<String,PricebookEntry> productCd_prbkEntryMap = new Map<String,PricebookEntry>();
                For(PricebookEntry pbe : priceBkEntryList){
                    productCd_prbkEntryMap.put(pbe.ProductCode,pbe);
                    System.debug('Product Code in System for this pricebook' + pbe.ProductCode);
                }
                
                for(lineItemsWrapper lineItem : purchaseDetail.lineItems){
                    if(qliMap.containsKey(lineItem.productId)){
                        system.debug('lineItem.productId '+ lineItem.productId);
                        QuoteLineItem qliRecord = qliMap.get(lineItem.productId);
                        qliRecord.Start_Date__c                   = Date.valueof(lineItem.startDate);
                        qliRecord.End_Date__c                     = Date.valueof(lineItem.endDate);
                        qliRecord.UnitPrice                       = lineItem.unitPrice;
                        qliRecord.Do_Not_Sync_Original_Price__c   = true;// We are again setting Do_Not_Sync_Original_Price__c to true so flow cannot execute at this time
                        if(lineItem.description != '' ){
                            qliRecord.Description = lineItem.description;
                        }
                        quoteLineItemListUpdate.add(qliRecord);
                        System.debug('qliRecord' + qliRecord.id);
                    }
                    else{
                        if(productCodeList.contains(lineItem.productId)){
                            String PricebookEntryId = productCd_prbkEntryMap.get(lineItem.productId).id;
                            String Product2Id = productCd_prbkEntryMap.get(lineItem.productId).Product2Id;
                            // Create a new QuoteLineItem object
                            QuoteLineItem newQuoteLineItem = new QuoteLineItem();
                            
                            // Set the required fields for the QuoteLineItem
                            newQuoteLineItem.QuoteId           = quoteRec.Id; 
                            newQuoteLineItem.PricebookEntryId  = PricebookEntryId; 
                            newQuoteLineItem.Product2Id        = Product2Id;
                            newQuoteLineItem.Quantity          = lineItem.quantity; 
                            newQuoteLineItem.UnitPrice         = lineItem.unitPrice; 
                            newQuoteLineItem.Start_Date__c     = Date.valueof(lineItem.startDate);
                            newQuoteLineItem.End_Date__c       = Date.valueof(lineItem.endDate);
                            if(lineItem.description != '' ){
                                newQuoteLineItem.Description = lineItem.description;
                            }
                            quoteLineItemListInsert.add(newQuoteLineItem);
                        }
                    }
                }
                if(quoteLineItemListInsert.size()>0){
                    Insert quoteLineItemListInsert;
                }
                System.debug('quoteLineItemListUpdate '+quoteLineItemListUpdate);
                if(quoteLineItemListUpdate.size()>0){
                    update quoteLineItemListUpdate;
                }
                for(QuoteLineItem qliRed: quoteLineItemListUpdate){
                    qliRed.Do_Not_Sync_Original_Price__c = false;
                    // We are again setting it to false so flow can execute from next time,
                    //  basically we have to stop it for api update so we set it to true above and now again to false
                }
                update quoteLineItemListUpdate;
                String taxInfo;
                if(quoteRec.Opportunity.Tax_Exempt__c){
                    if(quoteRec.Opportunity.Tax_Exempt_Expiration_Date__c <= Date.today()){
                        taxInfo = 'Sales Tax is exempted';
                    }
                    else{
                        taxInfo = 'Sales Tax Exemption was expired';
                    }
                }
                else{
                       taxInfo = 'Sales Tax is calculated successfully';                
                }
                
                String taxValueOutput = '$' + String.valueOf(taxValue.format());
                responseMap.put('response', taxInfo + ', Tax is : ' + taxValueOutput);
                responseMap.put('responseType','success');
                return responseMap;
            }
            Catch(exception ex){
                system.debug(ex.getMessage() + ex.getLineNumber() +ex.getCause());
                responseMap.put('response','Error Message: ' + ex.getMessage() + ', Error Line: ' + ex.getLineNumber() );
                responseMap.put('responseType','warning');
                return responseMap;
            }
        }
        Catch(exception ex){
            system.debug(ex.getMessage() + ex.getLineNumber() +ex.getCause());
            responseMap.put('response',res.getBody());
            responseMap.put('responseType','warning');
            return responseMap;
        }
    }
    
    // create json for Sales Tax output end point
    Public class SalesTaxResponseWrapper{
        Public PurchaseDetailWrapper purchaseDetails;
        Public String quoteType;
        Public validatedAddressWrapper validatedAddress;
    } 
    
    Public class PurchaseDetailWrapper{
        Public List<lineItemsWrapper> lineItems;
    } 
    
    Public class lineItemsWrapper{
        Public String productId;
        Public String productFamilyId;
        Public Decimal quantity;
        Public Decimal percentDiscount;
        Public Decimal unitPrice;
        Public Decimal total;
        Public String startDate;
        Public String endDate;
        Public String description;
    } 
    
    Public class validatedAddressWrapper{
        Public String line1;
        Public String line2;
        Public String city;
        Public String state;
        Public String countryCode;
        Public String postalCode;
    }
    
    // create json for Sales Tax input end point
    Public class subscriptionWrapper{
        Public String apiKey;
        Public SubscriptionPurchaseDetail purchaseDetails;
        Public SubscriptionCustomerDetail customerDetails;
    }
    Public class SubscriptionPurchaseDetail{
        Public List<SubscriptionLineItem> lineItems;
        Public Boolean earlyRenewal;
        Public TaxExemptionWrapper taxExemption;
        Public Date newEndDate;
    }
    public class TaxExemptionWrapper{
        Public string exemptionNo;
        Public string entityUseCode;
        Public Date expirationDate; 
    }
    Public class SubscriptionLineItem{
        Public String productId;
        Public String productFamilyId;
        Public Decimal quantity;
        Public Decimal percentDiscount;
        Public Decimal unitPrice;
        Public String startDate;
        Public String description;
        Public Decimal durationOverride;
        
    }
    Public class SubscriptionCustomerDetail{ 
        Public String adeptCustomerId;
        Public String salesforceCustomerId;
        Public Subscriptionlocation location;
    }
    Public class Subscriptionlocation{ 
        Public String line1;
        Public String city;
        Public String state;
        Public String postalCode;
        Public String countryCode;
    }
}