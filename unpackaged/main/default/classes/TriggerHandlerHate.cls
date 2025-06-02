public  class TriggerHandlerHate extends TriggerHandler {
    
    // Constructor 
    public TriggerHandlerHate() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {}
    public override void beforeUpdate() {}
    public override void beforeDelete() {}
    public override void afterInsert()  {}
    public override void afterUpdate()  {
        if(RecursiveTriggerHandler.runOnce()){
            syncHates(Trigger.new);
        }
    }
    public override void afterDelete()  {
    }
    public override void afterUndelete(){
    }
    
    private void syncHates(List<sObject> newHates){
        system.debug('syncHates');
        List<Hates__c> newHateList = (List<Hates__c>) newHates;
        List<Hates__c> hatesToUpdate = new List<Hates__c>();
                
        for(Hates__c primaryHate : newHateList){
            system.debug('Sync From Hates');
            Set<Id> linkedHateIds = new Set<Id>();
            Set<Id> hateIds = new Set<Id>();
            
            for (Linked_Hate__c lh : [SELECT Id, Linked_Hate_From__r.Id, Linked_Hate_To__r.Id FROM Linked_Hate__c WHERE Linked_Hate_From__c = :primaryHate.Id OR Linked_Hate_To__c = :primaryHate.Id]) {
                linkedHateIds.add(lh.Id);
                hateIds.add(lh.Linked_Hate_From__r.Id);
                hateIds.add(lh.Linked_Hate_To__r.Id);
            }
            
            //loop to get hates 9 levels deep...
            Integer listSize = hateIds.size();
            for (Integer i = 0; i < 9; i++) {
                System.debug('i: ' + i);
                
                for (Linked_Hate__c lh : [SELECT Id, Linked_Hate_From__r.Id, Linked_Hate_To__r.Id FROM Linked_Hate__c WHERE Linked_Hate_From__c IN :hateIds OR Linked_Hate_To__c IN :hateIds]) {
                    linkedHateIds.add(lh.Id);
                    hateIds.add(lh.Linked_Hate_From__r.Id);
                    hateIds.add(lh.Linked_Hate_To__r.Id);
                }
                
                //if list didn't increase, means no more hates to find so exit
                if (listSize == hateIds.size()) {
                    break;
                } else {
                    listSize = hateIds.size();
                }
            }
            
            system.debug('primaryHate: ' + primaryHate);
            
            for (Id childHId : hateIds) {
                if (childHId == primaryHate.Id) {
                    continue;
                } else {
                    Hates__c childHate = new Hates__c(Id = childHId);
                    childHate.Account_Number__c = primaryHate.Account_Number__c;
                    childHate.Airline_Seat_Hate__c = primaryHate.Airline_Seat_Hate__c;
                    childHate.Avid_Wine_Collector__c = primaryHate.Avid_Wine_Collector__c;
                    childHate.Gym__c = primaryHate.Gym__c;
                    childHate.Hated__c = primaryHate.Hated__c;
                    childHate.Hated_Means_of_Air_Travel__c = primaryHate.Hated_Means_of_Air_Travel__c;
                    childHate.Hated_Seating_Class__c = primaryHate.Hated_Seating_Class__c;
                    childHate.Member_of_Social_or_Athletic_Club__c = primaryHate.Member_of_Social_or_Athletic_Club__c;
                    childHate.Notes_Summary__c = primaryHate.Notes_Summary__c;
                    childHate.Notes__c = primaryHate.Notes__c;
                    childHate.Password__c = primaryHate.Password__c;
                    childHate.RecordTypeId = primaryHate.RecordTypeId;
                    childHate.Repeat_Orders__c = primaryHate.Repeat_Orders__c;
                    childHate.Room_Hate__c = primaryHate.Room_Hate__c;
                    childHate.Season_Ticket_Holder__c = primaryHate.Season_Ticket_Holder__c;
                    childHate.Security_Q_A__c = primaryHate.Security_Q_A__c;
                    childHate.Sports_Played__c = primaryHate.Sports_Played__c;
                    childHate.Status__c = primaryHate.Status__c;
                    childHate.Sub_Type__c = primaryHate.Sub_Type__c;
                    childHate.Support_Line__c = primaryHate.Support_Line__c;
                    childHate.Type__c = primaryHate.Type__c;
                    childHate.Username__c = primaryHate.Username__c;
                    childHate.Vacation_Locale_Hate__c = primaryHate.Vacation_Locale_Hate__c;
                    childHate.Hated_Vendor__c = primaryHate.Hated_Vendor__c;
                    childHate.Website__c = primaryHate.Website__c;
                    childHate.Wine_Cellar__c = primaryHate.Wine_Cellar__c;
                    hatesToUpdate.add(childHate); 
                }
            }
        }
        
        if (!hatesToUpdate.isEmpty()) {
            system.debug('hatesToUpdate: ' + hatesToUpdate);
            system.debug('hatesToUpdate.size(): ' + hatesToUpdate.size());
            update hatesToUpdate;
        }
    }
}