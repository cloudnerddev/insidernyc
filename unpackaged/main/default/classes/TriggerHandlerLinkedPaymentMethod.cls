public  class TriggerHandlerLinkedPaymentMethod extends TriggerHandler {
    
    // Constructor 
    public TriggerHandlerLinkedPaymentMethod() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {
        if(RecursiveTriggerHandler.runOnce()){
            beforeLogic(Trigger.new);
        }
    }
    public override void beforeUpdate() {}
    public override void beforeDelete() {}
    public override void afterInsert() {}
    public override void afterUpdate()  {}
    public override void afterDelete()  {}
    public override void afterUndelete() {}
    
    private void beforeLogic(List<sObject> newLinkedPMs){
        system.debug('beforeLogic');
        List<Linked_Payment_Method__c> newLinkedPMList = (List<Linked_Payment_Method__c>) newLinkedPMs;
        List<Payment_Method__c> pmToCreate = new List<Payment_Method__c>();
       
        for(Linked_Payment_Method__c linkedPM : newLinkedPMList){
            system.debug('linkedPM1: ' + linkedPM);
            
            //create new payment method logic
            if (linkedPM.Link_Payment_Method_To__c != NULL) {
                for (Payment_Method__c fromPM : [SELECT Active__c,Billing_Zip_Code__c,ClientAccount__c,Client__c,Credit_Card_Address__c,Credit_Card_Number_Encrypted__c,Description__c,Employee__c,Expiration_Month__c,Expiration_Year__c,Id,Inactive_Reason__c,Last_4_Digits_Credit_Card__c,Primary__c,Retainer_Payment__c,Security_Code__c,Type__c,Payment_Type__c 
                                                 FROM Payment_Method__c
                                                 WHERE Id = :linkedPM.Linked_Payment_Method_From__c LIMIT 1]) {
                                                     Payment_Method__c newPM = new Payment_Method__c();
                                                     newPM.Client__c = linkedPM.Link_Payment_Method_To__c;
                                                     newPM.ClientAccount__c = fromPM.ClientAccount__c;
                                                     newPM.Active__c = fromPM.Active__c;
                                                     newPM.Billing_Zip_Code__c = fromPM.Billing_Zip_Code__c;
                                                     newPM.Credit_Card_Address__c = fromPM.Credit_Card_Address__c;
                                                     newPM.Credit_Card_Number_Encrypted__c = fromPM.Credit_Card_Number_Encrypted__c;
                                                     newPM.Description__c = fromPM.Description__c;
                                                     newPM.Employee__c = fromPM.Employee__c;
                                                     newPM.Expiration_Month__c = fromPM.Expiration_Month__c;
                                                     newPM.Expiration_Year__c = fromPM.Expiration_Year__c;
                                                     newPM.Inactive_Reason__c = fromPM.Inactive_Reason__c;
                                                     newPM.Primary__c = fromPM.Primary__c;
                                                     newPM.Retainer_Payment__c = fromPM.Retainer_Payment__c;
                                                     newPM.Security_Code__c = fromPM.Security_Code__c;
                                                     newPM.Type__c = fromPM.Type__c;
                                                     newPM.Payment_Type__c = fromPM.Payment_Type__c;
                                                     insert newPM; 
                                                     system.debug('newPM: ' + newPM);
                                                     linkedPM.Linked_Payment_Method_To__c = newPM.Id;
                                                     system.debug('newPM2: ' + newPM);
                                                 }
            } else if (linkedPM.Linked_Payment_Method_To__c != NULL) { //link to existing pm logic so sync
                for (Payment_Method__c fromPM : [SELECT Active__c,Billing_Zip_Code__c,ClientAccount__c,Client__c,Credit_Card_Address__c,Credit_Card_Number_Encrypted__c,Description__c,Employee__c,Expiration_Month__c,Expiration_Year__c,Id,Inactive_Reason__c,Last_4_Digits_Credit_Card__c,Primary__c,Retainer_Payment__c,Security_Code__c,Type__c,Payment_Type__c
                                                 FROM Payment_Method__c
                                                 WHERE Id = :linkedPM.Linked_Payment_Method_From__c LIMIT 1]) {
                                                     Payment_Method__c syncPM = new Payment_Method__c(Id = linkedPM.Linked_Payment_Method_To__c);
                                                     syncPM.Active__c = fromPM.Active__c;
                                                     syncPM.Billing_Zip_Code__c = fromPM.Billing_Zip_Code__c;
                                                     syncPM.Credit_Card_Address__c = fromPM.Credit_Card_Address__c;
                                                     syncPM.Credit_Card_Number_Encrypted__c = fromPM.Credit_Card_Number_Encrypted__c;
                                                     syncPM.Description__c = fromPM.Description__c;
                                                     syncPM.Employee__c = fromPM.Employee__c;
                                                     syncPM.Expiration_Month__c = fromPM.Expiration_Month__c;
                                                     syncPM.Expiration_Year__c = fromPM.Expiration_Year__c;
                                                     syncPM.Inactive_Reason__c = fromPM.Inactive_Reason__c;
                                                     syncPM.Primary__c = fromPM.Primary__c;
                                                     syncPM.Retainer_Payment__c = fromPM.Retainer_Payment__c;
                                                     syncPM.Security_Code__c = fromPM.Security_Code__c;
                                                     syncPM.Type__c = fromPM.Type__c;
                                                     syncPM.Payment_Type__c = fromPM.Payment_Type__c;
                                                     RecursiveTriggerHandler.isFirstTime = TRUE;
                                                     update syncPM; 
                                                     system.debug('syncPM: ' + syncPM);
                                                 }
            }
        }
    }
}