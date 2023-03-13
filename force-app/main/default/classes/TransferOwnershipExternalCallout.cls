global class TransferOwnershipExternalCallout {
    public class InputVariables{
        @InvocableVariable public String email;
        @InvocableVariable public String firstName;
        @InvocableVariable public String lastName;   
        @InvocableVariable public String adeptCustomerId;
        @InvocableVariable public String calloutType;
    }
    public class OutputVariables{ 
        @InvocableVariable public String result;
        @InvocableVariable public String responseType;
        @InvocableVariable public String success;
    }
    
    @InvocableMethod(callout=true label='TransferOwnershipExternalCallout')    
    public static List<OutputVariables> makeTransferOwnershipExternalCallout(List<InputVariables> params) {
        
        Map<String, String> inputData = new Map<String, String>();
        inputData.put('email', params[0].email);
        inputData.put('firstName', params[0].firstName);
        inputData.put('lastName', params[0].lastName);
        inputData.put('adeptCustomerId', params[0].adeptCustomerId);
        inputData.put('calloutType', params[0].calloutType);
        
        Map<String, String> responseMap = TransferOwnershipCalloutHandler.makeHttpCallout(inputData);
        
        system.debug('resonseMap is + ' + responseMap);
        List<OutputVariables> results = new List<OutputVariables>();
        OutputVariables output = new OutputVariables();
        output.result = responseMap.get('result');
        output.responseType = responseMap.get('responseType');
        output.success = responseMap.get('success');
        results.add(output);
        return results;
    }
}