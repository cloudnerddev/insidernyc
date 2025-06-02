/*
*   PURPOSE:       This class will handle trigger behaviour and will perform task accordingly
*   INTERFACES:     
*   CHANGE LOG:    27-8-2018    Intial release 
*/
public class TriggerHandlerCase extends TriggerHandler {
    
    // Constructor 
    public TriggerHandlerCase() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {}
    public override void beforeUpdate() {
        //createTimeEntry(Trigger.new);
        setTime(Trigger.new, Trigger.oldMap);
        diningConversion(Trigger.new, Trigger.oldMap);
    }
    public override void beforeDelete() {}
    public override void afterInsert()  {}
    public override void afterUpdate()  {
        updateTimeLogParents(Trigger.new, Trigger.oldMap);
        recalcHierarchyTime(Trigger.new, Trigger.oldMap);
    }
    public override void afterDelete()  {
        recalcHierarchyTime(Trigger.new, Trigger.oldMap);
    }
    public override void afterUndelete(){
        recalcHierarchyTime(Trigger.new, Trigger.oldMap);
    }
    
    /*private void createTimeEntry(List<sObject> newCases){
        system.debug('createTimeEntry');
        List<Case> newCaseList = (List<Case>) newCases;
        List<Time_Log__c> newTimeLogs = new List<Time_Log__c>();

        for(Case cs : newCaseList){
            //oldMap.get(cs.Id).Status
            //cs.Status
            if (cs.Enter_Time__c != NULL) {
                Time_Log__c tl = new Time_Log__c(
                    Case__c = cs.Id,
                    Client__c = cs.AccountId,
                    Contact__c = cs.ContactId,
                    Duration_Minutes__c = cs.Enter_Time__c,
                    Comments__c = cs.Time_Description__c,
                    Date_Logged__c = Date.today(),
                    Multiplier_Reason__c = cs.Multiplier_Reason__c,
                    Multiplier__c = cs.Multiplier__c
                );
                newTimeLogs.add(tl);
                cs.Enter_Time__c = NULL;
                cs.Time_Description__c = NULL;
                cs.Multiplier__c = NULL;
                cs.Multiplier_Reason__c = NULL;
            }
        }
        insert newTimeLogs;
    }*/
    
    private void setTime(List<sObject> newCases , Map<Id,sObject> oldCaseMap){
        system.debug('setTime');
        List<Case> newCaseList = (List<Case>) newCases;
        
        if(oldCaseMap != NULL){
            Map<Id,Case> oldMap = (Map<Id,Case>) oldCaseMap;
            
            for(Case cs : newCaseList){
                if (cs.Flow_Destination_Arrival_Date_Time__c != NULL && cs.Flow_Destination_Arrival_Date_Time__c != oldMap.get(cs.Id).Flow_Destination_Arrival_Date_Time__c) {
                    system.debug('cs.Flow_Destination_Arrival_Date_Time__c: ' + cs.Flow_Destination_Arrival_Date_Time__c); 
                    DateTime convertedDateTime = DateTime.valueOf(cs.Flow_Destination_Arrival_Date_Time__c.format('yyyy-MM-dd HH:mm:ss', UserInfo.getTimeZone().toString()));
                    system.debug('convertedDateTime: ' + convertedDateTime); 
                    cs.Destination_Arrival_Date__c = convertedDateTime.date();
                    cs.Destination_Arrival_Time__c = convertedDateTime.time();
                }
                
                if (cs.Flow_Booking_Date_Time__c != NULL && cs.Flow_Booking_Date_Time__c != oldMap.get(cs.Id).Flow_Booking_Date_Time__c) {
                    system.debug('cs.Flow_Booking_Date_Time__c: ' + cs.Flow_Booking_Date_Time__c); 
                    DateTime convertedDateTime = DateTime.valueOf(cs.Flow_Booking_Date_Time__c.format('yyyy-MM-dd HH:mm:ss', UserInfo.getTimeZone().toString()));
                    system.debug('convertedDateTime: ' + convertedDateTime); 
                    cs.DateOfBooking__c = convertedDateTime.date();
                    cs.Time_of_Booking__c = convertedDateTime.time();
                }
                
                if (cs.Flow_Check_In_Date_Time__c != NULL && cs.Flow_Check_In_Date_Time__c != oldMap.get(cs.Id).Flow_Check_In_Date_Time__c) {
                    system.debug('cs.Flow_Check_In_Date_Time__c: ' + cs.Flow_Check_In_Date_Time__c); 
                    DateTime convertedDateTime = DateTime.valueOf(cs.Flow_Check_In_Date_Time__c.format('yyyy-MM-dd HH:mm:ss', UserInfo.getTimeZone().toString()));
                    system.debug('convertedDateTime: ' + convertedDateTime); 
                    cs.Check_In_Date__c = convertedDateTime.date();
                    cs.Check_In_Time__c = convertedDateTime.time();
                }
                
                if (cs.Flow_Check_Out_Date_Time__c != NULL && cs.Flow_Check_Out_Date_Time__c != oldMap.get(cs.Id).Flow_Check_Out_Date_Time__c) {
                    system.debug('cs.Flow_Check_Out_Date_Time__c: ' + cs.Flow_Check_Out_Date_Time__c); 
                    DateTime convertedDateTime = DateTime.valueOf(cs.Flow_Check_Out_Date_Time__c.format('yyyy-MM-dd HH:mm:ss', UserInfo.getTimeZone().toString()));
                    system.debug('convertedDateTime: ' + convertedDateTime); 
                    
                    cs.Check_Out_Date__c = convertedDateTime.date();
                    cs.Check_Out_Time__c = convertedDateTime.time();
                }
                
                if (cs.Flow_Departure_Date_Time__c != NULL && cs.Flow_Departure_Date_Time__c != oldMap.get(cs.Id).Flow_Departure_Date_Time__c) {
                    system.debug('cs.Flow_Departure_Date_Time__c: ' + cs.Flow_Departure_Date_Time__c); 
                    DateTime convertedDateTime = DateTime.valueOf(cs.Flow_Departure_Date_Time__c.format('yyyy-MM-dd HH:mm:ss', UserInfo.getTimeZone().toString()));
                    system.debug('convertedDateTime: ' + convertedDateTime); 
                    
                    cs.Date_of_Departure__c = convertedDateTime.date();
                    cs.Departure_Time__c = convertedDateTime.time();
                }
                
                if (cs.Flow_Drop_Off_Date_Time__c != NULL && cs.Flow_Drop_Off_Date_Time__c != oldMap.get(cs.Id).Flow_Drop_Off_Date_Time__c) {
                    system.debug('cs.Flow_Drop_Off_Date_Time__c: ' + cs.Flow_Drop_Off_Date_Time__c); 
                    DateTime convertedDateTime = DateTime.valueOf(cs.Flow_Drop_Off_Date_Time__c.format('yyyy-MM-dd HH:mm:ss', UserInfo.getTimeZone().toString()));
                    system.debug('convertedDateTime: ' + convertedDateTime); 
                    
                    cs.Drop_off_Date__c = convertedDateTime.date();
                    cs.Drop_off_Time__c = convertedDateTime.time();
                }
                
                if (cs.Flow_Pick_Up_Date_Time__c != NULL && cs.Flow_Pick_Up_Date_Time__c != oldMap.get(cs.Id).Flow_Pick_Up_Date_Time__c) {
                    system.debug('cs.Flow_Pick_Up_Date_Time__c: ' + cs.Flow_Pick_Up_Date_Time__c); 
                    DateTime convertedDateTime = DateTime.valueOf(cs.Flow_Pick_Up_Date_Time__c.format('yyyy-MM-dd HH:mm:ss', UserInfo.getTimeZone().toString()));
                    system.debug('convertedDateTime: ' + convertedDateTime); 
                    
                    cs.Pickup_Date__c = convertedDateTime.date();
                    cs.Pickup_Time__c = convertedDateTime.time();
                }
            }
        }
    }
    
    private void diningConversion(List<sObject> newCases , Map<Id,sObject> oldCaseMap){
        system.debug('diningConversion');
        List<Case> newCaseList = (List<Case>) newCases;
        
        if(oldCaseMap != NULL){
            Map<Id,Case> oldMap = (Map<Id,Case>) oldCaseMap;
            
            for(Case cs : newCaseList){
                if (cs.RecordTypeId != oldMap.get(cs.Id).RecordTypeId && oldMap.get(cs.Id).RecordTypeId == '0120b000000hwtbAAA') {
                    cs.House_Contact__c = oldMap.get(cs.Id).ContactId;
                    cs.House_Account__c = oldMap.get(cs.Id).AccountId;
                    cs.House_Conversion_Date_Time__c = DateTime.now();
                }
            }
        }
    }
    
    private void updateTimeLogParents(List<sObject> newCases , Map<Id,sObject> oldCaseMap){
        system.debug('updateTimeLogParents');
        List<Case> newCaseList = (List<Case>) newCases;
        
        if(oldCaseMap != NULL){
            Map<Id,Case> oldMap = (Map<Id,Case>) oldCaseMap;
            Set<Id> caseIds = new Set<Id>();
            List<Time_Log__c> timeLogsToUpdate = new List<Time_Log__c>();
            
            for(Case cs : newCaseList){
                if (cs.AccountId != oldMap.get(cs.Id).AccountId || cs.ContactId != oldMap.get(cs.Id).ContactId) {
                    caseIds.add(cs.Id);
                }
            }
            for (Time_Log__c tl : [SELECT Id, Case__c, Case__r.AccountId, Case__r.ContactId, Case__r.Contact.FirstName, Client__c, Contact__c, CreatedDate 
                                   FROM Time_Log__c 
                                   WHERE Case__c IN :caseIds AND CreatedDate >= :Date.newInstance(2019, 09, 12)  ]) {
                                       tl.Client__c = tl.Case__r.AccountId;
                                       tl.Contact__c = tl.Case__r.ContactId;
                                       timeLogsToUpdate.add(tl);
                                       system.debug('tl: ' + tl.Case__r.Contact.FirstName);
            }
            
            if (!timeLogsToUpdate.isEmpty()) {
                update timeLogsToUpdate;
            }
        }
    }
    
    private void recalcHierarchyTime(List<sObject> newCases , Map<Id,sObject> oldCaseMap){
        system.debug('recalcHierarchyTime');
        List<Case> newCaseList = (List<Case>) newCases;

        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        if(oldCaseMap != NULL){
            Map<Id,Case> oldMap = (Map<Id,Case>) oldCaseMap;
            Set<Id> caseIds = new Set<Id>();
            List<Case> casesToUpdate = new List<Case>();
			
            if (newCaseList == null) {
                for(Case cs : oldMap.values()){
                    caseIds.add(cs.ParentId);
                    
                    contactIds.add(cs.ContactId);
                    accountIds.add(cs.AccountId);
                }
            } else {
                for(Case cs : newCaseList){
                    //oldMap.get(cs.Id).Status
                    //cs.Status
                    if (cs.ParentId != oldMap.get(cs.Id).ParentId) {
                        if (cs.ParentId != NULL) {
                            caseIds.add(cs.ParentId);
                        }
                        if (oldMap.get(cs.Id).ParentId != NULL) {
                            caseIds.add(oldMap.get(cs.Id).ParentId);
                        }
                    }
                    
                    contactIds.add(cs.ContactId);
                    accountIds.add(cs.AccountId);
                    contactIds.add(oldMap.get(cs.Id).ContactId);
                    accountIds.add(oldMap.get(cs.Id).AccountId);
                }
            }
            
            system.debug('caseIds: ' + caseIds);
            if (caseIds.size() > 0) {
                casesToUpdate = [SELECT Id, ParentId, Hierarchical_Time_Logged__c, (SELECT Id, Case_Time_Logged__c FROM Cases) FROM Case WHERE Id IN :caseIds];
                for (Case parentCase : casesToUpdate) {
                    parentCase.Hierarchical_Time_Logged__c = 0;
                    for (Case childCase : parentCase.Cases) {
                        if (childCase.Case_Time_Logged__c != NULL) {
                            parentCase.Hierarchical_Time_Logged__c += childCase.Case_Time_Logged__c;
                        }
                    }
                }
                system.debug('casesToUpdate: ' + casesToUpdate);
                update casesToUpdate;
            }
            
            if (contactIds.size() > 0) {
                Util.recalcContacts(contactIds);
            }
            
            if (accountIds.size() > 0) {
                Util.recalcAccounts(accountIds);
            }
        }
    }
}