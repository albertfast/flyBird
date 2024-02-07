public with sharing class AccountProcessor {
    //I want a way to count the number of cases created through phone,web, and email. 
    //Update the counted value on account in the respective counter field.
    @future
    public static void processAccounts(List<Id> accountIds) {
        //collect all the accounts along with its cases
        List<Account> accounts = [SELECT Id, Case_Through_Web__c,Case_Through_Phone__c,Case_Through_Email__c,
                                 (SELECT Id, Origin FROM Cases) 
                                 FROM Account
                                 WHERE Id IN :accountIds];
        //iterate over the accounts and its cases to count them by category
        for (Account acc : accounts) {
            Integer web = 0;
            Integer phone = 0;
            Integer email = 0;
            for (Case cs : acc.Cases) {
                if (cs.Origin == 'Web') {
                    web++;
                } else if (cs.Origin == 'Phone') {
                    phone++;
                } else if (cs.Origin == 'Email') {
                    email++;
                }
            }
            acc.Case_Through_Web__c = web;
            acc.Case_Through_Phone__c = phone;
            acc.Case_Through_Email__c = email;
        }
        //update accounts
        if (!accounts.isEmpty()) {
            try {
                update accounts;
            } catch (Exception ex) {
                //create log
            System.debug(ex.getMessage());
            }
        }
    }
}


