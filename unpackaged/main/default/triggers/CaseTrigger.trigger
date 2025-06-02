/*
*   PURPOSE:        Establishes a trigger framework for the Case object.
                    Extension of TriggerHandler.class (virtual class) methods occurs
                    in TriggerHandlerCase.class
*   INTERFACES:     See specific method descriptions TriggerHandlerCase.class.
*/
trigger CaseTrigger on Case ( before insert,
                              before update,
                              before delete,
                              after insert,
                              after update,
                              after delete,
                              after undelete ) {

    new TriggerHandlerCase().run();
}