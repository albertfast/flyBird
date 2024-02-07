public with sharing class TelecomAccountsQueueable implements Queueable{
    private Set<Account> telecomAccounts = new Set<Account>();

    public TelecomAccountsQueueable(Set<Account> accounts){
        this.telecomAccounts = accounts;
    }

    public void execute(System.QueueableContext cxt){
        List<Contact> conList = new List<Contact>();

        //Iterate over the new accounts and create a contact
        for (Account acc : telecomAccounts) {
            //Create a Contact
            Contact con = new Contact();
            con.LastName = acc.Name;
            con.Phone = acc.Phone;
            con.Email= 'Queueabletest@Queueable.com';
            con.AccountId = acc.Id;
            conList.add(con);
        }

        if (!conList.isEmpty()) {
            try {
                insert conlist;
            } catch (Exception ex) {
                //create a log
                System.debug(ex.getMessage());
            }
        }
    }
}