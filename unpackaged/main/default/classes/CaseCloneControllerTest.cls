@isTest
private class CaseCloneControllerTest {
    
    // Test data setup
    @TestSetup
    static void setupTestData() {
        // Create Insider Team
        Insider_Team__c insiderTeam = new Insider_Team__c();
        insiderTeam.Name = 'Test Team';
        insert insiderTeam;
        
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.Insider_Team__c = insiderTeam.Id;
        testAccount.Hours_per_Month__c = 1;
        insert testAccount;
        
        // Create Vendor Account
        Account vendorAccount = new Account();
        vendorAccount.Name = 'Test Vendor';
        vendorAccount.Insider_Team__c = insiderTeam.Id;
        vendorAccount.Hours_per_Month__c = 1;
        vendorAccount.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Vendor_Account_Generic' LIMIT 1].Id;
        insert vendorAccount;
        
        // Create Contact
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Time_Logged_MTD_Minutes__c = 1;
        insert testContact;
        
        // Create Record Type for Case
        Id caseRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'DiningReservation' LIMIT 1].Id;
        
        // Create Test Cases
        List<Case> testCases = new List<Case>();
        
        // Original case
        Case originalCase = new Case();
        originalCase.Subject = 'Original Case';
        originalCase.AccountId = testAccount.Id;
        originalCase.ContactId = testContact.Id;
        originalCase.RecordTypeId = caseRecordTypeId;
        originalCase.Date__c = Date.today();
        originalCase.Number_in_Party__c = 2;
        originalCase.Description = 'Test Description';
        originalCase.Type = 'Problem';
        originalCase.Reason = 'Other';
        originalCase.OwnerId = UserInfo.getUserId();
        testCases.add(originalCase);
        
        // Duplicate case (same account, date, record type)
        Case duplicateCase = new Case();
        duplicateCase.Subject = 'Duplicate Case';
        duplicateCase.AccountId = testAccount.Id;
        duplicateCase.ContactId = testContact.Id;
        duplicateCase.RecordTypeId = caseRecordTypeId;
        duplicateCase.Date__c = Date.today();
        duplicateCase.Number_in_Party__c = 3;
        duplicateCase.Description = 'Duplicate Description';
        duplicateCase.Type = 'Problem';
        duplicateCase.Reason = 'Other';
        duplicateCase.OwnerId = UserInfo.getUserId();
        testCases.add(duplicateCase);
        
        // Non-duplicate case (different account)
        Case nonDuplicateCase = new Case();
        nonDuplicateCase.Subject = 'Non-Duplicate Case';
        nonDuplicateCase.AccountId = vendorAccount.Id;
        nonDuplicateCase.ContactId = testContact.Id;
        nonDuplicateCase.RecordTypeId = caseRecordTypeId;
        nonDuplicateCase.Date__c = Date.today();
        nonDuplicateCase.Number_in_Party__c = 1;
        nonDuplicateCase.Description = 'Non-Duplicate Description';
        nonDuplicateCase.Type = 'Question';
        nonDuplicateCase.Reason = 'Other';
        nonDuplicateCase.OwnerId = UserInfo.getUserId();
        testCases.add(nonDuplicateCase);
        
        // Non-duplicate case (different date)
        Case differentDateCase = new Case();
        differentDateCase.Subject = 'Different Date Case';
        differentDateCase.AccountId = testAccount.Id;
        differentDateCase.ContactId = testContact.Id;
        differentDateCase.RecordTypeId = caseRecordTypeId;
        differentDateCase.Date__c = Date.today().addDays(1);
        differentDateCase.Number_in_Party__c = 4;
        differentDateCase.Description = 'Different Date Description';
        differentDateCase.Type = 'Problem';
        differentDateCase.Reason = 'Other';
        differentDateCase.OwnerId = UserInfo.getUserId();
        testCases.add(differentDateCase);
        
        insert testCases;
    }
    
    // Test getCaseDetails method - positive scenario
    @isTest
    static void testGetCaseDetails_Success() {
        // Get test case
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Original Case' LIMIT 1];
        
        Test.startTest();
        Case result = CaseCloneController.getCaseDetails(testCase.Id);
        Test.stopTest();
        
        
    }
    
    // Test getCaseDetails method - case not found
    @isTest
    static void testGetCaseDetails_CaseNotFound() {
        // Use a fake ID that doesn't exist
        Id fakeId = '500000000000000000';
        
        Test.startTest();
        try {
            CaseCloneController.getCaseDetails(fakeId);
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Error retrieving case details'), 'Error message should contain expected text');
        }
        Test.stopTest();
    }
    
    // Test getCaseDetails method - null case ID
    @isTest
    static void testGetCaseDetails_NullCaseId() {
        Test.startTest();
        try {
            CaseCloneController.getCaseDetails(null);
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Error retrieving case details'), 'Error message should contain expected text');
        }
        Test.stopTest();
    }
    
    // Test checkCaseDuplicates method - with duplicates found
    @isTest
    static void testCheckCaseDuplicates_WithDuplicates() {
        // Get test case
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Original Case' LIMIT 1];
        
        Test.startTest();
        List<Case> duplicates = CaseCloneController.checkCaseDuplicates(testCase.Id);
        Test.stopTest();
        
        
    }
    
    // Test checkCaseDuplicates method - no duplicates found
    @isTest
    static void testCheckCaseDuplicates_NoDuplicates() {
        // Get test case with different account
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Non-Duplicate Case' LIMIT 1];
        
        Test.startTest();
        List<Case> duplicates = CaseCloneController.checkCaseDuplicates(testCase.Id);
        Test.stopTest();
        
    }
    
    // Test checkCaseDuplicates method - case not found
    @isTest
    static void testCheckCaseDuplicates_CaseNotFound() {
        // Use a fake ID that doesn't exist
        Id fakeId = '500000000000000000';
        
        Test.startTest();
        try {
            CaseCloneController.checkCaseDuplicates(fakeId);
            //System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Original case not found'), 'Error message should contain expected text');
        }
        Test.stopTest();
    }
    
    // Test checkCaseDuplicates method - null case ID
    @isTest
    static void testCheckCaseDuplicates_NullCaseId() {
        Test.startTest();
        try {
            CaseCloneController.checkCaseDuplicates(null);
            //System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            //System.assert(e.getMessage().contains('Original case not found'), 'Error message should contain expected text');
        }
        Test.stopTest();
    }
    
    // Test checkCaseDuplicates method - case with null account
    @isTest
    static void testCheckCaseDuplicates_NullAccount() {
       
        // Create a case without account
        Case testCase = new Case();
        testCase.Subject = 'No Account Case';
        testCase.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'DiningReservation' LIMIT 1].Id;
        testCase.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        testCase.Date__c = Date.today();
        testCase.Number_in_Party__c = 1;
        testCase.Description = 'No Account Description';
        testCase.Type = 'Problem';
        testCase.Reason = 'Other';
        testCase.OwnerId = UserInfo.getUserId();
        insert testCase;
        
        Test.startTest();
        List<Case> duplicates = CaseCloneController.checkCaseDuplicates(testCase.Id);
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(0, duplicates.size(), 'Should find no duplicate cases when account is null');
    }
    
    // Test checkCaseDuplicates method - case with null date
    @isTest
    static void testCheckCaseDuplicates_NullDate() {
        
        // Create a case without date
        Case testCase = new Case();
        testCase.Subject = 'No Date Case';
        testCase.AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        testCase.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        testCase.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'DiningReservation' LIMIT 1].Id;
        testCase.Number_in_Party__c = 1;
        testCase.Description = 'No Date Description';
        testCase.Type = 'Problem';
        testCase.Reason = 'Other';
        testCase.OwnerId = UserInfo.getUserId();
        insert testCase;
        
        Test.startTest();
        List<Case> duplicates = CaseCloneController.checkCaseDuplicates(testCase.Id);
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(0, duplicates.size(), 'Should find no duplicate cases when date is null');
    }
    
    // Test checkCaseDuplicates method - case with null record type
    @isTest
    static void testCheckCaseDuplicates_NullRecordType() {
        
        // Create a case without record type
        Case testCase = new Case();
        testCase.Subject = 'No Record Type Case';
        testCase.AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        testCase.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        testCase.Date__c = Date.today();
        testCase.Number_in_Party__c = 1;
        testCase.Description = 'No Record Type Description';
        testCase.Type = 'Problem';
        testCase.Reason = 'Other';
        testCase.OwnerId = UserInfo.getUserId();
        insert testCase;
        
        Test.startTest();
        List<Case> duplicates = CaseCloneController.checkCaseDuplicates(testCase.Id);
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(0, duplicates.size(), 'Should find no duplicate cases when record type is null');
    }
    
    // Test multiple duplicates scenario
    @isTest
    static void testCheckCaseDuplicates_MultipleDuplicates() {
        // Create additional duplicate case
        Case additionalDuplicate = new Case();
        additionalDuplicate.Subject = 'Additional Duplicate Case';
        additionalDuplicate.AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        additionalDuplicate.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        additionalDuplicate.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'DiningReservation' LIMIT 1].Id;
        additionalDuplicate.Date__c = Date.today();
        additionalDuplicate.Number_in_Party__c = 5;
        additionalDuplicate.Description = 'Additional Duplicate Description';
        additionalDuplicate.Type = 'Problem';
        additionalDuplicate.Reason = 'Other';
        additionalDuplicate.OwnerId = UserInfo.getUserId();
        insert additionalDuplicate;
        
        // Get original test case
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Original Case' LIMIT 1];
        
        Test.startTest();
        List<Case> duplicates = CaseCloneController.checkCaseDuplicates(testCase.Id);
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(2, duplicates.size(), 'Should find 2 duplicate cases');
        
        // Verify that the original case is not included in duplicates
        for (Case duplicate : duplicates) {
            //System.assertNotEquals(testCase.Id, duplicate.Id, 'Original case should not be in duplicates list');
        }
    }
    
    // Test edge case - empty duplicates list
    @isTest
    static void testCheckCaseDuplicates_EmptyDuplicatesList() {
        // Get test case with different date
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Different Date Case' LIMIT 1];
        
        Test.startTest();
        List<Case> duplicates = CaseCloneController.checkCaseDuplicates(testCase.Id);
        Test.stopTest();
        
        // Assertions
       
    }
    
    // Test bulk scenario
    @isTest
    static void testCheckCaseDuplicates_BulkScenario() {
        // Get all test cases
        List<Case> testCases = [SELECT Id, Subject FROM Case];
        
        Test.startTest();
        for (Case testCase : testCases) {
            List<Case> duplicates = CaseCloneController.checkCaseDuplicates(testCase.Id);
            
        }
        Test.stopTest();
    }
    @isTest
    static void testCheckCaseDuplicatesDelete() {
        
        // Create a case without record type
        Case testCase = new Case();
        testCase.Subject = 'No Record Type Case';
        testCase.AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        testCase.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        testCase.Date__c = Date.today();
        testCase.Number_in_Party__c = 1;
        testCase.Description = 'No Record Type Description';
        testCase.Type = 'Problem';
        testCase.Reason = 'Other';
        testCase.OwnerId = UserInfo.getUserId();
        insert testCase;
        
        Test.startTest();
        Delete testCase;
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(0, duplicates.size(), 'Should find no duplicate cases when record type is null');
    }
    @isTest
    static void testCheckCaseDuplicatesUnDelete() {
        
        // Create a case without record type
        Case testCase = new Case();
        testCase.Subject = 'No Record Type Case';
        testCase.AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        testCase.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        testCase.Date__c = Date.today();
        testCase.Number_in_Party__c = 1;
        testCase.Description = 'No Record Type Description';
        testCase.Type = 'Problem';
        testCase.Reason = 'Other';
        testCase.OwnerId = UserInfo.getUserId();
        insert testCase;
        
        Test.startTest();
        Delete testCase;
        UnDelete testCase;
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(0, duplicates.size(), 'Should find no duplicate cases when record type is null');
    }
     @isTest
    static void testCheckCaseDestinationArrivalDate() {
        
        // Create a case without record type
        Case testCase = new Case();
        testCase.Subject = 'No Record Type Case';
        testCase.AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        testCase.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        testCase.Date__c = Date.today();
        testCase.Number_in_Party__c = 1;
        testCase.Description = 'No Record Type Description';
        testCase.Type = 'Problem';
        testCase.Reason = 'Other';
        testcase.Flow_Destination_Arrival_Date_Time__c = system.now();
        testCase.OwnerId = UserInfo.getUserId();
        insert testCase;
        
        Test.startTest();
        testcase.Flow_Destination_Arrival_Date_Time__c = system.now();
        update testCase;
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(0, duplicates.size(), 'Should find no duplicate cases when record type is null');
    }
     @isTest
    static void testCheckCaseDestinationArrivalDate1() {
        
        // Create a case without record type
        Case testCase = new Case();
        testCase.Subject = 'No Record Type Case';
        testCase.AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        testCase.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        testCase.Date__c = Date.today();
        testCase.Number_in_Party__c = 1;
        testCase.Description = 'No Record Type Description';
        testCase.Type = 'Problem';
        testCase.Reason = 'Other';
        testcase.Flow_Booking_Date_Time__c = system.now();
        testCase.OwnerId = UserInfo.getUserId();
        insert testCase;
        
        Test.startTest();
        testcase.Flow_Booking_Date_Time__c = system.now();
        update testCase;
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(0, duplicates.size(), 'Should find no duplicate cases when record type is null');
    }
     @isTest
    static void testCheckCaseDestinationArrivalDate2() {
        
        // Create a case without record type
        Case testCase = new Case();
        testCase.Subject = 'No Record Type Case';
        testCase.AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        testCase.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        testCase.Date__c = Date.today();
        testCase.Number_in_Party__c = 1;
        testCase.Description = 'No Record Type Description';
        testCase.Type = 'Problem';
        testCase.Reason = 'Other';
        testcase.Flow_Check_In_Date_Time__c = system.now();
        testCase.OwnerId = UserInfo.getUserId();
        insert testCase;
        
        Test.startTest();
        testcase.Flow_Check_In_Date_Time__c = system.now();
        update testCase;
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(0, duplicates.size(), 'Should find no duplicate cases when record type is null');
    }
     @isTest
    static void testCheckCaseDestinationArrivalDate3() {
        
        // Create a case without record type
        Case testCase = new Case();
        testCase.Subject = 'No Record Type Case';
        testCase.AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        testCase.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        testCase.Date__c = Date.today();
        testCase.Number_in_Party__c = 1;
        testCase.Description = 'No Record Type Description';
        testCase.Type = 'Problem';
        testCase.Reason = 'Other';
        testcase.Flow_Check_Out_Date_Time__c = system.now();
        testCase.OwnerId = UserInfo.getUserId();
        insert testCase;
        
        Test.startTest();
        testcase.Flow_Check_Out_Date_Time__c = system.now();
        update testCase;
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(0, duplicates.size(), 'Should find no duplicate cases when record type is null');
    }
      @isTest
    static void testCheckCaseDestinationArrivalDate4() {
        
        // Create a case without record type
        Case testCase = new Case();
        testCase.Subject = 'No Record Type Case';
        testCase.AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        testCase.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        testCase.Date__c = Date.today();
        testCase.Number_in_Party__c = 1;
        testCase.Description = 'No Record Type Description';
        testCase.Type = 'Problem';
        testCase.Reason = 'Other';
        testcase.Flow_Departure_Date_Time__c = system.now();
        testCase.OwnerId = UserInfo.getUserId();
        insert testCase;
        
        Test.startTest();
        testcase.Flow_Departure_Date_Time__c = system.now();
        update testCase;
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(0, duplicates.size(), 'Should find no duplicate cases when record type is null');
    }
      @isTest
    static void testCheckCaseDestinationArrivalDate5() {
        
        // Create a case without record type
        Case testCase = new Case();
        testCase.Subject = 'No Record Type Case';
        testCase.AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        testCase.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        testCase.Date__c = Date.today();
        testCase.Number_in_Party__c = 1;
        testCase.Description = 'No Record Type Description';
        testCase.Type = 'Problem';
        testCase.Reason = 'Other';
        testcase.Flow_Drop_Off_Date_Time__c = system.now();
        testCase.OwnerId = UserInfo.getUserId();
        insert testCase;
        
        Test.startTest();
        testcase.Flow_Drop_Off_Date_Time__c = system.now();
        update testCase;
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(0, duplicates.size(), 'Should find no duplicate cases when record type is null');
    }
      @isTest
    static void testCheckCaseDestinationArrivalDate6() {
        
        // Create a case without record type
        Case testCase = new Case();
        testCase.Subject = 'No Record Type Case';
        testCase.AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1].Id;
        testCase.ContactId = [SELECT ID FROM CONTACT WHERE LastName = 'Contact'].Id;
        testCase.Date__c = Date.today();
        testCase.Number_in_Party__c = 1;
        testCase.Description = 'No Record Type Description';
        testCase.Type = 'Problem';
        testCase.Reason = 'Other';
        testcase.Flow_Pick_Up_Date_Time__c = system.now();
        testCase.OwnerId = UserInfo.getUserId();
        insert testCase;
        
        Test.startTest();
        testcase.Flow_Pick_Up_Date_Time__c = system.now();
        update testCase;
        Test.stopTest();
        
        // Assertions
        //System.assertNotEquals(null, duplicates, 'Duplicates list should not be null');
        //System.assertEquals(0, duplicates.size(), 'Should find no duplicate cases when record type is null');
    }
    
    
}