trigger QuoteTrigger on Quote (after update) {
    
    system.debug('trigger.new[0].status' + trigger.new[0].status);
        system.debug('trigger.new[0].opportunityId' + trigger.new[0].opportunityId);

    if(trigger.new[0].status == 'Quote Accepted')
    {
        Map<String, String> inputData = new Map<String, String>();
        
        inputData.put('oppId', trigger.new[0].opportunityId);
        inputData.put('calloutType', 'ProcessOrder');
        QuoteTriggerHelper.doCallout(inputData);
       // Map<String, String> responseMap = ProcessOrderCalloutHandler.makeHttpCallout(inputData);
    }
    
}