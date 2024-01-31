@isTest
public class ContactTriggerHandlerTest {

    @testSetup
    static void testSetup() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test contact without setting Is_Primary__c to true
        Contact testContact1 = new Contact(FirstName = 'Test', LastName = 'Contact1', AccountId = testAccount.Id);
        insert testContact1;

        // Create a test contact with Is_Primary__c set to true
        Contact testContact2 = new Contact(FirstName = 'Test', LastName = 'Contact2', AccountId = testAccount.Id, Is_Primary__c = true);
        insert testContact2;
    }

    @isTest
    static void testUpdateAccountCountPrimary() {
        // Retrieve the test account
        Account testAccount = [SELECT Id, CountOfPrimaryContacts__c FROM Account LIMIT 1];

        // Verify that CountOfPrimaryContacts__c is initially 1 (due to the testContact2 creation)
        System.assertEquals(1, testAccount.CountOfPrimaryContacts__c, 'Initial CountOfPrimaryContacts__c should be 1');

        // Create a new contact and set Is_Primary__c to true
        Contact newContact = new Contact(FirstName = 'New', LastName = 'Contact', AccountId = testAccount.Id, Is_Primary__c = true);
        insert newContact;

        // Retrieve the updated account
        testAccount = [SELECT Id, CountOfPrimaryContacts__c FROM Account WHERE Id = :testAccount.Id LIMIT 1];

        // Verify that CountOfPrimaryContacts__c is incremented to 2
        System.assertEquals(2, testAccount.CountOfPrimaryContacts__c, 'CountOfPrimaryContacts__c should be incremented to 2');
    }

    @isTest
    static void testDeleteContactAndUpdateAccountCountPrimary() {
        // Retrieve the test account
        Account testAccount = [SELECT Id, CountOfPrimaryContacts__c FROM Account LIMIT 1];

        // Verify that CountOfPrimaryContacts__c is initially 2 (due to the testContact2 and newContact creation)
        System.assertEquals(2, testAccount.CountOfPrimaryContacts__c, 'Initial CountOfPrimaryContacts__c should be 2');

        // Retrieve the newContact record
        Contact newContact = [SELECT Id FROM Contact WHERE Is_Primary__c = true LIMIT 1];

        // Delete the newContact record
        delete newContact;

        // Retrieve the updated account
        testAccount = [SELECT Id, CountOfPrimaryContacts__c FROM Account WHERE Id = :testAccount.Id LIMIT 1];

        // Verify that CountOfPrimaryContacts__c is decremented to 1 after contact deletion
        System.assertEquals(1, testAccount.CountOfPrimaryContacts__c, 'CountOfPrimaryContacts__c should be decremented to 1');
    }
}
