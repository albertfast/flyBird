// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);


List<Account> accList = new List<Account>();
for(integer i=0; i<400; i++){
    Account acc = new Account();
    acc.Name = 'jack' + ' ' + i + ' ' + ' Slow';
    acc.Active__c = 'Yes';
    acc.BillingStreet = '615 32th ave'  ;
    acc.BillingCity = 'Ankara';
    acc.BillingState = 'OH';
    acc.BillingPostalCode = '23689';
    accList.add(acc);
}
try{
    insert accList;
system.debug(accList);
}catch(Exception ex){
    system.debug(ex.getMessage());
}

List<Account> accountsToDelete = [SELECT Id FROM Account WHERE Name LIKE '%Albert %'];
        
        if (!accountsToDelete.isEmpty()) {
            delete accountsToDelete;
            System.debug('Accounts Deleted: ' + accountsToDelete);
        } else {
            System.debug('No Account found with "Learn" in last name.');
        }


AddressBatch batchable = new AddressBatch();
Database.executeBatch(batchable, 50);