public  class TriggerHandlerContact extends TriggerHandler {    
    // Constructor 
    public TriggerHandlerContact() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {}
    public override void beforeUpdate() {}
    public override void beforeDelete() {}
    public override void afterInsert()  {
        reminderSync(Trigger.new, NULL);
    }
    public override void afterUpdate()  {
        reminderSync(Trigger.new, Trigger.oldMap);
    }
    public override void afterDelete()  {}
    public override void afterUndelete(){}
    
    private void reminderSync(List<sObject> newCons, Map<Id,sObject> oldConMap){
        system.debug('reminderSync');
        
        List<Contact> newConList = (List<Contact>) newCons;
        List<Reminder__c> upsReminderList = new List<Reminder__c>();
        List<Reminder__c> delReminderList = new List<Reminder__c>();
        
        Set<String> rmdToDel = new Set<String>();

        Map<Id,Contact> oldMap;
        if(oldConMap != NULL){
            //existing contact, sync reminders
            oldMap = (Map<Id,Contact>) oldConMap;
            
            for(Contact con : newConList){
                if (con.Anniversary__c != oldMap.get(con.Id).Anniversary__c) {
                    if (con.Anniversary__c == NULL) { //anniversary deleted
                        rmdToDel.add(con.Id + 'Anniversary');
                    } else { //anniversary changed
                        Reminder__c newReminder = new Reminder__c(
                            Name = 'Anniversary',
                            Contact__c = con.Id,
                            Date__c = con.Anniversary__c,
                            Recurring__c = 'Annually',
                            Type__c = 'Anniversary',
                            SyncId__c = con.Id + 'Anniversary'
                        );
                        upsReminderList.add(newReminder);
                    }
                }
                
                if (con.Birthdate__c != oldMap.get(con.Id).Birthdate__c) {
                    if (con.Birthdate__c == NULL) { //birthday deleted
                        rmdToDel.add(con.Id + 'Birthday');
                    } else { //birthday changed
                        Reminder__c newReminder = new Reminder__c(
                            Name = 'Birthday',
                            Contact__c = con.Id,
                            Date__c = con.Birthdate__c,
                            Recurring__c = 'Annually',
                            Type__c = 'Birthday',
                            SyncId__c = con.Id + 'Birthday'
                        );
                        upsReminderList.add(newReminder);
                    }
                }
            }
        } else {
            //new contact, create reminders
            for(Contact con : newConList){
                if (con.Anniversary__c != NULL) {
                    Reminder__c newReminder = new Reminder__c(
                        Name = 'Anniversary',
                        Contact__c = con.Id,
                        Date__c = con.Anniversary__c,
                        Recurring__c = 'Annually',
                        Type__c = 'Anniversary',
                        SyncId__c = con.Id + 'Anniversary'
                    );
                    upsReminderList.add(newReminder);
                }
                
                if (con.Birthdate__c != NULL) {
                    Reminder__c newReminder = new Reminder__c(
                        Name = 'Birthday',
                        Contact__c = con.Id,
                        Date__c = con.Birthdate__c,
                        Recurring__c = 'Annually',
                        Type__c = 'Birthday',
                        SyncId__c = con.Id + 'Birthday'
                    );
                    upsReminderList.add(newReminder);
                }
            }
        }
        
        if (!upsReminderList.isEmpty()) {
            upsert upsReminderList SyncId__c;
        }
        
        if (!rmdToDel.isEmpty()) {
            delete [SELECT Id FROM Reminder__c WHERE SyncId__c IN :rmdToDel];
        }
    }
}