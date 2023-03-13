public class SalesTaxCalloutHandler {
    public static Map<String,String> makeHttpCallout(Map<String, String> inputData){
        string requestBody = createInputRequest(inputData);
        Map<String,String> responseMap = SalesTaxCallout(inputData,requestBody);
        return responseMap;
    }
    
    public static String createInputRequest(Map<String, String> inputData){
        Quote quoteRec = [select id,Tax,AccountId,BillingStreet,BillingCity, BillingState,
                          BillingPostalCode,BillingCountry,Early_Renewal__c,
                          Account.Adept_Customer_Id__c 
                          from Quote where Id =: inputData.get('quoteId')];
            subscriptionlocation  location = new subscriptionlocation();
            location.line1 =    quoteRec.BillingStreet;
            location.city = quoteRec.BillingCity;
            location.state = quoteRec.BillingState;
            location.postalCode = quoteRec.BillingPostalCode;
            location.countryCode = quoteRec.BillingCountry;
                 
            SubscriptionCustomerDetail customerDetail = new SubscriptionCustomerDetail(); 
         	customerDetail.adeptCustomerId = quoteRec.Account.Adept_Customer_Id__c;
        	customerDetail.salesforceCustomerId = quoteRec.AccountId;
        	customerDetail.location = location;
            
            List<SubscriptionLineItem> lineItems = new List<SubscriptionLineItem>();
            
            List<QuoteLineItem> qliRecList = [select id,UnitPrice,Product2.productcode,Quantity,
                                              Discount,Start_Date__c,Description,Original_Price__c 
                                             FROM QuoteLineItem where QuoteId =: inputData.get('quoteId')];
            
            
            for(QuoteLineItem qliRec : qliRecList){
                SubscriptionLineItem lineItem = new SubscriptionLineItem();
                lineItem.productId = qliRec.Product2.productcode;
                lineItem.quantity = qliRec.Quantity;
                lineItem.percentDiscount = qliRec.Discount != null ? qliRec.Discount/100 : 0;
                lineItem.unitPrice = qliRec.Original_Price__c ;
                lineItem.startDate = String.valueof(qliRec.Start_Date__c);
                lineItem.description = qliRec.Description;
                lineItems.add(lineItem);
            }
            
            SubscriptionPurchaseDetail purchaseDetail = new SubscriptionPurchaseDetail();
            purchaseDetail.lineItems = lineItems;
        	purchaseDetail.earlyRenewal = quoteRec.Early_Renewal__c;
            
            subscriptionWrapper data = new subscriptionWrapper();
            data.apiKey = HttpCalloutUtility.getValueCustomMetadata('apiKey');
            data.purchaseDetails = purchaseDetail;
            data.customerDetails = customerDetail;
            String jsonStr = JSON.serialize(data);
        	jsonStr = jsonStr.remove(',"earlyRenewal":false'); // if Early Renewal is false than we have to remove it from request
        	system.debug('Sales Tax Request' + jsonStr);
            return jsonStr;
    }
    
    
    public static Map<String,String> SalesTaxCallout(Map<String, String> inputData, string jsonString){
        HTTPResponse res;
        Map<String,String> responseMap = new Map<String,String>();
        try{
            system.debug('input request' + jsonString);
            HttpCalloutService service = new HTTPCalloutService('GetSalesTax');
            service.setRequestBody(jsonString);
            
            service.setHeaderParameter('adept-apikey', HttpCalloutUtility.getValueCustomMetadata('apiKey'));
            service.setHeaderParameter('adept-billing-env', HttpCalloutUtility.getValueCustomMetadata('env'));
            service.setHeaderParameter('adept-billing-sfuserid', UserInfo.getUserId());
            
            res = service.sendRequest();
            system.debug('response' + res.getBody());
            
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
                Quote quoteRec = [select id,Tax ,Opportunity.Tax_Exempt__c,End_Date__c,License_Type__c, (select id,Product2.productcode,Quantity,
                                                 Discount,UnitPrice,Start_Date__c,End_Date__c,
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
                quoteRec.End_Date__c  =  QuoteUtility.getEndDate(startDate,quoteRec.License_Type__c);
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
                    responseMap.put('response','Sales Tax is exempted.');
                    responseMap.put('responseType','Success');
                    return responseMap;
                }
                else{
                    String taxValueOutput = '$' + String.valueOf(taxValue.format());
                    responseMap.put('response','Sales Tax is calculated successfully. Tax is : ' + taxValueOutput);
                    responseMap.put('responseType','success');
                    return responseMap;
                }
            }
            Catch(exception ex){
                system.debug(ex.getMessage() + ex.getLineNumber() +ex.getCause());
                responseMap.put('response',ex.getMessage() + ex.getLineNumber() +ex.getCause());
                responseMap.put('responseType','warning');
                return responseMap;
            }
        }
        Catch(exception ex){
            HandleExceptionError.LogException('SalesTaxCalloutHandler','SalesTaxCallout',inputData.get('quoteId'),ex,jsonString,res.getBody());
            responseMap.put('response',res.getBody());
            responseMap.put('responseType','warning');
            return responseMap;
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
        Public Boolean earlyRenewal;
    }
    Public class SubscriptionLineItem{
        Public String productId;
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