public class CBTN_CaseTriggerUtility {

    public static void BeforeInsert(List<Case> newCases) 
    {
        for (Case c : newCases) 
        {
            if (c.Auto_Closed__c && c.Status != 'Closed') c.Status = 'Closed';

            c.Current_Status_Start_Time__c = DateTime.now();
            c.Total_Time_in_New_Status__c = 0;
            c.Total_Time_in_On_Hold_Status__c = 0;
            c.Total_Time_in_Waiting_Status__c = 0;
            c.Total_Time_in_Working_Status__c = 0;

            if (String.isBlank(c.Subject)) c.Subject = 'User Submission';
        }
        
    }

    public static void beforeUpdate(List<Case> newCases, Map<Id, Case> oldCases) 
    {
        for (Case c : newCases) 
        {
            if (c.Status != oldCases.get(c.Id).Status) 
            {
                c.Current_Status_Start_Time__c = DateTime.now();
                
            }
            if (c.Auto_Closed__c && c.Status != 'Closed') c.Status = 'Closed';
        }

        if (!newCases.isEmpty()) CBTN_CaseHelper.UpdateCases(newCases, oldCases);
    }

    public static void BeforeDelete(Map<Id, Case> oldMap){
        
    }
    public static void AfterInsert(List<Case> newCases) 
    {
        
    }

    public static void AfterUpdate(List<Case> newCases, Map<Id, Case> oldMap){
        
    }
}