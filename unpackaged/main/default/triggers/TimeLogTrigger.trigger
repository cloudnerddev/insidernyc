/*
*   PURPOSE:        Establishes a trigger framework for the Time_Log__c object.
                    Extension of TriggerHandler.class (virtual class) methods occurs
                    in TriggerHandlerTimeLog.class
*   INTERFACES:     See specific method descriptions TriggerHandlerTimeLog.class.
*/
trigger TimeLogTrigger on Time_Log__c ( 
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete ) {

    new TriggerHandlerTimeLog().run();
}