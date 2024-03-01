//                                 --->Question<---
//Write a batch apex to populate Account Billing Address on related Contact’s Mailing Address.
public with sharing class AddressBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Integer recordProcessed = 0;

   public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, ' 
                     + '(SELECT Id, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode FROM Contacts) '
                     + 'FROM Account';
        return Database.getQueryLocator(query);          
   }
   public void execute(Database.BatchableContext bc, List<Account> scope){
    List<Contact> contacts = new List<Contact>();
    //iterate over accounts and list of child contacts
    for (Account acc : scope) {
        for (Contact con : acc.Contacts) {
            con.MailingStreet = acc.BillingStreet;
            con.MailingCity = acc.BillingCity;
            con.MailingState = acc.BillingState;
            con.MailingCountry= acc.BillingCountry;
            con.MailingPostalCode = acc.BillingPostalCode;
            contacts.add(con);
            recordProcessed++;
        }
    }

    //update contacts
    try {
        update contacts;
    } catch (Exception ex) {
        //create log
        System.debug(ex.getMessage());
    }
   }

   public void finish(Database.BatchableContext bc){
        //get the batch job id
         Id jobId = bc.getJobId();
        //send email
        List<Messaging.SingleEmailMessage> msgs = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>{'ahmethasimsahiner@icloud.com'};
        msg.setToAddresses(toAddresses);
        msg.setSubject('Address Batch Complete');
        msg.setPlainTextBody('Address Batch Apex has been completed. The records processed are: ' + recordProcessed);
        msgs.add(msg);
        Messaging.sendEmail(msgs);

   }
}