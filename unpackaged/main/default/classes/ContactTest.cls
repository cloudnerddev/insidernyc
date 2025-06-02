@isTest
public class ContactTest {
    
    @isTest 
    static void testChildAndUpdates() {
        Insider_Team__c newInsiderTeam = new Insider_Team__c(
            Name = 'Test Team'
        );
        insert newInsiderTeam;
        
        Account newAccount = new Account(
            Name = 'Test',
            Insider_Team__c = newInsiderTeam.Id,
            Hours_per_Month__c = 1
        );
        insert newAccount;
        
        Contact newContact = new Contact(
            AccountId = newAccount.Id,
            FirstName = 'Test',
            LastName = 'Test',
            Time_Logged_MTD_Minutes__c = 1,
            Billable_Time_Logged_MTD_minutes__c = 1,
            Anniversary__c = Date.today(),
            Birthdate__c = Date.today()
        );
        insert newContact;
        
        newContact.Anniversary__c = Date.today().addDays(1);
        newContact.Birthdate__c = Date.today().addDays(1);
        update newContact;
        newContact.Anniversary__c = NULL;
        newContact.Birthdate__c = NULL;
        update newContact;
    }
}