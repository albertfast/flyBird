/*Calculate Number of Cases for each Account
based on their Status(New, Working, Escalated)*/
public with sharing class CaseTriggerHandler {
    public static void countCaseStatus(List<Case> caseList, Map<Id,Case> oldMap) {
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        Set<Id> accIds = new Set<Id>(); // Set to store parent account Ids
        Map<Id,Integer> newCaseCountMap = new  Map<Id,Integer>(); 
        Map<Id,Integer> workingCaseCountMap = new  Map<Id,Integer>();
        Map<Id,Integer> escalatedCaseCountMap = new  Map<Id,Integer>();
    
        // This part works when Case account will be changed
        if (!caseList.isEmpty()) {
            for (Case newCs : caseList) {
                if (oldMap != null) {
                    Case oldCs = oldMap.get(newCs.Id);
                    if (oldCs.AccountId != newCs.AccountId) {
                        accIds.add(oldCs.AccountId);
                        accIds.add(newCs.AccountId);
                    } else if (oldCs.Status != newCs.Status) {
                        accIds.add(newCs.AccountId);
                    }
                } else {
                    accIds.add(newCs.AccountId);
                }
            }
        }
        if (!accIds.isEmpty()) {
        for (Account acc : [SELECT Id,Number_Of_New_Cases__c,
                            Number_Of_Working_Cases__c,Number_Of_Escalated_Cases__c,
                            (SELECT Id,Status FROM Cases) FROM Account WHERE Id IN : accIds]) {
                newCaseCountMap.put(acc.Id, 0);
                workingCaseCountMap.put(acc.Id, 0);
                escalatedCaseCountMap.put(acc.Id, 0);

                for (Case caseObj : acc.Cases) {
                    if (caseObj.Status == 'New') {
                        newCaseCountMap.put(acc.Id,newCaseCountMap.get(acc.Id) + 1);
                    }
                    else if (caseObj.Status == 'Working') {
                        workingCaseCountMap.put(acc.Id,workingCaseCountMap.get(acc.Id) + 1);
                    }
                    else if (caseObj.Status == 'Escalated') {
                        escalatedCaseCountMap.put(acc.Id,escalatedCaseCountMap.get(acc.Id) + 1);
                    }
                }
                if (newCaseCountMap.get(acc.Id) != acc.Number_Of_New_Cases__c ||
                workingCaseCountMap.get(acc.Id) != acc.Number_Of_Working_Cases__c ||
                escalatedCaseCountMap.get(acc.Id) != acc.Number_Of_Escalated_Cases__c) {
                    acc.Number_Of_New_Cases__c = newCaseCountMap.get(acc.Id);
                    acc.Number_Of_Working_Cases__c = workingCaseCountMap.get(acc.Id);
                    acc.Number_Of_Escalated_Cases__c = escalatedCaseCountMap.get(acc.Id);

                    accountsToUpdate.put(acc.Id, acc);
                }
            }
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate.values();
            }
        }
    }
    //Automatically update Task Status And Account Description When case status are modified
    public static void updateAccDescription(List<Case> caseList,Map<Id,Case> oldMap) {
        Set<Id> accIds = new Set<Id>(); // Set to store parent account Ids
        Map<Id,String> caseStatusMap = new Map<Id,String>();
        List<Task> tastToUpdate = new List<Task>();
        List<Account> accountsToUpdate = new List<Account>();
        // This part works when Case status will be changed
        if (!caseList.isEmpty()) {
            for (Case newCs : caseList) {
                if (oldMap != null) {
                    Case oldCs = oldMap.get(newCs.Id);
                    if (oldCs.Status != newCs.Status && newCs.AccountId != null) {
                        caseStatusMap.put(newCs.Id, newCs.Status);
                        accIds.add(newCs.AccountId);
                    }
                } 
            }
        }

        if (!caseStatusMap.isEmpty()) {
            List<Task> tskList = [SELECT Id,Status,WhatId FROM Task
                                  WHERE WhatId IN : caseStatusMap.keySet()];
            if (!tskList.isEmpty()) {
                for (Task tsk : tskList) {
                    String caseStatus;
                    if (caseStatusMap.containsKey(tsk.WhatId)) {
                        caseStatus = caseStatusMap.get(tsk.WhatId);
                    }
                    tsk.Status = caseStatus;
                    tastToUpdate.add(tsk);
                }
            }
            if (!tastToUpdate.isEmpty()) {
                update tastToUpdate;
            }                      
        }

        if (!accIds.isEmpty()) {
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id,Description FROM Account WHERE Id IN : accIds]);
            Map<Id,Case> latestCaseMap = new  Map<Id,Case>();
            for (Case cs : [SELECT AccountId,CaseNumber,Status FROM Case WHERE AccountId IN : accIds AND Status != null]) {
                if (!latestCaseMap.containsKey(cs.AccountId)) {
                    latestCaseMap.put(cs.AccountId, cs);
                }
            }

            for (Account acc : accountMap.values()) {
                if (latestCaseMap.containsKey(acc.Id)) {
                    Case latestCase = latestCaseMap.get(acc.Id);
                    acc.Description = 'Latest Case Status for Case # ' 
                                       + latestCase.CaseNumber + 'and Case Status is ' + latestCase.Status;
                    accountsToUpdate.add(acc);                   
                }
            }
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }
    }
}



