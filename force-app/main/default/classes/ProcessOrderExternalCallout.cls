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
        @InvocableVariable public String css_EndDate;
        @InvocableVariable public String css_LicenseType;
        @InvocableVariable public String css_Quantity;
        @InvocableVariable public String rss_StartDate;
        @InvocableVariable public String rss_LicenseType;
        @InvocableVariable public String rss_Quantity;
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
        
        if(responseMap.get('result')  == 'Process Order Successful.'){
            output.css_EndDate = responseMap.get('css_EndDate');
            output.css_LicenseType = responseMap.get('css_LicenseType');
            output.css_Quantity = responseMap.get('css_Quantity');
            output.rss_StartDate = responseMap.get('rss_StartDate');
            output.rss_LicenseType = responseMap.get('rss_LicenseType');
            output.rss_Quantity = responseMap.get('rss_Quantity');
        }
        results.add(output);
        return results;
    }
}