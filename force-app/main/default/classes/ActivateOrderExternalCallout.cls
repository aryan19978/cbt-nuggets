public class ActivateOrderExternalCallout {
    public class InputVariables{
        @InvocableVariable public Id oppId;
        @InvocableVariable public String calloutType;
        @InvocableVariable public String adeptCustomerId;
    }
    public class OutputVariables{ 
        @InvocableVariable public String result;
    }
    
    @InvocableMethod(callout=true label='ActivateOrderExternalCallout')    
    public static List<OutputVariables> makeProcessOrderExternalCallout(List<InputVariables> params) {
        
        Map<String, String> inputData = new Map<String, String>();
        inputData.put('oppId', params[0].oppId);
        inputData.put('calloutType', params[0].calloutType);
        inputData.put('adeptCustomerId', params[0].adeptCustomerId);
        String response = ActivateOrderCalloutHandler.makeHttpCallout(inputData);
        system.debug('resonse is + ' + response);
        List<OutputVariables> results = new List<OutputVariables>();
        OutputVariables output = new OutputVariables();
        output.result = response;
        results.add(output);
        return results;
    }
}