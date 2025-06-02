global class MonthlyBillingBatch implements Database.Batchable<sObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
      
        return Database.getQueryLocator([SELECT Id, Name, Next_Billing_Scheduled__c FROM Account WHERE RecordTypeID = '0120b000000UmtNAAS' AND Account_Status__c = 'Client']);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> account) {
        // List to hold the Opportunities to be updated.
        List<Account> acctsToUpdate = new List<Account>();
        for(Account acc : account) {
            acc.Next_Billing_Scheduled__c = True; 
            acctsToUpdate.add(acc);
        }
        
       

        // Perform the update.
        update acctsToUpdate;
    }
    
    global void finish(Database.BatchableContext BC) {
        // You can perform any post-processing here if needed.
    }
    
    global void execute(SchedulableContext SC) {
        MonthlyBillingBatch batchJob = new MonthlyBillingBatch();
        Database.executeBatch(batchJob,20); // Batch size is 20
    }
}