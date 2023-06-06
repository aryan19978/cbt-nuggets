@IsTest
public class HttpCalloutUtilityTest {
    @IsTest
    static void testGetValueCustomMetadata() {
        HTTPEndpointConfiguration__mdt config  = TestDataFactory.createHTTPEndpointConfiguration('apiKey','bfec5831-b488'); 
        // Test getValueCustomMetadata() method
        String value = HttpCalloutUtility.getValueCustomMetadata('apiKey');
    }
}