public class TransferOwnershipCalloutHandler {
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
            TransferOwnershipResponseWrapper jsonStrToWrapper=  (TransferOwnershipResponseWrapper) System.JSON.deserialize(res.getBody(), TransferOwnershipResponseWrapper.class);
            system.debug('jsonStrToWrapper ' + jsonStrToWrapper);
            TransferOwnershipResponseWrapper response = (TransferOwnershipResponseWrapper)jsonStrToWrapper; 
            system.debug('response '+ response);
            
            if(response.success== Null){
                responseMap.put('result',res.getBody());
                responseMap.put('responseType', 'warning');                 
                return responseMap;
            }
            else{
                responseMap.put('result','Transfer Owner Successful.');
                responseMap.put('responseType', 'success');
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
        TransferOwnershipRequestWrapper data = new TransferOwnershipRequestWrapper();
        data.email = inputData.get('email');
        data.firstName = inputData.get('firstName');
        data.lastName = inputData.get('lastName');
        data.adeptCustomerId = inputData.get('adeptCustomerId');
        
        String requestBodyStr = JSON.serializePretty(data);
        return requestBodyStr;
    }
    
	// Request Wrapper Class
    Public class TransferOwnershipRequestWrapper{
        Public String email;
        Public String firstName;
        Public String lastName;
        Public String adeptCustomerId;
    } 
    
    // Response Wrapper Class
    Public class TransferOwnershipResponseWrapper{
        Public Boolean success;
    } 
    
}