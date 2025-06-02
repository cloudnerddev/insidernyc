/*
*   PURPOSE:       This class will handle trigger behaviour and will perform task accordingly
*/
public  class TriggerHandlerTimeLog extends TriggerHandler {    
    // Constructor 
    public TriggerHandlerTimeLog() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {}
    public override void beforeUpdate() {}
    public override void beforeDelete() {}
    public override void afterInsert()  {
        recalcCaseTimeLogs(Trigger.new, Trigger.oldMap);
    }
    public override void afterUpdate()  {
        recalcCaseTimeLogs(Trigger.new, Trigger.oldMap);
    }
    public override void afterDelete()  {
        recalcCaseTimeLogs(Trigger.new, Trigger.oldMap);
    }
    public override void afterUndelete(){
        recalcCaseTimeLogs(Trigger.new, Trigger.oldMap);
    }
    
    private void recalcCaseTimeLogs(List<sObject> newTimeLogs, Map<Id,sObject> oldTimeLogMap){
        system.debug('recalcCaseTimeLogs');
        
        List<Time_Log__c> newTimeLogsList = (List<Time_Log__c>) newTimeLogs;
        Map<Id,Time_Log__c> oldMap;
        
        if(oldTimeLogMap != NULL){
            oldMap = (Map<Id,Time_Log__c>) oldTimeLogMap;
        }
        
        Set<Id> caseIds = new Set<Id>();
        Set<Id> parentCaseIds = new Set<Id>();
        
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
                
        List<Case> casesToUpdate = new List<Case>();
        List<Case> parentCasesToUpdate = new List<Case>();
        
        if (newTimeLogsList == null) {
            for(Time_Log__c tl : oldMap.values()){
                caseIds.add(tl.Case__c);
                
                contactIds.add(tl.Contact__c);
                accountIds.add(tl.Client__c);
            }
        } else {
            for(Time_Log__c tl : newTimeLogsList){
                
                //oldMap.get(cs.Id).Status
                //cs.Status
                if (tl.Case__c != NULL) {
                    caseIds.add(tl.Case__c);
                }
                
                //check old cases
                if (oldMap != NULL) {
                    if (tl.Case__c != oldMap.get(tl.Id).Case__c) {
                        if (oldMap.get(tl.Id).Case__c != NULL) {
                            caseIds.add(oldMap.get(tl.Id).Case__c);
                        }
                    }
                }
                
                contactIds.add(tl.Contact__c);
                accountIds.add(tl.Client__c);
            }
        }
        
        system.debug('caseIds: ' + caseIds);
        if(caseIds.size() > 0) {
            casesToUpdate = [SELECT Id, ParentId, Case_Time_Logged__c, Hierarchical_Time_Logged__c, (SELECT Id, Case__c, ParentLogbookId__c, Duration_Minutes__c, Billable_Time__c FROM Time_Logs__r) FROM Case WHERE Id IN :caseIds];
            for (Case cs : casesToUpdate) {
                cs.Case_Time_Logged__c = 0;
                if (cs.Hierarchical_Time_Logged__c == NULL) {
                    cs.Hierarchical_Time_Logged__c = 0;
                }
                for (Time_Log__c tl : cs.Time_Logs__r) {
                    if (tl.Billable_Time__c != NULL) {
                        cs.Case_Time_Logged__c += tl.Billable_Time__c;
                    }
                }
                
                if (cs.ParentId != NULL) {
                    parentCaseIds.add(cs.ParentId);
                }
                
            }
            system.debug('casesToUpdate: ' + casesToUpdate);
            update casesToUpdate;
        }
        
        system.debug('parentCaseIds: ' + parentCaseIds);
        if(parentCaseIds.size() > 0) {
            parentCasesToUpdate = [SELECT Id, ParentId, Hierarchical_Time_Logged__c, (SELECT Id, Case_Time_Logged__c FROM Cases) FROM Case WHERE Id IN :parentCaseIds];
            for (Case parentCase : parentCasesToUpdate) {
                parentCase.Hierarchical_Time_Logged__c = 0;
                for (Case childCase : parentCase.Cases) {
                    if (childCase.Case_Time_Logged__c != NULL) {
                        parentCase.Hierarchical_Time_Logged__c += childCase.Case_Time_Logged__c;
                    }
                }
            }
            system.debug('parentCasesToUpdate: ' + parentCasesToUpdate);
            update parentCasesToUpdate;
        }
        
        if (contactIds.size() > 0) {
            Util.recalcContacts(contactIds);
        }
        if (accountIds.size() > 0) {
            Util.recalcAccounts(accountIds);
        }
    }
}