public with sharing class LeadTriggerHandler {
//Automatically create a follow-up Task with additional 
//info in Description when a Lead is converted.
    public static void createFollowUpTask(List<Lead> newLeadList, Map<Id,Lead> oldLeadMap) {
        Set<Id> convertedAccIds = new Set<Id>();
        Set<Id> convertedConIds = new Set<Id>();
        Set<Id> convertedOppIds = new Set<Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Lead> convertedLeads = new List<Lead>();
        List<Task> tasksToUpdate = new List<Task>();
        if (!newLeadList.isEmpty()) {
            for (Lead newLead : newLeadList) {
                if (!oldLeadMap.isEmpty()) {
                    Lead oldLead = oldLeadMap.get(newLead.Id);
                    if (newLead.IsConverted && !oldLead.IsConverted) {
                        convertedLeads.add(newLead);

                        if (newLead.ConvertedAccountId != null) {
                            convertedAccIds.add(newLead.ConvertedAccountId);
                        }
                        if (newLead.ConvertedOpportunityId != null) {
                            convertedOppIds.add(newLead.ConvertedOpportunityId);
                        }
                        if (newLead.ConvertedContactId != null) {
                            convertedConIds.add(newLead.ConvertedContactId);
                        }
                    }
                }
                
            }
        }

        if (!convertedLeads.isEmpty()) {
            if (!convertedAccIds.isEmpty()) {
                accMap = new Map<Id,Account>([SELECT Id,Name FROM Account WHERE Id IN : convertedAccIds]);
            }
            if (!convertedConIds.isEmpty()) {
                conMap = new Map<Id,Contact>([SELECT Id,Name,Email FROM Contact WHERE Id IN : convertedConIds]);
            }
            if (!convertedOppIds.isEmpty()) {
                oppMap = new Map<Id,Opportunity>([SELECT Id,Name,CloseDate FROM Opportunity WHERE Id IN : convertedOppIds]);
            }

            for (Lead leadObj : convertedLeads) {
                Task newTask = new Task();
                newTask.Subject = 'Follow-Up with converted leads';
                newTask.Priority = 'Normal';
                newTask.Status = 'Not Started';
                newTask.ActivityDate = Date.today()+7;
                newTask.WhoId = leadObj.ConvertedContactId;
                newTask.WhatId = leadObj.ConvertedOpportunityId;

                String taskDescription = 'Lead Name : ' + leadObj.FirstName + '\n';
                taskDescription += 'Lead Email : ' + leadObj.Email + '\n';
                taskDescription += 'Lead Phone : ' + leadObj.Phone + '\n';

                if (accMap.containsKey(leadObj.ConvertedAccountId)) {
                    Account acc = accMap.get(leadObj.ConvertedAccountId);
                    taskDescription += 'Account Name : ' + acc.Name + '\n';
                }
                if (conMap.containsKey(leadObj.ConvertedContactId)) {
                    Contact con = conMap.get(leadObj.ConvertedContactId);
                    taskDescription += 'Contact Name : ' + con.Name + '\n';
                    taskDescription += 'Contact Email : ' + con.Email + '\n';
                }
                if (oppMap.containsKey(leadObj.ConvertedOpportunityId)) {
                    Opportunity opp = oppMap.get(leadObj.ConvertedOpportunityId);
                    taskDescription += 'Opportunity Name : ' + opp.Name + '\n';
                    taskDescription += 'Opportunity Close Date : ' + opp.CloseDate + '\n';
                }

                newTask.Description = taskDescription;
                tasksToUpdate.add(newTask);
            }
        }

        if (!tasksToUpdate.isEmpty()) {
            insert tasksToUpdate;
        }
    }
  
}






