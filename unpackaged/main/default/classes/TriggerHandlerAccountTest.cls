@isTest
private class TriggerHandlerAccountTest {
    
    @testSetup
    static void setup() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        
        // Account with Zagat Review
        Account acct1 = new Account(
            Name = 'Test Restaurant 1',
            Zagat_Review__c = 'Amazing food and service\nThe ambiance is wonderful\nHighly recommended'
        );
        testAccounts.add(acct1);
        
        // Account without Zagat Review
        Account acct2 = new Account(
            Name = 'Test Restaurant 2'
        );
        testAccounts.add(acct2);
        
        insert testAccounts;
    }
    
    @isTest
    static void testBeforeInsert_WithZagatReview() {
        // Test that a new account with Zagat Review properly splits the content
        Account newAcct = new Account(
            Name = 'New Restaurant',
            Zagat_Review__c = 'First line of review\nSecond line\nThird line'
        );
        
        Test.startTest();
        insert newAcct;
        Test.stopTest();
        
        // Query the inserted account
        Account insertedAcct = [
            SELECT Id, Review_Description_First_Line__c, Review_Description_After_First_Line__c
            FROM Account
            WHERE Id = :newAcct.Id
        ];
        
        // Verify the review was split correctly
        System.assertEquals('First line of review', insertedAcct.Review_Description_First_Line__c, 
            'First line should be extracted');
        System.assert(insertedAcct.Review_Description_After_First_Line__c.contains('Second line'), 
            'Remaining content should contain second line');
        System.assert(insertedAcct.Review_Description_After_First_Line__c.contains('Third line'), 
            'Remaining content should contain third line');
    }
    
    @isTest
    static void testBeforeInsert_WithoutZagatReview() {
        // Test that a new account without Zagat Review sets fields to null
        Account newAcct = new Account(
            Name = 'New Restaurant No Review'
        );
        
        Test.startTest();
        insert newAcct;
        Test.stopTest();
        
        // Query the inserted account
        Account insertedAcct = [
            SELECT Id, Review_Description_First_Line__c, Review_Description_After_First_Line__c
            FROM Account
            WHERE Id = :newAcct.Id
        ];
        
        // Verify the review fields are null
        System.assertEquals(null, insertedAcct.Review_Description_First_Line__c, 
            'First line should be null');
        System.assertEquals(null, insertedAcct.Review_Description_After_First_Line__c, 
            'After first line should be null');
    }
    
    @isTest
    static void testBeforeUpdate_ZagatReviewChange() {
        // Get an existing account
        Account acct = [SELECT Id, Zagat_Review__c FROM Account WHERE Name = 'Test Restaurant 2' LIMIT 1];
        
        // Update with a new Zagat Review
        acct.Zagat_Review__c = 'Updated review first line\nUpdated second line';
        
        Test.startTest();
        update acct;
        Test.stopTest();
        
        // Query the updated account
        Account updatedAcct = [
            SELECT Id, Review_Description_First_Line__c, Review_Description_After_First_Line__c
            FROM Account
            WHERE Id = :acct.Id
        ];
        
        // Verify the review was split correctly
        System.assertEquals('Updated review first line', updatedAcct.Review_Description_First_Line__c, 
            'First line should be updated');
        System.assert(updatedAcct.Review_Description_After_First_Line__c.contains('Updated second line'), 
            'Remaining content should be updated');
    }
    
    @isTest
    static void testBeforeUpdate_RemoveZagatReview() {
        // Get an existing account with a review
        Account acct = [SELECT Id, Zagat_Review__c FROM Account WHERE Name = 'Test Restaurant 1' LIMIT 1];
        
        // Remove the Zagat Review
        acct.Zagat_Review__c = null;
        
        Test.startTest();
        update acct;
        Test.stopTest();
        
        // Query the updated account
        Account updatedAcct = [
            SELECT Id, Review_Description_First_Line__c, Review_Description_After_First_Line__c
            FROM Account
            WHERE Id = :acct.Id
        ];
        
        // Verify the review fields are now null
        System.assertEquals(null, updatedAcct.Review_Description_First_Line__c, 
            'First line should be null after removal');
        System.assertEquals(null, updatedAcct.Review_Description_After_First_Line__c, 
            'After first line should be null after removal');
    }
    
    @isTest
    static void testAfterUpdate_SyncOverhoursFieldsToMonthlyBilling() {
        // Get an existing account
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Restaurant 1' LIMIT 1];
        
        // Create a Monthly Billing record for the current month
        Date today = Date.today();
        Date firstDayOfMonth = Date.newInstance(today.year(), today.month(), 1);
        Date lastDayOfMonth = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));
        
        Monthly_Billing__c mb = new Monthly_Billing__c(
            Client_Account__c = acct.Id,
            Start_Date__c = firstDayOfMonth,
            Last_Day_of_Month__c = lastDayOfMonth
        );
        insert mb;
        
        // Update the account with overhours fields
        acct.Date_Warned__c = Date.today();
        acct.Warned_By__c = UserInfo.getUserId();
        acct.Overhours_Notes__c = 'Test overhours notes';
        acct.In_Case_of_Emergency_Overhours_Notes__c = 'Emergency notes';
        acct.Not_Warning__c = true;
        acct.Holding_Off__c = false;
        acct.Free_Credit_Notice_Date__c = Date.today().addDays(7);
        
        Test.startTest();
        update acct;
        Test.stopTest();
        
        // Query the Monthly Billing record
        Monthly_Billing__c updatedMB = [
            SELECT Id, Date_Warned__c, Warning_Given_By__c, Overhours_Notes__c,
                   In_Case_of_Emergency_Overhours_Notes__c, Not_Warning__c, Holding_Off__c,
                   Free_Credit_Notice_Date__c
            FROM Monthly_Billing__c
            WHERE Id = :mb.Id
        ];
        
        // Verify all fields were synced
        System.assertEquals(acct.Date_Warned__c, updatedMB.Date_Warned__c, 
            'Date Warned should be synced');
        System.assertEquals(acct.Warned_By__c, updatedMB.Warning_Given_By__c, 
            'Warning Given By should be synced');
        System.assertEquals(acct.Overhours_Notes__c, updatedMB.Overhours_Notes__c, 
            'Overhours Notes should be synced');
        System.assertEquals(acct.In_Case_of_Emergency_Overhours_Notes__c, 
            updatedMB.In_Case_of_Emergency_Overhours_Notes__c, 
            'Emergency Overhours Notes should be synced');
        System.assertEquals(acct.Not_Warning__c, updatedMB.Not_Warning__c, 
            'Not Warning should be synced');
        System.assertEquals(acct.Holding_Off__c, updatedMB.Holding_Off__c, 
            'Holding Off should be synced');
        System.assertEquals(acct.Free_Credit_Notice_Date__c, updatedMB.Free_Credit_Notice_Date__c, 
            'Free Credit Notice Date should be synced');
    }
    
    @isTest
    static void testAfterUpdate_PartialOverhoursFieldUpdate() {
        // Test that only changed fields trigger the sync
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Restaurant 2' LIMIT 1];
        
        // Create a Monthly Billing record for the current month
        Date today = Date.today();
        Date firstDayOfMonth = Date.newInstance(today.year(), today.month(), 1);
        Date lastDayOfMonth = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));
        
        Monthly_Billing__c mb = new Monthly_Billing__c(
            Client_Account__c = acct.Id,
            Start_Date__c = firstDayOfMonth,
            Last_Day_of_Month__c = lastDayOfMonth,
            Overhours_Notes__c = 'Original notes'
        );
        insert mb;
        
        // Update only specific overhours fields
        acct.Overhours_Notes__c = 'Updated notes';
        acct.Not_Warning__c = true;
        
        Test.startTest();
        update acct;
        Test.stopTest();
        
        // Query the Monthly Billing record
        Monthly_Billing__c updatedMB = [
            SELECT Id, Overhours_Notes__c, Not_Warning__c
            FROM Monthly_Billing__c
            WHERE Id = :mb.Id
        ];
        
        // Verify the changed fields were synced
        System.assertEquals('Updated notes', updatedMB.Overhours_Notes__c, 
            'Overhours Notes should be updated');
        System.assertEquals(true, updatedMB.Not_Warning__c, 
            'Not Warning should be updated');
    }
    
    @isTest
    static void testAfterUpdate_NoMonthlyBillingRecord() {
        // Test that no error occurs when there's no Monthly Billing record
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Restaurant 1' LIMIT 1];
        
        // Update the account with overhours fields but no Monthly Billing exists
        acct.Date_Warned__c = Date.today();
        acct.Overhours_Notes__c = 'Test notes';
        
        Test.startTest();
        // Should complete without error
        update acct;
        Test.stopTest();
        
        // Verify the account was updated (no DML exception)
        Account updatedAcct = [
            SELECT Id, Date_Warned__c, Overhours_Notes__c
            FROM Account
            WHERE Id = :acct.Id
        ];
        
        System.assertEquals(Date.today(), updatedAcct.Date_Warned__c, 
            'Account should be updated even without Monthly Billing');
        System.assertEquals('Test notes', updatedAcct.Overhours_Notes__c, 
            'Overhours Notes should be set on Account');
    }
    
    @isTest
    static void testAfterUpdate_NoOverhoursFieldsChanged() {
        // Test that nothing happens when non-overhours fields are updated
        Account acct = [SELECT Id FROM Account WHERE Name = 'Test Restaurant 1' LIMIT 1];
        
        // Create a Monthly Billing record
        Date today = Date.today();
        Date firstDayOfMonth = Date.newInstance(today.year(), today.month(), 1);
        Date lastDayOfMonth = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));
        
        Monthly_Billing__c mb = new Monthly_Billing__c(
            Client_Account__c = acct.Id,
            Start_Date__c = firstDayOfMonth,
            Last_Day_of_Month__c = lastDayOfMonth,
            Overhours_Notes__c = 'Original notes'
        );
        insert mb;
        
        // Update a non-overhours field
        acct.Name = 'Updated Restaurant Name';
        
        Test.startTest();
        update acct;
        Test.stopTest();
        
        // Query the Monthly Billing record
        Monthly_Billing__c updatedMB = [
            SELECT Id, Overhours_Notes__c
            FROM Monthly_Billing__c
            WHERE Id = :mb.Id
        ];
        
        // Verify Monthly Billing was not changed
        System.assertEquals('Original notes', updatedMB.Overhours_Notes__c, 
            'Monthly Billing should not be updated when non-overhours fields change');
    }
    
    @isTest
    static void testBulkInsert() {
        // Test bulk insert with multiple accounts
        List<Account> bulkAccounts = new List<Account>();
        
        for(Integer i = 0; i < 200; i++) {
            Account acct = new Account(
                Name = 'Bulk Test Restaurant ' + i,
                Zagat_Review__c = 'Review line 1 for restaurant ' + i + '\nReview line 2'
            );
            bulkAccounts.add(acct);
        }
        
        Test.startTest();
        insert bulkAccounts;
        Test.stopTest();
        
        // Query the inserted accounts
        List<Account> insertedAccounts = [
            SELECT Id, Review_Description_First_Line__c, Review_Description_After_First_Line__c
            FROM Account
            WHERE Name LIKE 'Bulk Test Restaurant%'
        ];
        
        // Verify all accounts were processed correctly
        System.assertEquals(200, insertedAccounts.size(), 'All 200 accounts should be inserted');
        
        for(Account acct : insertedAccounts) {
            System.assertNotEquals(null, acct.Review_Description_First_Line__c, 
                'First line should be set for all accounts');
            System.assert(acct.Review_Description_First_Line__c.contains('Review line 1'), 
                'First line should contain expected content');
        }
    }
    
    @isTest
    static void testBulkUpdate_OverhoursSync() {
        // Test bulk update with overhours sync
        List<Account> bulkAccounts = new List<Account>();
        
        // Create accounts
        for(Integer i = 0; i < 50; i++) {
            Account acct = new Account(
                Name = 'Bulk Overhours Test ' + i
            );
            bulkAccounts.add(acct);
        }
        insert bulkAccounts;
        
        // Create Monthly Billing records for all accounts
        Date today = Date.today();
        Date firstDayOfMonth = Date.newInstance(today.year(), today.month(), 1);
        Date lastDayOfMonth = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));
        
        List<Monthly_Billing__c> monthlyBillings = new List<Monthly_Billing__c>();
        for(Account acct : bulkAccounts) {
            Monthly_Billing__c mb = new Monthly_Billing__c(
                Client_Account__c = acct.Id,
                Start_Date__c = firstDayOfMonth,
                Last_Day_of_Month__c = lastDayOfMonth
            );
            monthlyBillings.add(mb);
        }
        insert monthlyBillings;
        
        // Update all accounts with overhours data
        for(Account acct : bulkAccounts) {
            acct.Overhours_Notes__c = 'Bulk test notes';
            acct.Not_Warning__c = true;
        }
        
        Test.startTest();
        update bulkAccounts;
        Test.stopTest();
        
        // Query and verify all Monthly Billing records were updated
        List<Monthly_Billing__c> updatedMBs = [
            SELECT Id, Overhours_Notes__c, Not_Warning__c
            FROM Monthly_Billing__c
            WHERE Client_Account__c IN :bulkAccounts
        ];
        
        System.assertEquals(50, updatedMBs.size(), 'All Monthly Billing records should exist');
        
        for(Monthly_Billing__c mb : updatedMBs) {
            System.assertEquals('Bulk test notes', mb.Overhours_Notes__c, 
                'Overhours Notes should be synced for all records');
            System.assertEquals(true, mb.Not_Warning__c, 
                'Not Warning should be synced for all records');
        }
    }
}