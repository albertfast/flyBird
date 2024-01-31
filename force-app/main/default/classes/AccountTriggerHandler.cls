public with sharing class AccountTriggerHandler {
    //Delete all related Opportunities and check Do Not Contact checkbox on related 
    //contact when user chages Account Status from Open to closed.
    public static void deleteOppandContact(List<Account> newAccList, Map<Id,Account> oldAccMap) {
        Set<Id> accIds = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Contact> listToUpdateCon = new List<Contact>();
        if (!newAccList.isEmpty()) {
            for (Account newAcc : newAccList) {
                if (!oldAccMap.isEmpty()) {
                    Account oldAcc = oldAccMap.get(newAcc.Id);

                    if (newAcc.Account_Status__c == 'Closed' && oldAcc.Account_Status__c == 'Open') {
                        accIds.add(newAcc.Id);
                    }
                }
            }
        }

        if (!accIds.isEmpty()) {
            conList = [SELECT Id,Do_Not_Contact__c FROM Contact WHERE AccountId IN : accIds
                       AND Do_Not_Contact__c = false ];
            oppList = [SELECT Id,StageName FROM Opportunity WHERE AccountId IN : accIds
                       AND StageName != 'Closed Won' ];
            if (!conList.isEmpty()) {
                for (Contact con : conList) {
                    con.Do_Not_Contact__c = true;
                    listToUpdateCon.add(con);
                }
            }
            try {
                if (!listToUpdateCon.isEmpty()) {
                    update listToUpdateCon;
                }

                if (!oppList.isEmpty()) {
                    delete oppList;
                }
            } catch (Exception ex) {
                System.debug('Error while doing updatiob or deletion--> ' + ex.getMessage());
            }           
        }
    }
}