public class LinkedAddressController {
    @AuraEnabled
    public static List <LinkedAddressWrapper> getLinkedAddresses(Id addressId) {
        system.debug('LinkedAddressController');
        List <LinkedAddressWrapper> linkedAddresses = new List<LinkedAddressWrapper>();
        
        Set<Id> linkedAddressIds = new Set<Id>();
        Set<Id> addressIds = new Set<Id>();
        Set<Id> alreadyLinkedIds = new Set<Id>();

        for (Linked_Address__c la : [SELECT Id,Name,Linked_Between__c,Linked_Address_To__c,Linked_Address_From__c,Linked_Address_From__r.Id,Linked_Address_From__r.Name,Linked_Address_From__r.Contact_Name__c,Linked_Address_To__r.Id,Linked_Address_To__r.Name,Linked_Address_To__r.Contact_Name__c
                                     FROM Linked_Address__c
                                     WHERE Linked_Address_From__c = :addressId OR Linked_Address_To__c = :addressId]) {
                                         linkedAddressIds.add(la.Id);
                                         if (la.Linked_Address_From__c != addressId) {
                                             linkedAddresses.add(new LinkedAddressWrapper(la, la.Linked_Address_From__r.Name, la.Linked_Address_From__r.Id,la.Linked_Address_From__r.Contact_Name__c, '1 - DIRECT'));
                                             alreadyLinkedIds.add(la.Linked_Address_From__r.Id);
                                         } else {
                                             linkedAddresses.add(new LinkedAddressWrapper(la, la.Linked_Address_To__r.Name, la.Linked_Address_To__r.Id,la.Linked_Address_To__r.Contact_Name__c,'1 - DIRECT'));
                                             alreadyLinkedIds.add(la.Linked_Address_To__r.Id);
                                         }
                                         addressIds.add(la.Linked_Address_From__r.Id);
                                         addressIds.add(la.Linked_Address_To__r.Id);
        }
        
        //loop 5 times to get addresses 9 levels deep...
        Integer listSize = addressIds.size();
        for (Integer i = 2; i < 11; i++) {
            System.debug('i: ' + i);
            
            for (Linked_Address__c la : [SELECT Id,Name,Linked_Between__c,Linked_Address_To__c,Linked_Address_From__c,Linked_Address_From__r.Id,Linked_Address_From__r.Name,Linked_Address_From__r.Contact_Name__c,Linked_Address_To__r.Id,Linked_Address_To__r.Name,Linked_Address_To__r.Contact_Name__c
                                         FROM Linked_Address__c
                                         WHERE (Linked_Address_From__c IN :addressIds OR Linked_Address_To__c IN :addressIds) AND Id NOT IN :linkedAddressIds]) {
                                             if (!alreadyLinkedIds.contains(la.Linked_Address_From__r.Id)) {
                                                 linkedAddresses.add(new LinkedAddressWrapper(la, la.Linked_Address_From__r.Name, la.Linked_Address_From__r.Id,la.Linked_Address_From__r.Contact_Name__c, String.valueOf(i) + ' - NON-DIRECT'));
                                             }
                                             if (!alreadyLinkedIds.contains(la.Linked_Address_To__r.Id)) {
                                                 linkedAddresses.add(new LinkedAddressWrapper(la, la.Linked_Address_To__r.Name, la.Linked_Address_To__r.Id,la.Linked_Address_To__r.Contact_Name__c,String.valueOf(i) + ' - NON-DIRECT'));
                                             }
                                             alreadyLinkedIds.add(la.Linked_Address_From__r.Id);
                                             alreadyLinkedIds.add(la.Linked_Address_To__r.Id);
                                             addressIds.add(la.Linked_Address_From__r.Id);
                                             addressIds.add(la.Linked_Address_To__r.Id);
                                         }
            
            //if list didn't increase, means no more linked to find so exit
            if (listSize == addressIds.size()) {
                break;
            } else {
                listSize = addressIds.size();
            }
        }
        /***/
        
        
        
        
        /*for (Linked_Address__c fromAdd : [SELECT Id,Name,Linked_Address_To__c,Linked_Address_From__c,Linked_Address_From__r.Id,Linked_Address_From__r.Name,Linked_Address_From__r.Contact_Name__c
                                          FROM Linked_Address__c
                                          WHERE Linked_Address_To__c = :addressId AND Linked_Address_From__c != :addressId]) {
                                              system.debug('fromAdd: ' + fromAdd);
                                              linkedAddresses.add(new LinkedAddressWrapper(fromAdd, fromAdd.Linked_Address_From__r.Name, fromAdd.Linked_Address_From__r.Id,fromAdd.Linked_Address_From__r.Contact_Name__c));
                                          }
        
        for (Linked_Address__c toAdd : [SELECT Id,Name,Linked_Address_From__c,Linked_Address_To__c,Linked_Address_To__r.Id,Linked_Address_To__r.Name,Linked_Address_To__r.Contact_Name__c
                                        FROM Linked_Address__c
                                        WHERE Linked_Address_From__c = :addressId AND Linked_Address_To__c != :addressId]) {
                                            system.debug('toAdd: ' + toAdd);
                                            linkedAddresses.add(new LinkedAddressWrapper(toAdd, toAdd.Linked_Address_To__r.Name, toAdd.Linked_Address_To__r.Id,toAdd.Linked_Address_To__r.Contact_Name__c));
                                        }
        system.debug('linkedAddresses: ' + linkedAddresses);*/

        return linkedAddresses;
    }
    
    public class LinkedAddressWrapper {
        @AuraEnabled
        public Linked_Address__c rec {get; set;}
        @AuraEnabled
        public String address {get; set;}
        @AuraEnabled
        public Id addressId {get; set;}
        @AuraEnabled
        public Id contactId {get; set;}
        @AuraEnabled
        public String syncLevel {get;set;}
        @AuraEnabled
        public Integer linkBetween {get;set;}
        
        public LinkedAddressWrapper(Linked_Address__c rec, String address, Id addressId, Id contactId, String syncLevel) {     
            this.rec = rec;
            this.address = address;
            this.addressId = addressId;
            this.contactId = contactId;
            this.syncLevel = syncLevel;
        }
    }
}