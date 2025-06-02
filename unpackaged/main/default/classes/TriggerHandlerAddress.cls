public  class TriggerHandlerAddress extends TriggerHandler {
    
    // Constructor 
    public TriggerHandlerAddress() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {}
    public override void beforeUpdate() {}
    public override void beforeDelete() {}
    public override void afterInsert()  {}
    public override void afterUpdate()  {
        if(RecursiveTriggerHandler.runOnce()){
            syncAddresses(Trigger.new);
        }
    }
    public override void afterDelete()  {
    }
    public override void afterUndelete(){
    }
    
    private void syncAddresses(List<sObject> newAddresses){
        system.debug('syncAddresses');
        List<Address__c> newAddressList = (List<Address__c>) newAddresses;
        List<Address__c> addressesToUpdate = new List<Address__c>();
                
        for(Address__c primaryAddress : newAddressList){
            system.debug('Sync From Addresses');
            Set<Id> linkedAddressIds = new Set<Id>();
            Set<Id> addressIds = new Set<Id>();
            
            for (Linked_Address__c la : [SELECT Id, Linked_Address_From__r.Id, Linked_Address_To__r.Id FROM Linked_Address__c WHERE Linked_Address_From__c = :primaryAddress.Id OR Linked_Address_To__c = :primaryAddress.Id]) {
                linkedAddressIds.add(la.Id);
                addressIds.add(la.Linked_Address_From__r.Id);
                addressIds.add(la.Linked_Address_To__r.Id);
            }
            
            //loop to get addresses 9 levels deep...
            Integer listSize = addressIds.size();
            for (Integer i = 0; i < 9; i++) {
                System.debug('i: ' + i);
                
                for (Linked_Address__c la : [SELECT Id, Linked_Address_From__r.Id, Linked_Address_To__r.Id FROM Linked_Address__c WHERE Linked_Address_From__c IN :addressIds OR Linked_Address_To__c IN :addressIds]) {
                    linkedAddressIds.add(la.Id);
                    addressIds.add(la.Linked_Address_From__r.Id);
                    addressIds.add(la.Linked_Address_To__r.Id);
                }
                
                //if list didn't increase, means no more addresses to find so exit
                if (listSize == addressIds.size()) {
                    break;
                } else {
                    listSize = addressIds.size();
                }
            }
            
            system.debug('primaryAddress: ' + primaryAddress);
            
            for (Id childAddId : addressIds) {
                if (childAddId == primaryAddress.Id) {
                    continue;
                } else {
                    Address__c childAddress = new Address__c(Id = childAddId);
                    childAddress.Address_City__c = primaryAddress.Address_City__c;
                    childAddress.Address_Country__c = primaryAddress.Address_Country__c;
                    childAddress.Address_State__c = primaryAddress.Address_State__c;
                    childAddress.Address_Street__c = primaryAddress.Address_Street__c;
                    childAddress.Address_Zip_Code__c = primaryAddress.Address_Zip_Code__c;
                    childAddress.Cross_Streets__c = primaryAddress.Cross_Streets__c;
                    childAddress.Doorman__c = primaryAddress.Doorman__c;
                    childAddress.Facility_Manager__c = primaryAddress.Facility_Manager__c;
                    childAddress.Neighbourhood__c = primaryAddress.Neighbourhood__c;
                    childAddress.Notes__c = primaryAddress.Notes__c;
                    childAddress.Primary__c = primaryAddress.Primary__c;
                    childAddress.Type__c = primaryAddress.Type__c;
                    childAddress.Active__c = primaryAddress.Active__c;
                    childAddress.Inactive_Reason__c = primaryAddress.Inactive_Reason__c;
                    addressesToUpdate.add(childAddress); 
                }
            }
        }
        
        if (!addressesToUpdate.isEmpty()) {
            system.debug('addressesToUpdate: ' + addressesToUpdate);
            system.debug('addressesToUpdate.size(): ' + addressesToUpdate.size());
            update addressesToUpdate;
        }
    }
}