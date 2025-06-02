@isTest
private class AddressTest { 
        
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
        
        Address__c addA = new Address__c();
        addA.Contact_Name__c = conA.Id;
        addA.Address_City__c = 'Toronto';
        addA.Address_Country__c = 'Canada';
        addA.Address_State__c = 'NY';
        addA.Address_Street__c = '123 Fake Street';
        addA.Address_Zip_Code__c = '12345';
        addA.Cross_Streets__c = '123 x 345';
        addA.Doorman__c = TRUE;
        addA.Facility_Manager__c = conB.Id;
        addA.Neighbourhood__c = '3';
        addA.Notes__c = '4';
        addA.Primary__c = TRUE;
        addA.Type__c = 'Work';
        addA.Active__c = TRUE;
        INSERT addA;
        
        Address__c addB = addA.clone(false,false,false,false);
        addB.Contact_Name__c = conB.Id;
        INSERT addB;
        
        Address__c addC = addA.clone(false,false,false,false);
        INSERT addC;
        
        Linked_Address__c linkedAdd1 = new Linked_Address__c(Linked_Address_From__c = addA.Id, Link_Address_To__c = conB.Id);
        RecursiveTriggerHandler.isFirstTime = TRUE;
        INSERT linkedAdd1;
        
        Linked_Address__c linkedAdd2 = new Linked_Address__c(Linked_Address_From__c = addA.Id, Linked_Address_To__c = addB.Id);
        RecursiveTriggerHandler.isFirstTime = TRUE;
        INSERT linkedAdd2;
        
        Linked_Address__c linkedAdd3 = new Linked_Address__c(Linked_Address_From__c = addB.Id, Linked_Address_To__c = addC.Id);
        RecursiveTriggerHandler.isFirstTime = TRUE;
        INSERT linkedAdd3;
        
        addC.Address_City__c = 'Toronto';
        RecursiveTriggerHandler.isFirstTime = TRUE;
        update addC;
        
        LinkedAddressController controller = new LinkedAddressController();
        LinkedAddressController.getLinkedAddresses(addA.Id);

        RecursiveTriggerHandler.isFirstTime = TRUE;
        addA.Active__c = FALSE;
        addA.Inactive_Reason__c = 'test';
        UPDATE addA;
        
        DELETE linkedAdd1;
        Test.StopTest();
    }
}