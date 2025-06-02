public class TimeLogRollupBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Id singleCaseId;
    private String query;
    private Map<Id, Decimal> caseToTotalTimeMap;

    // Constructor for ALL Travel_Planning cases (default)
    public TimeLogRollupBatch() {
        this.query = 'SELECT Id, Total_Billable_Time__c FROM Case WHERE RecordType.DeveloperName = \'Travel_Planning\'';
        this.caseToTotalTimeMap = new Map<Id, Decimal>();
    }

    // Constructor for a single Travel_Planning Case
    public TimeLogRollupBatch(Id caseId) {
        this.singleCaseId = caseId;
        this.query = 'SELECT Id, Total_Billable_Time__c FROM Case WHERE Id = :singleCaseId AND RecordType.DeveloperName = \'Travel_Planning\'';
        this.caseToTotalTimeMap = new Map<Id, Decimal>();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Case> scope) {
        Set<Id> caseIds = new Set<Id>();
        for (Case c : scope) {
            caseIds.add(c.Id);
        }

        // First, get all related cases (both parent and child relationships)
        Map<Id, Set<Id>> caseToRelatedCasesMap = new Map<Id, Set<Id>>();
        for (Case c : [SELECT Id, ParentId, (SELECT Id FROM Cases) FROM Case WHERE Id IN :caseIds OR ParentId IN :caseIds]) {
            if (caseIds.contains(c.Id)) {
                Set<Id> relatedCases = new Set<Id>();
                if (c.ParentId != null) {
                    relatedCases.add(c.ParentId);
                }
                for (Case childCase : c.Cases) {
                    relatedCases.add(childCase.Id);
                }
                caseToRelatedCasesMap.put(c.Id, relatedCases);
            }
        }

        // Gather all related Case Ids
        Set<Id> allRelatedCaseIds = new Set<Id>();
        for (Set<Id> relatedCases : caseToRelatedCasesMap.values()) {
            allRelatedCaseIds.addAll(relatedCases);
        }
        allRelatedCaseIds.addAll(caseIds);

        // Query all relevant Time Logs
        List<Time_Log__c> timeLogs = [
            SELECT Id, Case__c, Billable_Time__c
            FROM Time_Log__c
            WHERE Case__c IN :allRelatedCaseIds
        ];

        // Aggregate billable time
        for (Time_Log__c tl : timeLogs) {
            for (Id travelPlanningCaseId : caseToRelatedCasesMap.keySet()) {
                Set<Id> relatedCases = caseToRelatedCasesMap.get(travelPlanningCaseId);
                if (relatedCases.contains(tl.Case__c)) {
                    Decimal currentTotal = caseToTotalTimeMap.get(travelPlanningCaseId);
                    caseToTotalTimeMap.put(travelPlanningCaseId, (currentTotal != null ? currentTotal : 0) + (tl.Billable_Time__c != null ? tl.Billable_Time__c : 0));
                }
            }

            if (caseIds.contains(tl.Case__c)) {
                Decimal currentTotal = caseToTotalTimeMap.get(tl.Case__c);
                caseToTotalTimeMap.put(tl.Case__c, (currentTotal != null ? currentTotal : 0) + (tl.Billable_Time__c != null ? tl.Billable_Time__c : 0));
            }
        }

        // Update Cases
        List<Case> casesToUpdate = new List<Case>();
        for (Case c : scope) {
            if (caseToTotalTimeMap.containsKey(c.Id)) {
                c.Total_Billable_Time__c = caseToTotalTimeMap.get(c.Id);
                casesToUpdate.add(c);
            }
        }

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }

    public void finish(Database.BatchableContext BC) {
        // Optional post-processing
    }
}