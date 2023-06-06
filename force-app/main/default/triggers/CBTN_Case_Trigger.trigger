trigger CBTN_Case_Trigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete)  {
    if (Trigger.isBefore) {
        if (CBTN_TriggerRecursionHandler.CaseRunBeforeOnce()) {
            if (Trigger.isInsert) {
                if(!System.isFuture()){
                    CBTN_CaseTriggerUtility.BeforeInsert(Trigger.new);
                }
            }

            if (Trigger.isUpdate) {
                CBTN_CaseTriggerUtility.BeforeUpdate(Trigger.new, Trigger.oldMap);
            }

            if (Trigger.isUndelete) {}

            if (Trigger.isExecuting) {}
        }

        if (Trigger.isDelete) {
            CBTN_CaseTriggerUtility.BeforeDelete(Trigger.oldMap);
        }
    } else {
        if (CBTN_TriggerRecursionHandler.CaseRunAfterOnce()) {
            if (Trigger.isInsert) {
                CBTN_CaseTriggerUtility.AfterInsert(Trigger.new);
            }

            if (Trigger.isUpdate){
                CBTN_CaseTriggerUtility.AfterUpdate(Trigger.new, Trigger.oldMap);
            }

            if (Trigger.isInsert) {}

            if (Trigger.isDelete) {}

            if (Trigger.isUndelete) {}

            if (Trigger.isExecuting) {}
        }
    }

}