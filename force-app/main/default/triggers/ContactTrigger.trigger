trigger ContactTrigger on Contact (after insert,after update, after delete, after undelete) {
   if(trigger.isAfter && (trigger.isInsert || trigger.isUndelete)){
        ContactTriggerHandler.updateAccountCountPrimary(trigger.new, null);
    }
    else if(trigger.isAfter && trigger.isUpdate){
        ContactTriggerHandler.updateAccountCountPrimary(trigger.new, trigger.oldMap);
    }
    else if(trigger.isAfter && trigger.isDelete){
        ContactTriggerHandler.updateAccountCountPrimary(trigger.old, null);
    } 
}