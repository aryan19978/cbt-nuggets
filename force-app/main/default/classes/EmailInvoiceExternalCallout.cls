global class EmailInvoiceExternalCallout
{
    public class InputVariables{
        @InvocableVariable public Id oppId;
        @InvocableVariable public String invoiceId;
        @InvocableVariable public String purchaseOrder;
        @InvocableVariable public String invoiceMessage;
        @InvocableVariable public String emailOverride;
        @InvocableVariable public String calloutType;
    }
    public class OutputVariables{ 
        @InvocableVariable public String response; 
        @InvocableVariable public String responseType;
    }
    
    @InvocableMethod(callout=true label='EmailInvoiceExternalCallout')    
    public static List<OutputVariables> makeEmailInvoiceExternalCallout(List<InputVariables> params) {
        Map<String, String> inputData = new Map<String, String>();
        inputData.put('oppId', params[0].oppId);
        inputData.put('invoiceId', params[0].invoiceId);
        inputData.put('purchaseOrder', params[0].purchaseOrder);
        inputData.put('invoiceMessage', params[0].invoiceMessage);
        inputData.put('emailOverride', params[0].emailOverride);
        inputData.put('calloutType', params[0].calloutType);
        
        Map<String, String> responseMap = EmailInvoiceCalloutHandler.handleHttpCallout(inputData);
        system.debug('resonseMap is + ' + responseMap);
        
        List<OutputVariables> results = new List<OutputVariables>();
        OutputVariables output = new OutputVariables();
        output.response = responseMap.get('response');
        output.responseType = responseMap.get('responseType');
        results.add(output);
        
        return results;
    }
}