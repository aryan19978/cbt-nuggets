@isTest
private class CBTN_CaseHelperTests {
    @testSetup
    private static void setUpData()
    {
        Test.startTest();
        Case testCase = TestDataFactory.CreateNewCase();
        insert testCase;
        
        Case testCase2 = TestDataFactory.CreateWorkingCase();
        insert testCase2;
        
        Case testCase3 = TestDataFactory.CreateOnHoldCase();
        insert testCase3;
        
        Case testCase4 = TestDataFactory.CreateOnWaitingonCustomerCase();
        insert testCase4;
        
        Case testCase5 = TestDataFactory.CreateCase();
        insert testCase5;
    }
    @isTest
    private static void testUpdateCases_New() {
        Test.startTest();
        
        Case c = [SELECT id, Status from Case where Supplied_Email__c = 'case.newcase@test.biz'];
        c.Status = 'Closed';
        c.Total_Time_In_New_Status__c = null;
        update c;
        Test.stopTest();
        
        Case result = [SELECT id, Total_Time_in_New_Status__c, Current_hours_in_status__c from Case where Supplied_Email__c = 'case.newcase@test.biz'];
        if (result.Total_Time_in_New_Status__c == null) {
            System.assertEquals(0.00, result.Total_Time_in_New_Status__c);
        }
    }
    
    @isTest
    private static void testUpdateCases_Working() {
        Test.startTest();
        
        Case c = [SELECT id, Status from Case where Supplied_Email__c = 'case.workingcase@test.biz'];
        c.Status = 'Closed';
        c.Total_Time_in_Working_Status__c = null;
        update c;
        Test.stopTest();
        
        Case result = [SELECT id, Total_Time_in_Working_Status__c, Current_hours_in_status__c from Case where Supplied_Email__c = 'case.workingcase@test.biz'];
        if (result.Total_Time_in_Working_Status__c == null) {
            System.assertEquals(0.00, result.Total_Time_in_Working_Status__c);
        }
    }
    
    @isTest
    private static void testUpdateCases_OnHold() {
        Test.startTest();
        
        Case c = [SELECT id, Status from Case where Supplied_Email__c = 'case.onholdcase@test.biz'];
        c.Status = 'Closed';
        c.Total_Time_in_On_Hold_Status__c = null;
        update c;
        Test.stopTest();
        
        Case result = [SELECT id, Total_Time_in_On_Hold_Status__c, Current_hours_in_status__c from Case where Supplied_Email__c = 'case.onholdcase@test.biz'];
        if (result.Total_Time_in_On_Hold_Status__c == null) {
            System.assertEquals(0.00, result.Total_Time_in_On_Hold_Status__c);
        }
    }
    
    @isTest
    private static void testUpdateCases_WaitingonCustomer() {
        Test.startTest();
        
        Case c = [SELECT id, Status from Case where Supplied_Email__c = 'case.waitingcase@test.biz'];
        c.Status = 'Closed';
        c.Total_Time_in_Waiting_Status__c = null;
        update c;
        Test.stopTest();
        
        Case result = [SELECT id, Total_Time_in_Waiting_Status__c, Current_hours_in_status__c from Case where Supplied_Email__c = 'case.waitingcase@test.biz'];
        if (result.Total_Time_in_Waiting_Status__c == null) {
            System.assertEquals(0.00, result.Total_Time_in_Waiting_Status__c);
        }
    }
}