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
}