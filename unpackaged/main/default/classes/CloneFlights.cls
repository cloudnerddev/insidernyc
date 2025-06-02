public class CloneFlights {

    /**
     * Build a query of createable fields and clone flight, then return unsaved clone to component
     * @param flightId : Flight Id to clone
     * @param fieldsJson : Values of fields as inputted by the user
     * @return String : Id of the cloned flight
     * */
    @AuraEnabled
    public static Flight_Booking__c cloneFlightFields(String flightId, String flightJson) {
        System.debug('flightJson: ' + flightJson);
        Flight_Booking__c clonedFlightValues = (Flight_Booking__c)JSON.deserialize(flightJson, Flight_Booking__c.class);
        system.debug('clonedFlightValues: ' + clonedFlightValues);
        Map<String, Object> fieldsToValue = clonedFlightValues.getPopulatedFieldsAsMap();
        String flightQuery = 'SELECT Id, ';

        if(Schema.SObjectType.Flight_Booking__c.getRecordTypeInfosByName().size() > 1) {
            flightQuery += 'RecordTypeId, ';
        }
        
        //query all the fields in the page layout the user has filled out
        for( String fieldName : fieldsToValue.keySet() ) {
            if(!flightQuery.containsIgnoreCase(fieldName)) {
                flightQuery += fieldName + ', ';
            }
        }
        flightQuery += 'Logbook__c ';

        //flightQuery = flightQuery.removeEnd(', ');

        flightQuery += ' FROM Flight_Booking__c WHERE Id = :flightId';
        //get and clone the flight so we can use getCloneSourceId and isClone on the new flight
        Flight_Booking__c originalFlight = Database.query(flightQuery);
        Flight_Booking__c newFlight = originalFlight.clone(false, true);

        //apply new field values to cloned flight
        for( String fieldName : fieldsToValue.keySet() ) {
            newFlight.put(fieldName, fieldsToValue.get(fieldName));
        }
        /*
        try {
            insert newFlight;
        }catch(Exception e){
            throwException(e.getMessage());
        }*/

        return newFlight;
    }

    /**
     * Query flight line fields based on a fieldset, plus required fields we explicitly set
     * @param flightId : flight Id which is the source for the lines
     * */
    @AuraEnabled
    public static List<Airline_Ticket__c> getAirlineTickets(String flightId) {
        List<String> requiredSoqlFields = new List<String>{
                'Id'
        };
        List<Airline_Ticket__c> lstClonedTickets = new List<Airline_Ticket__c>();
        String lineItemQuery = 'SELECT ';

        //Get lines to query from the fieldset, unless it's in our required list, which we'll add later
        for (Schema.FieldSetMember f : SObjectType.Airline_Ticket__c.FieldSets.Clone_Airline_Ticket_Editable_Fields.getFields()) {
            if (!requiredSoqlFields.contains(f.getFieldPath())) {
                lineItemQuery += f.getFieldPath() + ', ';
            }
        }

        //Add in fields we require
        lineItemQuery += String.join(requiredSoqlFields, ',');
        lineItemQuery += ' FROM Airline_Ticket__c WHERE Flight__c = :flightId ORDER BY Contact__r.Name';

        try {
            lstClonedTickets = Database.query(lineItemQuery);
        }catch(Exception e){
            throwException('Error getting airline tickets: ' + e.getMessage());
        }

        return lstClonedTickets;
    }

    /**
     * Generate all the details required by a lightning:datatable to display the columns in our fieldset, and pass it back jsonified
     * */
    @AuraEnabled
    public static String getFieldset(){
        Schema.DescribeSObjectResult res = Airline_Ticket__c.sObjectType.getDescribe();

        String columnsJsonString = '';
        for (Schema.FieldSetMember f : SObjectType.Airline_Ticket__c.FieldSets.Clone_Airline_Ticket_Editable_Fields.getFields()) {
            if(f.getType() == Schema.DisplayType.Reference) {
                throwException('Fieldset error: Reference fields are incompatible.  Please remove or replace with a forumla');
            }
            String jsonPart = '{';
            jsonPart += '"label":"' + f.getLabel() + '",';
            jsonPart += '"type":"' + translateType(f.getType()) + '",';
            jsonPart += '"fieldName":"' + f.getFieldPath() + '"';
            if(res.fields.getMap().get(f.getFieldPath()).getDescribe().isCreateable()){
                jsonPart += ',"editable": "true"';
            }
            jsonPart += '},';
            columnsJsonString += jsonPart;
        }
        columnsJsonString = columnsJsonString.removeEnd(',');
        system.debug('columnsJsonString: ' + columnsJsonString);
        
        return '['+columnsJsonString+']';
    }

    /**
     * The type returned in a describe call doesn't match the allowed
     * values in Lightning Datatable column definitions, so translate them
     */
    @testVisible
    private static String translateType(Schema.DisplayType apexType){
        String ltngType;
        switch on apexType {
            when Boolean {
                ltngType = 'boolean';
            }
            when Currency {
                ltngType = 'currency';
            }
            when Date, DateTime, Time {
                ltngType = 'date';
            }
            when Email {
                ltngType = 'email';
            }
            when Address {
                ltngType = 'location';
            }
            when Integer, Double, Long {
                ltngType = 'number';
            }
            when Percent {
                ltngType = 'percent';
            }
            when Phone {
                ltngType = 'phone';
            }
            when URL {
                ltngType = 'url';
            }
            when else {
                ltngType = 'text';
            }
        }
        return ltngType;
    }

    /**
     * Clone flight line items, set values given in the datatable and attach to cloned flight
     * @param sourceFlightId : flight Id which is the source for cloning
     * @param clonedFlight : flight we will clone, to attach lines to
     * @param lstTickets : Airline Tickets which are going to be cloned
     * @param changes : Changes to existing lines
     * */
    @AuraEnabled
    public static String cloneAirlineTickets( Id sourceFlightId, Flight_Booking__c clonedFlight, List<Airline_Ticket__c> lstTickets, List<Airline_Ticket__c> changes){
        SavePoint sp = Database.setSavepoint();
        insert clonedFlight;
        Map<Id, Airline_Ticket__c> changesMap = new Map<Id, Airline_Ticket__c>();
        if(changes != null){
            changesMap.putAll(changes);
        }

        try {
            //update original lines with inline changes.
            //loop over changed fields and apply them to original lines
            for(Airline_Ticket__c at : lstTickets){
                if(changesMap.containsKey(at.Id)) {
                    //line has been changed in some way
                    Airline_Ticket__c changedLine = changesMap.get(at.Id);
                    //splits object into map of fieldName => fieldValue.
                    Map<String, Object> fieldsToValue = changedLine.getPopulatedFieldsAsMap();
                    for (String fieldName : fieldsToValue.keySet()) {
                        at.put(fieldName, fieldsToValue.get(fieldName));
                    }
                }
            }

            // Query the airline ticket fields from fieldset
            Set<String> setFlightAirlineTicketFields = new Set<String>();
            Map<String, Schema.SObjectField> mapFlightAirlineTicketFields = Schema.SObjectType.Airline_Ticket__c.fields.getMap();
            for( Schema.FieldSetMember f : SObjectType.Airline_Ticket__c.FieldSets.Clone_Airline_Ticket.getFields() ) {
                if( mapFlightAirlineTicketFields.get( f.getFieldPath() ).getDescribe().isCreateable() ) // Check if this field is createable for this user
                    setFlightAirlineTicketFields.add( f.getFieldPath().toLowerCase() );
            }

            // Check for the required fields on flight line item object
            // if they are not the part of the fieldset then add them in query explicitly
            for( String fieldName : mapFlightAirlineTicketFields.keySet() ){
                Schema.DescribeFieldResult desribeResult = mapFlightAirlineTicketFields.get( fieldName ).getDescribe();
                if( desribeResult.isCreateable() &&
                        !desribeResult.isNillable() &&
                        !desribeResult.isDefaultedOnCreate() &&
                        !setFlightAirlineTicketFields.contains( fieldName.toLowerCase() ) ) { // Check if field is required and not a part of fieldset

                    setFlightAirlineTicketFields.add( fieldName ); // Add to the query field list
                }
            }

            // Construct dynamic query from the fetched fields
            String queryForFlightLineItem = 'SELECT ' + String.join( new List<String>(setFlightAirlineTicketFields), ', ' ) +
                                            ' FROM Airline_Ticket__c WHERE Flight__c = \'' + sourceFlightId + '\'';

            List<Airline_Ticket__c> sourceAirlineTickets = Database.query( queryForFlightLineItem );
            
            // Create a map of flightLineItem objects so we can get its fields
            Map<Id, Airline_Ticket__c> mapflightTickets = new Map<Id, Airline_Ticket__c>(lstTickets);

            // Clone all the related flight airline tickets
            Schema.DescribeSObjectResult res = Airline_Ticket__c.sObjectType.getDescribe();
            List<Airline_Ticket__c> clonedAirlineTickets = new List<Airline_Ticket__c>();
            for(Airline_Ticket__c at : sourceAirlineTickets ) {
                //only add lines we have in our map from the datatable - don't want to clone deleted lines
                if( mapflightTickets.containsKey( at.Id ) ) {
                    Airline_Ticket__c clonedAt = at.clone( false, true, false, false );
                    clonedAt.Flight__c = clonedFlight.Id;

                    Airline_Ticket__c changedLine = mapflightTickets.get(at.Id);

                    Map<String, Object> fieldsToValue = changedLine.getPopulatedFieldsAsMap();
                    for (String fieldName : fieldsToValue.keySet()) {
                        if(res.fields.getMap().get(fieldName) != null && res.fields.getMap().get(fieldName).getDescribe().isCreateable()){
                            clonedAt.put(fieldName, fieldsToValue.get(fieldName));
                        }
                    }

                    clonedAirlineTickets.add( clonedAt );
                }
            }
            insert clonedAirlineTickets;
        }catch(Exception e) {
            Database.rollback(sp);
            throwException('Error cloning: ' + e.getMessage());
        }
        return clonedFlight.Id;
    }
    
    /**
     * Throwing an AuraHandledException is good for Lightning but not for debugging and testing since
     * logs only show "Script-thrown Exception" instead of real exception message.
     * Fix this by manually setting the message to match that of the exception.
     *
     * @param message exception message to throw
     */
    private static void throwException(String message){
        AuraHandledException ahe = new AuraHandledException(message);
        ahe.setMessage(message);
        throw ahe;
    }
}