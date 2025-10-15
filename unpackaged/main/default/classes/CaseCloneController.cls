public with sharing class CaseCloneController {
    
    @AuraEnabled
    public static Case getCaseDetails(Id caseId) {
        try {
            return [
                SELECT Id, CaseNumber, Date__c, Vendor__r.Name, Number_in_Party__c,
                       RecordTypeId, AccountId, ContactId, CreatedDate,
                       Description, Type, Reason, OwnerId
                FROM Case 
                WHERE Id = :caseId 
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving case details: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Case> checkCaseDuplicates(Id caseId) {
        try {
            // Get the original case details
            Case originalCase = getCaseDetails(caseId);
            System.debug('****** ' + originalCase);
            if (originalCase == null) {
                throw new AuraHandledException('Original case not found');
            }
            
            // Build dynamic query to check for potential duplicates
            List<Case> duplicates = new List<Case>();
                        
            // Check for similar cases by Account and Contact if no exact matches
            if (duplicates.isEmpty() && originalCase.AccountId != null) {
                duplicates.addAll(findDuplicatesByAccount(originalCase));
            }
            
            // Remove the original case from duplicates list
            /*for (Integer i = duplicates.size() - 1; i >= 0; i--) {
                if (duplicates[i].Id == caseId) {
                    duplicates.remove(i);
                }
            }*/
            system.debug('***** ' + duplicates);
            return duplicates;
            
        } catch (Exception e) {
            System.debug('Error in checkCaseDuplicates: ' + e.getMessage());
            throw new AuraHandledException('Error checking for duplicates: ' + e.getMessage());
        }
    }
    
    
    private static List<Case> findDuplicatesByAccount(Case originalCase) {
        List<Case> accountDuplicates = new List<Case>();
        
        // Look for cases with similar characteristics
        if (originalCase.AccountId != null) {
            // ✅ FIXED: Create local variables for bind parameters
            Id accountId = originalCase.AccountId;
            Id caseId = originalCase.Id;
            Date cutoffDate = originalCase.Date__c;
            String recordTypeId = originalCase.RecordTypeId;
            
            String query = 'SELECT Id, CaseNumber, Subject, Status, Priority, CreatedDate, Date__c, Vendor__r.Name, Number_in_Party__c,' +
                          'LastModifiedDate, AccountId, ContactId, Type, Reason, OwnerId ' +
                          'FROM Case ' +
                          'WHERE AccountId = :accountId ' +     // ✅ FIXED: Use local variable
                          'AND Date__c = :cutoffDate ' +   // ✅ FIXED: Use local variable
                          'AND recordTypeId = :recordTypeId';
			system.debug('***** ' + query);
            
            accountDuplicates = Database.query(query);
            system.debug('***** ' + accountDuplicates.size());
        }
        
        return accountDuplicates;
    }
}