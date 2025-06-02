global class ContentDocumentShare_batch implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext Bc){
        return Database.getQueryLocator([SELECT Id, FileType, (SELECT Id, ShareType, LinkedEntityId FROM ContentDocumentLinks WHERE ShareType != 'I') FROM ContentDocument]);
    }

    global void execute(Database.BatchableContext Bc, List<ContentDocument> scope){
        Savepoint sp = Database.setSavepoint();
        List<ContentDocumentLink> cdlsToUpdate = new List<ContentDocumentLink>();
        
        try {
            for (ContentDocument cd :scope) {
                ContentDocument c = (ContentDocument)cd; //Grab the ContentDocument sObject - needed to avoid query locator error
                
                ContentDocumentLink[] cdlList = c.getSObjects('ContentDocumentLinks'); //grab all the related ContentDocumentLinks records
                if (cdlList != null) { //if there are related Custom_Object_One__c record
                    for (ContentDocumentLink cdl : cdlList) {
                        if (!String.valueOf(cdl.LinkedEntityId).startsWith('005') && !String.valueOf(cdl.LinkedEntityId).startsWith('02s')) {
                            cdl.ShareType = 'I';
                            cdlsToUpdate.add(cdl);
                        }                        
                    }
                }
            }
            
            if (!cdlsToUpdate.isEmpty()) {
                update cdlsToUpdate;
            }
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            Database.rollback(sp);
        }
    }
    
    global void finish(Database.BatchableContext Bc){

    }
}