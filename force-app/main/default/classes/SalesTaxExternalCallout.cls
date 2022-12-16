global class SalesTaxExternalCallout
{
    public class InputVariables{
        @InvocableVariable public Id quoteId;
        @InvocableVariable public String calloutType;
    }
    public class OutputVariables{ 
        @InvocableVariable public String result; 
    }
    
    @InvocableMethod(callout=true label='SalesTaxExternalCallout')    
    public static List<OutputVariables> makeSalesTaxExternalCallout(List<InputVariables> params) {
        Id quoteId = params[0].quoteId;
        String calloutType = params[0].calloutType;
        Map<String, String> inputData = new Map<String, String>();
        inputData.put('quoteId', quoteId);
        inputData.put('calloutType', calloutType);
        String response = SalesTaxCalloutHandler.makeHttpCallout(inputData);
        system.debug('resonse is + ' + response);
        List<OutputVariables> results = new List<OutputVariables>();
        OutputVariables output = new OutputVariables();
        output.result = response;
        results.add(output);
        return results;
    }
}