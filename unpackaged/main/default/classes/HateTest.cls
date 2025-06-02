@isTest
private class HateTest { 
        
    @isTest 
    static void testTriggers() {
        Test.StartTest();
        Insider_Team__c IT = new Insider_Team__c();
        IT.Name = 'Test Team';
        INSERT IT;
        
        Account A = new Account();
        A.Name = 'Test';
        A.Insider_Team__c = IT.Id;
        A.Hours_per_Month__c = 1;
        INSERT A;
        
        Contact conA = new Contact();
        conA.AccountId = A.Id;
        conA.FirstName = 'Test1';
        conA.LastName = 'Test2';
        INSERT conA;
        
        Contact conB = new Contact();
        conB.AccountId = A.Id;
        conB.FirstName = 'Test2';
        conB.LastName = 'Test2';
        INSERT conB;
        
        Hates__c addA = new Hates__c();
        addA.Contact_Name__c = conA.Id;
        addA.Account_Number__c = '123';
        addA.Airline_Seat_Hate__c = 'Middle';
        addA.Avid_Wine_Collector__c = TRUE;
        addA.Gym__c = A.Id;
        addA.Member_of_Social_or_Athletic_Club__c = 'Test';
        addA.Notes__c = 'Test';
        addA.Password__c = '123';
        addA.Hated_Means_of_Air_Travel__c = 'Commercial';
        addA.Hated_Seating_Class__c = 'Economy';
        addA.RecordTypeId = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Hates__c' AND DeveloperName = 'Airline_and_Flight_Hates' LIMIT 1].Id;
        addA.Repeat_Orders__c = 'Test';
        addA.Room_Hate__c = 'Test';
        INSERT addA;
        
        Hates__c addB = addA.clone(false,false,false,false);
        addB.Contact_Name__c = conB.Id;
        INSERT addB;
        
        Hates__c addC = addA.clone(false,false,false,false);
        INSERT addC;
        
        Linked_Hate__c linkedAdd1 = new Linked_Hate__c(Linked_Hate_From__c = addA.Id, Link_Hate_To__c = conB.Id);
        RecursiveTriggerHandler.isFirstTime = TRUE;
        INSERT linkedAdd1;
        
        Linked_Hate__c linkedAdd2 = new Linked_Hate__c(Linked_Hate_From__c = addA.Id, Linked_Hate_To__c = addB.Id);
        RecursiveTriggerHandler.isFirstTime = TRUE;
        INSERT linkedAdd2;
        
        Linked_Hate__c linkedAdd3 = new Linked_Hate__c(Linked_Hate_From__c = addB.Id, Linked_Hate_To__c = addC.Id);
        RecursiveTriggerHandler.isFirstTime = TRUE;
        INSERT linkedAdd3;
        
        addC.Room_Hate__c = 'Test2';
        RecursiveTriggerHandler.isFirstTime = TRUE;
        update addC;
        
        LinkedHateController controller = new LinkedHateController();
        LinkedHateController.getLinkedHates(addA.Id);

        RecursiveTriggerHandler.isFirstTime = TRUE;
        addA.Repeat_Orders__c = 'Test3';
        UPDATE addA;
        
        DELETE linkedAdd1;
        Test.StopTest();
    }
}