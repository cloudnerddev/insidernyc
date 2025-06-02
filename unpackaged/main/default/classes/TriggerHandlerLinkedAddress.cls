public  class TriggerHandlerLinkedAddress extends TriggerHandler {
    
    // Constructor 
    public TriggerHandlerLinkedAddress() {}
    
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
    
    private void beforeLogic(List<sObject> newLinkedAddresses){
        system.debug('beforeLogic');
        List<Linked_Address__c> newLinkedAddressList = (List<Linked_Address__c>) newLinkedAddresses;
        List<Address__c> addressesToCreate = new List<Address__c>();
       
        for(Linked_Address__c linkedAdd : newLinkedAddressList){
            system.debug('linkedAdd1: ' + linkedAdd);
            
            //Create new address logic
            if (linkedAdd.Link_Address_To__c != NULL) {
                for (Address__c fromAdd : [SELECT Address_City__c,Address_Country__c,Address_State__c,Address_Street__c,Address_Zip_Code__c,Cross_Streets__c,Doorman__c,Facility_Manager__c,Id,Neighbourhood__c,Notes__c,Primary__c,Type__c,Inactive_Reason__c 
                                           FROM Address__c 
                                           WHERE Id = :linkedAdd.Linked_Address_From__c LIMIT 1]) {
                                               Address__c newAdd = new Address__c();
                                               newAdd.Contact_Name__c = linkedAdd.Link_Address_To__c;
                                               newAdd.Address_City__c = fromAdd.Address_City__c;
                                               newAdd.Address_Country__c = fromAdd.Address_Country__c;
                                               newAdd.Address_State__c = fromAdd.Address_State__c;
                                               newAdd.Address_Street__c = fromAdd.Address_Street__c;
                                               newAdd.Address_Zip_Code__c = fromAdd.Address_Zip_Code__c;
                                               newAdd.Cross_Streets__c = fromAdd.Cross_Streets__c;
                                               newAdd.Doorman__c = fromAdd.Doorman__c;
                                               newAdd.Facility_Manager__c = fromAdd.Facility_Manager__c;
                                               newAdd.Neighbourhood__c = fromAdd.Neighbourhood__c;
                                               newAdd.Notes__c = fromAdd.Notes__c;
                                               newAdd.Primary__c = fromAdd.Primary__c;
                                               newAdd.Type__c = fromAdd.Type__c;
                                               insert newAdd; 
                                               system.debug('newAdd: ' + newAdd);
                                               linkedAdd.Linked_Address_To__c = newAdd.Id;
                                               system.debug('newAdd2: ' + newAdd);
                                           }
            } else if (linkedAdd.Linked_Address_To__c != NULL) { //link to existing address logic so sync
                for (Address__c fromAdd : [SELECT Address_City__c,Address_Country__c,Address_State__c,Address_Street__c,Address_Zip_Code__c,Cross_Streets__c,Doorman__c,Facility_Manager__c,Id,Neighbourhood__c,Notes__c,Primary__c,Type__c,Inactive_Reason__c
                                           FROM Address__c 
                                           WHERE Id = :linkedAdd.Linked_Address_From__c LIMIT 1]) {
                                               Address__c syncAdd = new Address__c(Id = linkedAdd.Linked_Address_To__c);
                                               syncAdd.Address_City__c = fromAdd.Address_City__c;
                                               syncAdd.Address_Country__c = fromAdd.Address_Country__c;
                                               syncAdd.Address_State__c = fromAdd.Address_State__c;
                                               syncAdd.Address_Street__c = fromAdd.Address_Street__c;
                                               syncAdd.Address_Zip_Code__c = fromAdd.Address_Zip_Code__c;
                                               syncAdd.Cross_Streets__c = fromAdd.Cross_Streets__c;
                                               syncAdd.Doorman__c = fromAdd.Doorman__c;
                                               syncAdd.Facility_Manager__c = fromAdd.Facility_Manager__c;
                                               syncAdd.Neighbourhood__c = fromAdd.Neighbourhood__c;
                                               syncAdd.Notes__c = fromAdd.Notes__c;
                                               syncAdd.Primary__c = fromAdd.Primary__c;
                                               syncAdd.Type__c = fromAdd.Type__c;
                                               syncAdd.Inactive_Reason__c = fromAdd.Inactive_Reason__c;
                                               RecursiveTriggerHandler.isFirstTime = TRUE;
                                               update syncAdd; 
                                               system.debug('syncAdd: ' + syncAdd);
                                           }
            }
        }
    }
}