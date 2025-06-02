trigger updateCases on Time_Log__c (after insert, after update, after delete, after undelete) {

    /*Set<Id> CaseIds = new Set<Id>();
    List<Case> Cases = new List<Case>();
    List<Time_Log__c> TimeLogs = new List<Time_Log__c>();
    
    IF(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        FOR (Time_Log__c TL : Trigger.new) {
            IF(TL.Case__c != NULL) {
                CaseIds.add(TL.Case__c);
                IF(TL.Case__r.ParentId != NULL) {
                    CaseIds.add(TL.Case__r.ParentId);
                }
            }
        }
    }
    IF(Trigger.isDelete || Trigger.isUpdate) {
        FOR (Time_Log__c TL : Trigger.old) {
            IF(TL.Case__c != NULL) {
                CaseIds.add(TL.Case__c);
                IF(TL.Case__r.ParentId != NULL) {
                    CaseIds.add(TL.Case__r.ParentId);
                }
            }
        }
    }
    
    IF(CaseIds.size() > 0){
       
       TimeLogs = [SELECT Id, Case__c, Case__r.ParentId, Duration_Minutes__c, Billable_Time__c FROM Time_Log__c WHERE Case__c IN :CaseIds];
       IF(TimeLogs.size() > 0){
           FOR(Time_Log__c TL : TimeLogs) {
               IF (TL.Case__r.ParentId != NULL) {
                   CaseIds.add(TL.Case__r.ParentId);
               }
           }
       }
       TimeLogs = [SELECT Id, Case__c, Case__r.ParentId, Duration_Minutes__c, Billable_Time__c FROM Time_Log__c WHERE Case__c IN :CaseIds];
       Cases = [SELECT Id, Case_Time_Logged__c, ParentId, Hierarchical_Time_Logged__c FROM Case WHERE Id IN :CaseIds];
    }
    
    
    
    IF(Cases.size() > 0 && TimeLogs.size() > 0) {
        FOR(Case C : Cases) {
            Double CTL = 0;
            FOR (Time_Log__c TL : TimeLogs) {
                IF(TL.Case__c == C.Id) {
                    if (TL.Billable_Time__c != null) {
                        CTL += TL.Billable_Time__c;
                    }
                }
            }
            C.Case_Time_Logged__c = CTL;
        }
    
        FOR(Case P : Cases) {
            Double HTL = 0;
            FOR (Case C : Cases) {
                System.Debug('PARENT ID ####### ' + C.ParentId);
                System.Debug('CASE ID ####### ' + P.Id);
                System.Debug('CTL ####### ' + C.Case_Time_Logged__c);
                IF (C.ParentId == P.Id) {
                    HTL += C.Case_Time_Logged__c;
                }
            }
            P.Hierarchical_Time_Logged__c = HTL;
        }
        
        Update Cases;
    
    }*/
}