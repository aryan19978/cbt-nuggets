global with sharing class GlobalDeleteHandler {
    // Expose this Action to the Flow
    @InvocableMethod
    global static List<Results> get(List<Requests> requestList) {
        // initialize variables
        Results response = new Results();
        List<Results> responseWrapper = new List<Results>();
        List<GlobalDeleteWrapper> globalDeleteRecList = new List<GlobalDeleteWrapper>(); // *** Apex-Defined Class Descriptor Name ***
        GlobalDeleteWrapper a = new GlobalDeleteWrapper();
        a.Name = 'TEST';
        a.Email = 'test@gmail.com';
        a.ObjectType = 'Account';
        globalDeleteRecList.add(a);
        GlobalDeleteWrapper b = new GlobalDeleteWrapper();
        a.Name = 'TEST1';
        a.Email = 'test1@gmail.com';
        a.ObjectType = 'Contact';
        globalDeleteRecList.add(b);
        
        
        // Convert Record Collection to Serialized String
        String stringOutput = JSON.serialize(globalDeleteRecList);
        
        // Prepare the response to send back to the Flow
        // Set Output Values
        response.outputCollection = globalDeleteRecList;
        response.outputString = stringOutput;
        
        responseWrapper.add(response);
        
        // Return values back to the Flow
        return responseWrapper;
    }
    
    // Attributes passed in from the Flow
    global class Requests {
        @InvocableVariable(label='Input Email')
        global String inputEmail;
    }
    
    // Attributes passed back to the Flow
    global class Results {
        @InvocableVariable
        public List<GlobalDeleteWrapper> outputCollection;
        
        @InvocableVariable
        public String outputString;
    }
    
}