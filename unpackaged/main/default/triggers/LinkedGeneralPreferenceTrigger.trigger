trigger LinkedGeneralPreferenceTrigger on Linked_General_Preference__c ( before insert,
                                                                        before update,
                                                                        before delete,
                                                                        after insert,
                                                                        after update,
                                                                        after delete,
                                                                        after undelete ) {
                                                                            
                                                                            new TriggerHandlerLinkedGeneralPreference().run();
                                                                        }