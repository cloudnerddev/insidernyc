public  class TriggerHandlerGeneralPreference extends TriggerHandler {
    
    // Constructor 
    public TriggerHandlerGeneralPreference() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {}
    public override void beforeUpdate() {}
    public override void beforeDelete() {}
    public override void afterInsert()  {}
    public override void afterUpdate()  {
        if(RecursiveTriggerHandler.runOnce()){
            syncGeneralPreferences(Trigger.new);
        }
    }
    public override void afterDelete()  {
    }
    public override void afterUndelete(){
    }
    
    private void syncGeneralPreferences(List<sObject> newGeneralPreferences){
        system.debug('syncGeneralPreferences');
        List<General_Preferences__c> newGeneralPreferenceList = (List<General_Preferences__c>) newGeneralPreferences;
        List<General_Preferences__c> generalPreferencesToUpdate = new List<General_Preferences__c>();
                
        for(General_Preferences__c primaryGeneralPreference : newGeneralPreferenceList){
            system.debug('Sync From GeneralPreferences');
            Set<Id> linkedGeneralPreferenceIds = new Set<Id>();
            Set<Id> generalPreferenceIds = new Set<Id>();
            
            for (Linked_General_Preference__c lgp : [SELECT Id, Linked_General_Preference_From__r.Id, Linked_General_Preference_To__r.Id FROM Linked_General_Preference__c WHERE Linked_General_Preference_From__c = :primaryGeneralPreference.Id OR Linked_General_Preference_To__c = :primaryGeneralPreference.Id]) {
                linkedGeneralPreferenceIds.add(lgp.Id);
                generalPreferenceIds.add(lgp.Linked_General_Preference_From__r.Id);
                generalPreferenceIds.add(lgp.Linked_General_Preference_To__r.Id);
            }
            
            //loop to get generalPreferences 9 levels deep...
            Integer listSize = generalPreferenceIds.size();
            for (Integer i = 0; i < 9; i++) {
                System.debug('i: ' + i);
                
                for (Linked_General_Preference__c lgp : [SELECT Id, Linked_General_Preference_From__r.Id, Linked_General_Preference_To__r.Id FROM Linked_General_Preference__c WHERE Linked_General_Preference_From__c IN :generalPreferenceIds OR Linked_General_Preference_To__c IN :generalPreferenceIds]) {
                    linkedGeneralPreferenceIds.add(lgp.Id);
                    generalPreferenceIds.add(lgp.Linked_General_Preference_From__r.Id);
                    generalPreferenceIds.add(lgp.Linked_General_Preference_To__r.Id);
                }
                
                //if list didn't increase, means no more generalPreferences to find so exit
                if (listSize == generalPreferenceIds.size()) {
                    break;
                } else {
                    listSize = generalPreferenceIds.size();
                }
            }
            
            system.debug('primaryGeneralPreference: ' + primaryGeneralPreference);
            
            for (Id childGpId : generalPreferenceIds) {
                if (childGpId == primaryGeneralPreference.Id) {
                    continue;
                } else {
                    General_Preferences__c childGeneralPreference = new General_Preferences__c(Id = childGpId);
                    childGeneralPreference.Account_Number__c = primaryGeneralPreference.Account_Number__c;
                    childGeneralPreference.Airline_Seat_Preference__c = primaryGeneralPreference.Airline_Seat_Preference__c;
                    childGeneralPreference.Avid_Wine_Collector__c = primaryGeneralPreference.Avid_Wine_Collector__c;
                    childGeneralPreference.Car_Rental_Preferences__c = primaryGeneralPreference.Car_Rental_Preferences__c;
                    childGeneralPreference.Gym__c = primaryGeneralPreference.Gym__c;
                    childGeneralPreference.Member_of_Social_or_Athletic_Club__c = primaryGeneralPreference.Member_of_Social_or_Athletic_Club__c;
                    childGeneralPreference.Notes_Summary__c = primaryGeneralPreference.Notes_Summary__c;
                    childGeneralPreference.Notes__c = primaryGeneralPreference.Notes__c;
                    childGeneralPreference.Password__c = primaryGeneralPreference.Password__c;
                    childGeneralPreference.Preferred_Means_of_Air_Travel__c = primaryGeneralPreference.Preferred_Means_of_Air_Travel__c;
                    childGeneralPreference.Preferred_Seating_Class__c = primaryGeneralPreference.Preferred_Seating_Class__c;
                    childGeneralPreference.RecordTypeId = primaryGeneralPreference.RecordTypeId;
                    childGeneralPreference.Repeat_Orders__c = primaryGeneralPreference.Repeat_Orders__c;
                    childGeneralPreference.Room_Preference__c = primaryGeneralPreference.Room_Preference__c;
                    childGeneralPreference.Season_Ticket_Holder__c = primaryGeneralPreference.Season_Ticket_Holder__c;
                    childGeneralPreference.Security_Q_A__c = primaryGeneralPreference.Security_Q_A__c;
                    childGeneralPreference.Sports_Played__c = primaryGeneralPreference.Sports_Played__c;
                    childGeneralPreference.Status__c = primaryGeneralPreference.Status__c;
                    childGeneralPreference.Sub_Type__c = primaryGeneralPreference.Sub_Type__c;
                    childGeneralPreference.Type__c = primaryGeneralPreference.Type__c;
                    childGeneralPreference.Username__c = primaryGeneralPreference.Username__c;
                    childGeneralPreference.Vacation_Locale_Preference__c = primaryGeneralPreference.Vacation_Locale_Preference__c;
                    childGeneralPreference.Preferred_Vendor__c = primaryGeneralPreference.Preferred_Vendor__c;
                    childGeneralPreference.Wine_Cellar__c = primaryGeneralPreference.Wine_Cellar__c;
                    generalPreferencesToUpdate.add(childGeneralPreference); 
                }
            }
        }
        
        if (!generalPreferencesToUpdate.isEmpty()) {
            system.debug('generalPreferencesToUpdate: ' + generalPreferencesToUpdate);
            system.debug('generalPreferencesToUpdate.size(): ' + generalPreferencesToUpdate.size());
            update generalPreferencesToUpdate;
        }
    }
}