/* 
    * Class Name : FlightRecordsSortingControllerTest
    * Description : Test Class for FlightRecordsSortingControllerTest.
    * Created Date : 17/01/2024
*/
@isTest
public class FlightRecordsSortingControllerTest {
	@TestSetup
    static void createData() { 
        Account A1 = new Account();
        A1.Name = 'Test';
        A1.Hours_per_Month__c = 1;
        A1.Zagat_Review__c = 'asdasdasd \n sdasda';
        INSERT A1;
        
        Account A2 = new Account();
        A2.Name = 'Test';
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
        
    	Case C = new Case();
        C.Subject = 'Child';
        C.AccountId = A1.Id;
        C.ContactId = CON.Id;
        C.Confirmation_Date__c = DateTime.now();
        INSERT C;
        
        Flight_Booking__c fb = new Flight_Booking__c();
        fb.Departure_Date__c = System.today();
        fb.Name = 'Test';
        fb.Refundable__c = 'true';
        fb.Logbook__c = c.Id;
        INSERT fb;
    }
    /* ***********************************************************************************************************************        
        @Method_Name : flightRecord_Test       
        @Method_Description : Method is used to test FlightRecordsSortingController class.    
    ************************************************************************************************************************** */
    @IsTest 
    private static void flightRecord_Test() {
        Test.StartTest(); 

            FlightRecordsSortingController testFlightRecordsSortingController = new FlightRecordsSortingController();
            List <Flight_Booking__c> flightrecord = testFlightRecordsSortingController.relatedFlightRecords;
        Test.StopTest();
                              
        Assert.isNotNull(testFlightRecordsSortingController.relatedFlightRecords);                                     
    }  
}