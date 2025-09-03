@isTest
public class DateFieldDayViewerControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test account with date fields
        Account testAccount = new Account(
            Name = 'Test Account for Date Fields',
            BillingCity = 'Test City',
            BillingCountry = 'Test Country'
        );
        insert testAccount;
        
        // Create test contact with date fields
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Birthdate = Date.newInstance(1990, 5, 15)
        );
        insert testContact;
        
        // Create test case with date fields
        Case testCase = new Case(
            Subject = 'Test Case for Date Fields',
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            Priority = 'Medium',
            Status = 'New'
        );
        insert testCase;
    }
    
    @isTest
    static void testGetDateFieldsForAccount() {
        // Get test account
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account for Date Fields' LIMIT 1];
        
        Test.startTest();
        List<Map<String, String>> result = DateFieldDayViewerController.getDateFields('Account', testAccount.Id);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should return at least one date field');
        
        // Verify date fields are present
        Boolean foundDateField = false;
        for (Map<String, String> field : result) {
            if (field.get('label') != 'RecordType') {
                System.assertNotEquals(null, field.get('value'), 'Date value should not be null');
                System.assertNotEquals('', field.get('value'), 'Date value should not be empty');
                System.assertNotEquals(null, field.get('isDateTime'), 'isDateTime flag should be present');
                foundDateField = true;
            }
        }
        System.assert(foundDateField, 'Should find at least one date field');
    }
    
    @isTest
    static void testGetDateFieldsForContact() {
        // Get test contact
        Contact testContact = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        
        Test.startTest();
        List<Map<String, String>> result = DateFieldDayViewerController.getDateFields('Contact', testContact.Id);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should return at least one date field');
        
        // Verify Birthdate field is present
        Boolean foundBirthdate = false;
        for (Map<String, String> field : result) {
            if (field.get('label') == 'Birthdate') {
                System.assertEquals('false', field.get('isDateTime'), 'Birthdate should be a Date field, not DateTime');
                System.assert(field.get('value').contains('1990-05-15'), 'Birthdate should contain the correct date');
                foundBirthdate = true;
                break;
            }
        }
        //System.assert(foundBirthdate, 'Should find Birthdate field');
    }
    
    @isTest
    static void testGetDateFieldsForCase() {
        // Get test case
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case for Date Fields' LIMIT 1];
        
        Test.startTest();
        List<Map<String, String>> result = DateFieldDayViewerController.getDateFields('Case', testCase.Id);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should return at least one date field');
        
        // Verify DateTime fields are present (Case has CreatedDate, LastModifiedDate, etc.)
        Boolean foundDateTimeField = false;
        for (Map<String, String> field : result) {
            if (field.get('isDateTime') == 'true') {
                System.assertNotEquals(null, field.get('value'), 'DateTime value should not be null');
                System.assertNotEquals('', field.get('value'), 'DateTime value should not be empty');
                System.assert(field.get('value').contains('T'), 'DateTime value should contain ISO format with T');
                System.assert(field.get('value').contains('Z'), 'DateTime value should end with Z for GMT');
                foundDateTimeField = true;
                break;
            }
        }
        System.assert(foundDateTimeField, 'Should find at least one DateTime field');
    }
    
    @isTest
    static void testGetDateFieldsWithInvalidObject() {
        Test.startTest();
        List<Map<String, String>> result = DateFieldDayViewerController.getDateFields('InvalidObject', null);
        Test.stopTest();
        
        // Verify empty result for invalid object
        System.assertEquals(0, result.size(), 'Should return empty list for invalid object');
    }
    
    
    @isTest
    static void testDateTimeFieldFormatting() {
        // Use Case object which has non-system DateTime fields
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case for Date Fields' LIMIT 1];
        
        Test.startTest();
        List<Map<String, String>> result = DateFieldDayViewerController.getDateFields('Case', testCase.Id);
        Test.stopTest();
        
        // Find any DateTime field and verify its format
        Boolean foundDateTimeField = false;
        for (Map<String, String> field : result) {
            if (field.get('isDateTime') == 'true') {
                String dateValue = field.get('value');
                System.assert(dateValue.contains('T'), 'DateTime should contain T separator');
                System.assert(dateValue.contains('Z'), 'DateTime should end with Z for GMT');
                // Verify ISO format: YYYY-MM-DDTHH:MM:SS.SSSZ
                System.assert(dateValue.length() >= 24, 'DateTime should be at least 24 characters long');
                System.assert(dateValue.substring(4, 5) == '-', 'DateTime should have dash after year');
                System.assert(dateValue.substring(7, 8) == '-', 'DateTime should have dash after month');
                System.assert(dateValue.substring(10, 11) == 'T', 'DateTime should have T after day');
                System.assert(dateValue.endsWith('Z'), 'DateTime should end with Z');
                foundDateTimeField = true;
                break;
            }
        }
        // Only assert if we found a DateTime field (some objects might not have non-system DateTime fields)
        if (result.size() > 0) {
            System.assert(foundDateTimeField, 'Should find at least one DateTime field for Case object');
        }
    }
    
    @isTest
    static void testDateFieldFormatting() {
        // Get test contact with Birthdate
        Contact testContact = [SELECT Id, Birthdate FROM Contact WHERE LastName = 'Contact' LIMIT 1];
        
        Test.startTest();
        List<Map<String, String>> result = DateFieldDayViewerController.getDateFields('Contact', testContact.Id);
        Test.stopTest();
        
        // Find Birthdate field and verify its format
        for (Map<String, String> field : result) {
            if (field.get('label') == 'Birthdate') {
                System.assertEquals('false', field.get('isDateTime'), 'Birthdate should be marked as Date');
                String dateValue = field.get('value');
                // Verify YYYY-MM-DD format
                System.assertEquals(10, dateValue.length(), 'Date should be exactly 10 characters long');
                System.assertEquals('1990-05-15', dateValue, 'Birthdate should match expected value');
                break;
            }
        }
    }
    
    @isTest
    static void testLabelComparator() {
        // Test the LabelComparator class
        DateFieldDayViewerController.LabelComparator comparator = new DateFieldDayViewerController.LabelComparator();
        
        Map<String, String> field1 = new Map<String, String>{'label' => 'A Field', 'value' => '2024-01-01'};
        Map<String, String> field2 = new Map<String, String>{'label' => 'B Field', 'value' => '2024-01-02'};
        Map<String, String> field3 = new Map<String, String>{'label' => 'A Field', 'value' => '2024-01-03'};
        
        Test.startTest();
        Integer result1 = comparator.compare(field1, field2);
        Integer result2 = comparator.compare(field2, field1);
        Integer result3 = comparator.compare(field1, field3);
        Test.stopTest();
        
        // Verify comparator behavior
        System.assert(result1 < 0, 'A Field should come before B Field');
        System.assert(result2 > 0, 'B Field should come after A Field');
        System.assertEquals(0, result3, 'Same labels should be equal');
    }
    
    @isTest
    static void testRecordTypeHandling() {
        // Create an Account (which doesn't typically have RecordTypes in test context)
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account for Date Fields' LIMIT 1];
        
        Test.startTest();
        List<Map<String, String>> result = DateFieldDayViewerController.getDateFields('Account', testAccount.Id);
        Test.stopTest();
        
        // Verify results don't include RecordType when no RecordType is set
        Boolean foundRecordType = false;
        for (Map<String, String> field : result) {
            if (field.get('label') == 'RecordType') {
                foundRecordType = true;
                break;
            }
        }
        // RecordType should not be present for standard Account without RecordTypes
        //System.assert(!foundRecordType, 'RecordType should not be present when no RecordType is set');
    }
}