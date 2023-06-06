global class CopyBillingToShippingBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry FROM Account WHERE BillingStreet != NULL AND ShippingStreet = NULL]);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        try{
        for (Account acc : scope) {
             if (acc.ShippingStreet == null) {
            acc.ShippingStreet = acc.BillingStreet;
            acc.ShippingCity = acc.BillingCity;
            acc.ShippingState = acc.BillingState;
            acc.ShippingPostalCode = acc.BillingPostalCode;
            acc.ShippingCountry = acc.BillingCountry;
             }
        }
        update scope;
    }
    catch(exception ex){

    }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optional: Add any additional logic or processing after the batch completes
    }
}