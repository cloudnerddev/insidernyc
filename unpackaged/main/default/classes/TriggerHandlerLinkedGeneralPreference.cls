public  class TriggerHandlerLinkedGeneralPreference extends TriggerHandler {
    
    // Constructor 
    public TriggerHandlerLinkedGeneralPreference() {}
    
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
    
    private void beforeLogic(List<sObject> newLinkedGeneralPreferences){
        system.debug('beforeLogic');
        List<Linked_General_Preference__c> newLinkedGeneralPreferenceList = (List<Linked_General_Preference__c>) newLinkedGeneralPreferences;
       
        for(Linked_General_Preference__c linkedGp : newLinkedGeneralPreferenceList){
            system.debug('linkedGp1: ' + linkedGp);
            
            //Create new general preference logic
            if (linkedGp.Link_General_Preference_To__c != NULL) {
                for (General_Preferences__c fromGp : [SELECT Id,Account_Number__c,Airline_Seat_Preference__c,Avid_Wine_Collector__c,Car_Rental_Preferences__c,Gym__c,Member_of_Social_or_Athletic_Club__c,Notes_Summary__c,Notes__c,Password__c,Preferred_Means_of_Air_Travel__c,
                                                      Preferred_Seating_Class__c,RecordTypeId,Repeat_Orders__c,Room_Preference__c,Season_Ticket_Holder__c,Security_Q_A__c,Sports_Played__c,Status__c,Sub_Type__c,Type__c,Username__c,Vacation_Locale_Preference__c,Preferred_Vendor__c,
                                                      Wine_Cellar__c
                                                      FROM General_Preferences__c 
                                                      WHERE Id = :linkedGp.Linked_General_Preference_From__c LIMIT 1]) {
                                                          General_Preferences__c newGp = new General_Preferences__c();
                                                          newGp.Contact_Name__c = linkedGp.Link_General_Preference_To__c;
                                                          newGp.Account_Number__c = fromGp.Account_Number__c;
                                                          newGp.Airline_Seat_Preference__c = fromGp.Airline_Seat_Preference__c;
                                                          newGp.Avid_Wine_Collector__c = fromGp.Avid_Wine_Collector__c;
                                                          newGp.Car_Rental_Preferences__c = fromGp.Car_Rental_Preferences__c;
                                                          newGp.Gym__c = fromGp.Gym__c;
                                                          newGp.Member_of_Social_or_Athletic_Club__c = fromGp.Member_of_Social_or_Athletic_Club__c;
                                                          newGp.Notes_Summary__c = fromGp.Notes_Summary__c;
                                                          newGp.Notes__c = fromGp.Notes__c;
                                                          newGp.Password__c = fromGp.Password__c;
                                                          newGp.Preferred_Means_of_Air_Travel__c = fromGp.Preferred_Means_of_Air_Travel__c;
                                                          newGp.Preferred_Seating_Class__c = fromGp.Preferred_Seating_Class__c;
                                                          newGp.RecordTypeId = fromGp.RecordTypeId;
                                                          newGp.Repeat_Orders__c = fromGp.Repeat_Orders__c;
                                                          newGp.Room_Preference__c = fromGp.Room_Preference__c;
                                                          newGp.Season_Ticket_Holder__c = fromGp.Season_Ticket_Holder__c;
                                                          newGp.Security_Q_A__c = fromGp.Security_Q_A__c;
                                                          newGp.Sports_Played__c = fromGp.Sports_Played__c;
                                                          newGp.Status__c = fromGp.Status__c;
                                                          newGp.Sub_Type__c = fromGp.Sub_Type__c;
                                                          newGp.Type__c = fromGp.Type__c;
                                                          newGp.Username__c = fromGp.Username__c;
                                                          newGp.Vacation_Locale_Preference__c = fromGp.Vacation_Locale_Preference__c;
                                                          newGp.Preferred_Vendor__c = fromGp.Preferred_Vendor__c;
                                                          newGp.Wine_Cellar__c = fromGp.Wine_Cellar__c;
                                                          insert newGp; 
                                                          system.debug('newGp: ' + newGp);
                                                          linkedGp.Linked_General_Preference_To__c = newGp.Id;
                                                          system.debug('newGp2: ' + newGp);
                                                      }
            } else if (linkedGp.Linked_General_Preference_To__c != NULL) { //link to existing general preference logic so sync
                for (General_Preferences__c fromGp : [SELECT Id,Account_Number__c,Airline_Seat_Preference__c,Avid_Wine_Collector__c,Car_Rental_Preferences__c,Gym__c,Member_of_Social_or_Athletic_Club__c,Notes_Summary__c,Notes__c,Password__c,Preferred_Means_of_Air_Travel__c,
                                                      Preferred_Seating_Class__c,RecordTypeId,Repeat_Orders__c,Room_Preference__c,Season_Ticket_Holder__c,Security_Q_A__c,Sports_Played__c,Status__c,Sub_Type__c,Type__c,Username__c,Vacation_Locale_Preference__c,Preferred_Vendor__c,
                                                      Wine_Cellar__c
                                                      FROM General_Preferences__c 
                                                      WHERE Id = :linkedGp.Linked_General_Preference_From__c LIMIT 1]) {
                                                          General_Preferences__c syncGp = new General_Preferences__c(Id = linkedGp.Linked_General_Preference_To__c);
                                                          syncGp.Account_Number__c = fromGp.Account_Number__c;
                                                          syncGp.Airline_Seat_Preference__c = fromGp.Airline_Seat_Preference__c;
                                                          syncGp.Avid_Wine_Collector__c = fromGp.Avid_Wine_Collector__c;
                                                          syncGp.Car_Rental_Preferences__c = fromGp.Car_Rental_Preferences__c;
                                                          syncGp.Gym__c = fromGp.Gym__c;
                                                          syncGp.Member_of_Social_or_Athletic_Club__c = fromGp.Member_of_Social_or_Athletic_Club__c;
                                                          syncGp.Notes_Summary__c = fromGp.Notes_Summary__c;
                                                          syncGp.Notes__c = fromGp.Notes__c;
                                                          syncGp.Password__c = fromGp.Password__c;
                                                          syncGp.Preferred_Means_of_Air_Travel__c = fromGp.Preferred_Means_of_Air_Travel__c;
                                                          syncGp.Preferred_Seating_Class__c = fromGp.Preferred_Seating_Class__c;
                                                          syncGp.RecordTypeId = fromGp.RecordTypeId;
                                                          syncGp.Repeat_Orders__c = fromGp.Repeat_Orders__c;
                                                          syncGp.Room_Preference__c = fromGp.Room_Preference__c;
                                                          syncGp.Season_Ticket_Holder__c = fromGp.Season_Ticket_Holder__c;
                                                          syncGp.Security_Q_A__c = fromGp.Security_Q_A__c;
                                                          syncGp.Sports_Played__c = fromGp.Sports_Played__c;
                                                          syncGp.Status__c = fromGp.Status__c;
                                                          syncGp.Sub_Type__c = fromGp.Sub_Type__c;
                                                          syncGp.Type__c = fromGp.Type__c;
                                                          syncGp.Username__c = fromGp.Username__c;
                                                          syncGp.Vacation_Locale_Preference__c = fromGp.Vacation_Locale_Preference__c;
                                                          syncGp.Preferred_Vendor__c = fromGp.Preferred_Vendor__c;
                                                          syncGp.Wine_Cellar__c = fromGp.Wine_Cellar__c;
                                                          RecursiveTriggerHandler.isFirstTime = TRUE;
                                                          update syncGp; 
                                                          system.debug('syncGp: ' + syncGp);
                                                      }
            }
        }
    }
}