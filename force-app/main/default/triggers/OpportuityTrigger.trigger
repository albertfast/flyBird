trigger OpportuityTrigger on Opportunity (after insert,after update, after delete, after undelete) {
    /*Update Account Total_Opportunity_Amount__c based on Total Amount of Related Opportunities.*/
    if(trigger.isAfter && (trigger.isInsert || trigger.isUndelete)){
        opportunityTriggerHandler.updateAccountTotalOppFields(trigger.new, null);
        opportunityTriggerHandler.updateAccountStatus(trigger.new, null);
        opportunityTriggerHandler.updateAccountRating(trigger.new, null);
        opportunityTriggerHandler.accountUpdateFromOppAmount(trigger.new, null);
    }
    else if(trigger.isAfter && trigger.isUpdate){
        opportunityTriggerHandler.updateAccountTotalOppFields(trigger.new, trigger.oldMap);
        opportunityTriggerHandler.updateAccountStatus(trigger.new, trigger.oldMap);
        opportunityTriggerHandler.updateAccountRating(trigger.new, trigger.oldMap);
        opportunityTriggerHandler.accountUpdateFromOppAmount(trigger.new, trigger.oldMap);
    }
    else if(trigger.isAfter && trigger.isDelete){
        opportunityTriggerHandler.updateAccountTotalOppFields(trigger.old, null);
        opportunityTriggerHandler.updateAccountRating(trigger.old, null);
        opportunityTriggerHandler.updateAccountRating(trigger.old, null);
        opportunityTriggerHandler.accountUpdateFromOppAmount(trigger.old, null);
    }   
}


