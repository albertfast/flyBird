public with sharing class AccountSalaryHandler {
    public static void afterInsert(List<Account_Salary__c> newSalaries) {
        Set<Id> accountIds = new Set<Id>();
        //iterate over salary records & collect their parent account ids
        for (Account_Salary__c sal : newSalaries) {
            accountIds.add(sal.Account__c);
        }

        //get all the accounts along with its children salary records
        List<Account> accounts = [SELECT Id, Total_Salary__c, Max_Salary__c,
                                 (SELECT Id, Account__c, Salary__c FROM Account_Salaries__r) 
                                 FROM Account WHERE Id IN :accountIds];
        for (Account acc : accounts) {
            Decimal total = 0.0; 
            Decimal max = 0.0;
            for (Account_Salary__c sal : acc.Account_Salaries__r) {
                if (max < sal.Salary__c) {
                    max = sal.Salary__c;
                }
                total = total + sal.Salary__c;
            }
            acc.Total_Salary__c = total;
            acc.Max_Salary__c = max;
        }

        //update accounts
        try {
            update accounts;
        } catch (Exception ex) {
            //create log
            System.debug(ex.getMessage());
        }
    }
}