trigger OpportunityTrigger on Opportunity (before insert, before Update) {

    if(trigger.isBefore && trigger.isInsert)
    {
        OpportunityTriggerHandler.checkTaxExempt(trigger.new, true);
    }
    if(trigger.isBefore && trigger.isUpdate)
    {
        OpportunityTriggerHandler.checkTaxExempt(trigger.new, false);
    }
}