trigger LinkedHateTrigger on Linked_Hate__c ( before insert,
                                             before update,
                                             before delete,
                                             after insert,
                                             after update,
                                             after delete,
                                             after undelete ) {
                                                 
                                                 new TriggerHandlerLinkedHate().run();
                                             }