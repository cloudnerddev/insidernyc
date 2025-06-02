/* 
    * Class Name : ItineraryTemplateController2Test
    * Description : Test Class for ItineraryTemplateController2.
    * Created Date : 11/09/2023
*/
@isTest
private class ItineraryTemplateController2Test {
    /* ***********************************************************************************************************************        
        @Method_Name : createData       
        @Method_Description : Method is used to generate data.    
    ************************************************************************************************************************** */
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
        P.Date__c = System.today();
        P.Description = 'qwertyuiop';
        P.Description__c = 'Its just a description.';
        P.Subject = 'Test';
        P.Check_In_Date__c = System.today();
        P.Check_Out_Date__c = System.today()+1;
        P.Room_Type__c = 'Room';
        P.Vendor__c = A2.Id;
        P.Status = 'New';
        P.Origin = 'Email';
        INSERT P;
        
        Itinerary__c itV = new Itinerary__c();
        itV.Client__c = A1.Id;
        itV.End_Date__c = System.today();
        itV.Intro_Picture__c = 'dummy';
        itV.Name = 'Dummy';
        itV.Logbook__c = P.Id;
        itV.Start_Date__c = System.today();
        INSERT itV;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Flight_Booking_Single_Person').getRecordTypeId();

        Case C = new Case();
        C.Subject = 'Child';
        C.AccountId = A1.Id;
        C.ContactId = CON.Id;
        C.Itinerary__c = itV.Id;
        C.Confirmation_Date__c = DateTime.now();
        C.RecordTypeId = recordTypeId;
        INSERT C;
        Case Ca = new Case();
        Ca.Subject = 'Child';
        Ca.AccountId = A1.Id;
        Ca.ContactId = CON.Id;
        Ca.Itinerary__c = itV.Id;
        Ca.Confirmation_Date__c = DateTime.now();
        INSERT Ca;

        Flight_Booking__c fb = new Flight_Booking__c();
        fb.Departure_Date__c = System.today();
        fb.Name = 'Test';
        fb.Refundable__c = 'true';
        fb.Logbook__c = C.Id;
        INSERT fb;

        Passenger__c ps = new Passenger__c();
        ps.Contact__c = CON.Id;
        ps.Logbook__c = C.Id;
        INSERT ps;

    }
    
    
    /* ***********************************************************************************************************************        
        @Method_Name : ItineraryTemplate_Test       
        @Method_Description : Method is used to test ItineraryTemplateController2 class.    
    ************************************************************************************************************************** */
    @IsTest 
    private static void ItineraryTemplate_Test() {
        Itinerary__c ca = [SELECT Id FROM Itinerary__c LIMIT 1];
        Test.StartTest(); 
            ApexPages.currentPage().getParameters().put('id', String.valueOf(ca.Id));
            ItineraryTemplateController2 testItineraryTemplateController = new ItineraryTemplateController2();
        Test.StopTest();
        Assert.areEqual(ca.Id, testItineraryTemplateController.currentRecordId);                      
        Assert.areEqual(ca.Id, testItineraryTemplateController.thisItinerary.Id);                      
        Assert.isNotNull(testItineraryTemplateController.metadataLogBooks);                      
        Assert.isNotNull(testItineraryTemplateController.relatedflightBooks);                                        
    }  
}