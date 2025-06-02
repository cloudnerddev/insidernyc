global class TimeLogRecalc_Batch implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext Bc){
        return Database.getQueryLocator([SELECT Id, AccountId, (SELECT Id, Duration_Minutes__c, Billable_Time__c, ThisMonth__c FROM Time_Logs__r WHERE ThisMonth__c = TRUE) 
                                         FROM Contact 
                                         WHERE Time_Logged_MTD_Minutes__c != null OR Billable_Time_Logged_MTD_minutes__c != null
                                         ORDER BY AccountId]);
    }

    global void execute(Database.BatchableContext Bc, List<Contact> scope){
        Savepoint sp = Database.setSavepoint();
        Set<Id> accountIds = new Set<Id>();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Account> accountsToUpdate = new List<Account>();
        
        try {
            for (Contact con :scope) {
                accountIds.add(con.AccountId);
                con.Time_Logged_MTD_Minutes__c = 0;
                con.Billable_Time_Logged_MTD_minutes__c = 0;
                Contact a = (Contact)con; //Grab the Account sObject - needed to avoid query locator error
                
                Time_Log__c[] tlList = a.getSObjects('Time_Logs__r'); //grab all the related Time_Log__c records
                if (tlList != null) { //if there are related Custom_Object_One__c record
                    for (Time_Log__c tl : tlList) {
                        if (tl.Duration_Minutes__c != null) {
                            con.Time_Logged_MTD_Minutes__c += tl.Duration_Minutes__c;
                        }
                        if (tl.Billable_Time__c != null) {
                            con.Billable_Time_Logged_MTD_minutes__c += tl.Billable_Time__c;
                        }
                    }
                }
                
                
                contactsToUpdate.add(con);
            }
            
            for (Id acctId :accountIds) {
                Account acct = new Account(
                    Id = acctId,
                    Time_Logged_MTD__c = 0,
                    Billable_Time_Logged_MTD_minutes__c = 0
                );
                for (Contact con :contactsToUpdate) {
                    if (acct.Id == con.AccountId) {
                        acct.Time_Logged_MTD__c += con.Time_Logged_MTD_Minutes__c;
                        acct.Billable_Time_Logged_MTD_minutes__c += con.Billable_Time_Logged_MTD_minutes__c;
                    }
                }
                accountsToUpdate.add(acct);
            }
            
            update contactsToUpdate;
            update accountsToUpdate;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            Database.rollback(sp);
        }
    }
    
    global void finish(Database.BatchableContext Bc){

    }
}