public class GetInvoicePDFHandler {
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
            GetInvoicePDFResponseWrapper jsonStrToWrapper=  (GetInvoicePDFResponseWrapper) System.JSON.deserialize(res.getBody(), GetInvoicePDFResponseWrapper.class);
            system.debug('jsonStrToWrapper ' + jsonStrToWrapper);
            GetInvoicePDFResponseWrapper response = (GetInvoicePDFResponseWrapper)jsonStrToWrapper; 
            system.debug('response '+ response);
            
            if(response.signedUrl == Null){
                responseMap.put('result',res.getBody());
                responseMap.put('message', response.message);
                responseMap.put('responseType', 'warning');                 
                return responseMap;
            }
            else{
                responseMap.put('result',response.message);
                responseMap.put('responseType', 'success');
                responseMap.put('signedUrl', response.signedUrl);
                responseMap.put('message', response.message);
            }
        }
        Catch(Exception ex){
            	responseMap.put('result',ex.getCause() + ex.getMessage() + ex.getTypeName() + '\n ******** Response*******'+ res.getBody() );
                responseMap.put('responseType', 'warning');
        }
        return responseMap;
    }
    
    public static String createInputRequest(Map<String, String> inputData){
        GetInvoicePDFRequestWrapper data = new GetInvoicePDFRequestWrapper();
        data.invoiceId = inputData.get('invoiceId');
        String requestBodyStr = JSON.serializePretty(data);
        return requestBodyStr;
    }
    
	// Request Wrapper Class
    Public class GetInvoicePDFRequestWrapper{
        Public String invoiceId;
    } 
    
    // Response Wrapper Class
    Public class GetInvoicePDFResponseWrapper{
        Public String signedUrl;
        Public String message;
    } 
    
}