public class LinkedGeneralPreferenceController {
    @AuraEnabled
    public static List <LinkedGeneralPreferenceWrapper> getLinkedGeneralPreferences(Id generalPreferenceId) {
        system.debug('LinkedGeneralPreferenceController');
        List <LinkedGeneralPreferenceWrapper> linkedGeneralPreferences = new List<LinkedGeneralPreferenceWrapper>();
        
        Set<Id> linkedGeneralPreferenceIds = new Set<Id>();
        Set<Id> generalPreferenceIds = new Set<Id>();
        Set<Id> alreadyLinkedIds = new Set<Id>();
        
        for (Linked_General_Preference__c lgp : [SELECT Id,Name,Linked_Between__c,Linked_General_Preference_To__c,Linked_General_Preference_From__c,Linked_General_Preference_From__r.Id,Linked_General_Preference_From__r.Name,Linked_General_Preference_From__r.Contact_Name__c,Linked_General_Preference_From__r.Contact_Name__r.Full_Name__c,
                                                 Linked_General_Preference_To__r.Id,Linked_General_Preference_To__r.Name,Linked_General_Preference_To__r.Contact_Name__c,Linked_General_Preference_To__r.Contact_Name__r.Full_Name__c
                                                 FROM Linked_General_Preference__c
                                                 WHERE Linked_General_Preference_From__c = :generalPreferenceId OR Linked_General_Preference_To__c = :generalPreferenceId]) {
                                                     linkedGeneralPreferenceIds.add(lgp.Id);
                                                     if (lgp.Linked_General_Preference_From__c != generalPreferenceId) {
                                                         linkedGeneralPreferences.add(new LinkedGeneralPreferenceWrapper(lgp, lgp.Linked_General_Preference_From__r.Name, lgp.Linked_General_Preference_From__r.Id,lgp.Linked_General_Preference_From__r.Contact_Name__c,lgp.Linked_General_Preference_From__r.Contact_Name__r.Full_Name__c, '1 - DIRECT'));
                                                         alreadyLinkedIds.add(lgp.Linked_General_Preference_From__r.Id);
                                                     } else {
                                                         linkedGeneralPreferences.add(new LinkedGeneralPreferenceWrapper(lgp, lgp.Linked_General_Preference_To__r.Name, lgp.Linked_General_Preference_To__r.Id,lgp.Linked_General_Preference_To__r.Contact_Name__c,lgp.Linked_General_Preference_To__r.Contact_Name__r.Full_Name__c,'1 - DIRECT'));
                                                         alreadyLinkedIds.add(lgp.Linked_General_Preference_To__r.Id);
                                                     }
                                                     generalPreferenceIds.add(lgp.Linked_General_Preference_From__r.Id);
                                                     generalPreferenceIds.add(lgp.Linked_General_Preference_To__r.Id);
                                                 }
        
        //loop 5 times to get general preferences 9 levels deep...
        Integer listSize = generalPreferenceIds.size();
        for (Integer i = 2; i < 11; i++) {
            System.debug('i: ' + i);
            
            for (Linked_General_Preference__c lgp : [SELECT Id,Name,Linked_Between__c,Linked_General_Preference_To__c,Linked_General_Preference_From__c,Linked_General_Preference_From__r.Id,Linked_General_Preference_From__r.Name,Linked_General_Preference_From__r.Contact_Name__c,Linked_General_Preference_From__r.Contact_Name__r.Full_Name__c,
                                                     Linked_General_Preference_To__r.Id,Linked_General_Preference_To__r.Name,Linked_General_Preference_To__r.Contact_Name__c,Linked_General_Preference_To__r.Contact_Name__r.Full_Name__c
                                                     FROM Linked_General_Preference__c
                                                     WHERE (Linked_General_Preference_From__c IN :generalPreferenceIds OR Linked_General_Preference_To__c IN :generalPreferenceIds) AND Id NOT IN :linkedGeneralPreferenceIds]) {
                                                         if (!alreadyLinkedIds.contains(lgp.Linked_General_Preference_From__r.Id)) {
                                                             linkedGeneralPreferences.add(new LinkedGeneralPreferenceWrapper(lgp, lgp.Linked_General_Preference_From__r.Name, lgp.Linked_General_Preference_From__r.Id,lgp.Linked_General_Preference_From__r.Contact_Name__c,lgp.Linked_General_Preference_From__r.Contact_Name__r.Full_Name__c,String.valueOf(i) + ' - NON-DIRECT'));
                                                         }
                                                         if (!alreadyLinkedIds.contains(lgp.Linked_General_Preference_To__r.Id)) {
                                                             linkedGeneralPreferences.add(new LinkedGeneralPreferenceWrapper(lgp, lgp.Linked_General_Preference_To__r.Name, lgp.Linked_General_Preference_To__r.Id,lgp.Linked_General_Preference_To__r.Contact_Name__c,lgp.Linked_General_Preference_To__r.Contact_Name__r.Full_Name__c,String.valueOf(i) + ' - NON-DIRECT'));
                                                         }
                                                         alreadyLinkedIds.add(lgp.Linked_General_Preference_From__r.Id);
                                                         alreadyLinkedIds.add(lgp.Linked_General_Preference_To__r.Id);
                                                         generalPreferenceIds.add(lgp.Linked_General_Preference_From__r.Id);
                                                         generalPreferenceIds.add(lgp.Linked_General_Preference_To__r.Id);
                                                     }
            
            //if list didn't increase, means no more linked to find so exit
            if (listSize == generalPreferenceIds.size()) {
                break;
            } else {
                listSize = generalPreferenceIds.size();
            }
        }
        return linkedGeneralPreferences;
    }
    
    public class LinkedGeneralPreferenceWrapper {
        @AuraEnabled
        public Linked_General_Preference__c rec {get; set;}
        @AuraEnabled
        public String generalPreference {get; set;}
        @AuraEnabled
        public Id generalPreferenceId {get; set;}
        @AuraEnabled
        public Id contactId {get; set;}
        @AuraEnabled
        public String contactName {get; set;}
        @AuraEnabled
        public String syncLevel {get;set;}
        @AuraEnabled
        public Integer linkBetween {get;set;}
        
        public LinkedGeneralPreferenceWrapper(Linked_General_Preference__c rec, String generalPreference, Id generalPreferenceId, Id contactId, String contactName, String syncLevel) {     
            this.rec = rec;
            this.generalPreference = generalPreference;
            this.generalPreferenceId = generalPreferenceId;
            this.contactId = contactId;
            this.contactName = contactName;
            this.syncLevel = syncLevel;
        }
    }
}