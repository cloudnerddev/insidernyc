global class SetupSandbox implements SandboxPostCopy {
    global void runApexClass(SandboxContext context) {
        System.debug('Org ID: ' + context.organizationId());
        System.debug('Sandbox ID: ' + context.sandboxId());
        System.debug('Sandbox Name: ' + context.sandboxName());
        
        Insider_Team__c IT = new Insider_Team__c();
        IT.Name = 'Test Team 1';
        INSERT IT;
        
        Account A = new Account();
        A.Name = 'Insider';
        A.Insider_Team__c = IT.Id;
        INSERT A;
        
        Account B = new Account();
        B.Name = 'SimpCo';
        B.Insider_Team__c = IT.Id;
        INSERT B;
        
        Contact C = new Contact();
        C.FirstName = 'Homer';
        C.LastName = 'Simpson';
        C.AccountId = B.Id;
        INSERT C;

        Global_Setting__c GS = [SELECT Insider_Account__c FROM Global_Setting__c LIMIT 1];
        GS.Insider_Account__c = A.Id;
        UPDATE GS;
    }
}