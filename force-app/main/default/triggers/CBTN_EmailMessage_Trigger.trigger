trigger CBTN_EmailMessage_Trigger on EmailMessage (before update, before insert, before delete, after update, after insert, after delete) 
{
  if(Trigger.isBefore) 
    {
        if(Trigger.isInsert){
            // CBTN_EmailMessageTriggerUtility.BeforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {}
        if(Trigger.isDelete) {}
        if(Trigger.isUndelete) {}
        if(Trigger.isExecuting) {}    
    }
    else 
    {
        // if (CBTN_TriggerRecursionHandler.emailMessageRunAfterOnce()) 
        // {
        //     if(Trigger.isInsert){
        //         // CBTN_EmailMessageTriggerUtility.AfterInsert(Trigger.new);
        //     }
        //     if(Trigger.isUpdate) {}
        //     if(Trigger.isDelete) {}
        //     if(Trigger.isUndelete) {}
        //     if(Trigger.isExecuting) {}     
        // }     
    }
}