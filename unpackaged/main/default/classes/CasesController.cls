public class CasesController {
    @AuraEnabled
    public static List <Case> getRelatedConfirmedCases(Id caseId) {
        return [SELECT Id, accountId, CaseNumber, Subject, Status, CreatedDate, RecordType.Name, Confirmation_Date__c 
                FROM Case 
                WHERE ParentId = :caseId AND Confirmation_Date__c != NULL 
                ORDER BY createdDate ASC];
    }
}