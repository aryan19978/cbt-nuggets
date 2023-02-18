public class HttpCalloutUtility { 
    // get value from HTTPEndpointConfiguration	custom metadata
    public static string getValueCustomMetadata(string label)
    {
        HTTPEndpointConfiguration__mdt key = HTTPEndpointConfiguration__mdt.getInstance(label);
        return key.Value__c;
    }

}