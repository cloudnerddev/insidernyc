public class LinkedHateController {
    @AuraEnabled
    public static List <LinkedHateWrapper> getLinkedHates(Id hateId) {
        system.debug('LinkedHateController');
        List <LinkedHateWrapper> linkedHates = new List<LinkedHateWrapper>();
        
        Set<Id> linkedHateIds = new Set<Id>();
        Set<Id> hateIds = new Set<Id>();
        Set<Id> alreadyLinkedIds = new Set<Id>();
        
        for (Linked_Hate__c lh : [SELECT Id,Name,Linked_Between__c,Linked_Hate_To__c,Linked_Hate_From__c,Linked_Hate_From__r.Id,Linked_Hate_From__r.Name,Linked_Hate_From__r.Contact_Name__c,Linked_Hate_From__r.Contact_Name__r.Full_Name__c,
                                  Linked_Hate_To__r.Id,Linked_Hate_To__r.Name,Linked_Hate_To__r.Contact_Name__c,Linked_Hate_To__r.Contact_Name__r.Full_Name__c
                                  FROM Linked_Hate__c
                                  WHERE Linked_Hate_From__c = :hateId OR Linked_Hate_To__c = :hateId]) {
                                      linkedHateIds.add(lh.Id);
                                      if (lh.Linked_Hate_From__c != hateId) {
                                          linkedHates.add(new LinkedHateWrapper(lh, lh.Linked_Hate_From__r.Name, lh.Linked_Hate_From__r.Id,lh.Linked_Hate_From__r.Contact_Name__c,lh.Linked_Hate_From__r.Contact_Name__r.Full_Name__c, '1 - DIRECT'));
                                          alreadyLinkedIds.add(lh.Linked_Hate_From__r.Id);
                                      } else {
                                          linkedHates.add(new LinkedHateWrapper(lh, lh.Linked_Hate_To__r.Name, lh.Linked_Hate_To__r.Id,lh.Linked_Hate_To__r.Contact_Name__c,lh.Linked_Hate_To__r.Contact_Name__r.Full_Name__c,'1 - DIRECT'));
                                          alreadyLinkedIds.add(lh.Linked_Hate_To__r.Id);
                                      }
                                      hateIds.add(lh.Linked_Hate_From__r.Id);
                                      hateIds.add(lh.Linked_Hate_To__r.Id);
                                  }
        
        //loop 5 times to get hates 9 levels deep...
        Integer listSize = hateIds.size();
        for (Integer i = 2; i < 11; i++) {
            System.debug('i: ' + i);
            
            for (Linked_Hate__c lh : [SELECT Id,Name,Linked_Between__c,Linked_Hate_To__c,Linked_Hate_From__c,Linked_Hate_From__r.Id,Linked_Hate_From__r.Name,Linked_Hate_From__r.Contact_Name__c,Linked_Hate_From__r.Contact_Name__r.Full_Name__c,
                                      Linked_Hate_To__r.Id,Linked_Hate_To__r.Name,Linked_Hate_To__r.Contact_Name__c,Linked_Hate_To__r.Contact_Name__r.Full_Name__c
                                      FROM Linked_Hate__c
                                      WHERE (Linked_Hate_From__c IN :hateIds OR Linked_Hate_To__c IN :hateIds) AND Id NOT IN :linkedHateIds]) {
                                          if (!alreadyLinkedIds.contains(lh.Linked_Hate_From__r.Id)) {
                                              linkedHates.add(new LinkedHateWrapper(lh, lh.Linked_Hate_From__r.Name, lh.Linked_Hate_From__r.Id,lh.Linked_Hate_From__r.Contact_Name__c,lh.Linked_Hate_From__r.Contact_Name__r.Full_Name__c,String.valueOf(i) + ' - NON-DIRECT'));
                                          }
                                          if (!alreadyLinkedIds.contains(lh.Linked_Hate_To__r.Id)) {
                                              linkedHates.add(new LinkedHateWrapper(lh, lh.Linked_Hate_To__r.Name, lh.Linked_Hate_To__r.Id,lh.Linked_Hate_To__r.Contact_Name__c,lh.Linked_Hate_To__r.Contact_Name__r.Full_Name__c,String.valueOf(i) + ' - NON-DIRECT'));
                                          }
                                          alreadyLinkedIds.add(lh.Linked_Hate_From__r.Id);
                                          alreadyLinkedIds.add(lh.Linked_Hate_To__r.Id);
                                          hateIds.add(lh.Linked_Hate_From__r.Id);
                                          hateIds.add(lh.Linked_Hate_To__r.Id);
                                      }
            
            //if list didn't increase, means no more linked to find so exit
            if (listSize == hateIds.size()) {
                break;
            } else {
                listSize = hateIds.size();
            }
        }
        return linkedHates;
    }
    
    public class LinkedHateWrapper {
        @AuraEnabled
        public Linked_Hate__c rec {get; set;}
        @AuraEnabled
        public String hate {get; set;}
        @AuraEnabled
        public Id hateId {get; set;}
        @AuraEnabled
        public Id contactId {get; set;}
        @AuraEnabled
        public String contactName {get; set;}
        @AuraEnabled
        public String syncLevel {get;set;}
        @AuraEnabled
        public Integer linkBetween {get;set;}
        
        public LinkedHateWrapper(Linked_Hate__c rec, String hate, Id hateId, Id contactId, String contactName, String syncLevel) {     
            this.rec = rec;
            this.hate = hate;
            this.hateId = hateId;
            this.contactId = contactId;
            this.contactName = contactName;
            this.syncLevel = syncLevel;
        }
    }
}