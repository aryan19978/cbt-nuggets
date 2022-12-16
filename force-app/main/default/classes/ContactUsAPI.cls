@RestResource(urlMapping='/apex/contact_us')
global class ContactUsAPI {
    @HttpPost 
    global static void doPost() {
        RestResponse res = RestContext.response;

        try {
            Map<String, Object> req = (Map<String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.ToString());
            Flow.Interview.Contact_Us contactUs = new Flow.Interview.Contact_Us(req);     
            contactUs.start();
            res.responseBody = Blob.valueOf(String.valueOf(contactUs.getVariableValue('response_message')));
            res.statusCode = Integer.valueOf(contactUs.getVariableValue('response_status'));
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
        }
    }
}