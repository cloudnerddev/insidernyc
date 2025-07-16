@isTest
private class CasesControllerTest {
    static testMethod void CreateRecords() {        
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
        C.Confirmation_Date__c = DateTime.now();
        INSERT C;
        
        Case C1 = new Case();
        C1.Subject = 'Child';
        C1.AccountId = A1.Id;
        C1.ContactId = CON.Id;
        C1.ParentId = P.Id;
        C1.RecordTypeId = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'DiningReservation' LIMIT 1].Id;
        C1.Confirmation_Date__c = DateTime.now();
        C1.Date__c = System.today();
        INSERT C1;
        
        ContentNote cn = new ContentNote();
        cn.OwnerId = UserInfo.getUserId();
        cn.SharingPrivacy = 'N';
        cn.Title = 'Test';
        INSERT cn;
        
        
        //Testing content document trigger
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cn.Id;
        cdl.LinkedEntityId = C.Id;
        cdl.Visibility = 'AllUsers';
        INSERT cdl;
        
        cdl.ShareType = 'V';
        UPDATE cdl;
        Id batchJobId = Database.executeBatch(new ContentDocumentShare_batch(), 100);
        
        CasesController controller1 = new CasesController();
        CasesController.getRelatedConfirmedCases(P.Id);
        
        Flight_Booking__c fb1 = new Flight_Booking__c();
        fb1.Name = 'Test 1';
        fb1.Logbook__c = C.Id;
        fb1.Airline__c = A2.Id;
        INSERT fb1;
        
        Flight_Booking__c fb2 = new Flight_Booking__c();
        fb2.Name = 'Test 1';
        fb2.Logbook__c = C.Id;
        fb2.Airline__c = A2.Id;
        
        Flight_Booking__c fb3 = [Select Id, Name, Airline__c FROM Flight_Booking__c WHERE Id = :fb1.Id];
            
        Airline_Ticket__c at = new Airline_Ticket__c();
        at.Flight__c = fb1.Id;
        at.Case__c = C.Id;
        INSERT at;
        
        List<Airline_Ticket__c> atList1 = new List<Airline_Ticket__c>();
        atList1.add(at);
        
        List<Airline_Ticket__c> atList2 = new List<Airline_Ticket__c>();
        atList2.add(at.clone(false, false, false, false));  

        CloneFlights controller2 = new CloneFlights();
        CloneFlights.cloneFlightFields(fb1.Id, JSON.serialize(fb3));
        CloneFlights.getAirlineTickets(fb1.Id);
        CloneFlights.cloneAirlineTickets(fb1.Id, fb2, atList1, atList2);
        CloneFlights.getFieldset();
        
        flightBookingData controller3 = new flightBookingData();
        controller3.csID = C.Id;
        String str = controller3.passengerNames;
    }
    static testMethod void testSetTime_AllFieldsChanged() {
        // Create datetime values
        DateTime originalDT = DateTime.newInstance(2025, 7, 13, 10, 0, 0);
        DateTime updatedDT = DateTime.newInstance(2025, 7, 14, 12, 30, 0);

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
        
        
        // Old Case (simulate old values)
        // New Case (simulate updated flow values)
        Case newCase = new Case(
            Flow_Destination_Arrival_Date_Time__c = updatedDT,
            Flow_Booking_Date_Time__c = updatedDT,
            Flow_Check_In_Date_Time__c = updatedDT,
            Flow_Check_Out_Date_Time__c = updatedDT,
            Flow_Departure_Date_Time__c = updatedDT,
            Flow_Drop_Off_Date_Time__c = updatedDT,
            Flow_Pick_Up_Date_Time__c = updatedDT,
            AccountId = A1.Id,
            ContactId = CON.Id
        );
		Insert newCase;
        
        // Simulate calling the private method by wrapping it in a public method in your handler class
        Test.startTest();
        newCase.Flow_Destination_Arrival_Date_Time__c = system.today();
        update newCase;
        Test.stopTest();

        // Assert that split fields are correctly set
      }
    static testMethod void testSetTime_AllFieldsChanged1() {
        // Create datetime values
        DateTime originalDT = DateTime.newInstance(2025, 7, 13, 10, 0, 0);
        DateTime updatedDT = DateTime.newInstance(2025, 7, 14, 12, 30, 0);

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
        
        
        // Old Case (simulate old values)
        // New Case (simulate updated flow values)
        Case newCase = new Case(
            Flow_Destination_Arrival_Date_Time__c = updatedDT,
            Flow_Booking_Date_Time__c = updatedDT,
            Flow_Check_In_Date_Time__c = updatedDT,
            Flow_Check_Out_Date_Time__c = updatedDT,
            Flow_Departure_Date_Time__c = updatedDT,
            Flow_Drop_Off_Date_Time__c = updatedDT,
            Flow_Pick_Up_Date_Time__c = updatedDT,
            AccountId = A1.Id,
            ContactId = CON.Id
        );
		Insert newCase;
        
        // Simulate calling the private method by wrapping it in a public method in your handler class
        Test.startTest();
        newCase.Flow_Booking_Date_Time__c = system.today();
        update newCase;
        Test.stopTest();

        // Assert that split fields are correctly set
      }
    static testMethod void testSetTime_AllFieldsChanged2() {
        // Create datetime values
        DateTime originalDT = DateTime.newInstance(2025, 7, 13, 10, 0, 0);
        DateTime updatedDT = DateTime.newInstance(2025, 7, 14, 12, 30, 0);

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
        
        
        // Old Case (simulate old values)
        // New Case (simulate updated flow values)
        Case newCase = new Case(
            Flow_Destination_Arrival_Date_Time__c = updatedDT,
            Flow_Booking_Date_Time__c = updatedDT,
            Flow_Check_In_Date_Time__c = updatedDT,
            Flow_Check_Out_Date_Time__c = updatedDT,
            Flow_Departure_Date_Time__c = updatedDT,
            Flow_Drop_Off_Date_Time__c = updatedDT,
            Flow_Pick_Up_Date_Time__c = updatedDT,
            AccountId = A1.Id,
            ContactId = CON.Id
        );
		Insert newCase;
        
        // Simulate calling the private method by wrapping it in a public method in your handler class
        Test.startTest();
        newCase.Flow_Check_In_Date_Time__c = system.today();
        update newCase;
        Test.stopTest();

        // Assert that split fields are correctly set
      }
    static testMethod void testSetTime_AllFieldsChanged3() {
        // Create datetime values
        DateTime originalDT = DateTime.newInstance(2025, 7, 13, 10, 0, 0);
        DateTime updatedDT = DateTime.newInstance(2025, 7, 14, 12, 30, 0);

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
        
        
        // Old Case (simulate old values)
        // New Case (simulate updated flow values)
        Case newCase = new Case(
            Flow_Destination_Arrival_Date_Time__c = updatedDT,
            Flow_Booking_Date_Time__c = updatedDT,
            Flow_Check_In_Date_Time__c = updatedDT,
            Flow_Check_Out_Date_Time__c = updatedDT,
            Flow_Departure_Date_Time__c = updatedDT,
            Flow_Drop_Off_Date_Time__c = updatedDT,
            Flow_Pick_Up_Date_Time__c = updatedDT,
            AccountId = A1.Id,
            ContactId = CON.Id
        );
		Insert newCase;
        
        // Simulate calling the private method by wrapping it in a public method in your handler class
        Test.startTest();
        newCase.Flow_Check_Out_Date_Time__c = system.today();
        update newCase;
        Test.stopTest();

        // Assert that split fields are correctly set
      }
    static testMethod void testSetTime_AllFieldsChanged4() {
        // Create datetime values
        DateTime originalDT = DateTime.newInstance(2025, 7, 13, 10, 0, 0);
        DateTime updatedDT = DateTime.newInstance(2025, 7, 14, 12, 30, 0);

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
        
        
        // Old Case (simulate old values)
        // New Case (simulate updated flow values)
        Case newCase = new Case(
            Flow_Destination_Arrival_Date_Time__c = updatedDT,
            Flow_Booking_Date_Time__c = updatedDT,
            Flow_Check_In_Date_Time__c = updatedDT,
            Flow_Check_Out_Date_Time__c = updatedDT,
            Flow_Departure_Date_Time__c = updatedDT,
            Flow_Drop_Off_Date_Time__c = updatedDT,
            Flow_Pick_Up_Date_Time__c = updatedDT,
            AccountId = A1.Id,
            ContactId = CON.Id
        );
		Insert newCase;
        
        // Simulate calling the private method by wrapping it in a public method in your handler class
        Test.startTest();
        newCase.Flow_Departure_Date_Time__c = system.today();
        update newCase;
        Test.stopTest();

        // Assert that split fields are correctly set
      }
    static testMethod void testSetTime_AllFieldsChanged5() {
        // Create datetime values
        DateTime originalDT = DateTime.newInstance(2025, 7, 13, 10, 0, 0);
        DateTime updatedDT = DateTime.newInstance(2025, 7, 14, 12, 30, 0);

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
        
        
        // Old Case (simulate old values)
        // New Case (simulate updated flow values)
        Case newCase = new Case(
            Flow_Destination_Arrival_Date_Time__c = updatedDT,
            Flow_Booking_Date_Time__c = updatedDT,
            Flow_Check_In_Date_Time__c = updatedDT,
            Flow_Check_Out_Date_Time__c = updatedDT,
            Flow_Departure_Date_Time__c = updatedDT,
            Flow_Drop_Off_Date_Time__c = updatedDT,
            Flow_Pick_Up_Date_Time__c = updatedDT,
            AccountId = A1.Id,
            ContactId = CON.Id
        );
		Insert newCase;
        
        // Simulate calling the private method by wrapping it in a public method in your handler class
        Test.startTest();
        newCase.Flow_Drop_Off_Date_Time__c = system.today();
        update newCase;
        Test.stopTest();

        // Assert that split fields are correctly set
      }
    static testMethod void testSetTime_AllFieldsChanged6() {
        // Create datetime values
        DateTime originalDT = DateTime.newInstance(2025, 7, 13, 10, 0, 0);
        DateTime updatedDT = DateTime.newInstance(2025, 7, 14, 12, 30, 0);

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
        
        
        // Old Case (simulate old values)
        // New Case (simulate updated flow values)
        Case newCase = new Case(
            Flow_Destination_Arrival_Date_Time__c = updatedDT,
            Flow_Booking_Date_Time__c = updatedDT,
            Flow_Check_In_Date_Time__c = updatedDT,
            Flow_Check_Out_Date_Time__c = updatedDT,
            Flow_Departure_Date_Time__c = updatedDT,
            Flow_Drop_Off_Date_Time__c = updatedDT,
            Flow_Pick_Up_Date_Time__c = updatedDT,
            AccountId = A1.Id,
            ContactId = CON.Id
        );
		Insert newCase;
        
        // Simulate calling the private method by wrapping it in a public method in your handler class
        Test.startTest();
        newCase.Flow_Pick_Up_Date_Time__c = system.today();
        update newCase;
        Test.stopTest();

        // Assert that split fields are correctly set
      }
}