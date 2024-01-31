/*
“I have a custom checkbox field IsPrimary__c in the Contact object, 
and a custom field CountOfPrimaryContacts__c in the Account object. 
I would like to increment the CountOfPrimaryContacts__c field on the Account object
whenever a Contact is created or updated with IsPrimary__c set to true.
Could you guide me on how to achieve this functionality?”
*/
public with sharing class ContactTriggerHandler {
    public static void updateAccountCountPrimary(List<Contact> conList, Map<Id,Contact> oldMap) {
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        Set<Id> accIds = new Set<Id>(); // Set to store parent account Ids
    
        // This part works when Contact account will be changed
        if (!conList.isEmpty()) {
            for (Contact newCon : conList) {
                if (oldMap != null) {
                    Contact oldCon = oldMap.get(newCon.Id);
                    if (oldCon.AccountId != newCon.AccountId) {
                        accIds.add(oldCon.AccountId);
                        accIds.add(newCon.AccountId);
                    } else if (oldCon.Is_Primary__c != newCon.Is_Primary__c) {
                        accIds.add(newCon.AccountId);
                    }
                } else {
                    accIds.add(newCon.AccountId);
                }
            }
        }

        if (!accIds.isEmpty()) {
            Map<Id, Integer> conCountMap = new Map<Id, Integer>(); 
            List<Contact> contactList = [SELECT Id,AccountId,Is_Primary__c FROM Contact
            WHERE AccountId IN :accIds AND Is_Primary__c = true ];
            if (!contactList.isEmpty()) {
                for (Contact conObj : contactList) {
                    if (conCountMap.containsKey(conObj.AccountId)) {
                        conCountMap.put(conObj.AccountId, conCountMap.get(conObj.AccountId)+1);
                    }
                    else {
                        conCountMap.put(conObj.AccountId, 1);
                    }
                }
            }
            for (Id ids : accIds) {
                if (conCountMap.containsKey(ids)) {
                    Integer totalCount = conCountMap.containsKey(ids) ? conCountMap.get(ids) : 0;
                    if (totalCount != null) {
                        accountsToUpdate.put(ids, new Account(Id = ids, CountOfPrimaryContacts__c = totalCount ));
                    }
                    else {
                        accountsToUpdate.put(ids, new Account(Id = ids,  
                                             CountOfPrimaryContacts__c   = null ));
                    }
                }
                else {
                    accountsToUpdate.put(ids, new Account(Id = ids, 
                                          CountOfPrimaryContacts__c = null ));
                }
            }
        }
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate.values();
        }
        }
    }

    