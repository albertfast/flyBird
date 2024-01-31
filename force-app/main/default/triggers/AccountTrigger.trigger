trigger AccountTrigger on Account (after insert, after update) {
    if (trigger.isAfter && trigger.isUpdate) {
        AccountTriggerHandler.deleteOppandContact(trigger.new, trigger.oldMap);
    }
}