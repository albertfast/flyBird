trigger AccountTrigger on Account (after insert, after update) {
    if (trigger.isAfter) {
        if (Trigger.isInsert) {
            AccountTriggerHandler.afterInsert(trigger.new);
        }
        if (trigger.isUpdate) {
            AccountTriggerHandler.afterUpdate(trigger.newMap, trigger.oldMap);
            AccountTriggerHandler.deleteOppandContact(trigger.new, trigger.oldMap);
            
        }
    }
}