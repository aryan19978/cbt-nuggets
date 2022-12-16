public class ActivateOrderCalloutHandler {
    public static String makeHttpCallout(Map<String, String> inputData){
        HttpCalloutService service = new HTTPCalloutService(inputData.get('calloutType'));
        system.debug('Input Request ActivateOrder' + createInputRequest(inputData));
        service.setRequestBody(createInputRequest(inputData));
        HTTPResponse res = service.sendRequest();
        system.debug(res.getBody());
        try{
            return res.getBody();
        }
        Catch(Exception ex){
            return res.getBody();
        }
    }
    
    public static String createInputRequest(Map<String, String> inputData){
        system.debug(inputData);
        ActivateOrderWrapper activateOrder = new ActivateOrderWrapper();        
        activateOrder.apiKey = HttpCalloutUtility.getValueCustomMetadata('apiKey');
        activateOrder.adeptCustomerId = inputData.get('adeptCustomerId');
        String jsonStr = JSON.serialize(activateOrder);
        system.debug('Activate Order request' + jsonStr);
        return jsonStr;
    }
    
    // create json for trial endpoint
    Public class ActivateOrderWrapper{
        Public String apiKey;
        Public String adeptCustomerId;
        
    }
}