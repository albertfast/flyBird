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
        List<Contact> conList = new List<Contact>();
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Account> telecomAccounts = new Set<Account>();
        //Iterate over the new accounts and create a contact & opp
        for (Account acc : newAccList) {
            //check if the industry is Telecommunications
            if (acc.Industry == 'Telecommunications') {
                telecomAccounts.add(acc);
            }
            //Create a Contact
            Contact con = new Contact();
            con.LastName = acc.Name;
            con.Phone = acc.Phone;
            con.AccountId = acc.Id;
            conList.add(con);
            //create a Opp
            Opportunity opp = new Opportunity();
            opp.Name = acc.Name;
            opp.StageName = STAGE_PROSOECT;
            opp.Type = TYPE_NEW_CUSTOMER;
            opp.Amount = acc.AnnualRevenue;
            opp.CloseDate = Date.today().addDays(7) ;
            opp.AccountId = acc.Id;
            oppList.add(opp);
        }

        // invoke queueable on telecom accounts
        if (!telecomAccounts.isEmpty()) {
            TelecomAccountsQueueable queueable = new TelecomAccountsQueueable(telecomAccounts);
            System.enqueueJob(queueable);
        }
        //insert contacts
        if (!conList.isEmpty()) {
            try {
                insert conlist;
            } catch (Exception ex) {
                //create a log
            }
        }
        //insert opportunitiy
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
}