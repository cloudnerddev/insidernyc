@isTest
private class PaymentMethodTest {
    @isTest 
    static void tests() {        
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
        
        Payment_Method__c pmA = new Payment_Method__c();
        pmA.Name = 'Test';
        pmA.Type__c = 'Business';
        pmA.Credit_Card_Number_Encrypted__c = '41111111111111111';
        INSERT pmA;

        Payment_Method__c pmB = pmA.clone(false,false,false,false);
        pmB.Client__c = conB.Id;
        INSERT pmB;
        
        Payment_Method__c pmC = pmA.clone(false,false,false,false);
        INSERT pmC;
        
        Linked_Payment_Method__c linkedPm1 = new Linked_Payment_Method__c(Linked_Payment_Method_From__c = pmA.Id, Link_Payment_Method_To__c = conB.Id);
        RecursiveTriggerHandler.isFirstTime = TRUE;
        INSERT linkedPm1;
        
        Linked_Payment_Method__c linkedPm2 = new Linked_Payment_Method__c(Linked_Payment_Method_From__c = pmA.Id, Linked_Payment_Method_To__c = pmB.Id);
        RecursiveTriggerHandler.isFirstTime = TRUE;
        INSERT linkedPm2;
        
        Linked_Payment_Method__c linkedPm3 = new Linked_Payment_Method__c(Linked_Payment_Method_From__c = pmB.Id, Linked_Payment_Method_To__c = pmC.Id);
        RecursiveTriggerHandler.isFirstTime = TRUE;
        INSERT linkedPm3;
        

        pmA.Credit_Card_Number_Encrypted__c = '';
        RecursiveTriggerHandler.isFirstTime = TRUE;
        UPDATE pmA;
        
        LinkedPaymentMethodController controller = new LinkedPaymentMethodController();
        LinkedPaymentMethodController.getLinkedPaymentMethods(pmA.Id);

        RecursiveTriggerHandler.isFirstTime = TRUE;
        pmA.Active__c = FALSE;
        pmA.Inactive_Reason__c = 'test';
        UPDATE pmA;
        
        DELETE linkedPm1;
        Test.StopTest();
    }
}