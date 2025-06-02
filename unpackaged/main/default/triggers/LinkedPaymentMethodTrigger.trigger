trigger LinkedPaymentMethodTrigger on Linked_Payment_Method__c ( before insert,
                                                   before update,
                                                   before delete,
                                                   after insert,
                                                   after update,
                                                   after delete,
                                                   after undelete ) {
                                                       
                                                       new TriggerHandlerLinkedPaymentMethod().run();
                                                   }