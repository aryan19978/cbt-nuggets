@isTest
private class ContactUsAPITest {
    
    @isTest
    static void testPost() {
        // Create a mock request
        RestRequest request = new RestRequest();
        request.requestURI = '/apex/contact_us';
        request.httpMethod = 'POST';
        
        // Set the request body and content type
        request.requestBody = Blob.valueOf('{"name":"John Doe","email":"johndoe@example.com"}');
        request.addHeader('Content-Type', 'application/json');
        
        // Create a mock response
        RestResponse response = new RestResponse();
        
        // Set the mock
        Test.setMock(HttpCalloutMock.class, new MyRestResourceMock());
        
        // Call the REST resource method
        RestContext.request = request;
        RestContext.response = response;
        ContactUsAPI.doPost();
        
    }
    // Mock class for the HTTP callout
    private class MyRestResourceMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(201);
            response.setBody('{"id":"123"}');
            return response;
        }
    }
}