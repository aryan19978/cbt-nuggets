public class ReverseInvoiceCalloutHandler {
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
            ReverseResponseWrapper jsonStrToWrapper=  (ReverseResponseWrapper) System.JSON.deserialize(res.getBody(), ReverseResponseWrapper.class);
            system.debug('jsonStrToWrapper ' + jsonStrToWrapper);
            ReverseResponseWrapper response = (ReverseResponseWrapper)jsonStrToWrapper; 
            system.debug('response '+ response);
            
            if(response.invoiceId== Null || response.success == false){
                responseMap.put('result',res.getBody());
                responseMap.put('responseType', 'warning');                 
                return responseMap;
            }
            else{
                if(response.success == true){
                    responseMap.put('result','Reverse Successful.');
                }
                else{
                    responseMap.put('result', res.getBody()); 
                }
                responseMap.put('responseType', 'success');
                responseMap.put('invoiceId', response.invoiceId);
                responseMap.put('success', String.valueof(response.success));
                responseMap.put('reversalInvoiceId', response.reversalInvoiceId);
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
        ReverseRequestWrapper data = new ReverseRequestWrapper();
        data.invoiceId = inputData.get('invoiceId');
        String requestBodyStr = JSON.serializePretty(data);
        return requestBodyStr;
    }

	// Request Wrapper Class
    Public class ReverseRequestWrapper{
        Public String invoiceId;
    } 
    
    // Response Wrapper Class
    Public class ReverseResponseWrapper{
        Public String invoiceId;
        Public Boolean success;
        Public String reversalInvoiceId;
    } 
    
}