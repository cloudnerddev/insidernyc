public  class TriggerHandlerInsiderTeamMember extends TriggerHandler {
    
    // Constructor 
    public TriggerHandlerInsiderTeamMember() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {}
    public override void beforeUpdate() {}
    public override void beforeDelete() {}
    public override void afterInsert()  {
        updateTeamFields(Trigger.new);
    }
    public override void afterUpdate()  {
        updateTeamFields(Trigger.new);
    }
    public override void afterDelete()  {
        updateTeamFields(Trigger.old);
    }
    public override void afterUndelete(){
        updateTeamFields(Trigger.new);
    }
    
    private void updateTeamFields(List<sObject> triggerITMs){
        system.debug('updateTeamFields-ITM');
        List<Insider_Team_Member__c> iTMList = (List<Insider_Team_Member__c>) triggerITMs;
        Set<Id> userIds = new Set<Id>();
        Map<Id, User> usersToUpdate = new Map<Id, User>();
        
        for(Insider_Team_Member__c itm : iTMList){
            system.debug('itma: ' + itm);
            userIds.add(itm.Team_Member__c);
        }
        
        for (Id usrId : userIds) {
            User usr = new User(
                Id = usrId,
                My_Teams_Active__c = NULL,
                My_Teams_Inactive__c = NULL
            );
            usersToUpdate.put(usrId, usr);
            system.debug('usersToUpdate: ' + usersToUpdate);
        }
        
        User usr = new User();
        for (Insider_Team_Member__c itm : [SELECT Id,Insider_Team__c,Insider_Team__r.Insider_Team__c,Insider_Team__r.Active__c,Team_Member__c,Team_Member__r.Name 
                                           FROM Insider_Team_Member__c 
                                           WHERE Team_Member__c IN :userIds
                                           ORDER BY Team_Member__c ASC, Insider_Team__r.Active__c DESC, Insider_Team__r.Insider_Team__c ASC]) {
                                               system.debug('itm: ' + itm);
                                               system.debug('usr1: ' + usr);
                                               if (usr == NULL || usr.Id != itm.Team_Member__c) {
                                                   if (usr.Id != NULL) {
                                                       system.debug('add user 1');
                                                       usersToUpdate.put(usr.Id, usr);
                                                   }
                                                   system.debug('set user');
                                                   usr = new User(Id = itm.Team_Member__c,My_Teams_Active__c = NULL,My_Teams_Inactive__c = NULL);
                                               }
                                               if (itm.Insider_Team__r.Active__c) {
                                                   system.debug('itm1: ' + itm);
                                                   
                                                   if (usr.My_Teams_Active__c == NULL) {
                                                       usr.My_Teams_Active__c = itm.Insider_Team__r.Insider_Team__c;
                                                   } else {
                                                       usr.My_Teams_Active__c+= itm.Insider_Team__r.Insider_Team__c;
                                                   }
                                               } else {
                                                   system.debug('itm2: ' + itm);

                                                   if (usr.My_Teams_Inactive__c == NULL) {
                                                       usr.My_Teams_Inactive__c = itm.Insider_Team__r.Insider_Team__c;
                                                   } else {
                                                       usr.My_Teams_Inactive__c+= itm.Insider_Team__r.Insider_Team__c;
                                                   }
                                               }
                                               system.debug('usr2: ' + usr);
                                           }
        if (usr.Id != NULL) {
            system.debug('add user 2');
            usersToUpdate.put(usr.Id, usr);
        }
    
        if (!usersToUpdate.isEmpty()) {
            system.debug('usersToUpdate: ' + usersToUpdate);
            update usersToUpdate.values();
        }
    }
}