public with sharing class DateFieldDayViewerController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getDateFields(String objectApiName, Id recordId, String fieldSetName) {
        List<Map<String, String>> result = new List<Map<String, String>>();

        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
        if (sObjectType == null) return result;

        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        Schema.FieldSet fieldSet = describeResult.fieldSets.getMap().get(fieldSetName);
        if (fieldSet == null) return result;

        List<Schema.FieldSetMember> fields = fieldSet.getFields();

        List<String> fieldNames = new List<String>();
        for (Schema.FieldSetMember f : fields) {
            fieldNames.add(f.getFieldPath());
        }

        String soql = 'SELECT RecordType.Name, ' + String.join(fieldNames, ',') + ' FROM ' + objectApiName + ' WHERE Id = :recordId';
        SObject record = Database.query(soql);

        for (Schema.FieldSetMember field : fields) {
            String api = field.getFieldPath();
            Object val = record.get(api);

            if (val != null && (val instanceof Date || val instanceof DateTime)) {
                result.add(new Map<String, String>{
                    'label' => field.getLabel(),
                    'value' => String.valueOf(val)
                });
            }

            
        }

        result.add(new Map<String, String>{
            'label' => 'RecordType',
            'value' => String.valueOf(record.getSobject('RecordType').get('Name'))
        });

        return result;
    }
}