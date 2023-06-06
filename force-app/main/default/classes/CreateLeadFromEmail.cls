global class CreateLeadFromEmail implements Messaging.InboundEmailHandler 
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env)
    {
        // Create an InboundEmailResult object for returning the result of the Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try 
        {
            List<Lead> leadList = [Select Id, Name, Email From Lead Where Email = :email.fromAddress Limit 1];
            if( !leadList.IsEmpty()) {
                Task taskObj = new Task();taskObj.Description =  email.plainTextBody;taskObj.Priority = 'Normal';  taskObj.Status = 'Inbound Email';
                taskObj.Subject = email.subject;taskObj.IsReminderSet = true;taskObj.ReminderDateTime = System.now() + 7; taskObj.WhoId =  leadList[0].Id;
                taskObj.ActivityDate = System.today().addDays(1);  insert taskObj; 
                /*
                EmailMessage emailMessage = new EmailMessage();  
                emailMessage.Status = '0';
                emailMessage.FromAddress = email.FromAddress;
                
                if(email.toAddresses.size() > 0){
                    emailMessage.ToAddress = String.join( email.toAddresses, ';' );
                }
                
                if(email.ccAddresses != null && email.ccAddresses.size() > 0){
                    emailMessage.CcAddress = String.join( email.ccAddresses, ';' );
                }
                emailMessage.FromName = email.FromName; // from name  
                emailMessage.Subject = email.Subject; // email subject  
                emailMessage.TextBody = email.plainTextBody; // email body  
                emailMessage.RelatedToId = leadList[0].Id;
                insert emailMessage;
                */
                /*if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                    for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
                        Attachment attachment = new Attachment();
                        // attach to the newly created contact record
                        attachment.ParentId = leadList[0].Id;
                        attachment.Name = email.binaryAttachments[i].filename;
                        attachment.Body = email.binaryAttachments[i].body;
                        insert attachment;
                    }
                } */   
            }
            else {
                // Create a Lead with this email
                Lead leadToInsert = new lead();
                leadToInsert.LastName       = email.FromName;
                leadToInsert.email          = email.fromAddress;
                leadToInsert.Company        = 'Inbound Email';
                leadToInsert.Description    = email.subject + '  :  '+ email.plainTextBody;
                insert leadToInsert;
            } 
        }
        catch (Exception e) 
        {
            System.debug('Exception : ' + e);
        }
        result.success = true;
        return result;
    }
}