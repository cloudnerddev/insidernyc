trigger LinkedAddressTrigger on Linked_Address__c ( before insert,
                                                   before update,
                                                   before delete,
                                                   after insert,
                                                   after update,
                                                   after delete,
                                                   after undelete ) {
                                                       
                                                       new TriggerHandlerLinkedAddress().run();
                                                   }