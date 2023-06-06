global class ModifySubscriptionExternalCallout {
	public class InputVariables{
        @InvocableVariable public String SubscriptionModification;
        @InvocableVariable public String startDate;
        @InvocableVariable public String endDate;
        @InvocableVariable public String quantity;
        @InvocableVariable public String endCustomerAdeptId;
        @InvocableVariable public String autoRenew;
        @InvocableVariable public String newStartDate;
        @InvocableVariable public String calloutType;
    }
    public class OutputVariables{ 
        @InvocableVariable public String result;
        @InvocableVariable public String responseType;
        @InvocableVariable public String success;
    }
    
    @InvocableMethod(callout=true label='ModifySubscriptionExternalCallout')    
    public static List<OutputVariables> makeModifySubscriptionCalloutHandler(List<InputVariables> params) {
        Map<String, String> inputData = new Map<String, String>();
        
        inputData.put('calloutType', params[0].calloutType);
		inputData.put('startDate', params[0].startDate);
        inputData.put('endDate', params[0].endDate);
        inputData.put('quantity', params[0].quantity);
        inputData.put('endCustomerAdeptId', params[0].endCustomerAdeptId);
        inputData.put('autoRenew', params[0].autoRenew);
        inputData.put('newStartDate', params[0].newStartDate);
        inputData.put('SubscriptionModification', params[0].SubscriptionModification);
        
        
        
        Map<String, String> responseMap = ModifySubscriptionCalloutHandler.makeHttpCallout(inputData);
        
        system.debug('ModifySubscription Resonse' + responseMap);
        List<OutputVariables> results = new List<OutputVariables>();
        OutputVariables output = new OutputVariables();
        output.result = responseMap.get('result');
        output.responseType = responseMap.get('responseType');
        output.success = responseMap.get('success');
        results.add(output);
        return results;
    }
}