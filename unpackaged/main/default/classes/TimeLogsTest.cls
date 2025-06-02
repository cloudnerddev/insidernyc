@isTest
private class TimeLogsTest { 
        
    @isTest 
    static void testChildAndUpdates() {
        Test.StartTest();
        Case C = new Case();
        C.Subject = 'Child';
        C.AccountId = newAccount.Id;
        C.ContactId = newContact.Id;
        INSERT C;
        
        Time_Log__c TL2 = new Time_Log__c();
        TL2.Client__c = newAccount.Id;
        TL2.Contact__c = newContact.Id;
        TL2.Case__c = C.Id;
        TL2.Duration_Minutes__c = 5;
        TL2.Multiplier__c = '2';
        TL2.Date_Logged__c = Date.today();
        INSERT TL2;
        
        TL2.Duration_Minutes__c = 6;
        TL2.Case__c = C.Id;
        UPDATE TL2;      
        
        TimeLogRecalc_Schedule sh1 = new TimeLogRecalc_Schedule();
        String sch = '0 0 23 * * ?'; system.schedule('Test Schedule', sch, sh1);
        TimeLogRecalc_Batch batch = new TimeLogRecalc_Batch();
        ID batchprocessid = Database.executeBatch(batch,50);   
        Test.StopTest();
    }
    
    @isTest 
    static void testAccountContactReparent() {
        Test.StartTest();
        Account accClone = newAccount.clone(false, true, false, false);
        insert accClone;
        Contact conClone = newContact.clone(false, true, false, false);
        insert conClone;

        Case C = new Case();
        C.Subject = 'Child';
        C.AccountId = newAccount.Id;
        C.ContactId = newContact.Id;
        INSERT C;
        
        Time_Log__c TL2 = new Time_Log__c();
        TL2.Client__c = newAccount.Id;
        TL2.Contact__c = newContact.Id;
        TL2.Case__c = C.Id;
        TL2.Duration_Minutes__c = 5;
        TL2.Multiplier__c = '2';
        TL2.Date_Logged__c = Date.today().addDays(3);
        TL2.CreatedDate = Date.today();
        INSERT TL2;
        
        C.ParentId = newCase.Id;
        C.AccountId = accClone.Id;
        C.ContactId = conClone.Id;
        UPDATE C;
                
        Test.StopTest();
    }
    
    @isTest 
    static void testDeleteTimeLog() {
        Test.StartTest();
        DELETE newTimeLog;
        UNDELETE newTimeLog;
        Test.StopTest();
    }
    
    @isTest 
    static void testDeleteCase() {
        Test.StartTest();
        DELETE newCase;
        UNDELETE newCase;
        Test.StopTest();
    }
    
  	/***************************************************************************************************
                          Initialize Test Data
    **************************************************************************************************/    
    private static Insider_Team__c newInsiderTeam{
        get {
            if (newInsiderTeam == NULL ) {
                newInsiderTeam = new Insider_Team__c(
                    Name = 'Test Team'
                );
                insert newInsiderTeam;
            }
            return newInsiderTeam;
        }
        private set;
    }
    
    private static Account newAccount{
        get {
            if (newAccount == NULL ) {
                newAccount = new Account(
                   Name = 'Test',
                   Insider_Team__c = newInsiderTeam.Id,
                   Hours_per_Month__c = 1
                );
                insert newAccount;
            }
            return newAccount;
        }
        private set;
    }
    
    private static Contact newContact{
        get {
            if (newContact == NULL ) {
                newContact = new Contact(
                    AccountId = newAccount.Id,
                    FirstName = 'Test',
                    LastName = 'Test',
                    Time_Logged_MTD_Minutes__c = 1,
                    Billable_Time_Logged_MTD_minutes__c = 1,
                    Anniversary__c = Date.today(),
                    Birthdate = Date.today()
                );
                insert newContact;
            }
            return newContact;
        }
        private set;
    }
    
    private static Case newCase{
        get {
            if (newCase == NULL ) {
                newCase = new Case(
                    Subject = 'Case',
                    AccountId = newAccount.Id,
                    ContactId = newContact.Id
                );
                insert newCase;
            }
            return newCase;
        }
        private set;
    }
    
    private static Time_Log__c newTimeLog{
        get {
            if (newTimeLog == NULL ) {
                newTimeLog = new Time_Log__c(
                    Client__c = newAccount.Id,
                    Contact__c = newContact.Id,
                    Case__c = newCase.Id,
                    Duration_Minutes__c = 5,
                    Multiplier__c = '2',
                    Date_Logged__c = Date.today()
                );
                insert newTimeLog;
            }
            return newTimeLog;
        }
        private set;
    }
}