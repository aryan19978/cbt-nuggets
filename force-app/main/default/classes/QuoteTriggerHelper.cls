public class QuoteTriggerHelper {
    @future(callout=true)
    public static void doCallout(Map<String, String> inputData)
    {
        ProcessOrderCalloutHandler.makeHttpCallout(inputData);
    }
}