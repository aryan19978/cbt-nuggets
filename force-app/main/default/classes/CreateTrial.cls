global class CreateTrial {
    
    global class leadRequest {
        @InvocableVariable(required=true)
        global Id LeadIds;
        @InvocableVariable
        global String resellerAccountId;
    }
    
    global class FlowOutput{
        @InvocableVariable public Id contactId;
        @InvocableVariable public Id OpportunityId;
    }
    
    
    @InvocableMethod(label='Convert Lead')
    global static List<FlowOutput> assignLeads(List<leadRequest> lr){
        LeadStatus cLeadStatus=[Select Id,MasterLabel from LeadStatus where isConverted=true limit 1];
        List<Database.LeadConvert> massLeadConvert=new List<Database.LeadConvert>();
        Database.LeadConvert LeadConvert=new Database.LeadConvert();
        LeadConvert.setLeadId(lr[0].LeadIds);
        LeadConvert.setConvertedStatus(cLeadStatus.MasterLabel);
        LeadConvert.setDoNotCreateOpportunity(false);        
        massLeadConvert.add(LeadConvert);
        List<Database.LeadConvertResult> lcr;
        if(!massLeadConvert.isEmpty()){
            lcr  = Database.convertLead(massLeadConvert);
        }
        Id OpportunityId;
        Id ContactId;
        for(Database.LeadConvertResult lctemp: lcr){
            OpportunityId = lctemp.getOpportunityId();
            ContactId = lctemp.getContactId();
        }
        if(ContactId != null){
            Contact con = new Contact(Id=ContactId, Primary_Contact__c = true,Owner__c = true);
            update con;
        }
        if(OpportunityId != null && lr[0].resellerAccountId != null)
        {
            Opportunity opp = new Opportunity(Id=OpportunityId, Bill_to_Account__c = lr[0].resellerAccountId);
            update opp;
        }
        
        List<FlowOutput> results = new List<FlowOutput>();
        FlowOutput result = new FlowOutput();
        result.contactId =  ContactId;
        result.OpportunityId = OpportunityId;
        results.add(result);
        
        return results;
    }
}