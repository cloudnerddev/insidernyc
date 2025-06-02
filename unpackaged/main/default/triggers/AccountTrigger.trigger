trigger AccountTrigger on Account ( before insert,
                              		before update ) {

    new TriggerHandlerAccount().run();
                                        
                                        
                                  /*,
                              before delete,
                              after insert,
                              after update,
                              after delete,
                              after undelete*/
}