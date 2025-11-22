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
    
    public override void afterUpdate() {
        syncOverhoursFieldsToMonthlyBilling(Trigger.new, Trigger.oldMap);
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
    
    private void syncOverhoursFieldsToMonthlyBilling(List<sObject> newAccounts, Map<Id, sObject> oldMap) {
        List<Account> accountsToProcess = new List<Account>();
        Map<Id, Account> oldAccountsMap = (Map<Id, Account>) oldMap;
        
        // Identify accounts where any of the overhours fields have changed
        for(Account newAcct : (List<Account>) newAccounts) {
            Account oldAcct = oldAccountsMap.get(newAcct.Id);
            
            // Check if any of the fields have changed
            if (oldAcct != null && (
                newAcct.Date_Warned__c != oldAcct.Date_Warned__c ||
                newAcct.Warned_By__c != oldAcct.Warned_By__c ||
                newAcct.Overhours_Notes__c != oldAcct.Overhours_Notes__c ||
                newAcct.In_Case_of_Emergency_Overhours_Notes__c != oldAcct.In_Case_of_Emergency_Overhours_Notes__c ||
                newAcct.Not_Warning__c != oldAcct.Not_Warning__c ||
                newAcct.Holding_Off__c != oldAcct.Holding_Off__c ||
                newAcct.Free_Credit_Notice_Date__c != oldAcct.Free_Credit_Notice_Date__c
            )) {
                accountsToProcess.add(newAcct);
            }
        }
        
        if (accountsToProcess.isEmpty()) {
            return;
        }
        
        // Calculate current month's date range
        Date today = Date.today();
        Date firstDayOfMonth = Date.newInstance(today.year(), today.month(), 1);
        Date lastDayOfMonth = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));
        
        // Get Account IDs
        Set<Id> accountIds = new Set<Id>();
        for(Account acct : accountsToProcess) {
            accountIds.add(acct.Id);
        }
        
        // Query for current month's Monthly Billing records
        List<Monthly_Billing__c> monthlyBillings = [
            SELECT Id, Client_Account__c, Start_Date__c, Last_Day_of_Month__c,
                   Date_Warned__c, Warning_Given_By__c, Overhours_Notes__c,
                   In_Case_of_Emergency_Overhours_Notes__c, Not_Warning__c, Holding_Off__c,
                   Free_Credit_Notice_Date__c
            FROM Monthly_Billing__c
            WHERE Client_Account__c IN :accountIds
            AND Start_Date__c = :firstDayOfMonth
            AND Last_Day_of_Month__c = :lastDayOfMonth
        ];
        
        // Create a map of Account ID to Monthly Billing
        Map<Id, Monthly_Billing__c> accountToMonthlyBilling = new Map<Id, Monthly_Billing__c>();
        for(Monthly_Billing__c mb : monthlyBillings) {
            accountToMonthlyBilling.put(mb.Client_Account__c, mb);
        }
        
        // Update Monthly Billing records with changed values from Account
        List<Monthly_Billing__c> monthlyBillingsToUpdate = new List<Monthly_Billing__c>();
        
        for(Account acct : accountsToProcess) {
            Monthly_Billing__c mb = accountToMonthlyBilling.get(acct.Id);
            
            if (mb != null) {
                boolean needsUpdate = false;
                Account oldAcct = oldAccountsMap.get(acct.Id);
                
                // Map each field if it changed
                if (acct.Date_Warned__c != oldAcct.Date_Warned__c) {
                    mb.Date_Warned__c = acct.Date_Warned__c;
                    needsUpdate = true;
                }
                
                if (acct.Warned_By__c != oldAcct.Warned_By__c) {
                    mb.Warning_Given_By__c = acct.Warned_By__c;
                    needsUpdate = true;
                }
                
                if (acct.Overhours_Notes__c != oldAcct.Overhours_Notes__c) {
                    mb.Overhours_Notes__c = acct.Overhours_Notes__c;
                    needsUpdate = true;
                }
                
                if (acct.In_Case_of_Emergency_Overhours_Notes__c != oldAcct.In_Case_of_Emergency_Overhours_Notes__c) {
                    mb.In_Case_of_Emergency_Overhours_Notes__c = acct.In_Case_of_Emergency_Overhours_Notes__c;
                    needsUpdate = true;
                }
                
                if (acct.Not_Warning__c != oldAcct.Not_Warning__c) {
                    mb.Not_Warning__c = acct.Not_Warning__c;
                    needsUpdate = true;
                }
                
                if (acct.Holding_Off__c != oldAcct.Holding_Off__c) {
                    mb.Holding_Off__c = acct.Holding_Off__c;
                    needsUpdate = true;
                }
                
                if (acct.Free_Credit_Notice_Date__c != oldAcct.Free_Credit_Notice_Date__c) {
                    mb.Free_Credit_Notice_Date__c = acct.Free_Credit_Notice_Date__c;
                    needsUpdate = true;
                }
                
                if (needsUpdate) {
                    monthlyBillingsToUpdate.add(mb);
                }
            }
        }
        
        // Update Monthly Billing records
        if (!monthlyBillingsToUpdate.isEmpty()) {
            update monthlyBillingsToUpdate;
        }
    }
}