trigger AccountSalaryTrigger on Account_Salary__c (before delete, after insert) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            AccountSalaryHandler.afterInsert(Trigger.new);
        }
    }
}


   