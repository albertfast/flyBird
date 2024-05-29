public with sharing class AccountTriggerHandler {
    //class level contants
    private static final String STAGE_PROSOECT = 'Prospecting';
    private static final String TYPE_NEW_CUSTOMER = 'New Customer';
    private static final String STATUS_CLOSED = 'Closed';

    //Delete all related Opportunities and check Do Not Contact checkbox on related 
    //contact when user chages Account Status from Open to closed.
    public static void deleteOppandContact(List<Account> newAccList, Map<Id,Account> oldAccMap) {
        Set<Id> accIds = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Contact> listToUpdateCon = new List<Contact>();
        if (!newAccList.isEmpty()) {
            for (Account newAcc : newAccList) {
                if (!oldAccMap.isEmpty()) {
                    Account oldAcc = oldAccMap.get(newAcc.Id);

                    if (newAcc.Account_Status__c == 'Closed' && oldAcc.Account_Status__c == 'Open') {
                        accIds.add(newAcc.Id);
                    }
                }
            }
        }

        if (!accIds.isEmpty()) {
            conList = [SELECT Id,Do_Not_Contact__c FROM Contact WHERE AccountId IN : accIds
                       AND Do_Not_Contact__c = false ];
            oppList = [SELECT Id,StageName FROM Opportunity WHERE AccountId IN : accIds
                       AND StageName != 'Closed Won' ];
            if (!conList.isEmpty()) {
                for (Contact con : conList) {
                    con.Do_Not_Contact__c = true;
                    listToUpdateCon.add(con);
                }
            }
            try {
                if (!listToUpdateCon.isEmpty()) {
                    update listToUpdateCon;
                }

                if (!oppList.isEmpty()) {
                    delete oppList;
                }
            } catch (Exception ex) {
                System.debug('Error while doing updatiob or deletion--> ' + ex.getMessage());
            }           
        }
    }

    public static void afterInsert(List<Account> newAccList) {
        Set<Id> accIds = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        List<Account> listToUpdate = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Account> telecomAccounts = new Set<Account>();
        //Iterate over the new accounts and create a contact & opp
        //Automatically create related Contact on insertion of account and update Client Contact lookup field.
        for (Account acc : newAccList) {
            //check if the industry is Telecommunications
            if (acc.Industry == 'Telecommunications') {
                telecomAccounts.add(acc);
            }
            //Create a Contact
            Contact con = new Contact();
            con.LastName = acc.Name;
            con.Phone = acc.Phone;
            con.Status__c = 'Active';
            con.AccountId = acc.Id;
            conList.add(con);
            accIds.add(acc.Id);
            //create a Opp
            Opportunity opp = new Opportunity();
            opp.Name = acc.Name;
            opp.StageName = STAGE_PROSOECT;
            opp.Type = TYPE_NEW_CUSTOMER;
            opp.Amount = acc.AnnualRevenue;
            opp.CloseDate = Date.today().addDays(7) ;
            opp.Amount = 1;
            opp.AccountId = acc.Id;
            oppList.add(opp);
        }
        if (!conList.isEmpty()) {
            try {
                insert conlist;
            } catch (Exception ex) {
                //create a log
            }
        }
        if (!oppList.isEmpty()) {
            try {
                insert oppList;
            } catch (Exception ex) {
                
            }
        }
    }

   //When customer priority is changed  update to related case priority same as account

   public static void afterUpdate(Map<Id,Account> newAccMap, Map<Id,Account> oldAccMap) {
    Set<Id> accids = new Set<Id>();

    //check if the account's customer priority is changed
    for (Id accId : newAccMap.keySet()) {
        Account oldAccount = oldAccMap.get(accId);
        Account newAccount = newAccMap.get(accId);
        if (newAccount.CustomerPriority__c != oldAccount.CustomerPriority__c) {
            accids.add(newAccount.Id);
        }
    }

    //make the open cases priority aligned
    List<Case> caseList = [SELECT Id, Priority, Account.CustomerPriority__c
                           FROM Case WHERE AccountId IN: accids
                           AND Status != :STATUS_CLOSED];
    for (Case cs : caseList) {
        cs.Priority = cs.Account.CustomerPriority__c;
    }
    if (!caseList.isEmpty()) {
        try {
            update caseList;
        } catch (Exception ex) {
            //create a log
            System.debug(ex.getMessage());
        }
    }                       
   }

   //Automatically close Opportunities with Probability Greater than 70% when checkbox is checked on Account
   public static void deleteOppProbability(List<Account> accList, Map<Id,Account> oldMap) {
    
    Set<Id> accIds = new Set<Id>();
    if (!accList.isEmpty()) {
        for (Account acc : accList) {
            if (acc.Close_all_Opps__c == true && oldMap.containsKey(acc.Id) && oldMap.get(acc.Id).Close_all_Opps__c == false) {
                accIds.add(acc.Id);
            }
        }
    }
    if (!accIds.isEmpty()) {
        List<Opportunity> oppList = [SELECT Id, AccountId, StageName FROM Opportunity 
                                     WHERE AccountId IN : accIds and StageName != 'Closed Won' AND Probability >= 70];
        List<Opportunity> listToUpdate = new List<Opportunity>();                           
        if (!oppList.isEmpty()) {
            for (Opportunity opp : oppList) {
                opp.StageName = 'Closed Won';
                opp.CloseDate = Date.today();
                listToUpdate.add(opp);
            }
        }   
        if (!listToUpdate.isEmpty()) {
            update listToUpdate;
        }                          
    }
    
   }

/*Want to write a trigger, that fires when an Account's "Status__c" field is updated from "Active" to "Inactive"
    [Account.Status__c : "Active", "Inactive"]
        Can assume picklist, and restricted to these values
When this happens, we want to query all of the Contacts for the Account, and update them from "Active" to "Inactive"
    [Contact.Status__c : "Active", "Inactive"]
        Can assume picklist, and restricted to these values
Also we must make sure that the Account:
    -- has no OPEN opportunities before we do this
        OPEN means a that the Opportunity Stage is _not_ "Closed Won" or "Closed Lost"
    -- and that the Account is of Record Type "Customer"*/

    public static void accStatusChanged(Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        Set<Id> accToUpdateCon = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
    
        // Retrieve Business Record Type Id from custom setting
        Id businessRecordTypeId = BusinessRecordType__c.getInstance().RecordTypeId__c;
    
        // Retrieve Customer Record Type Id from custom setting
        Id customerRecordTypeId = CustomerRecordType__c.getInstance().RecordTypeId__c;
    
        for (Account updateAccount : newMap.values()) {
            System.debug('Account being processed: ' + updateAccount);
    
            // Ensure we are checking for Status change from Active to Inactive
            if (updateAccount.Status__c == 'Inactive' && oldMap.get(updateAccount.Id).Status__c == 'Active') {
                System.debug('Account status changed from Active to Inactive: ' + updateAccount.Id);
                if (!hasOpp(updateAccount.Id)) {
                    System.debug('No open opportunities for Account: ' + updateAccount.Id);
                    // Check if Account Record Type is 'Business'
                    if (updateAccount.RecordTypeId == businessRecordTypeId) {
                        System.debug('Account is of Business Record Type: ' + updateAccount.Id);
                        // Change the record type to 'Customer'
                        Account updatedAccount = new Account(
                            Id = updateAccount.Id,
                            RecordTypeId = customerRecordTypeId
                        );
                        accountsToUpdate.add(updatedAccount);
                        accToUpdateCon.add(updateAccount.Id);
                    }
                }
            }
        }
    
        if (!accToUpdateCon.isEmpty()) {
            System.debug('Accounts to update contacts: ' + accToUpdateCon);
            List<Contact> contactsToUpdate = [SELECT Id, Status__c, LastName FROM Contact WHERE AccountId IN :accToUpdateCon];
    
            for (Contact con : contactsToUpdate) {
                con.Status__c = 'Inactive';
                System.debug('Contact to be updated: ' + con);
                System.debug('Contact Last Name: ' + con.LastName);
            }
    
            update contactsToUpdate;
        }
    
        if (!accountsToUpdate.isEmpty()) {
            System.debug('Accounts to update record type: ' + accountsToUpdate);
            update accountsToUpdate;
        }
    }
    
    public static Boolean hasOpp(Id accountId) {
        List<Opportunity> openOpp = [SELECT Id FROM Opportunity 
                                     WHERE AccountId = :accountId AND StageName NOT IN ('Closed Won', 'Closed Lost')];
        System.debug('Open opportunities for Account: ' + accountId + ' are ' + openOpp);
        return !openOpp.isEmpty();
    }
    


}

//Automatically create related Contact on insertion of account and update Client Contact lookup field.



