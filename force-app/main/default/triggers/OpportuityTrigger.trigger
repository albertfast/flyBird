trigger OpportuityTrigger on Opportunity (after insert,after update, after delete, after undelete) {
    /*Update Account Total_Opportunity_Amount__c based on Total Amount of Related Opportunities.*/
    if(trigger.isAfter && (trigger.isInsert || trigger.isUndelete)){
        opportunityTriggerHandler.updateAccountTotalOppFields(trigger.new, null);
    }
    else if(trigger.isAfter && trigger.isUpdate){
        opportunityTriggerHandler.updateAccountTotalOppFields(trigger.new, trigger.oldMap);
    }
    else if(trigger.isAfter && trigger.isDelete){
        opportunityTriggerHandler.updateAccountTotalOppFields(trigger.old, null);
    }

    if(trigger.isAfter && (trigger.isInsert || trigger.isUndelete)){
        opportunityTriggerHandler.updateAccountStatus(trigger.new, null);
    }
    else if(trigger.isAfter && trigger.isUpdate){
        opportunityTriggerHandler.updateAccountStatus(trigger.new, trigger.oldMap);
    }
    else if(trigger.isAfter && trigger.isDelete){
        opportunityTriggerHandler.updateAccountRating(trigger.old, null);
    }
    //Update Account Rating based on Total Amount of Related Opportunities.
    if(trigger.isAfter && (trigger.isInsert || trigger.isUndelete)){
        opportunityTriggerHandler.updateAccountRating(trigger.new, null);
    }
    else if(trigger.isAfter && trigger.isUpdate){
        opportunityTriggerHandler.updateAccountRating(trigger.new, trigger.oldMap);
    }
    else if(trigger.isAfter && trigger.isDelete){
        opportunityTriggerHandler.updateAccountRating(trigger.old, null);
    } 
    
}


