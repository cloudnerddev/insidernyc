@isTest
private class MonthlyBillingBatchTest {
    
    @testSetup
    static void setup() {
        // Setup test data
        List<Account> acctsToInsert = new List<Account>();
        
                 
        Account acc1= new Account(
        );
        acc1.Name='Test Name 1';
        acc1.recordTypeId='0120b000000UmtNAAS';
        acc1.Account_Status__c='Client';
        
        insert acc1;
        
        Account acc2= new Account(
        );
        acc2.Name='Test Name 2';
        acc2.recordTypeId='0120b000000UmtNAAS';
        acc2.Account_Status__c='Client';
         
        insert acc2;
        
        Account acc3= new Account(
        );
        acc3.Name='Test Name 3';
        acc3.recordTypeId='0120b000000UmtNAAS';
        acc3.Account_Status__c='Client';
        
        insert acc3;
        
    }
    
    static testMethod void testMonthlyBillingBatch() {
        // Get the Opportunities created in setup method.
        List<Account> accts = [SELECT Id, Name, Next_Billing_Scheduled__c FROM Account];
        
        Test.startTest();
        // Instantiate the batch class and execute it.
        MonthlyBillingBatch batch = new MonthlyBillingBatch();
        Id batchId = Database.executeBatch(batch, 20);
        Test.stopTest();
        
        // Re-query the Opportunities to get the updated StageNames.
        List<Account> updatedAccts = [SELECT Id, Name, Next_Billing_Scheduled__c FROM Account WHERE Id IN: accts];
        
        // Assert that the Opportunities were closed.
        for(Account acc : updatedAccts) {
            System.assertEquals(FALSE, acc.Next_Billing_Scheduled__c, 'Next Billing Scheduled should be FALSE');
        }
    }
    
    static testMethod void testSchedulable() {
        // Schedule the job
        Test.startTest();
        String cronExpression = '0 0 23 * * ?';
        String jobId = System.schedule('Test Monthly Billing Batch Scheduled Job', cronExpression, new MonthlyBillingBatch());
        Test.stopTest();
        
        // Assert that the job has been scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id =: jobId];
        System.assertEquals(cronExpression, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }
}