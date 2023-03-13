public class CancelServiceCalloutHandler {
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
            CancelServiceResponseWrapper jsonStrToWrapper=  (CancelServiceResponseWrapper) System.JSON.deserialize(res.getBody(), CancelServiceResponseWrapper.class);
            system.debug('jsonStrToWrapper ' + jsonStrToWrapper);
            CancelServiceResponseWrapper response = (CancelServiceResponseWrapper)jsonStrToWrapper; 
            system.debug('response '+ response);
            
            if(response.invoiceId== Null){
                responseMap.put('result',res.getBody());
                responseMap.put('responseType', 'warning');                 
                return responseMap;
            }
            else{
                responseMap.put('result','Cancel Service Successful.');
                responseMap.put('responseType', 'success');
                responseMap.put('invoiceId', response.invoiceId);
                responseMap.put('success', String.valueof(response.success));
            }
        }
        Catch(Exception ex){
            	responseMap.put('result',ex.getCause() + ex.getMessage() + ex.getTypeName() + '\n ******** Response*******'+ res.getBody() );
                responseMap.put('responseType', 'warning');
        }
        return responseMap;
    }
    
    public static String createInputRequest(Map<String, String> inputData){
        CancelServiceRequestWrapper data = new CancelServiceRequestWrapper();
        data.invoiceId = inputData.get('invoiceId');
        String requestBodyStr = JSON.serializePretty(data);
        return requestBodyStr;
    }
    
	// Request Wrapper Class
    Public class CancelServiceRequestWrapper{
        Public String invoiceId;
    } 
    
    // Response Wrapper Class
    Public class CancelServiceResponseWrapper{
        Public String invoiceId;
        Public Boolean success;
    } 
    
}