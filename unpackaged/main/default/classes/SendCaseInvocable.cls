public class SendCaseInvocable {

public class flowParameters{
       @InvocableVariable(required=true)
       public Id emailTempId;
        
    }
@InvocableMethod(label='InvocableCaseSend')    
     


    public static void sendCase(List<Id> caseIds)
    {
        Case c = [select id, ContactId, Contact.Email, Record_Type_Name__c from Case where Id in:caseIds limit 1];
        
        

        //OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'SHW Claims' LIMIT 1];
        EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE name =: c.Record_Type_Name__c];
        String[] toAddresses = new String[] {c.Contact.Email};
            system.debug('c.Contact.Email: ' + c.Contact.Email);
        
        Messaging.SingleEmailMessage eml = new Messaging.SingleEmailMessage();
        eml.setTargetObjectId(c.Contactid); 
        eml.setTemplateID(templateId.Id); 
        eml.setSaveAsActivity(true);
        //eml.setOrgWideEmailAddressId(i.OwnerId.email);
        eml.setToAddresses(toAddresses);
        eml.setWhatId(c.Id);
        system.debug('eml: ' + eml);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { eml });
        system.debug('result: ' + r);
    }
}