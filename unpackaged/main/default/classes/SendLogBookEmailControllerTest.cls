@isTest
private class SendLogBookEmailControllerTest {
    @TestSetup
    static void createData() {        
        Insider_Team__c IT = new Insider_Team__c();
        IT.Name = 'Test Team';
        INSERT IT;
        
        Account A1 = new Account();
        A1.Name = 'Test';
        A1.Insider_Team__c = IT.Id;
        A1.Hours_per_Month__c = 1;
        A1.Zagat_Review__c = 'asdasdasd \n sdasda';
        INSERT A1;
        
        Account A2 = new Account();
        A2.Name = 'Test';
        A2.Insider_Team__c = IT.Id;
        A2.Hours_per_Month__c = 1;
        A2.Zagat_Review__c = 'asdasdasd \n sdasda';
        A2.RecordTypeId = [Select Id, Name, DeveloperName From RecordType WHERE DeveloperName = 'Vendor_Account_Generic'].Id;
        INSERT A2;

        A2.Zagat_Review__c = NULL;
        UPDATE A2;
        
        Contact CON = new Contact();
        CON.AccountId = A1.Id;
        CON.FirstName = 'Test';
        CON.LastName = 'Test';
        CON.Time_Logged_MTD_Minutes__c = 1;        
        INSERT CON;
        
        Case P = new Case();
        P.Subject = 'Parent';
        P.AccountId = A1.Id;
        P.ContactId = CON.Id;
        INSERT P;
        
        Case C = new Case();
        C.Subject = 'Child';
        C.AccountId = A1.Id;
        C.ContactId = CON.Id;
        C.ParentId = P.Id;
        C.RecordTypeId = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Service_Booking' LIMIT 1].Id;
        C.Confirmation_Date__c = DateTime.now();
        INSERT C;
    }
    @IsTest private static void getLogBookDetails_Test () {
        Case ca = [SELECT Id FROM Case WHERE Subject = 'Parent' LIMIT 1];
        List<case> allCases = SendLogBookEmailController.getLogBookDetails(ca.Id);
        Assert.areEqual(allCases.size(),1);                           
    }    
    @IsTest private static void usingEmailTemplate_Test () {
        Case ca = [SELECT Id FROM Case WHERE Subject = 'Child' LIMIT 1];
        List<String> caList = new List<String>();
        caList.add(ca.Id);
        String allCases = SendLogBookEmailController.usingEmailTemplate(caList);
        Assert.areEqual(allCases,'0');                           
    }    
}