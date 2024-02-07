trigger CaseTrigger on Case (after insert,after update, after delete, after undelete) {
    Set<Id> accountIds = new Set<Id>();

    if (Trigger.isInsert || Trigger.isUndelete) {
        for (Case cs : Trigger.new) {
            if (cs.AccountId != null) {
                accountIds.add(cs.AccountId);
            }
        }
        CaseTriggerHandler.countCaseStatus(Trigger.new, null);
    } else if (Trigger.isUpdate) {
        for (Case cs : Trigger.new) {
            if (cs.AccountId != null && (Trigger.oldMap.get(cs.Id).Origin != cs.Origin)) {
                accountIds.add(cs.AccountId);
            }
        }
        CaseTriggerHandler.countCaseStatus(Trigger.new, Trigger.oldMap);
        CaseTriggerHandler.updateAccDescription(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isDelete) {
        for (Case cs : Trigger.old) {
            if (cs.AccountId != null) {
                accountIds.add(cs.AccountId);
            }
        }
        CaseTriggerHandler.countCaseStatus(Trigger.old, null);
    }

    if (!accountIds.isEmpty()) {
        AccountProcessor.processAccounts(new List<Id>(accountIds));
    }
}




/*
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
*/