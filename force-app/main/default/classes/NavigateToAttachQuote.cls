public class NavigateToAttachQuote {
 
    @AuraEnabled
    public static String fetchQuoteButtonValue(String LabelValue) {
        List < Attach_Quote_Button_Id__mdt > cusMeta = [ SELECT Label, Attach_Quote_Button_Value__c FROM Attach_Quote_Button_Id__mdt where Label =: LabelValue ];
        return cusMeta[0].Attach_Quote_Button_Value__c;
    }
}