trigger QuoteTrigger on Quote (after update) {
    for (Quote qtRec : Trigger.new) {
        Quote oldqtRec = Trigger.oldMap.get(qtRec.Id);
        if(qtRec.status == 'Quote Accepted' && qtRec.status != oldqtRec.status)
        {
            Map<String, String> inputData = new Map<String, String>();
            inputData.put('oppId', trigger.new[0].opportunityId);
            inputData.put('calloutType', 'ProcessOrder');
            QuoteTriggerHelper.doCallout(inputData);
        }
    }
}