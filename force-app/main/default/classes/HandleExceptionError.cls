public class HandleExceptionError {
    public static void LogException(String className, String methodName, string relatedToId,Exception e,
                                    String Request, String Response)
    {
        try
        {
            String stackTrace = e.getStackTraceString().substringBefore('\n');
            
            //Log information in object
            Custom_Exception__c exc = new Custom_Exception__c();
            Id relatedTo = relatedToId; 
            exc.Related_To__c = String.valueof(relatedTo.getsobjecttype());
            exc.Exception_Message__c = e.getMessage();
            exc.Exception_Type__c = e.getTypeName();
            exc.Line_Number__c = String.valueof(e.getLineNumber());
            exc.StackTrace__c = e.getStackTraceString();
            exc.MethodName__c=methodName;
            exc.ClassName__c=className;
            exc.Request__c = Request;
            exc.Response__c = Response;
            exc.User__c     =  ' UserName: '+ UserInfo.getName() +'\n UserId: ' + UserInfo.getUserId() +'\n ProfileId: ' + UserInfo.getProfileId();
            database.insert(exc);            
        } 
        finally{
        }            
    } 
}