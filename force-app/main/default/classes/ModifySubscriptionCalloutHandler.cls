public class ModifySubscriptionCalloutHandler {
    public static Map<String,String> makeHttpCallout(Map<String, String> inputData){
        HttpCalloutService service = new HTTPCalloutService(inputData.get('calloutType'));
        // Set Header
        service.setHeaderParameter('adept-apikey', HttpCalloutUtility.getValueCustomMetadata('apiKey'));
        service.setHeaderParameter('adept-billing-env', HttpCalloutUtility.getValueCustomMetadata('env'));
        service.setHeaderParameter('adept-billing-sfuserid', UserInfo.getUserId());
        Map<String,String> responseMap = new Map<String,String>();
        
        system.debug('SubscriptionModification '+inputData.get('SubscriptionModification'));
        if(inputData.get('SubscriptionModification') == 'SET SUBSCRIPTION DETAILS'){
            // create request body
            string requestBodyStr = createSubscriptionDetailInputRequest(inputData);
            service.setRequestBody(requestBodyStr);
            system.debug('SET SUBSCRIPTION DETAILS '+ requestBodyStr);
        }
        else if(inputData.get('SubscriptionModification') == 'SET AUTORENEW DETAILS'){
            // create request body
            string requestBodyStr = createAutoRenewInputRequest(inputData);
            service.setRequestBody(requestBodyStr);
            system.debug('SET AUTORENEW DETAILS '+ requestBodyStr);
            
        }
        else if(inputData.get('SubscriptionModification') == 'SET RENEWAL DATE'){
            // create request body
            string requestBodyStr = createRenewalDateInputRequest(inputData);
            service.setRequestBody(requestBodyStr);
            system.debug('SET RENEWAL DATE '+requestBodyStr);
        }
        HTTPResponse res = service.sendRequest();
        responseMap = handleModifySubscription(res);
        return responseMap;
    }
    
    public static String createSubscriptionDetailInputRequest(Map<String, String> inputData){        
        SetDetailRequestWrapper dataDetail = new SetDetailRequestWrapper();
        dataDetail.typeIs     =  'SET_SUBSCRIPTION_DETAILS';
        dataDetail.startDate  = inputData.get('startDate');
        dataDetail.endDate    = inputData.get('endDate');
        dataDetail.quantity   = Integer.valueof(inputData.get('quantity'));
        SetSubscriptionDetailRequestWrapper data = new SetSubscriptionDetailRequestWrapper();
        data.details = dataDetail;
        data.endCustomerAdeptId = inputData.get('endCustomerAdeptId');
        String requestBodyStr = JSON.serializePretty(data);
        requestBodyStr = requestBodyStr.replace('typeIs', 'type');
        return requestBodyStr;
    }
    
    public static String createAutoRenewInputRequest(Map<String, String> inputData){        
        SetAutoRenewRequestWrapper dataDetail = new SetAutoRenewRequestWrapper();
        dataDetail.typeIs     =  'TOGGLE_AUTORENEW';
        dataDetail.autoRenew  = inputData.get('autoRenew') == 'Yes' ? true : false;
        SetSubscriptionAutoRenewRequestWrapper data = new SetSubscriptionAutoRenewRequestWrapper();
        data.details = dataDetail;
        data.endCustomerAdeptId = inputData.get('endCustomerAdeptId');
        String requestBodyStr = JSON.serializePretty(data);
        requestBodyStr = requestBodyStr.replace('typeIs', 'type');
        return requestBodyStr;
    }
    
    public static String createRenewalDateInputRequest(Map<String, String> inputData){        
        SetRenewalDateRequestWrapper dataDetail = new SetRenewalDateRequestWrapper();
        dataDetail.typeIs     =  'SET_RENEWAL_DATE';
        dataDetail.newStartDate  = inputData.get('newStartDate');
        SetSubscriptionRenewalDateRequestWrapper data = new SetSubscriptionRenewalDateRequestWrapper();
        data.details = dataDetail;
        data.endCustomerAdeptId = inputData.get('endCustomerAdeptId');
        String requestBodyStr = JSON.serializePretty(data);
        requestBodyStr = requestBodyStr.replace('typeIs', 'type');
        return requestBodyStr;
    }
    
    Public Static Map<String,String> handleModifySubscription(HTTPResponse res){
        Map<String,String> responseMap = new Map<String,String>();
        try{
            ModifySubscriptionResponseWrapper jsonStrToWrapper=  (ModifySubscriptionResponseWrapper) System.JSON.deserialize(res.getBody(), ModifySubscriptionResponseWrapper.class);
            system.debug('jsonStrToWrapper ' + jsonStrToWrapper);
            ModifySubscriptionResponseWrapper response = (ModifySubscriptionResponseWrapper)jsonStrToWrapper; 
            system.debug('response '+ response);
            if(response.success == false){
                responseMap.put('result',res.getBody());
                responseMap.put('responseType', 'warning');                 
                return responseMap;
            }
            else{
                if(response.success == true){
                    responseMap.put('result', 'Subscription Modified Successfully.');
                }
                else{
                    responseMap.put('result', res.getBody()); 
                }
                responseMap.put('responseType', 'success');
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
    
    
    
    ///////////SubscriptionDetail
    Public class SetSubscriptionDetailRequestWrapper{
        Public SetDetailRequestWrapper details;
        Public String endCustomerAdeptId;
    } 
    
    Public class SetDetailRequestWrapper{
        Public String typeIs;
        Public String startDate;
        Public String endDate;
        Public Integer quantity;
    }
    ////////////AutoRenew
    Public class SetSubscriptionAutoRenewRequestWrapper{
        Public SetAutoRenewRequestWrapper details;
        Public String endCustomerAdeptId;
    } 
    Public class SetAutoRenewRequestWrapper{
        Public String typeIs;
        Public Boolean autoRenew;
    }
    //////RenewalDate
    Public class SetSubscriptionRenewalDateRequestWrapper{
        Public SetRenewalDateRequestWrapper details;
        Public String endCustomerAdeptId;
    } 
    Public class SetRenewalDateRequestWrapper{
        Public String typeIs;
        Public String newStartDate;
    }
    
    // Response Wrapper Class
    Public class ModifySubscriptionResponseWrapper{
        Public Boolean success;
    } 
    
}