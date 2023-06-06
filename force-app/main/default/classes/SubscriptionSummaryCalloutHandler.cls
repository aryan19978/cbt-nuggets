public class SubscriptionSummaryCalloutHandler {
    public static Map<String,String> makeHttpCallout(Map<String, String> inputData){
        HttpCalloutService service = new HTTPCalloutService(inputData.get('calloutType'));
        // Set Header
        service.setHeaderParameter('adept-apikey', HttpCalloutUtility.getValueCustomMetadata('apiKey'));
        service.setHeaderParameter('adept-billing-env', HttpCalloutUtility.getValueCustomMetadata('env'));
        service.setHeaderParameter('adept-billing-sfuserid', UserInfo.getUserId());
        // create request body
        string requestBodyStr = createInputRequest(inputData);
        service.setRequestBody(requestBodyStr);
        HTTPResponse res = service.sendRequest();
        Map<String,String> responseMap = new Map<String,String>();
        try{
            SubscriptionSummaryResponseWrapper jsonStrToWrapper=  (SubscriptionSummaryResponseWrapper) System.JSON.deserialize(res.getBody(), SubscriptionSummaryResponseWrapper.class);
            system.debug('jsonStrToWrapper ' + jsonStrToWrapper);
            SubscriptionSummaryResponseWrapper response = (SubscriptionSummaryResponseWrapper)jsonStrToWrapper; 
            system.debug('response '+ response);
            
            if(response.subscription == Null ){
                responseMap.put('result',res.getBody());
                responseMap.put('responseType', 'warning');                 
                return responseMap;
            }
            else{
                responseMap.put('responseType', 'success');
                responseMap.put('startDate', response.subscription.startDate);
                responseMap.put('endDate', response.subscription.endDate);
                responseMap.put('quantity', String.valueof(response.subscription.items[0].quantity));
            }
        }
        Catch(Exception ex){
            responseMap.put('result', res.getBody() );
            System.debug(ex.getCause() + ex.getMessage() + ex.getTypeName());    
            responseMap.put('responseType', 'warning');
        }
        return responseMap;
    }
    
    public static String createInputRequest(Map<String, String> inputData){
        SubscriptionSummaryRequestWrapper data = new SubscriptionSummaryRequestWrapper();
        data.idIs = '10000079';
        data.typeIs = 'SALESFORCE_ID';
        String requestBodyStr = JSON.serializePretty(data);
        requestBodyStr = requestBodyStr.replace('idIs', 'id').replace('typeIs', 'type');
        return requestBodyStr;
    }
        
	// Request Wrapper Class
    Public class SubscriptionSummaryRequestWrapper{
        Public String idIs;
        Public String typeIs;
    } 
    
    // Response Wrapper Class
    Public class SubscriptionSummaryResponseWrapper{
        Public SubscriptionWrapper subscription;
    }
    Public class SubscriptionWrapper{
        Public string startDate;
        Public string endDate;
        Public Boolean autoRenew;
        Public Boolean freeTrial;
        Public List<itemsWrapper> items;
            
    }
    Public class itemsWrapper{
        Public String productId;
        Public Integer quantity;
    }  
}