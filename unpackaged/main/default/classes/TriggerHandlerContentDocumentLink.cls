/*
*   PURPOSE:       This class will handle trigger behaviour and will perform task accordingly
*/
public  class TriggerHandlerContentDocumentLink extends TriggerHandler {    
    // Constructor 
    public TriggerHandlerContentDocumentLink() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {
        cdSharing(Trigger.new);
    }
    public override void beforeUpdate() {}
    public override void beforeDelete() {}
    public override void afterInsert()  {}
    public override void afterUpdate()  {}
    public override void afterDelete()  {}
    public override void afterUndelete(){}
    
    private void cdSharing(List<sObject> newCDLs){
        system.debug('cdSharing');
        
        List<ContentDocumentLink> newCDLList = (List<ContentDocumentLink>) newCDLs;
        
        for(ContentDocumentLink cdl : newCDLList){
            //005 - user
            //02s - email message
            if (!String.valueOf(cdl.LinkedEntityId).startsWith('005') && !String.valueOf(cdl.LinkedEntityId).startsWith('02s')) {
                cdl.ShareType = 'I';
            }
        }
    }
}