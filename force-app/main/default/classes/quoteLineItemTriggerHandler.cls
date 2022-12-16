public class quoteLineItemTriggerHandler {
    /*
    public static void checkPriceOverride(List<QuoteLineItem> qliList)
    {
        Set<Id> productId = new Set<Id>();
        for(QuoteLineItem qli: qliList)
        {
            productId.add(qli.Product2Id);
        }
        Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT ID, ProductCode FROM Product2 WHERE Id IN :productId]);
        List<Quote> quoteNeedToUpdate = new List<Quote>();
        Map<Id, Quote> quoteIdMap = new Map<Id, Quote>();
        for(QuoteLineItem qli: qliList)
        {
            
            system.debug(qli.TotalPrice);
            system.debug(qli.ListPrice__c);
            system.debug(qli.Quantity);
            Boolean priceOverride = qli.TotalPrice < qli.ListPrice__c * qli.Quantity;
            if(priceOverride)
            {
                Quote q = new Quote();
                if(quoteIdMap.containsKey(qli.quoteId))
                {
                    q = quoteIdMap.get(qli.quoteId);
                    q.Product_Code__c = productMap.get(qli.Product2Id).ProductCode;
                }
                else
                {
                    q.Id = qli.quoteId;
                    q.Price_Override__c = true; 
                    q.Product_Code__c = productMap.get(qli.Product2Id).ProductCode;
                    quoteIdMap.put(qli.quoteId, q);
                }
                //quoteNeedToUpdate.add(q);
            }
            
           
        }
        if(quoteIdMap.values().size()>0)
        {
            update quoteIdMap.values();
        }
    }
*/
}