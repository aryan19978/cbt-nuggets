@IsTest
public class CreateQuoteControllerTest {
    @isTest
    static void testgetEndDate() {
        // Set up test data
        Account accRec = TestDataFactory.CreateAccount();
        Insert accRec;
        Contact conRec = TestDataFactory.CreateContact(accRec.id);
        Insert conRec;
        Opportunity oppRec = TestDataFactory.CreateOpportunity(accRec.id);
        Insert oppRec;
        Product2 prdRec = TestDataFactory.Createproduct();
        insert prdRec;
        PricebookEntry pbeRec = TestDataFactory.CreatePricebookEntry(prdRec.Id);
        insert pbeRec;
        Product2 prdRec2 = TestDataFactory.CreateproductProrationDiscount();
        insert prdRec2;
        PricebookEntry pbeRec2 = TestDataFactory.CreatePricebookEntry(prdRec2.Id);
        insert pbeRec2;
        Quote quoRec = TestDataFactory.CreateQuote(oppRec.id);
        Insert quoRec;
        test.startTest();
        CreateQuoteController.getEndDate(Date.today().addDays(5),'Yearly');
        CreateQuoteController.getContact(conRec.id);
        CreateQuoteController.getQuoteDetail(oppRec.id);
        test.stopTest();
    }
}