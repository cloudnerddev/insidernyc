public class Util {
    public static void recalcContacts(Set<Id> contactIds){
        List<Contact> conList = [SELECT Id, Time_Logged_MTD_Minutes__c, Billable_Time_Logged_MTD_minutes__c, (SELECT Id, Contact__c, Duration_Minutes__c, Billable_Time__c FROM Time_Logs__r WHERE ThisMonth__c = TRUE) FROM Contact WHERE Id IN :contactIds];
              
        for (Contact con : conList) {
            con.Time_Logged_MTD_Minutes__c = 0;
            con.Billable_Time_Logged_MTD_minutes__c = 0;
            for (Time_Log__c tl : con.Time_Logs__r) {
                if (tl.Duration_Minutes__c != NULL) {
                    con.Time_Logged_MTD_Minutes__c += tl.Duration_Minutes__c;
                }
                if (tl.Billable_Time__c != NULL) {
                    con.Billable_Time_Logged_MTD_minutes__c += tl.Billable_Time__c;
                }
            }
        }
        
        update conList;
    }
    
    public static void recalcAccounts(Set<Id> accountIds){
        List<Account> accList = [SELECT Id, Time_Logged_MTD__c, Billable_Time_Logged_MTD_minutes__c, (SELECT Id, Client__c, Duration_Minutes__c, Billable_Time__c FROM Time_Logs__r WHERE ThisMonth__c = TRUE) FROM Account WHERE Id IN :accountIds];
              
        for (Account acc : accList) {
            acc.Time_Logged_MTD__c = 0;
            acc.Billable_Time_Logged_MTD_minutes__c = 0;
            for (Time_Log__c tl : acc.Time_Logs__r) {
                if (tl.Duration_Minutes__c != NULL) {
                    acc.Time_Logged_MTD__c += tl.Duration_Minutes__c;
                }
                if (tl.Billable_Time__c != NULL) {
                    acc.Billable_Time_Logged_MTD_minutes__c += tl.Billable_Time__c;
                }
            }
        }
        
        update accList;
    }

}