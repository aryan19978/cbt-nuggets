global class GetInvoicePDFCallout {
	public class InputVariables{
        @InvocableVariable public String invoiceId;
        @InvocableVariable public String calloutType;
    }
    public class OutputVariables{ 
        @InvocableVariable public String result;
        @InvocableVariable public String responseType;
        @InvocableVariable public String signedUrl;
        @InvocableVariable public String message;
    }
    
    @InvocableMethod(callout=true label='GetInvoicePDFExternalCallout')    
    public static List<OutputVariables> makeGetInvoicePDFHandler(List<InputVariables> params) {
        Map<String, String> inputData = new Map<String, String>();
        inputData.put('invoiceId', params[0].invoiceId);
        inputData.put('calloutType', params[0].calloutType);
        
        Map<String, String> responseMap = GetInvoicePDFHandler.makeHttpCallout(inputData);
        
        system.debug('resonseMap is + ' + responseMap);
        List<OutputVariables> results = new List<OutputVariables>();
        OutputVariables output = new OutputVariables();
        output.result = responseMap.get('result');
        output.responseType = responseMap.get('responseType');
        output.signedUrl = responseMap.get('signedUrl');
        output.message = responseMap.get('message');
        results.add(output);
        system.debug(results);
        return results;
    }
}