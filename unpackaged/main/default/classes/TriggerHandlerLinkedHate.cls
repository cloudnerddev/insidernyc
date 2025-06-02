public  class TriggerHandlerLinkedHate extends TriggerHandler {
    
    // Constructor 
    public TriggerHandlerLinkedHate() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {
        if(RecursiveTriggerHandler.runOnce()){
            beforeLogic(Trigger.new);
        }
    }
    public override void beforeUpdate() {}
    public override void beforeDelete() {}
    public override void afterInsert() {}
    public override void afterUpdate() {}
    public override void afterDelete() {}
    public override void afterUndelete() {}
    
    private void beforeLogic(List<sObject> newLinkedHates){
        system.debug('beforeLogic');
        List<Linked_Hate__c> newLinkedHateList = (List<Linked_Hate__c>) newLinkedHates;
        
        for(Linked_Hate__c linkedH : newLinkedHateList){
            system.debug('linkedH1: ' + linkedH);
            
            //Create new general preference logic
            if (linkedH.Link_Hate_To__c != NULL) {
                for (Hates__c fromH : [SELECT Id,Account_Number__c,Airline_Seat_Hate__c,Avid_Wine_Collector__c,Gym__c,Hated__c,Hated_Means_of_Air_Travel__c,Hated_Seating_Class__c,
                                       Member_of_Social_or_Athletic_Club__c,Notes_Summary__c,Notes__c,Password__c,RecordTypeId,Repeat_Orders__c,Room_Hate__c,Season_Ticket_Holder__c,
                                       Security_Q_A__c,Sports_Played__c,Status__c,Sub_Type__c,Support_Line__c,Type__c,Username__c,Vacation_Locale_Hate__c,Hated_Vendor__c,Website__c,
                                       Wine_Cellar__c
                                       FROM Hates__c 
                                       WHERE Id = :linkedH.Linked_Hate_From__c LIMIT 1]) {
                                           Hates__c newH = new Hates__c();
                                           newH.Contact_Name__c = linkedH.Link_Hate_To__c;
                                           newH.Account_Number__c = fromH.Account_Number__c;
                                           newH.Airline_Seat_Hate__c = fromH.Airline_Seat_Hate__c;
                                           newH.Avid_Wine_Collector__c = fromH.Avid_Wine_Collector__c;
                                           newH.Gym__c = fromH.Gym__c;
                                           newH.Hated__c = fromH.Hated__c;
                                           newH.Hated_Means_of_Air_Travel__c = fromH.Hated_Means_of_Air_Travel__c;
                                           newH.Hated_Seating_Class__c = fromH.Hated_Seating_Class__c;
                                           newH.Member_of_Social_or_Athletic_Club__c = fromH.Member_of_Social_or_Athletic_Club__c;
                                           newH.Notes_Summary__c = fromH.Notes_Summary__c;
                                           newH.Notes__c = fromH.Notes__c;
                                           newH.Password__c = fromH.Password__c;
                                           newH.RecordTypeId = fromH.RecordTypeId;
                                           newH.Repeat_Orders__c = fromH.Repeat_Orders__c;
                                           newH.Room_Hate__c = fromH.Room_Hate__c;
                                           newH.Season_Ticket_Holder__c = fromH.Season_Ticket_Holder__c;
                                           newH.Security_Q_A__c = fromH.Security_Q_A__c;
                                           newH.Sports_Played__c = fromH.Sports_Played__c;
                                           newH.Status__c = fromH.Status__c;
                                           newH.Sub_Type__c = fromH.Sub_Type__c;
                                           newH.Support_Line__c = fromH.Support_Line__c;
                                           newH.Type__c = fromH.Type__c;
                                           newH.Username__c = fromH.Username__c;
                                           newH.Vacation_Locale_Hate__c = fromH.Vacation_Locale_Hate__c;
                                           newH.Hated_Vendor__c = fromH.Hated_Vendor__c;
                                           newH.Website__c = fromH.Website__c;
                                           newH.Wine_Cellar__c = fromH.Wine_Cellar__c;
                                           insert newH; 
                                           system.debug('newH: ' + newH);
                                           linkedH.Linked_Hate_To__c = newH.Id;
                                           system.debug('newH2: ' + newH);
                                       }
            } else if (linkedH.Linked_Hate_To__c != NULL) { //link to existing general preference logic so sync
                for (Hates__c fromH : [SELECT Id,Account_Number__c,Airline_Seat_Hate__c,Avid_Wine_Collector__c,Gym__c,Hated__c,Hated_Means_of_Air_Travel__c,Hated_Seating_Class__c,
                                       Member_of_Social_or_Athletic_Club__c,Notes_Summary__c,Notes__c,Password__c,RecordTypeId,Repeat_Orders__c,Room_Hate__c,Season_Ticket_Holder__c,
                                       Security_Q_A__c,Sports_Played__c,Status__c,Sub_Type__c,Support_Line__c,Type__c,Username__c,Vacation_Locale_Hate__c,Hated_Vendor__c,Website__c,
                                       Wine_Cellar__c
                                       FROM Hates__c 
                                       WHERE Id = :linkedH.Linked_Hate_From__c LIMIT 1]) {
                                           Hates__c syncH = new Hates__c(Id = linkedH.Linked_Hate_To__c);
                                           syncH.Account_Number__c = fromH.Account_Number__c;
                                           syncH.Airline_Seat_Hate__c = fromH.Airline_Seat_Hate__c;
                                           syncH.Avid_Wine_Collector__c = fromH.Avid_Wine_Collector__c;
                                           syncH.Gym__c = fromH.Gym__c;
                                           syncH.Hated__c = fromH.Hated__c;
                                           syncH.Hated_Means_of_Air_Travel__c = fromH.Hated_Means_of_Air_Travel__c;
                                           syncH.Hated_Seating_Class__c = fromH.Hated_Seating_Class__c;
                                           syncH.Member_of_Social_or_Athletic_Club__c = fromH.Member_of_Social_or_Athletic_Club__c;
                                           syncH.Notes_Summary__c = fromH.Notes_Summary__c;
                                           syncH.Notes__c = fromH.Notes__c;
                                           syncH.Password__c = fromH.Password__c;
                                           syncH.RecordTypeId = fromH.RecordTypeId;
                                           syncH.Repeat_Orders__c = fromH.Repeat_Orders__c;
                                           syncH.Room_Hate__c = fromH.Room_Hate__c;
                                           syncH.Season_Ticket_Holder__c = fromH.Season_Ticket_Holder__c;
                                           syncH.Security_Q_A__c = fromH.Security_Q_A__c;
                                           syncH.Sports_Played__c = fromH.Sports_Played__c;
                                           syncH.Status__c = fromH.Status__c;
                                           syncH.Sub_Type__c = fromH.Sub_Type__c;
                                           syncH.Support_Line__c = fromH.Support_Line__c;
                                           syncH.Type__c = fromH.Type__c;
                                           syncH.Username__c = fromH.Username__c;
                                           syncH.Vacation_Locale_Hate__c = fromH.Vacation_Locale_Hate__c;
                                           syncH.Hated_Vendor__c = fromH.Hated_Vendor__c;
                                           syncH.Website__c = fromH.Website__c;
                                           syncH.Wine_Cellar__c = fromH.Wine_Cellar__c;
                                           RecursiveTriggerHandler.isFirstTime = TRUE;
                                           update syncH; 
                                           system.debug('syncH: ' + syncH);
                                       }
            }
        }
    }
}