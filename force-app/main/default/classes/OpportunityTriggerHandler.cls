public class OpportunityTriggerHandler {
    
    public static void checkTaxExempt(List<Opportunity> newOppList, Boolean isNew)
    {
        if(isNew)
        {
            for(opportunity opp: newOppList)
            {
                if(opp.Bill_to_Account__c == null && opp.Tax_Exempt__c)
                {
                    //If user Make Tax Exempt as true manually while creating the record show the error.
                   opp.addError('You can not set tax exempt true without providing tax exempt document or reseller account');
                }
            }
        }
        else
        {
            Set<id> oppSet = new Set<Id>();
            for(opportunity opp: newOppList)
            {
                oppSet.add(opp.Id);
            }
            //fetch the content Document Link related to the updated opportunity records.
            List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :oppSet];
            Map<Id, Id> documentWithOpportunityMap = new Map<Id, Id>();
            Set<Id> contentDocumentIds = new Set<Id>();
            For(ContentDocumentLink cdl: cdlList)
            {
                documentWithOpportunityMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                contentDocumentIds.add(cdl.contentDocumentId);
            }
            //Fetch ContentVersion Records of the above query content document link records where Is tax Exempt checkbox need to be true
            List<ContentVersion> cvList = [SELECT Id, contentDocumentId FROM ContentVersion WHERE contentDocumentId In :contentDocumentIds AND is_Tax_Exempt__c = true];
            Map<Id, List<ContentVersion>> opportunityWithContentVersionMap = new Map<Id, List<ContentVersion>>();
            Set<Id> opportunitySet = new Set<Id>();
            For(ContentVersion cv: cvList)
            {
                if(documentWithOpportunityMap.containsKey(cv.ContentDocumentId))
                {
                    opportunitySet.add(documentWithOpportunityMap.get(cv.ContentDocumentId));
                }
            }
            for(opportunity opp: newOppList)
            {
                //Show the error if opportunity did not find in Opportunity Set.
                if(opp.Bill_to_Account__c == null && opp.Tax_Exempt__c && !opportunitySet.contains(opp.id))
                {
                   opp.addError('You can not set tax exempt true without providing tax exempt document or reseller account');
                }
            }
        }
    }

}