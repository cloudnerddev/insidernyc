@isTest
private class DateFieldDayViewerControllerTest {

    @isTest
    static void testGetDateFields() {
        // Setup test data
        Account testAccount = new Account(
            Name = 'Test Account',       
            Account_Unfrozen_Date__c = DateTime.now()   // Use your actual custom datetime fields
        );
        insert testAccount;

        // Provide the object API name and field set name
        String objectApiName = 'Account';
        Id recordId = testAccount.Id;
        String fieldSetName = 'Day_Conversion_Date_Fields'; // Make sure this exists with date fields

        // Call the method
        Test.startTest();
        List<Map<String, String>> result = DateFieldDayViewerController.getDateFields(objectApiName, recordId, fieldSetName);
        Test.stopTest();

        // Validate results
        System.assertNotEquals(0, result.size(), 'Result should not be empty');

        Boolean hasRecordType = false;
        Boolean hasDate = false;
        Boolean hasDateTime = false;

        for (Map<String, String> entry : result) {
            if (entry.get('label') == 'RecordType') {
                hasRecordType = true;
            }
            if (entry.get('label') == 'Account Unfrozen Date') { // Change this to your field label
                hasDateTime = true;
            }
        }

        System.assert(hasRecordType, 'Should include RecordType name');
        System.assert(hasDateTime, 'Should include Custom DateTime field');
    }
}