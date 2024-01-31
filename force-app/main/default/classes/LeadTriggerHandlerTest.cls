@isTest
public class LeadTriggerHandlerTest {
    @testSetup
    static void testSetup() {
        // Create a System Admin user
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' WITH USER_MODE LIMIT 1];
        User runningUser = new User(
            Alias = 'runuser',
            Email = 'abc@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'runninguser' + DateTime.now().getTime() + '@abc.com', // Use a valid email format
            ProfileId = sysAdminProfile.Id
        );
    
        insert runningUser;
    
        System.runAs(runningUser) {
            // Create Lead records
            List<Lead> testLeads = new List<Lead>();
            for (Integer i = 0; i < 2; i++) {
                Lead testLead = new Lead(
                    FirstName = 'Test' + i,
                    LastName = 'Lead',
                    Company = 'Test Company',
                    Email = 'abc@test.com',
                    Status = 'Open'
                );
                testLeads.add(testLead);
            }
            insert testLeads;
    
            // Create related Contact, Account, and Opportunity records
            
    
            Account testAccount = new Account(
                Name = 'TestAccount'
                // Add other required fields
            );
            insert testAccount;

            Contact testContact = new Contact(
                FirstName = 'TestContact',
                LastName = 'Contact',
                Email = 'abc@test.com',
                AccountId = testAccount.Id 
                // Add other required fields
            );
            insert testContact;
    
            Opportunity testOpportunity = new Opportunity(
                Name = 'TestOpportunity',
                AccountId = testAccount.Id,
                CloseDate = Date.today() + 7,
                StageName = 'Prospecting'
                // Add other required fields
            );
            insert testOpportunity;
    
            // Simulate conversion
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(testLeads[0].Id);
            lc.setConvertedStatus('Closed - Converted');
            lc.setContactId(testContact.Id);
            lc.setAccountId(testAccount.Id); // Add this line to set the AccountId
            lc.setOpportunityId(testOpportunity.Id);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
        }
    }
    

    @isTest
    static void convertLeadTest() {
        User runAsUser = [SELECT Id, Email FROM User WHERE Email = 'abc@test.com' WITH USER_MODE LIMIT 1];
        System.runAs(runAsUser) {
            List<Lead> testLeads = [SELECT Id, FirstName, LastName, Email, Status FROM Lead WHERE LastName = 'Lead' WITH USER_MODE];
            System.debug('Before lead update: ' + testLeads);

            // Change lead status to trigger conversion
            testLeads[0].Status = 'Closed - Converted';
            Test.startTest();
            update testLeads;
            Test.stopTest();

            System.debug('After lead update: ' + testLeads);

            // Declare the convertedLead variable outside of the try-catch block
            Lead convertedLead;

            try {
                convertedLead = [SELECT Id, Email, Status, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId FROM Lead WHERE Id = :testLeads[0].Id WITH USER_MODE];
                System.debug('Converted Lead: ' + convertedLead);
            } catch (Exception e) {
                System.debug('An error occurred: ' + e.getMessage());
            }

            // Add additional debug statements in your trigger logic
            List<Task> followUpTasks = [SELECT Id FROM Task WHERE WhoId = :convertedLead.ConvertedContactId AND WhatId = :convertedLead.ConvertedOpportunityId WITH USER_MODE];
            System.debug('Follow-up Tasks: ' + followUpTasks);

            System.assertEquals(1, followUpTasks.size(), 'Expected 1 follow-up task to be created for the converted lead.');
        }
    }
}
