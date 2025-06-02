trigger GeneralPreferenceTrigger on General_Preferences__c ( before insert,
                                                            before update,
                                                            before delete,
                                                            after insert,
                                                            after update,
                                                            after delete,
                                                            after undelete ) {
                                                                
                                                                new TriggerHandlerGeneralPreference().run();
                                                            }