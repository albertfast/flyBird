public with sharing class opportunityTriggerHandler {
/*When all opportunities linked to an Account are Closed Won,Update the Account Status to Closed. 
However if any Opportunity is not Closed Won,update the Account Status to Open.*/
   public static void updateAccountStatus(List<Opportunity> oppList, Map<Id,Opportunity> oldMap){
    List<Account> listToUpdate = new List<Account>();
    Set<Id> accIds = new Set<Id>(); //Set to store parent account Ids
    //This part work on when opportunity account will be change
    if(!oppList.isEmpty()){
        for(Opportunity newOpp : oppList){
            if(oldMap != null){
                Opportunity oldOpp = oldMap.get(newOpp.Id);
                if(oldOpp.AccountId != newOpp.AccountId){
                    accIds.add(oldOpp.AccountId); 
                    accIds.add(newOpp.AccountId);
                }
                else if(oldOpp.StageName != newOpp.StageName){
                    accIds.add(newOpp.AccountId);
                }
            }
            else{
                accIds.add(newOpp.AccountId);
            }
        }
    }

    if(!accIds.isEmpty()){
        Map<Id,List<Opportunity>> accMap = new Map<Id,List<Opportunity>>();
        for(Opportunity oppObj : [SELECT Id,AccountId,StageName FROM Opportunity
                                  WHERE AccountId IN : accIds])
        {
            if(!accMap.containsKey(oppObj.AccountId)){
                accMap.put(oppObj.AccountId, new List<Opportunity>());
            }
            accMap.get(oppObj.AccountId).add(oppObj);
        }
        for(Id ids : accMap.keySet()){
            List<Opportunity> accOpps = accMap.get(ids);
            if(!accOpps.isEmpty()){
                Boolean allClosedOpps = true;
                for(Opportunity opp : accOpps){
                    if(!opp.StageName.equals('Closed Won')){
                        allClosedOpps = false;
                        break;
                    }
                }
               if(allClosedOpps){
                listToUpdate.add(new Account(Id = ids, Account_Status__c='Closed'));
               }

               else{
                listToUpdate.add(new Account(Id = ids, Account_Status__c='Open'));
               } 
            }
        }
        if(!listToUpdate.isEmpty()){
            update listToUpdate;
        }
    }
   }
   /*Update Account Rating based on Total Amount of Related Opportunities.*/
   public static void updateAccountRating(List<Opportunity> oppList,  Map<Id,Opportunity> oldMap) {
    Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
    Set<Id> accIds = new Set<Id>(); //Set to store parent account Ids
    //This part work on when opportunity account will be change
    if (!oppList.isEmpty()) {
        for (Opportunity newOpp : oppList) {
            if(oldMap != null){
                Opportunity oldOpp = oldMap.get(newOpp.Id);
                if(oldOpp.AccountId != newOpp.AccountId){
                    accIds.add(oldOpp.AccountId); 
                    accIds.add(newOpp.AccountId);
                }
                else if(oldOpp.Amount != newOpp.Amount){
                    accIds.add(newOpp.AccountId);
                }
            }
            else{
                accIds.add(newOpp.AccountId);
            }
        }
    }
    if (!accIds.isEmpty()) {
        Map<Id,Double> oppTotalAmountMap = new Map<Id,Double>();
        List<Opportunity> opptyList = [SELECT Id,AccountId,Amount FROM Opportunity
                                       WHERE AccountId IN : accIds];
        if (!opptyList.isEmpty()) {
            for (Opportunity oppObj : opptyList) {
                if (oppTotalAmountMap.containsKey(oppObj.AccountId)) {
                    oppTotalAmountMap.put(oppObj.AccountId, oppTotalAmountMap.get(oppObj.AccountId)+oppObj.Amount);
                }
                else {
                    oppTotalAmountMap.put(oppObj.AccountId, oppObj.Amount);
                }
            }
        } 
        for (Id ids : accIds) {
            if (oppTotalAmountMap.containsKey(ids)) {
                Double totalAmount = oppTotalAmountMap.get(ids);
                String rating;

                Integer coldThreshold = 50000;
                Integer warmThereshold = 100000;

                if (totalAmount <= coldThreshold) {
                    rating = 'Cold';
                }
                else if (totalAmount <= warmThereshold) {
                    rating = 'Warm';
                }
                else  {
                    rating = 'Hot';
                }
                accountsToUpdate.put(ids, new Account(Id = ids, Rating = rating));
            }
            else {
                accountsToUpdate.put(ids, new Account(Id = ids, Rating = null));
            }
        }
    }
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate.values();
    } 
   }
   /*Update Account Total_Opportunity_Amount__c and Total_Opportunity_Count__c
    based on Total Amount of Related Opportunities.*/
   public static void updateAccountTotalOppFields(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
    Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
    Set<Id> accIds = new Set<Id>(); // Set to store parent account Ids

    // This part works when opportunity account will be changed
    if (!oppList.isEmpty()) {
        for (Opportunity newOpp : oppList) {
            if (oldMap != null) {
                Opportunity oldOpp = oldMap.get(newOpp.Id);
                if (oldOpp.AccountId != newOpp.AccountId) {
                    accIds.add(oldOpp.AccountId);
                    accIds.add(newOpp.AccountId);
                } else if (oldOpp.Amount != newOpp.Amount) {
                    accIds.add(newOpp.AccountId);
                }
            } else {
                accIds.add(newOpp.AccountId);
            }
        }
    }

    if (!accIds.isEmpty()) {
        Map<Id, Double> oppTotalAmountMap = new Map<Id, Double>();
        Map<Id, Integer> oppCountMap = new Map<Id, Integer>();

        List<Opportunity> opptyList = [SELECT Id, AccountId, Amount FROM Opportunity WHERE AccountId IN :accIds];

        if (!opptyList.isEmpty()) {
            for (Opportunity oppObj : opptyList) {
                if (oppTotalAmountMap.containsKey(oppObj.AccountId)) {
                    oppTotalAmountMap.put(oppObj.AccountId, oppTotalAmountMap.get(oppObj.AccountId) + oppObj.Amount);
                    oppCountMap.put(oppObj.AccountId, oppCountMap.get(oppObj.AccountId) + 1);
                } else {
                    oppTotalAmountMap.put(oppObj.AccountId, oppObj.Amount);
                    oppCountMap.put(oppObj.AccountId, 1);
                }
            }
        }

        for (Id ids : accIds) {
            if (oppTotalAmountMap.containsKey(ids)) {
                Double totalAmount = oppTotalAmountMap.get(ids);
                Integer totalCount = oppCountMap.containsKey(ids) ? oppCountMap.get(ids) : 0;

                if (totalAmount != null && totalAmount > 0) {
                    accountsToUpdate.put(ids, new Account(Id = ids, Total_Opportunity_Amount__c = totalAmount, Total_Opportunity_Count__c = totalCount));
                    System.debug('TotalCount: ' + totalCount);
System.debug('OppCountMap: ' + oppCountMap);

                } else {
                    accountsToUpdate.put(ids, new Account(Id = ids, Total_Opportunity_Amount__c = null, Total_Opportunity_Count__c = null));
                }
                
            } else {
                accountsToUpdate.put(ids, new Account(Id = ids, Total_Opportunity_Amount__c = null, Total_Opportunity_Count__c = null));
            }
        }
    }

    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate.values();
    }
}

}


/*
 public static void updateAccountTotalOppAmount(List<Opportunity> oppList,  Map<Id,Opportunity> oldMap) {
    Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
    Set<Id> accIds = new Set<Id>(); //Set to store parent account Ids
    //This part work on when opportunity account will be change
    if (!oppList.isEmpty()) {
        for (Opportunity newOpp : oppList) {
            if(oldMap != null){
                Opportunity oldOpp = oldMap.get(newOpp.Id);
                if(oldOpp.AccountId != newOpp.AccountId){
                    accIds.add(oldOpp.AccountId); 
                    accIds.add(newOpp.AccountId);
                }
                else if(oldOpp.Amount != newOpp.Amount){
                    accIds.add(newOpp.AccountId);
                }
            }
            else{
                accIds.add(newOpp.AccountId);
            }
        }
    }
    if (!accIds.isEmpty()) {
        Map<Id,Double> oppTotalAmountMap = new Map<Id,Double>();
        List<Opportunity> opptyList = [SELECT Id,AccountId,Amount FROM Opportunity
                                       WHERE AccountId IN : accIds];
        if (!opptyList.isEmpty()) {
            for (Opportunity oppObj : opptyList) {
                if (oppTotalAmountMap.containsKey(oppObj.AccountId)) {
                    oppTotalAmountMap.put(oppObj.AccountId, oppTotalAmountMap.get(oppObj.AccountId)+oppObj.Amount);
                }
                else {
                    oppTotalAmountMap.put(oppObj.AccountId, oppObj.Amount);
                }
            }
        } 
        for (Id ids : accIds) {
            if (oppTotalAmountMap.containsKey(ids)) {
                Double totalAmount = oppTotalAmountMap.get(ids);
       
                if (totalAmount != null && totalAmount > 0) {
                    accountsToUpdate.put(ids, new Account(Id = ids, Total_Opportunity_Amount__c = totalAmount));
                }
            }
            else {
                accountsToUpdate.put(ids, new Account(Id = ids, Total_Opportunity_Amount__c = null));
            }
        }
    }
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate.values();
    } 
   }
*/




