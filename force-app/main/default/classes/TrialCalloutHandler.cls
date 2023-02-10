public class TrialCalloutHandler {
	public static String makeHttpCallout(Map<String, String> inputData){
            HttpCalloutService service = new HTTPCalloutService(inputData.get('calloutType'));
            service.setRequestBody(createInputRequest(inputData));
        
            service.setHeaderParameter('adept-apikey', HttpCalloutUtility.getValueCustomMetadata('apiKey'));
            service.setHeaderParameter('adept-billing-env', HttpCalloutUtility.getValueCustomMetadata('env'));
            service.setHeaderParameter('adept-billing-sfuserid', UserInfo.getUserId());
        
            system.debug('Trial input Request' + createInputRequest(inputData));
            HTTPResponse res = service.sendRequest();
        	
            system.debug(res.getBody());
            return res.getBody();
    }
    
    public static String createInputRequest(Map<String, String> inputData){
        TrialPurchaseDetails purchaseDetail = new TrialPurchaseDetails();
            purchaseDetail.startDate = inputData.get('startDate');
            purchaseDetail.quantity = integer.valueof(inputData.get('licenseCount'));
            TrialCustomerDetails customerDetail = new TrialCustomerDetails(); 
            customerDetail.salesforceCustomerId = inputData.get('accountId');
            //customerDetail.salesforceContactId = '';
            customerDetail.firstName = inputData.get('firstName');
            customerDetail.lastName = inputData.get('lastName');
            customerDetail.email = inputData.get('email');
            customerDetail.company = inputData.get('accountName');
            TrialWrapper trialdata = new TrialWrapper();
            trialdata.apiKey = HttpCalloutUtility.getValueCustomMetadata('apiKey');
            trialdata.env =  HttpCalloutUtility.getValueCustomMetadata('env');
            trialdata.purchaseDetails = purchaseDetail;
            trialdata.customerDetails = customerDetail;
        	system.debug(JSON.serializePretty(trialdata));
            String jsonStr = JSON.serialize(trialdata);
            return jsonStr;
    }
    
    // create json for trial endpoint
    Public class TrialWrapper{
        Public String apiKey;
        Public String env;
        Public TrialPurchaseDetails purchaseDetails;
        Public TrialCustomerDetails customerDetails;
    }
    
    Public class TrialPurchaseDetails{ 
        Public String startDate;
        Public Integer quantity;
    }
    
    Public class TrialCustomerDetails{ 
        Public String salesforceCustomerId;
        //Public String salesforceContactId;
        Public String firstName;
        Public String lastName;
        Public String email;
        Public String company;
    }
}