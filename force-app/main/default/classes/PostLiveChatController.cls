public class PostLiveChatController {
    public String SelectedExperienceImproved {get; set;}
    public String SelectedLikelihoodToRecommend {get; set;}
    public String OtherComments {get; set;}
    public String ChatDetails {get; set;}
    public String TranscriptId {get; set;}
    public String AgentId {get; set;}
    public String FirstName {get; set;}
    public String LastName {get; set;}
    public String Queue {get; set;}
    public String Email {get; set;}
    public String Source {get; set;}
    public String ChatKey {get; set;}
    public Double expImp {get; set;}
    public Double userNPS {get; set;}
    
    // public Survey_Feedback__c survey = new Survey_Feedback__c();
    
    public PostLiveChatController(){}
    
    public String ContactSearch(String email){
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :email];
        
        if(contacts.size() > 0) return contacts[0].Id;
        else return null;
    }
    
    public String LeadSearch(String email){
        List<Lead> leads = [SELECT Id FROM Lead WHERE Email = :email];
        
        if(leads.size() > 0) return leads[0].Id;
        else return null;
    }
    
    public PageReference submit(){
        // expImp = Double.valueOf(SelectedExperienceImproved);
        // survey.New_CSAT__c = expImp;
        // userNPS = Double.valueOf(SelectedLikelihoodToRecommend);
        // survey.New_NPS__c = userNPS;
        // survey.Other_Comments__c = OtherComments;
        // survey.Provided_First_Name__c = FirstName;
        // survey.Provided_Last_Name__c = LastName;
        // survey.Provided_Email_Address__c = Email;
        // survey.Agent__c = AgentId;
        // survey.Source__c = 'Live Chat';
        // survey.Chat_Key__c = ChatKey;
        // survey.Queue_Detail__c = Queue;
        
        // if(Email != null && Email != ''){
        //     String relatedContact = ContactSearch(Email);
        
        //     if(relatedContact != null){
        //         survey.Related_Contact__c = relatedContact;
        //     } else {
        //         String relatedLead = LeadSearch(Email);
                
        //         if(relatedLead != null) survey.Related_Lead__c = relatedLead;
        //     }
        // }
        
		try {
			// insert survey;
		} catch(Exception e) {
			System.debug('Error PostLiveChatController: '+ e.getMessage());
		}
        
        
        PageReference redirectToFeedbackEnd =  Page.CBTN_postlivechat_end;
        redirectToFeedbackEnd.setRedirect(true);
        return redirectToFeedbackEnd;
    }
}