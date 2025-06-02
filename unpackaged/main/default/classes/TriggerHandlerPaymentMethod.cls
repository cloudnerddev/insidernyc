public class TriggerHandlerPaymentMethod extends TriggerHandler {
    
    // Constructor 
    public TriggerHandlerPaymentMethod() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {
        setLast4Digits(Trigger.new);
    }
    public override void beforeUpdate() {
        setLast4Digits(Trigger.new);
    }
    public override void beforeDelete() {}
    public override void afterInsert() {}
    public override void afterUpdate()  {
        if(RecursiveTriggerHandler.runOnce()){
            syncPaymentMethods(Trigger.new);
        }
    }
    public override void afterDelete()  {}
    public override void afterUndelete() {}
    
    private void setLast4Digits(List<sObject> newPMs){
        system.debug('setLast4Digits');
        List<Payment_Method__c> newPMList = (List<Payment_Method__c>) newPMs;
        
        for(Payment_Method__c pm : newPMList){
            if (pm.Credit_Card_Number_Encrypted__c!=NULL) {
                pm.Last_4_Digits_Credit_Card__c = pm.Credit_Card_Number_Encrypted__c.right(4);
            } else {
                pm.Last_4_Digits_Credit_Card__c = NULL;
            }

        }
    }
    
    private void syncPaymentMethods(List<sObject> newPMs){
        system.debug('syncPaymentMethods');
        List<Payment_Method__c> newPMList = (List<Payment_Method__c>) newPMs;
        List<Payment_Method__c> pmToUpdate = new List<Payment_Method__c>();
        
        for(Payment_Method__c primaryPM : newPMList){
            system.debug('Sync From Addresses');
            Set<Id> linkedPMIds = new Set<Id>();
            Set<Id> pmIds = new Set<Id>();
            
            for (Linked_Payment_Method__c lpm : [SELECT Id, Linked_Payment_Method_From__r.Id, Linked_Payment_Method_To__r.Id FROM Linked_Payment_Method__c WHERE Linked_Payment_Method_From__c = :primaryPM.Id OR Linked_Payment_Method_To__c = :primaryPM.Id]) {
                linkedPMIds.add(lpm.Id);
                pmIds.add(lpm.Linked_Payment_Method_From__r.Id);
                pmIds.add(lpm.Linked_Payment_Method_To__r.Id);
            }
            
            //loop to get addresses 9 levels deep...
            Integer listSize = pmIds.size();
            for (Integer i = 0; i < 9; i++) {
                System.debug('i: ' + i);
                
                for (Linked_Payment_Method__c lpm : [SELECT Id, Linked_Payment_Method_From__r.Id, Linked_Payment_Method_To__r.Id FROM Linked_Payment_Method__c WHERE Linked_Payment_Method_From__c IN :pmIds OR Linked_Payment_Method_To__c IN :pmIds]) {
                    linkedPMIds.add(lpm.Id);
                    pmIds.add(lpm.Linked_Payment_Method_From__r.Id);
                    pmIds.add(lpm.Linked_Payment_Method_To__r.Id);
                }
                
                //if list didn't increase, means no more addresses to find so exit
                if (listSize == pmIds.size()) {
                    break;
                } else {
                    listSize = pmIds.size();
                }
            }
            
            system.debug('primaryPM: ' + primaryPM);
            
            for (Id childAddId : pmIds) {
                if (childAddId == primaryPM.Id) {
                    continue;
                } else {
                    Payment_Method__c childPM = new Payment_Method__c(Id = childAddId);
                    childPM.Active__c = primaryPM.Active__c;
                    childPM.ClientAccount__c = primaryPM.ClientAccount__c;
                    childPM.Billing_Zip_Code__c = primaryPM.Billing_Zip_Code__c;
                    childPM.Credit_Card_Address__c = primaryPM.Credit_Card_Address__c;
                    childPM.Credit_Card_Number_Encrypted__c = primaryPM.Credit_Card_Number_Encrypted__c;
                    childPM.Description__c = primaryPM.Description__c;
                    childPM.Employee__c = primaryPM.Employee__c;
                    childPM.Expiration_Month__c = primaryPM.Expiration_Month__c;
                    childPM.Expiration_Year__c = primaryPM.Expiration_Year__c;
                    childPM.Inactive_Reason__c = primaryPM.Inactive_Reason__c;
                    childPM.Primary__c = primaryPM.Primary__c;
                    childPM.Retainer_Payment__c = primaryPM.Retainer_Payment__c;
                    childPM.Security_Code__c = primaryPM.Security_Code__c;
                    childPM.Type__c = primaryPM.Type__c;
                    childPM.Payment_Type__c = primaryPM.Payment_Type__c;
                    pmToUpdate.add(childPM); 
                }
            }
        }
        
        if (!pmToUpdate.isEmpty()) {
            system.debug('pmToUpdate: ' + pmToUpdate);
            system.debug('pmToUpdate.size(): ' + pmToUpdate.size());
            update pmToUpdate;
        }
    }
}