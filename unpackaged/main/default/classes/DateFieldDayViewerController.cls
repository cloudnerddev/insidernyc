public with sharing class DateFieldDayViewerController {
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getDateFields(String objectApiName, Id recordId) {
        List<Map<String, String>> result = new List<Map<String, String>>();

        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
        if (sObjectType == null) return result;

        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();

        Set<String> systemFields = new Set<String>{
            'createddate', 'lastmodifieddate', 'systemmodstamp',
            'lastactivitydate', 'lastvieweddate', 'lastreferenceddate'
        };

        List<String> dateFields = new List<String>();
        for (String fieldName : fieldMap.keySet()) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDesc = field.getDescribe();
            
            if ((fieldDesc.getType() == Schema.DisplayType.Date || 
                 fieldDesc.getType() == Schema.DisplayType.DateTime) &&
                fieldDesc.isAccessible() &&
                !systemFields.contains(fieldName.toLowerCase())) {
                dateFields.add(fieldName);
            }
        }

        if (dateFields.isEmpty()) return result;

        // Check if object has RecordType field
        Boolean hasRecordType = fieldMap.containsKey('recordtypeid');
        
        String soql = 'SELECT ' + String.join(dateFields, ',');
        if (hasRecordType) {
            soql += ', RecordType.Name';
        }
        soql += ' FROM ' + objectApiName + ' WHERE Id = :recordId';
        

        
        SObject record = Database.query(soql);

        for (String fieldName : dateFields) {
            Object val = record.get(fieldName);
            if (val != null) {
                Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
                String dateValue;
                Boolean isDateTime = fieldDesc.getType() == Schema.DisplayType.DateTime;
                
                if (isDateTime) {
                    // For DateTime fields, return the full ISO string and let frontend handle timezone
                    DateTime dt = (DateTime) val;
                    dateValue = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'', 'GMT');
                } else {
                    // For Date fields, format as simple date string  
                    Date d = (Date) val;
                    dateValue = String.valueOf(d.year()) + '-' + 
                               String.valueOf(d.month()).leftPad(2, '0') + '-' + 
                               String.valueOf(d.day()).leftPad(2, '0');
                }
                
                result.add(new Map<String, String>{
                    'label' => fieldDesc.getLabel(),
                    'value' => dateValue,
                    'isDateTime' => String.valueOf(isDateTime)
                });
            }
        }

        // Sort by label alphabetically
        result.sort(new LabelComparator());

        // Add RecordType if available
        if (hasRecordType && record.getSobject('RecordType') != null) {
            result.add(new Map<String, String>{
                'label' => 'RecordType',
                'value' => String.valueOf(record.getSobject('RecordType').get('Name')),
                'isDateTime' => 'false'
            });
        }

        return result;
    }

    public class LabelComparator implements Comparator<Map<String, String>> {
        public Integer compare(Map<String, String> a, Map<String, String> b) {
            return a.get('label').compareTo(b.get('label'));
        }
    }
}