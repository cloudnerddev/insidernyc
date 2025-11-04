global class UpdatePrevMonthBillingTotalsBatch implements Database.Batchable<sObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Calculate previous month's first and last day
        Date today = Date.today();
        Date prevMonthFirstDay = Date.newInstance(today.year(), today.month(), 1).addMonths(-1);
        Date prevMonthLastDay = Date.newInstance(prevMonthFirstDay.year(), prevMonthFirstDay.month(), 
                                                 Date.daysInMonth(prevMonthFirstDay.year(), prevMonthFirstDay.month()));
        
        // Query ONLY Monthly Billing records for the previous month
        // Multiple safety filters to prevent wrong records from being updated
        String query = 'SELECT Id, Client_Account__c, Start_Date__c, End_Date__c, ' +
                      'Billable_Time_Logged_MTD_hours__c, Last_Day_of_Month__c ' +
                      'FROM Monthly_Billing__c ' +
                      'WHERE Start_Date__c = :prevMonthFirstDay ' +  // Safety Filter 1
                      'AND Last_Day_of_Month__c = :prevMonthLastDay ' + // Safety Filter 2
                      'AND Client_Account__c != null';  // Safety Filter 3
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Monthly_Billing__c> scope) {
        // Get all Account IDs from this batch
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Monthly_Billing__c> accountToMonthlyBilling = new Map<Id, Monthly_Billing__c>();
        
        for(Monthly_Billing__c mb : scope) {
            accountIds.add(mb.Client_Account__c);
            accountToMonthlyBilling.put(mb.Client_Account__c, mb);
        }
        
        // Calculate date range for PREVIOUS MONTH only (extra safety)
        Date today = Date.today();
        Date prevMonthFirstDay = Date.newInstance(today.year(), today.month(), 1).addMonths(-1);
        Date prevMonthLastDay = Date.newInstance(prevMonthFirstDay.year(), prevMonthFirstDay.month(), 
                                                 Date.daysInMonth(prevMonthFirstDay.year(), prevMonthFirstDay.month()));
        
        // Query time logs for previous month for these accounts
        List<Time_Log__c> timeLogs = [
            SELECT Id, Client__c, Billable_Time__c, Date_Logged__c
            FROM Time_Log__c
            WHERE Client__c IN :accountIds
            AND Date_Logged__c >= :prevMonthFirstDay
            AND Date_Logged__c <= :prevMonthLastDay
        ];
        
        // Calculate totals per account
        Map<Id, Decimal> accountTotals = new Map<Id, Decimal>();
        for(Id accId : accountIds) {
            accountTotals.put(accId, 0);
        }
        
        for(Time_Log__c tl : timeLogs) {
            if(tl.Billable_Time__c != null) {
                Decimal currentTotal = accountTotals.get(tl.Client__c);
                accountTotals.put(tl.Client__c, currentTotal + tl.Billable_Time__c);
            }
        }
        
        // Update Monthly Billing records with calculated totals
        List<Monthly_Billing__c> monthlyBillingsToUpdate = new List<Monthly_Billing__c>();
        
        for(Id accId : accountTotals.keySet()) {
            if(accountToMonthlyBilling.containsKey(accId)) {
                Monthly_Billing__c mb = accountToMonthlyBilling.get(accId);
                
                // Convert minutes to hours
                Decimal totalMinutes = accountTotals.get(accId);
                Decimal totalHours = totalMinutes / 60;
                
                mb.Billable_Time_Logged_MTD_hours__c = totalHours.setScale(2);
                monthlyBillingsToUpdate.add(mb);
                
                System.debug('Updating Previous Month Billing ' + mb.Id + ' for Account ' + accId + 
                           ' with ' + totalHours + ' hours');
            }
        }
        
        if(!monthlyBillingsToUpdate.isEmpty()) {
            try {
                update monthlyBillingsToUpdate;
                System.debug('Successfully updated ' + monthlyBillingsToUpdate.size() + ' Previous Month Billing records');
            } catch(DmlException e) {
                System.debug('Error updating Previous Month Billing records: ' + e.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('UpdatePrevMonthBillingTotalsBatch completed');
    }
    
    // Schedulable interface implementation
    global void execute(SchedulableContext SC) {
        UpdatePrevMonthBillingTotalsBatch batch = new UpdatePrevMonthBillingTotalsBatch();
        Database.executeBatch(batch, 200);
    }
}