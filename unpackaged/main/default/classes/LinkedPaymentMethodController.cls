public class LinkedPaymentMethodController {
    @AuraEnabled
    public static List <PaymentMethodWrapper> getLinkedPaymentMethods(Id paymentMethodId) {
        system.debug('LinkedPaymentMethodController');
        List <PaymentMethodWrapper> linkedPaymentMethods = new List<PaymentMethodWrapper>();
        
        Set<Id> linkedPaymentMethodIds = new Set<Id>();
        Set<Id> paymentMethodIds = new Set<Id>();
        Set<Id> alreadyLinkedIds = new Set<Id>();
        
        for (Linked_Payment_Method__c lpm : [SELECT Id,Name,Linked_Between__c,Linked_Payment_Method_To__c,Linked_Payment_Method_From__c,Linked_Payment_Method_From__r.Id,Linked_Payment_Method_From__r.Name,Linked_Payment_Method_From__r.Client__c,Linked_Payment_Method_To__r.Id,Linked_Payment_Method_To__r.Name,Linked_Payment_Method_To__r.Client__c
                                             FROM Linked_Payment_Method__c
                                             WHERE Linked_Payment_Method_From__c = :paymentMethodId OR Linked_Payment_Method_To__c = :paymentMethodId]) {
                                                 linkedPaymentMethodIds.add(lpm.Id);
                                                 if (lpm.Linked_Payment_Method_From__c != paymentMethodId) {
                                                     linkedPaymentMethods.add(new PaymentMethodWrapper(lpm, lpm.Linked_Payment_Method_From__r.Name, lpm.Linked_Payment_Method_From__r.Id, lpm.Linked_Payment_Method_From__r.Client__c, '1 - DIRECT'));
                                                     alreadyLinkedIds.add(lpm.Linked_Payment_Method_From__r.Id);
                                                 } else {
                                                     linkedPaymentMethods.add(new PaymentMethodWrapper(lpm, lpm.Linked_Payment_Method_To__r.Name, lpm.Linked_Payment_Method_To__r.Id, lpm.Linked_Payment_Method_To__r.Client__c, '1 - DIRECT'));
                                                     alreadyLinkedIds.add(lpm.Linked_Payment_Method_To__r.Id);
                                                 }
                                                 paymentMethodIds.add(lpm.Linked_Payment_Method_From__r.Id);
                                                 paymentMethodIds.add(lpm.Linked_Payment_Method_To__r.Id);
                                             }
        
        //loop 5 times to get addresses 9 levels deep...
        Integer listSize = paymentMethodIds.size();
        for (Integer i = 2; i < 11; i++) {
            System.debug('i: ' + i);
            
            for (Linked_Payment_Method__c lpm : [SELECT Id,Name,Linked_Between__c,Linked_Payment_Method_To__c,Linked_Payment_Method_From__c,Linked_Payment_Method_From__r.Id,Linked_Payment_Method_From__r.Name,Linked_Payment_Method_From__r.Client__c,Linked_Payment_Method_To__r.Id,Linked_Payment_Method_To__r.Name,Linked_Payment_Method_To__r.Client__c
                                                 FROM Linked_Payment_Method__c
                                                 WHERE (Linked_Payment_Method_From__c IN :paymentMethodIds OR Linked_Payment_Method_To__c IN :paymentMethodIds) AND Id NOT IN :linkedPaymentMethodIds]) {
                                                     if (!alreadyLinkedIds.contains(lpm.Linked_Payment_Method_From__r.Id)) {
                                                         linkedPaymentMethods.add(new PaymentMethodWrapper(lpm, lpm.Linked_Payment_Method_From__r.Name, lpm.Linked_Payment_Method_From__r.Id, lpm.Linked_Payment_Method_From__r.Client__c, String.valueOf(i) + ' - NON-DIRECT'));
                                                     }
                                                     if (!alreadyLinkedIds.contains(lpm.Linked_Payment_Method_To__r.Id)) {
                                                         linkedPaymentMethods.add(new PaymentMethodWrapper(lpm, lpm.Linked_Payment_Method_To__r.Name, lpm.Linked_Payment_Method_To__r.Id, lpm.Linked_Payment_Method_To__r.Client__c, String.valueOf(i) + ' - NON-DIRECT'));
                                                     }
                                                     alreadyLinkedIds.add(lpm.Linked_Payment_Method_From__r.Id);
                                                     alreadyLinkedIds.add(lpm.Linked_Payment_Method_To__r.Id);
                                                     paymentMethodIds.add(lpm.Linked_Payment_Method_From__r.Id);
                                                     paymentMethodIds.add(lpm.Linked_Payment_Method_To__r.Id);
                                                 }
            
            //if list didn't increase, means no more linked to find so exit
            if (listSize == paymentMethodIds.size()) {
                break;
            } else {
                listSize = paymentMethodIds.size();
            }
        }
        return linkedPaymentMethods;
    }
    
    public class PaymentMethodWrapper {
        @AuraEnabled
        public Linked_Payment_Method__c rec {get; set;}
        @AuraEnabled
        public String paymentMethod {get; set;}
        @AuraEnabled
        public Id paymentMethodId {get; set;}
        @AuraEnabled
        public Id contactId {get; set;}
        @AuraEnabled
        public String syncLevel {get;set;}
        @AuraEnabled
        public Integer linkBetween {get;set;}
        
        public PaymentMethodWrapper(Linked_Payment_Method__c rec, String paymentMethod, Id paymentMethodId, Id contactId, String syncLevel) {     
            this.rec = rec;
            this.paymentMethod = paymentMethod;
            this.paymentMethodId = paymentMethodId;
            this.contactId = contactId;
            this.syncLevel = syncLevel;
        }
    }
}