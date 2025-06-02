/*
*   PURPOSE:        Establishes a trigger framework for the ContentDocumentLink object.
                    Extension of TriggerHandler.class (virtual class) methods occurs
                    in TriggerHandlerContentDocumentLink.class
*   INTERFACES:     See specific method descriptions TriggerHandlerContentDocumentLink.class.
*/
trigger ContentDocumentLinkTrigger on ContentDocumentLink ( before insert,
                              before update,
                              before delete,
                              after insert,
                              after update,
                              after delete,
                              after undelete ) {

    new TriggerHandlerContentDocumentLink().run();
}