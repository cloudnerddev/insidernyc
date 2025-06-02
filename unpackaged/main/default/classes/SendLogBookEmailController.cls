public with sharing class SendLogBookEmailController {
    
    @AuraEnabled
    public static List<Case> getLogBookDetails(String recordId){     
        return [SELECT id, Subject FROM Case WHERE ParentId =: recordId AND Status != 'Cancelled' Order by ReferenceDateTime__c Asc];
    }
    @AuraEnabled
    public static string usingEmailTemplate(List<String> recordIds){
        try {
            String mainbody = '';
            Messaging.SingleEmailMessage rmail = new Messaging.SingleEmailMessage();
            List<LogBook_Record__mdt> mcs = LogBook_Record__mdt.getAll().values();
            List<Case> allCases = [SELECT Id, recordType.DeveloperName from case Where Id IN :recordIds Order by ReferenceDateTime__c Asc];
            for(Case rId:allCases){
               for(LogBook_Record__mdt eTId: mcs) {
                    if((eTId.DeveloperName == rId.recordType.DeveloperName)  ){
                        rmail = Messaging.renderStoredEmailTemplate(eTId.Email_Template_ID__c, null, rId.Id);
                        mainbody = mainbody + rmail.getHtmlBody();
                        String signatureStart = '<span style="font-size:10.0pt;color:#9f9f9f;font-family:&quot;Arial Unicode MS&quot;">';
                        String signatureEnd = '</center>';
                        Integer startIndex = mainbody.indexOf(signatureStart);
                        Integer endIndex = mainbody.indexOf(signatureEnd, startIndex + signatureStart.length());
                        if (startIndex != -1 && endIndex != -1) {
                            // Remove the signature block
                            mainbody = mainbody.substring(0, startIndex) + mainbody.substring(endIndex + signatureEnd.length());
                        }
                    }
               }
            }
            if(mainbody != ''){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                
                message.setSubject('LogBook Confirmations');
                message.setHtmlBody(mainbody);
                String[] toAddresses = new list<string> {UserInfo.getUserEmail()};
                message.setToAddresses( toAddresses );
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
            return '0';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}