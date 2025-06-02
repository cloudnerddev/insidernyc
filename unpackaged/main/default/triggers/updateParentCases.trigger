trigger updateParentCases on Case (after update, after delete, after undelete) {
    
    /*Set<Id> CaseIds = new Set<Id>();
    List<Case> Cases = new List<Case>();
    List<Time_Log__c> TimeLogs = new List<Time_Log__c>();
    
    IF(Trigger.isUndelete) {
        FOR (Case C : Trigger.new) {
            IF(C.ParentId != NULL) {
                CaseIds.add(C.ParentId);
            }
        }
    }
    IF(Trigger.isDelete) {
        FOR (Case C : Trigger.old) {
            IF(C.ParentId != NULL) {
                CaseIds.add(C.ParentId);
            }
        }
    }
    IF(Trigger.isUpdate) {
        FOR (Case CN : Trigger.new) {
            FOR (Case CO : Trigger.old) {
                IF (CN.Id == CO.Id) {
                    IF (CN.ParentId != CO.ParentId) {
                        IF (CN.ParentId != NULL) {
                            CaseIds.add(CN.ParentId);
                        }
                        IF (CO.ParentId != NULL) {
                            CaseIds.add(CO.ParentId);
                        }
                    }
                }
            }
        }
    }
    
    IF(CaseIds.size() > 0){
       Cases = [SELECT Id, Case_Time_Logged__c, ParentId, Hierarchical_Time_Logged__c FROM Case WHERE ParentId IN :CaseIds OR Id IN :CaseIds];
    }
    
    IF(Cases.size() > 0) {
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