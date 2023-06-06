global class ActivateInvoiceExternalCallout {
	public class InputVariables{
        @InvocableVariable public String invoiceId;
        @InvocableVariable public String calloutType;
    }
    public class OutputVariables{ 
        @InvocableVariable public String result;
        @InvocableVariable public String responseType;
        @InvocableVariable public String invoiceId;
        @InvocableVariable public String success;
    }
    
    @InvocableMethod(callout=true label='ActivateInvoiceExternalCallout')    
    public static List<OutputVariables> makeActivateInvoiceCalloutHandler(List<InputVariables> params) {
        Map<String, String> inputData = new Map<String, String>();
        inputData.put('invoiceId', params[0].invoiceId);
        inputData.put('calloutType', params[0].calloutType);
        Map<String, String> responseMap = ActivateInvoiceCalloutHandler.makeHttpCallout(inputData);
        system.debug('ActivateInvoiceExternalCallout::makeActivateInvoiceCalloutHandler : ResonseMap ' + responseMap);
        List<OutputVariables> results = new List<OutputVariables>();
        OutputVariables output = new OutputVariables();
        output.result = responseMap.get('result');
        output.responseType = responseMap.get('responseType');
        output.invoiceId = responseMap.get('invoiceId');
        output.success = responseMap.get('success');
        results.add(output);
        return results;
    }
}