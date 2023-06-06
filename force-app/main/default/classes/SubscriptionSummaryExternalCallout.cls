global class SubscriptionSummaryExternalCallout {
	public class InputVariables{
        @InvocableVariable public String subId;
        @InvocableVariable public String calloutType;
    }
    public class OutputVariables{ 
        @InvocableVariable public String result;
        @InvocableVariable public String responseType;
        @InvocableVariable public String startDate;
        @InvocableVariable public String endDate;
        @InvocableVariable public String quantity;
    }
    
    @InvocableMethod(callout=true label='SubscriptionSummaryExternalCallout')    
    public static List<OutputVariables> makeSubscriptionSummaryExternalCallout(List<InputVariables> params) {
        Map<String, String> inputData = new Map<String, String>();
        inputData.put('subId', params[0].subId);
        inputData.put('calloutType', params[0].calloutType);
        
        Map<String, String> responseMap = SubscriptionSummaryCalloutHandler.makeHttpCallout(inputData);
        
        system.debug('resonseMap is + ' + responseMap);
        List<OutputVariables> results = new List<OutputVariables>();
        OutputVariables output = new OutputVariables();
        output.result = responseMap.get('result');
        output.responseType = responseMap.get('responseType');
        output.startDate = responseMap.get('startDate');
        output.endDate = responseMap.get('endDate');
        output.quantity = responseMap.get('quantity');
        results.add(output);
        return results;
    }
}