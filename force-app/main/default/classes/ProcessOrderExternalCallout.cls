global class ProcessOrderExternalCallout
{
    public class InputVariables{
        @InvocableVariable public Id oppId;
        @InvocableVariable public String calloutType;
    }
    public class OutputVariables{ 
        @InvocableVariable public String result;
        @InvocableVariable public String responseType;
        @InvocableVariable public String adeptCustomerIdCheck;
    }
    
    @InvocableMethod(callout=true label='ProcessOrderExternalCallout')    
    public static List<OutputVariables> makeProcessOrderExternalCallout(List<InputVariables> params) {
        Map<String, String> inputData = new Map<String, String>();
        
        inputData.put('oppId', params[0].oppId);
        inputData.put('calloutType', params[0].calloutType);
        Map<String, String> responseMap = ProcessOrderCalloutHandler.makeHttpCallout(inputData);
        system.debug('resonseMap is + ' + responseMap);
        List<OutputVariables> results = new List<OutputVariables>();
        OutputVariables output = new OutputVariables();
        output.result = responseMap.get('result');
        output.responseType = responseMap.get('responseType');
        output.adeptCustomerIdCheck = responseMap.get('adeptCustomerIdCheck');
        
        results.add(output);
        return results;
    }
}