@IsTest
public class CreateTrialTest {
    @isTest
    static void testMakeActivateInvoiceCalloutHandler() {
        // Set up test data
        Lead ld = TestDataFactory.CreateLead();
        insert ld;
        CreateTrial.leadRequest input = new CreateTrial.leadRequest();
        input.LeadIds = ld.id;
        List<CreateTrial.leadRequest> inputs = new List<CreateTrial.leadRequest>();
        inputs.add(input);
        
        test.startTest();
        //Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        List<CreateTrial.FlowOutput> result1 = CreateTrial.assignLeads(inputs);
        //System.assertEquals(1, result1.size());
        //CreateTrial.FlowOutput output1 = result1[0];
        //System.assertEquals('success', output1.responseType);
        
    }
    
    
}