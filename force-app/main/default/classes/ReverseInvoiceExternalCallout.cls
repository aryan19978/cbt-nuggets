global class ReverseInvoiceExternalCallout {
	public class InputVariables{
        @InvocableVariable public String invoiceId;
        @InvocableVariable public String calloutType;
    }
    public class OutputVariables{ 
        @InvocableVariable public String result;
        @InvocableVariable public String responseType;
        @InvocableVariable public String invoiceId;
        @InvocableVariable public String success;
        @InvocableVariable public String reversalInvoiceId;
    }
    
    @InvocableMethod(callout=true label='ReverseInvoiceExternalCallout')    
    public static List<OutputVariables> makeReverseInvoiceExternalCallout(List<InputVariables> params) {
        Map<String, String> inputData = new Map<String, String>();
        inputData.put('invoiceId', params[0].invoiceId);
        inputData.put('calloutType', params[0].calloutType);
        
        Map<String, String> responseMap = ReverseInvoiceCalloutHandler.makeHttpCallout(inputData);
        
        system.debug('resonseMap is + ' + responseMap);
        List<OutputVariables> results = new List<OutputVariables>();
        OutputVariables output = new OutputVariables();
        output.result = responseMap.get('result');
        output.responseType = responseMap.get('responseType');
        output.invoiceId = responseMap.get('invoiceId');
        output.success = responseMap.get('success');
        output.reversalInvoiceId = responseMap.get('reversalInvoiceId');
        results.add(output);
        return results;
    }
}