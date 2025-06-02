public  class TriggerHandlerAccount extends TriggerHandler {
    
    // Constructor 
    public TriggerHandlerAccount() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {
        setReviewDescription(Trigger.new);
    }
    public override void beforeUpdate() {
        setReviewDescription(Trigger.new);
    }
    
    private void setReviewDescription(List<sObject> newAccts ){
        /*public override void beforeDelete() {}
    public override void afterInsert()  {}
    public override void afterUpdate()  {}
    public override void afterDelete()  {}
    public override void afterUndelete(){}*/
        system.debug('setReviewDescription');
        List<Account> newAcctsList = (List<Account>) newAccts;
        
        for(Account acct : newAcctsList){
            if (acct.Zagat_Review__c != NULL) {
                String[] stringSplit = acct.Zagat_Review__c.split('\n');
                String stringBody = acct.Zagat_Review__c.mid(stringSplit[0].length(), acct.Zagat_Review__c.length());

                acct.Review_Description_First_Line__c = stringSplit[0];
                acct.Review_Description_After_First_Line__c = stringBody;
            } else {
                acct.Review_Description_First_Line__c = NULL;
                acct.Review_Description_After_First_Line__c = NULL;
            }
        }
    }
}