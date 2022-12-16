trigger QuoteLineItemTrigger on QuoteLineItem (after insert, after Update) {
    
    if(trigger.isAfter && (Trigger.isInsert || trigger.isUpdate))
    {
        quoteLineItemTriggerHandler.checkPriceOverride(trigger.new);
    }

}