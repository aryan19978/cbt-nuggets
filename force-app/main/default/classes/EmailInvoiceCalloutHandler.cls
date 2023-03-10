public class EmailInvoiceCalloutHandler { 
    
    public static Map<String,String> handleHttpCallout(Map<String, String> inputData){
        HttpCalloutService service = new HTTPCalloutService(inputData.get('calloutType'));
        string requestBody = createInputRequest(inputData);
        system.debug('requestBody'+ requestBody);
        service.setHeaderParameter('adept-apikey', HttpCalloutUtility.getValueCustomMetadata('apiKey'));
        service.setHeaderParameter('adept-billing-env', HttpCalloutUtility.getValueCustomMetadata('env'));
        service.setHeaderParameter('adept-billing-sfuserid', UserInfo.getUserId());
        service.setRequestBody(requestBody);
        
        system.debug(service.sendRequest());
        HTTPResponse res = service.sendRequest();
        
        
		Map<String,String> responseMap = new Map<String,String>();
        try{
            EmailInvoiceResponseWrapper jsonStrToWrapper=  (EmailInvoiceResponseWrapper) System.JSON.deserialize(res.getBody(), EmailInvoiceResponseWrapper.class);
            EmailInvoiceResponseWrapper response = (EmailInvoiceResponseWrapper)jsonStrToWrapper; 
            system.debug('response'+ response.success);
            if(response.success == true){
                responseMap.put('response', 'Email Invoice Successful.');
                responseMap.put('responseType', 'success'); 
            }
            else{
                responseMap.put('response', res.getBody());
                responseMap.put('responseType', 'warning');  
            }
                           
            return responseMap;
        }
        Catch(Exception ex){
            HandleExceptionError.LogException('EmailInvoiceCalloutHandler','handleHttpCallout',inputData.get('oppId'),ex,requestBody,res.getBody());
            responseMap.put('response', res.getBody());
            responseMap.put('responseType', 'warning');                 
            return responseMap;
        }
    }
    
    public static String createInputRequest(Map<String, String> inputData){
        //opportunity oppRec = [SELECT id,Invoice_Id__c FROM opportunity where id = : inputData.get('oppId')];

        EmailInvoiceRequestWrapper data = new EmailInvoiceRequestWrapper();
        data.apiKey = HttpCalloutUtility.getValueCustomMetadata('apiKey');
        data.env =  HttpCalloutUtility.getValueCustomMetadata('env');
        data.invoiceId = inputData.get('invoiceId');
        data.purchaseOrder = inputData.get('purchaseOrder');
        data.invoiceMessage = inputData.get('invoiceMessage');

        String jsonStr = JSON.serializePretty(data);
        return jsonStr;
    }
    
    Public class EmailInvoiceResponseWrapper{
        Public boolean success;
    }

    Public class EmailInvoiceRequestWrapper{
        Public string apiKey;
        Public string env;
        Public string invoiceId;
        Public string purchaseOrder;
        Public string invoiceMessage;
    }
}