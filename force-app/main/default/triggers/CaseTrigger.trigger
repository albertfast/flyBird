trigger CaseTrigger on Case (after insert,after update, after delete, after undelete) {
    if(trigger.isAfter && (trigger.isInsert || trigger.isUndelete)){
        CaseTriggerHandler.countCaseStatus(trigger.new, null);
    }
    else if(trigger.isAfter && trigger.isUpdate){
        CaseTriggerHandler.countCaseStatus(trigger.new, trigger.oldMap);
        CaseTriggerHandler.updateAccDescription(trigger.new, trigger.oldMap);
    }
    else if(trigger.isAfter && trigger.isDelete){
        CaseTriggerHandler.countCaseStatus(trigger.old, null);
    }
}




