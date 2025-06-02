@isTest
private class InsiderTeamTest { 
        
    @isTest 
    static void testTriggers() {
        Test.StartTest();
        Insider_Team__c itA = new Insider_Team__c(Name = 'Team A', Active__c = TRUE);
        Insider_Team__c itB = new Insider_Team__c(Name = 'Team B', Active__c = FALSE);
        INSERT itA;
        INSERT itB;
        
        User[] usrList = [Select Id FROM User WHERE IsActive = True AND User.Profile.UserLicense.Name = 'Salesforce' LIMIT 2];
        Insider_Team_Member__c itmA = new Insider_Team_Member__c(Insider_Team__c = itA.Id, Team_Member__c = usrList[0].Id);
        Insider_Team_Member__c itmB = new Insider_Team_Member__c(Insider_Team__c = itB.Id, Team_Member__c = usrList[1].Id);
        Insider_Team_Member__c itmC = new Insider_Team_Member__c(Insider_Team__c = itA.Id, Team_Member__c = usrList[1].Id);
        Insider_Team_Member__c itmD = new Insider_Team_Member__c(Insider_Team__c = itB.Id, Team_Member__c = usrList[0].Id);
        INSERT itmA;
        INSERT itmB;
        INSERT itmC;
        INSERT itmD;
        
        DELETE itmA;
        UNDELETE itmA;

        DELETE itA;
        UNDELETE itA;
        
        itB.Active__c = TRUE;
        UPDATE itB;
        Test.StopTest();
    }
}