//collect account ids and then call future method
List<Id> accountIds = new List<Id>();
for (Account acc : [SELECT Id FROM Account]) {
    accountIds.add(acc.Id);
}
AccountProcessor.processAccounts(accountIds);