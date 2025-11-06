@isTest
private class UpdateMonthlyBillingTotalsBatchTest {
    
    @testSetup
    static void setup() {
        // Create test Account
        Account acc = new Account(
            Name = 'Practice Angus Kaplan Account'
        );
        // Try to get Client Account RecordType if it exists
        List<RecordType> clientRTs = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' 
                                     AND DeveloperName = 'Client_Account' LIMIT 1];
        if (!clientRTs.isEmpty()) {
            acc.RecordTypeId = clientRTs[0].Id;
        }
        // Set Account_Status__c if the field exists
        if (Schema.sObjectType.Account.fields.getMap().containsKey('Account_Status__c')) {
            acc.Account_Status__c = 'Client';
        }
        insert acc;
        
        // Create Vendor Account (required for Case Vendor__c field)
        Account vendorAcc = new Account(
            Name = 'Test Vendor Restaurant'
        );
        // Get Vendor_Account RecordType
        List<RecordType> vendorRTs = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' 
                                     AND DeveloperName = 'Vendor_Account' LIMIT 1];
        if (!vendorRTs.isEmpty()) {
            vendorAcc.RecordTypeId = vendorRTs[0].Id;
        }
        insert vendorAcc;
        
        // Create Contact (required MasterDetail for Time_Log__c)
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id
        );
        insert con;
        
        // Get DiningReservation RecordType for Case
        Id diningReservationRTId;
        try {
            diningReservationRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                .get('DiningReservation').getRecordTypeId();
        } catch (Exception e) {
            // If RecordType doesn't exist, use default
            System.debug('DiningReservation RecordType not found: ' + e.getMessage());
        }
        
        // Create Case (required lookup for Time_Log__c) with DiningReservation record type
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = acc.Id,
            ContactId = con.Id,
            Status = 'New',  // Required: Logbook Status
            Requested_By_Someone_Else__c = con.Id,  // Required: Requested by (lookup to Contact)
            Person_Using__c = con.Id,  // Required: Person Using (lookup to Contact)
            Origin = 'Email',  // Required: Logbook Origin
            Number_in_Party__c = 2,  // Required for DiningReservation
            Date__c = Date.today(),  // Required for Reservation Details
            Vendor__c = vendorAcc.Id,  // Required: Vendor Account
            Cancellation_Policy__c = 'Test cancellation policy text'  // Required: Text field
        );
        
        // Set RecordType FIRST before setting restricted picklist fields
        if (diningReservationRTId != null) {
            testCase.RecordTypeId = diningReservationRTId;
        }
        
        // Note: Reason__c is not required when Status = 'New'
        
        insert testCase;
        
        // Get current month dates
        Date today = Date.today();
        Date firstDay = Date.newInstance(today.year(), today.month(), 1);
        Date lastDay = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));
        
        // Create current month billing record
        Monthly_Billing__c currentMonthBilling = new Monthly_Billing__c(
            Client_Account__c = acc.Id,
            Start_Date__c = firstDay,
            Last_Day_of_Month__c = lastDay,
            Billable_Time_Logged_MTD_hours__c = 0
        );
        insert currentMonthBilling;
        
        // Create previous month billing record (should NOT be updated)
        Date prevMonthFirst = firstDay.addMonths(-1);
        Date prevMonthLast = Date.newInstance(prevMonthFirst.year(), prevMonthFirst.month(), 
                                             Date.daysInMonth(prevMonthFirst.year(), prevMonthFirst.month()));
        Monthly_Billing__c prevMonthBilling = new Monthly_Billing__c(
            Client_Account__c = acc.Id,
            Start_Date__c = prevMonthFirst,
            Last_Day_of_Month__c = prevMonthLast,
            Billable_Time_Logged_MTD_hours__c = 5
        );
        insert prevMonthBilling;
        
        // Create time logs for current month
        // Billable_Time__c is a formula field (Multiplier__c * Duration_Minutes__c)
        // so we set the source fields instead
        List<Time_Log__c> timeLogs = new List<Time_Log__c>();
        for(Integer i = 0; i < 3; i++) {
            timeLogs.add(new Time_Log__c(
                Client__c = acc.Id,
                Contact__c = con.Id,
                Case__c = testCase.Id,
                Date_Logged__c = today,
                Multiplier__c = '1', // Multiplier of 1
                Duration_Minutes__c = 120 // 120 minutes = 2 hours (when Multiplier = 1)
            ));
        }
        insert timeLogs;
    }
    
    @isTest
    static void testBatchUpdatesCurrentMonthOnly() {
        Test.startTest();
        UpdateMonthlyBillingTotalsBatch batch = new UpdateMonthlyBillingTotalsBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        Date today = Date.today();
        Date firstDay = Date.newInstance(today.year(), today.month(), 1);
        Date lastDay = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));
        
        // Check current month billing was updated (3 logs × 2 hours = 6 hours)
        Monthly_Billing__c currentMonth = [
            SELECT Id, Billable_Time_Logged_MTD_hours__c 
            FROM Monthly_Billing__c 
            WHERE Start_Date__c = :firstDay 
            AND Last_Day_of_Month__c = :lastDay
            LIMIT 1
        ];
        System.assertEquals(6.00, currentMonth.Billable_Time_Logged_MTD_hours__c, 
                          'Current month should have 6 hours');
        
        // Check previous month billing was NOT changed
        Date prevMonthFirst = firstDay.addMonths(-1);
        Date prevMonthLast = Date.newInstance(prevMonthFirst.year(), prevMonthFirst.month(), 
                                             Date.daysInMonth(prevMonthFirst.year(), prevMonthFirst.month()));
        Monthly_Billing__c prevMonth = [
            SELECT Id, Billable_Time_Logged_MTD_hours__c 
            FROM Monthly_Billing__c 
            WHERE Start_Date__c = :prevMonthFirst
            AND Last_Day_of_Month__c = :prevMonthLast
            LIMIT 1
        ];
        System.assertEquals(5.00, prevMonth.Billable_Time_Logged_MTD_hours__c, 
                          'Previous month should still have 5 hours (unchanged)');
    }
    
    @isTest
    static void testSchedulable() {
        Test.startTest();
        UpdateMonthlyBillingTotalsBatch batch = new UpdateMonthlyBillingTotalsBatch();
        String cronExp = '0 0 2 * * ?'; // Every night at 2 AM
        System.schedule('Test Update Monthly Billing', cronExp, batch);
        Test.stopTest();
        
        // Verify job was scheduled
        List<CronTrigger> scheduledJobs = [
            SELECT Id, CronExpression, State 
            FROM CronTrigger 
            WHERE CronJobDetail.Name = 'Test Update Monthly Billing'
        ];
        System.assertEquals(1, scheduledJobs.size(), 'Job should be scheduled');
    }
    
    @isTest
    static void testBatchWithNoTimeLogs() {
        // Delete all time logs
        delete [SELECT Id FROM Time_Log__c];
        
        Test.startTest();
        UpdateMonthlyBillingTotalsBatch batch = new UpdateMonthlyBillingTotalsBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        Date today = Date.today();
        Date firstDay = Date.newInstance(today.year(), today.month(), 1);
        Date lastDay = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));
        
        // Check current month billing was updated to 0
        Monthly_Billing__c currentMonth = [
            SELECT Id, Billable_Time_Logged_MTD_hours__c 
            FROM Monthly_Billing__c 
            WHERE Start_Date__c = :firstDay 
            AND Last_Day_of_Month__c = :lastDay
            LIMIT 1
        ];
        System.assertEquals(0.00, currentMonth.Billable_Time_Logged_MTD_hours__c, 
                          'Current month should have 0 hours when no time logs');
    }
}