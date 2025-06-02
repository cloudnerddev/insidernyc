trigger InsiderTeamTrigger on Insider_Team__c ( before insert,
                                                            before update,
                                                            before delete,
                                                            after insert,
                                                            after update,
                                                            after delete,
                                                            after undelete ) {
                                                                
                                                                new TriggerHandlerInsiderTeam().run();
                                                            }