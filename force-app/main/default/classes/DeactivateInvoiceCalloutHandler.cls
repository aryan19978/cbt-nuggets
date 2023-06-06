public class DeactivateInvoiceCalloutHandler {
    public static Map<String,String> makeHttpCallout(Map<String, String> inputData){
        HttpCalloutService service = new HTTPCalloutService(inputData.get('calloutType'));
        // Set Header
        service.setHeaderParameter('adept-apikey', HttpCalloutUtility.getValueCustomMetadata('apiKey'));
        service.setHeaderParameter('adept-billing-env', HttpCalloutUtility.getValueCustomMetadata('env'));
        service.setHeaderParameter('adept-billing-sfuserid', UserInfo.getUserId());
        // create request body
        string requestBodyStr = createInputRequest(inputData);
        service.setRequestBody(requestBodyStr);
        system.debug(requestBodyStr);
        HTTPResponse res = service.sendRequest();
        Map<String,String> responseMap = new Map<String,String>();
        try{
            DeactivateInvoiceResponseWrapper jsonStrToWrapper=  (DeactivateInvoiceResponseWrapper) System.JSON.deserialize(res.getBody(), DeactivateInvoiceResponseWrapper.class);
            system.debug('jsonStrToWrapper ' + jsonStrToWrapper);
            DeactivateInvoiceResponseWrapper response = (DeactivateInvoiceResponseWrapper)jsonStrToWrapper; 
            system.debug('response '+ response);
            
            if(response.invoiceId== Null){
                responseMap.put('result',res.getBody());
                responseMap.put('responseType', 'warning');                 
                return responseMap;
            }
            else{
                if(response.success == true){
                    responseMap.put('result', 'Invoice Deactivated Successfully.');
                }
                else{
                   responseMap.put('result', res.getBody()); 
                }
                responseMap.put('responseType', 'success');
                responseMap.put('invoiceId', response.invoiceId);
                responseMap.put('success', String.valueof(response.success));
            }
        }
        Catch(Exception ex){
            	responseMap.put('result', + res.getBody() );
            	System.debug('Error Handle: ' + ex.getCause() + ex.getMessage() + ex.getTypeName());
                responseMap.put('responseType', 'warning');
        }
        return responseMap;
    }
    
    public static String createInputRequest(Map<String, String> inputData){
        DeactivateInvoiceRequestWrapper data = new DeactivateInvoiceRequestWrapper();
        data.invoiceId = inputData.get('invoiceId');
        String requestBodyStr = JSON.serializePretty(data);
        return requestBodyStr;
    }
    
	// Request Wrapper Class
    Public class DeactivateInvoiceRequestWrapper{
        Public String invoiceId;
    } 
    
    // Response Wrapper Class
    Public class DeactivateInvoiceResponseWrapper{
        Public String invoiceId;
        Public Boolean success;
    } 
    
}