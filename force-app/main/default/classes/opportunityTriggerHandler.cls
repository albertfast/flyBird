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

                Integer coldThreshold = 500000;
                Integer warmThereshold = 1000000;

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

/* Update the Parent Account field with the Opportunity Name that has the Highest Amount */
public static void accountUpdateFromOppAmount(List<Opportunity> oppList, Map<Id,Opportunity> oldMap){
    Set<Id> parentIds = new Set<Id>(); // to store  parent Ids
    //This part work on when opportunity account will be change
    if (!oppList.isEmpty()) {
        for (Opportunity newOpp : oppList) {
            if(oldMap != null){
                Opportunity oldOpp = oldMap.get(newOpp.Id);
                if(oldOpp.AccountId != newOpp.AccountId){
                    parentIds.add(oldOpp.AccountId); 
                    parentIds.add(newOpp.AccountId);
                }
                else {
                    parentIds.add(newOpp.AccountId);
                }
            }
            else{
                parentIds.add(newOpp.AccountId);
            }
        }
    }
    if (!parentIds.isEmpty()) {
        List<Account> accList = [SELECT maxOpp__c,
                                (SELECT Name,Amount FROM Opportunities 
                                 WHERE Amount != null order by Amount desc limit 1) 
                                 FROM Account WHERE Id IN :parentIds];
        List<Account> listToUpdate = new List<Account>();                         
        if (!accList.isEmpty()) {
            for (Account acc : accList) {
                if (!acc.Opportunities.isEmpty()) {
                    acc.maxOpp__c = acc.Opportunities[0].Name;
                    listToUpdate.add(acc);
                }
                else {
                    acc.maxOpp__c = '';
                    listToUpdate.add(acc);
                }
            }
        }  
        
        if (!listToUpdate.isEmpty()) {
            update  listToUpdate;
        }
    }
  }
}






/*

    private static Boolean isExecuting = false;
    public static void handleOpportunityChanges(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunityMap) {
      if (!isExecuting) {
        isExecuting = true;
      Set<Id> accountIds = new Set<Id>();
      for (Opportunity opp : newOpportunities) {
          accountIds.add(opp.AccountId);
      }
  
      List<AggregateResult> countResults = [
          SELECT AccountId, COUNT(Id) opptCount
          FROM Opportunity 
          WHERE AccountId IN :accountIds
          GROUP BY AccountId
      ];
  
      List<AggregateResult> amountResults = [
          SELECT AccountId, SUM(Amount) oppAmount 
          FROM Opportunity 
          WHERE AccountId IN :accountIds
          AND StageName != 'Closed Won'
          GROUP BY AccountId
      ];
  
      List<Account> accountsToUpdate = new List<Account>();
      for (AggregateResult countResult : countResults) {
          Id accountId = (Id) countResult.get('AccountId');
          Integer count = (Integer) countResult.get('opptCount');
  
          Decimal amountSum = 0;
          for (AggregateResult amountResult : amountResults) {
              if ((Id) amountResult.get('AccountId') == accountId) {
                  amountSum = (Decimal) amountResult.get('oppAmount');
                  break;
              }
          }
  
          accountsToUpdate.add(new Account(
              Id = accountId,
              Total_Opportunity_Count__c = count,
              Total_Opportunity_Amount__c = amountSum
          ));
      }
  
      if (!accountsToUpdate.isEmpty()) {
          update accountsToUpdate;
      }
  
      isExecuting = false;
          }
  }
  
  public static void handleAccountChange(Set<Id> affectedAccountIds) {
      List<Account> accountsToUpdate = new List<Account>();
      for (Id accountId : affectedAccountIds) {
          Integer totalCount = [SELECT COUNT() FROM Opportunity WHERE AccountId = :accountId];
          Decimal totalAmount = (Decimal) [
              SELECT SUM(Amount)
              FROM Opportunity 
              WHERE AccountId = :accountId AND StageName != 'Closed Won'
          ][0].get('expr0');
  
          accountsToUpdate.add(new Account(
              Id = accountId,
              Total_Opportunity_Count__c = totalCount,
              Total_Opportunity_Amount__c = totalAmount
          ));
      }
  
      if (!accountsToUpdate.isEmpty()) {
          update accountsToUpdate;
      }
  }
    
*/




