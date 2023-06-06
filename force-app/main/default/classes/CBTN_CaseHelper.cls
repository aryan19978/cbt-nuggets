public class CBTN_CaseHelper {
    
    public static void UpdateCases(List<Case> newCases, Map<Id, Case> oldCases) {
        for (Case lsCase : newCases) {
            Case oldCase = oldCases.get(lsCase.Id);

            if (lsCase.Status != oldCase.Status) {
                if (oldCase.Status == 'New') {
                    if (lsCase.Total_Time_in_New_Status__c == null) {
                        lsCase.Total_Time_in_New_Status__c = 0.00;
                    }
                    if (oldCase.Current_hours_in_status__c != null) {
                        lsCase.Total_Time_in_New_Status__c += oldCase.Current_hours_in_status__c;
                    } else {
                        lsCase.Total_Time_in_New_Status__c += 0.00;
                    }
                } else if (oldCase.Status == 'Working') {
                    if (lsCase.Total_Time_in_Working_Status__c == null) {
                        lsCase.Total_Time_in_Working_Status__c = 0.00;
                    }
                    if (oldCase.Current_hours_in_status__c != null) {
                        lsCase.Total_Time_in_Working_Status__c += oldCase.Current_hours_in_status__c;
                    } else {
                        lsCase.Total_Time_in_Working_Status__c += 0.00;
                    }
                } else if (oldCase.Status == 'On Hold') {
                    if (lsCase.Total_Time_in_On_Hold_Status__c == null) {
                        lsCase.Total_Time_in_On_Hold_Status__c = 0.00;
                    }
                    if (oldCase.Current_hours_in_status__c != null) {
                        lsCase.Total_Time_in_On_Hold_Status__c += oldCase.Current_hours_in_status__c;
                    } else {
                        lsCase.Total_Time_in_On_Hold_Status__c += 0.00;
                    }
                } else if (oldCase.Status == 'Waiting on Customer' || oldCase.Status == 'Waiting on Dev' || oldCase.Status == 'Waiting on Refund' || oldCase.Status == 'Waiting on Accounting' || oldCase.Status == 'Waiting for Review') {
                    if (lsCase.Total_Time_in_Waiting_Status__c == null) {
                        lsCase.Total_Time_in_Waiting_Status__c = 0.00;
                    }
                    if (oldCase.Current_hours_in_status__c != null) {
                        lsCase.Total_Time_in_Waiting_Status__c += oldCase.Current_hours_in_status__c;
                    } else {
                        lsCase.Total_Time_in_Waiting_Status__c += 0.00;
                    }
                }
            }
        }
    }
}