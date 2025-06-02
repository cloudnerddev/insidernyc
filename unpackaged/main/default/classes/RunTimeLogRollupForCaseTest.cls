@isTest
public class RunTimeLogRollupForCaseTest {
	@isTest 
    static void testRunTimeLogRollupForCase() {
        Test.StartTest();
         
         Account newAccount = new Account();
         newAccount.Name = 'Test';
         newAccount.Hours_per_Month__c = 1;
         insert newAccount;
        
         Contact newContact = new Contact();
         newContact.AccountId = newAccount.Id;
         newContact.FirstName = 'Test';
         newContact.LastName = 'Test';
         newContact.Time_Logged_MTD_Minutes__c = 1;
         newContact.Billable_Time_Logged_MTD_minutes__c = 1;
      	 newContact.Anniversary__c = Date.today();
         newContact.Birthdate = Date.today();
		 insert newContact;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Travel_Planning').getRecordTypeId();

        Case C = new Case();
        C.Subject = 'Child';
        C.AccountId = newAccount.Id;
        C.ContactId = newContact.Id;
        C.RecordTypeId = recordTypeId;
        INSERT C;
        
        Time_Log__c TL2 = new Time_Log__c();
        TL2.Client__c = newAccount.Id;
        TL2.Contact__c = newContact.Id;
        TL2.Case__c = C.Id;
        TL2.Duration_Minutes__c = 5;
        TL2.Multiplier__c = '2';
        TL2.Date_Logged__c = Date.today();
        INSERT TL2;
        
        TL2.Duration_Minutes__c = 6;
        TL2.Case__c = C.Id;
        UPDATE TL2;      
        RunTimeLogRollupForCase.InputWrapper iw = new RunTimeLogRollupForCase.InputWrapper();
        iw.caseId = C.Id;
        List<RunTimeLogRollupForCase.InputWrapper> iwList = new List<RunTimeLogRollupForCase.InputWrapper>();
        iwList.add(iw);
        RunTimeLogRollupForCase.runBatch(iwList); 
        
        String sch ='0 48 * * * ?'; 
		System.schedule('Schedule to update Account Name', sch,new TimeLogRollupBatchScheduler());
        Test.StopTest();
    }
}