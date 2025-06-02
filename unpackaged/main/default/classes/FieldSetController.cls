/***********************************************************
* Date: 2019-July-31
* Developer: Linda Nguyen
* Description: Installed fieldSetForm Package
*
* --CHANGE LOG--
* DATE                DEVELOPER        CHANGE
* 2019-July-31        Linda Nguyen     Tweaked for Insider
************************************************************/
public class FieldSetController {

    @AuraEnabled
    public static List<String> getTypeNames() {
        Map<String, Schema.SObjectType> types = Schema.getGlobalDescribe();
        List<String> typeNames = new List<String>();
        String typeName = null;
        List<String> fsNames;
        for (String name : types.keySet()) {
            if (hasFieldSets(name)) {
                typeNames.add(name);        
            }
        }
        return typeNames;
    }

    @AuraEnabled
    public static Boolean hasFieldSets(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        return !fsMap.isEmpty();
    }

    @AuraEnabled
    public static List<String> getFieldSetNames(String typeName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        List<String> fsNames = new List<String>();
        for (String name : fsMap.keySet()) {
            fsNames.add(name);
        }
        return fsNames;
    }

    @AuraEnabled
    public static List<FieldSetMember> getFields(String typeName, String fsName, String recId) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        Schema.DescribeSObjectResult describe = targetType.getDescribe();
        Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
        Schema.FieldSet fs = fsMap.get(fsName);
        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        List<FieldSetMember> fset = new List<FieldSetMember>();
        
        String strQuery = 'SELECT ';
        for (Schema.FieldSetMember f: fieldSet) {
            strQuery += f.getFieldPath() + ', ';
        }
        
        //Add recordType.Name for Account object
        if (typeName=='Account') {
            strQuery += 'RecordType.Name, ';
        }
        
        strQuery += 'Id, Name FROM ' + typeName + ' WHERE Id = :recId LIMIT 1';
        SObject sObj = Database.query(strQuery);
        System.debug('strQuery: ' + strQuery);
        System.debug('sObj: ' + sObj);
        
        for (Schema.FieldSetMember f: fieldSet) {
            Boolean renderField = true;
            //Ser render field to false on account legal entities
            System.debug('typeName1: ' + typeName);
            System.debug('f.fieldpath: ' + f.fieldpath);

            if (typeName=='Account' && f.fieldpath.contains('__pc')) {
                String recordTypeName = (String)sObj.get(Schema.Account.RecordType.Name);
                String rtName = Schema.getGlobalDescribe().get(typeName).getDescribe().getRecordTypeInfosById().get((String)sObj.get('RecordTypeId')).getName();
                System.debug('rtName: ' + rtName);

                if (rtName.contains('Legal Entity')) {
                	renderField = false;
                }
            }
            
            System.debug('renderField: ' + renderField);
            fset.add(new FieldSetMember(f, (String)sObj.get(f.fieldpath), renderField));
        }
        system.debug('fset: ' + fset);
        return fset;
    }
    
    //This method is stamp the audit field if it's set on the lightning component
    @AuraEnabled
    public static void updateAuditField(String typeName, String auditField, String recId) {
        String strQuery = 'SELECT Id, ';
        strQuery += auditField + ' FROM ' + typeName + ' WHERE Id = :recId LIMIT 1';
        SObject sObj = Database.query(strQuery);
        System.debug('strQuery: ' + strQuery);
        System.debug('sObj: ' + sObj);
        System.debug('auditField: ' + auditField);
        sObj.put(auditField,DateTime.now().format('MMMM dd, yyyy \'at\' hh:mm:ss:SSS a z'));
        Database.update(sObj);
    }
    
    //This method is to update the reason field if it's there
    @AuraEnabled
    public static void updateReasonField(String typeName, String fieldName, String recId, String reason) {
        System.debug('typeName: ' + typeName);
        System.debug('fieldName: ' + fieldName);
        System.debug('recId: ' + recId);
        System.debug('reason: ' + reason);

        String strQuery = 'SELECT Id, ';
        strQuery += fieldName + ' FROM ' + typeName + ' WHERE Id = :recId LIMIT 1';
        SObject sObj = Database.query(strQuery);
        System.debug('strQuery: ' + strQuery);
        System.debug('sObj: ' + sObj);
        sObj.put(fieldName,reason);
        Database.update(sObj);
    }
    
}