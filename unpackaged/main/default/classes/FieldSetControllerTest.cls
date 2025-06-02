@isTest
public class FieldSetControllerTest {

    //public static String typeName = 'Contact';
    //public static String fsName = 'lightningFormContactFields';
	public static String typeName = 'Payment_Method__c';
    public static String fsName = 'Credit_Card_Number';
        
    @isTest
    public static void tests(){
        Insider_Team__c IT = new Insider_Team__c();
        IT.Name = 'Test Team';
        INSERT IT;
        
        Account A = new Account();
        A.Name = 'Test';
        A.Insider_Team__c = IT.Id;
        A.Hours_per_Month__c = 1;
        INSERT A;
        
        Contact CON = new Contact();
        CON.AccountId = A.Id;
        CON.FirstName = 'Test';
        CON.LastName = 'Test';
        CON.Time_Logged_MTD_Minutes__c = 1;        
        INSERT CON;
        
        Payment_Method__c pm = new Payment_Method__c();
        pm.Credit_Card_Number_Encrypted__c = '2312';
        INSERT PM;
        
        Test.startTest();
        FieldSetController.getFields(typeName, fsName, pm.Id);
        FieldSetController.getFieldSetNames(typeName);
        FieldSetController.getTypeNames();
        FieldSetController.hasFieldSets(typeName);
        FieldSetController.updateAuditField(typeName, 'Reason__c', pm.Id);
        FieldSetController.updateReasonField(typeName, 'Reason__c', pm.Id, '123');
        //FieldSetController.getRecordTypeName(accts[0].RecordType.Name, accts[0].Id);
        
        Test.stopTest();
    }
}