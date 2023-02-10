global class SalesTaxExternalCallout
{
    public class InputVariables{
        @InvocableVariable public Id quoteId;
        @InvocableVariable public String calloutType;
    }
    public class OutputVariables{ 
        @InvocableVariable public String result; 
        @InvocableVariable public String responseType; 
    }
    
    @InvocableMethod(callout=true label='SalesTaxExternalCallout')    
    public static List<OutputVariables> makeSalesTaxExternalCallout(List<InputVariables> params) {
        Id quoteId = params[0].quoteId;
        String calloutType = params[0].calloutType;
        Map<String, String> inputData = new Map<String, String>();
        inputData.put('quoteId', quoteId);
        inputData.put('calloutType', calloutType);
        Map<String,String> responseMap = SalesTaxCalloutHandler.makeHttpCallout(inputData);
        system.debug('resonse is + ' + responseMap);
        List<OutputVariables> results = new List<OutputVariables>();
        
        OutputVariables output = new OutputVariables();
        output.result = responseMap.get('response');
        output.responseType =  responseMap.get('responseType');
        results.add(output);
        return results;
    }
}