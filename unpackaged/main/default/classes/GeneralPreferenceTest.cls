@isTest
private class GeneralPreferenceTest { 
        
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
        
        General_Preferences__c addA = new General_Preferences__c();
        addA.Contact_Name__c = conA.Id;
        addA.Account_Number__c = '123';
        addA.Airline_Seat_Preference__c = 'Middle';
        addA.Avid_Wine_Collector__c = TRUE;
        addA.Gym__c = A.Id;
        addA.Member_of_Social_or_Athletic_Club__c = 'Test';
        addA.Notes__c = 'Test';
        addA.Password__c = '123';
        addA.Preferred_Means_of_Air_Travel__c = 'Commercial';
        addA.Preferred_Seating_Class__c = 'Economy';
        addA.RecordTypeId = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'General_Preferences__c' AND DeveloperName = 'Airline_and_Flight_Preferences' LIMIT 1].Id;
        addA.Repeat_Orders__c = 'Test';
        addA.Room_Preference__c = 'Test';
        INSERT addA;
        
        General_Preferences__c addB = addA.clone(false,false,false,false);
        addB.Contact_Name__c = conB.Id;
        INSERT addB;
        
        General_Preferences__c addC = addA.clone(false,false,false,false);
        INSERT addC;
        
        Linked_General_Preference__c linkedAdd1 = new Linked_General_Preference__c(Linked_General_Preference_From__c = addA.Id, Link_General_Preference_To__c = conB.Id);
        RecursiveTriggerHandler.isFirstTime = TRUE;
        INSERT linkedAdd1;
        
        Linked_General_Preference__c linkedAdd2 = new Linked_General_Preference__c(Linked_General_Preference_From__c = addA.Id, Linked_General_Preference_To__c = addB.Id);
        RecursiveTriggerHandler.isFirstTime = TRUE;
        INSERT linkedAdd2;
        
        Linked_General_Preference__c linkedAdd3 = new Linked_General_Preference__c(Linked_General_Preference_From__c = addB.Id, Linked_General_Preference_To__c = addC.Id);
        RecursiveTriggerHandler.isFirstTime = TRUE;
        INSERT linkedAdd3;
        
        addC.Room_Preference__c = 'Test2';
        RecursiveTriggerHandler.isFirstTime = TRUE;
        update addC;
        
        LinkedGeneralPreferenceController controller = new LinkedGeneralPreferenceController();
        LinkedGeneralPreferenceController.getLinkedGeneralPreferences(addA.Id);

        RecursiveTriggerHandler.isFirstTime = TRUE;
        addA.Repeat_Orders__c = 'Test3';
        UPDATE addA;
        
        DELETE linkedAdd1;
        Test.StopTest();
    }
}