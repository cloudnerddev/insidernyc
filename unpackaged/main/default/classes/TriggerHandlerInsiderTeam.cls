public  class TriggerHandlerInsiderTeam extends TriggerHandler {
    
    // Constructor 
    public TriggerHandlerInsiderTeam() {}
    
    /* Trigger context overrides */
    public override void beforeInsert() {}
    public override void beforeUpdate() {}
    public override void beforeDelete() {
        updateTeamFieldsDelete(Trigger.old);
    }
    public override void afterInsert()  {
    }
    public override void afterUpdate()  {
        updateTeamFieldsUpdate(Trigger.new);
    }
    public override void afterDelete()  {}
    public override void afterUndelete(){
        updateTeamFieldsUpdate(Trigger.new);
    }
    
    private void updateTeamFieldsUpdate(List<sObject> triggerITs){
        system.debug('updateTeamFieldsUpdate-IT');
        List<Insider_Team__c> iTList = (List<Insider_Team__c>) triggerITs;
        Set<Id> userIds = new Set<Id>();
        Map<Id, User> usersToUpdate = new Map<Id, User>();
        
        //grab users affected
        for(Insider_Team_Member__c itm : [SELECT Id,Insider_Team__c,Insider_Team__r.Insider_Team__c,Insider_Team__r.Active__c,Team_Member__c,Team_Member__r.Name 
                                          FROM Insider_Team_Member__c 
                                          WHERE Insider_Team__c IN :iTList
                                          ORDER BY Team_Member__c ASC, Insider_Team__r.Active__c DESC, Insider_Team__r.Insider_Team__c ASC]){
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
    
    
    private void updateTeamFieldsDelete(List<sObject> triggerITs){
        system.debug('updateTeamFieldsDelete-IT');
        List<Insider_Team__c> iTList = (List<Insider_Team__c>) triggerITs;
        Set<Id> delItIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Map<Id, User> usersToUpdate = new Map<Id, User>();
        
        for (Insider_Team__c it : iTList) {
            delItIds.add(it.Id);
        }
        
        //grab users affected
        for(Insider_Team_Member__c itm : [SELECT Id,Insider_Team__c,Insider_Team__r.Insider_Team__c,Insider_Team__r.Active__c,Team_Member__c,Team_Member__r.Name 
                                          FROM Insider_Team_Member__c 
                                          WHERE Insider_Team__c IN :iTList
                                          ORDER BY Team_Member__c ASC, Insider_Team__r.Active__c DESC, Insider_Team__r.Insider_Team__c ASC]){
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
                                               
                                               //IF TEAM IS GOING TO BE DELETED, DO NOT ADD
                                               if (!delItIds.contains(itm.Insider_Team__c)) {
                                                   system.debug('pass check');

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