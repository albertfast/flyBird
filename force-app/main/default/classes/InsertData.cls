@RestResource(urlMapping='/contactCreated/*')
global class InsertData {

    @httpget
    global static List<Contact> getContactData(){
        RestRequest req = RestContext.request;
        Map<String,String> mapOfData = req.params;
        String myRecId = mapOfData.get('sfId');
        String email = mapOfData.get('email');
        System.debug('Check passed Email' + email);

        List<Contact> conList = [SELECT Id, Name from Contact WHERE Id =: myRecId AND Email =: email];

        return conList;
    }
/*
    // Create 10 Data from External System to Salesforce | integration in salesforce
    @httpPost
    global static void insertCon(String name, String email){
        List<Contact> contactList = new List<Contact>();
        for (Integer i=0; i<10; i++) {
            Contact con = new Contact();
            con.LastName = name + ' ' + i;
            con.Email = email;
            contactList.add(con);
        }
        insert contactList;
        System.debug('Contact Created '+ contactList);
    } */

   /* @httpDelete
    global static void deleteContactsContainingLoop() {
        List<Contact> contactsToDelete = [SELECT Id FROM Contact WHERE LastName LIKE '%Look%'];
        
        if (!contactsToDelete.isEmpty()) {
            delete contactsToDelete;
            System.debug('Contacts Deleted: ' + contactsToDelete);
        } else {
            System.debug('No contacts found with "loop" in last name.');
        }
    } */

    /*
    List<Account> accList = new List<Account>();
for(integer i=1; i<11; i++){
    Account acc = new Account();
    acc.Name = 'Execute Acc ' + ' ' + i;
    acc.Active__c = 'Yes';
    accList.add(acc);
}
try{
    insert accList;
system.debug(accList);
}catch(Exception ex){
    system.debug(ex);
}
    */

    @httpDelete
    global static void deleteAccountssContainingLoop() {
        List<Account> accountsToDelete = [SELECT Id FROM Account WHERE Name LIKE '%Dummy %'];
        
        if (!accountsToDelete.isEmpty()) {
            delete accountsToDelete;
            System.debug('Accounts Deleted: ' + accountsToDelete);
        } else {
            System.debug('No Account found with "loop" in last name.');
        }
    }

  

    @httpPost
global static void updateAccActive(Boolean active){
    List<Account> accList = [SELECT Id, Name, Active__c FROM Account WHERE Name LIKE '%Execute%'];

    for (Account acc : accList) {
        acc.Active__c = active ? 'Yes' : 'No';
    }

    update accList;
    System.debug('Accounts Updated: ' + accList);
}

}
