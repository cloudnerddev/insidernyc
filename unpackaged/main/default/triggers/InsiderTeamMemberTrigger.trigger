trigger InsiderTeamMemberTrigger on Insider_Team_Member__c ( before insert,
                                                            before update,
                                                            before delete,
                                                            after insert,
                                                            after update,
                                                            after delete,
                                                            after undelete ) {
                                                                
                                                                new TriggerHandlerInsiderTeamMember().run();
                                                            }