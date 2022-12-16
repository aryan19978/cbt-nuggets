public class SalesTaxCalloutHandler {
    public static String makeHttpCallout(Map<String, String> inputData){
        string requestBody = createInputRequest(inputData);
        string response = SalesTaxCallout(inputData,requestBody);
        return response;
    }
    
    public static String createInputRequest(Map<String, String> inputData){
        Quote quoteRec = [select id,Tax,AccountId,BillingStreet,BillingCity, BillingState, BillingPostalCode,BillingCountry from Quote where Id =: inputData.get('quoteId')];
            subscriptionlocation  location = new subscriptionlocation();
            location.line1 =    quoteRec.BillingStreet;
            location.city = quoteRec.BillingCity;
            location.state = quoteRec.BillingState;
            location.postalCode = quoteRec.BillingPostalCode;
            location.countryCode = quoteRec.BillingCountry;
                 
            SubscriptionCustomerDetail customerDetail = new SubscriptionCustomerDetail(); 
         	customerDetail.adeptCustomerId = 'dylan-10000022';
        	customerDetail.salesforceCustomerId = 'fakeSfCustomerid3b8dadee-33fe-4254-a9b2-f0983c5839cd';//quoteRec.AccountId;
            
        	customerDetail.location = location;
            
            List<SubscriptionLineItem> lineItems = new List<SubscriptionLineItem>();
            
            List<QuoteLineItem> qliRecList = [select id,UnitPrice,Product2.productcode,Quantity,
                                              Discount,Start_Date__c,Description,Original_Price__c 
                                             FROM QuoteLineItem where QuoteId =: inputData.get('quoteId')];
            
            
            for(QuoteLineItem qliRec : qliRecList){
                SubscriptionLineItem lineItem = new SubscriptionLineItem();
                lineItem.productId = qliRec.Product2.productcode;
                lineItem.productFamilyId = '';
                lineItem.quantity = qliRec.Quantity;
                lineItem.percentDiscount = qliRec.Discount;
                lineItem.unitPrice = qliRec.Original_Price__c ;
                lineItem.startDate = String.valueof(qliRec.Start_Date__c);
                lineItem.description = qliRec.Description;
                lineItems.add(lineItem);
            }
            
            SubscriptionPurchaseDetail purchaseDetail = new SubscriptionPurchaseDetail();
            purchaseDetail.lineItems = lineItems;
            
            subscriptionWrapper data = new subscriptionWrapper();
            data.apiKey = HttpCalloutUtility.getValueCustomMetadata('apiKey');
            data.purchaseDetails = purchaseDetail;
            data.customerDetails = customerDetail;
            String jsonStr = JSON.serialize(data);
        	system.debug('jsonStr' + jsonStr);
            return jsonStr;
    }
    
    
    public static String SalesTaxCallout(Map<String, String> inputData, string jsonString){
        HTTPResponse res;
        try{
            system.debug('input request' + jsonString);
            HttpCalloutService service = new HTTPCalloutService('GetSalesTax');
            service.setRequestBody(jsonString);
            res = service.sendRequest();
            system.debug(res.getBody());
            
            SalesTaxResponseWrapper jsonStrToWrapper=  (SalesTaxResponseWrapper) System.JSON.deserialize(res.getBody(), SalesTaxResponseWrapper.class);
            try{
                SalesTaxResponseWrapper response = (SalesTaxResponseWrapper)jsonStrToWrapper;
                system.debug(response.quoteType);
                PurchaseDetailWrapper purchaseDetail = (PurchaseDetailWrapper)response.purchaseDetails;
                system.debug(purchaseDetail);
                Decimal taxValue;
                Date startDate;
                Map<String, lineItemsWrapper> productCodeLineItemMap = new  Map<String, lineItemsWrapper>();
                for(lineItemsWrapper lineItem : purchaseDetail.lineItems){
                    productCodeLineItemMap.put(lineItem.productId,lineItem);
                    system.debug(lineItem);
                    system.debug(lineItem.productId);
                    if(lineItem.productId == '998'){
                        taxValue = lineItem.unitPrice;
                        startDate = Date.valueof(lineItem.startDate);
                    }
                }  
                system.debug('taxValue' + taxValue);
                Quote quoteRec = [select id,Tax ,Opportunity.Tax_Exempt__c, (select id,Product2.productcode,Quantity,
                                                 Discount,UnitPrice,Start_Date__c,
                                                 Do_Not_Sync_Original_Price__c,Original_Price__c
                                                  from  QuoteLineItems)
                                  from Quote where Id =: inputData.get('quoteId')];
                if(quoteRec.Opportunity.Tax_Exempt__c){
                	quoteRec.Tax = 0.00;
                }else{
                    quoteRec.Tax = taxValue;
                }
                quoteRec.Quote_Type__c = response.quoteType;
                quoteRec.Start_Date__c = startDate;
                
                list<QuoteLineItem> quoteLineItemList = new list<QuoteLineItem>();
                for(QuoteLineItem qliRec : quoteRec.QuoteLineItems){
                    system.debug(qliRec.Product2.productcode);
                    lineItemsWrapper lineItem = productCodeLineItemMap.get(qliRec.Product2.productcode);
                    qliRec.Start_Date__c = Date.valueof(lineItem.startDate);
                    qliRec.UnitPrice = lineItem.unitPrice; 
                    if(lineItem.description != '' ){
                        qliRec.Description = lineItem.description;
                    }
                    qliRec.Do_Not_Sync_Original_Price__c = true;
                    quoteLineItemList.add(qliRec);
                }
                update quoteLineItemList;
                update quoteRec;
                
                for(QuoteLineItem qliRed: quoteLineItemList){
                    qliRed.Do_Not_Sync_Original_Price__c = false;
                }
                update quoteLineItemList;
                if(quoteRec.Opportunity.Tax_Exempt__c){
                    return 'Sales Tax is exempted. Tax is : 0' ;
                }
                else{
                    return 'Sales Tax is calculated successfully. Tax is : ' + taxValue;
                }
            }
            Catch(exception ex){
                system.debug(ex.getMessage() + ex.getLineNumber() +ex.getCause());
                return ex.getMessage() + ex.getLineNumber() +ex.getCause();
            }
        }
        Catch(exception ex){
            system.debug(res.getBody());
            return res.getBody();
        }
    }
    
    // create json for Sales Tax output end point
    Public class SalesTaxResponseWrapper{
        Public PurchaseDetailWrapper purchaseDetails;
        Public String quoteType;
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
        Public String startDate;
        Public String description;
    } 
    
    // create json for Sales Tax input end point
    Public class subscriptionWrapper{
        Public String apiKey;
        Public SubscriptionPurchaseDetail purchaseDetails;
        Public SubscriptionCustomerDetail customerDetails;
    }
    Public class SubscriptionPurchaseDetail{
        Public List<SubscriptionLineItem> lineItems;
    }
    Public class SubscriptionLineItem{
        Public String productId;
        Public String productFamilyId;
        Public Decimal quantity;
        Public Decimal percentDiscount;
        Public Decimal unitPrice;
        Public String startDate;
        Public String description;
        
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