public class flightBookingData {
    public String csID {get;set;}
    public String passengerNames {get{
        Set<Id> contactsSet = new Set<Id>();
        passengerNames = '';
        for (Airline_Ticket__c at : [select Id, Contact__c, Contact_Name__c From Airline_Ticket__c where Case__c =: csId Order By Contact_Name__c]) {
            if (!contactsSet.contains(at.Contact__c)) {
                if (passengerNames == '') {
                     passengerNames = at.Contact_Name__c;

                } else {
                     passengerNames = passengerNames + ', ' + at.Contact_Name__c;
                }
               
                contactsSet.add(at.Contact__c);
            }
        }
        
        return passengerNames; 
        
    }
        private set;}
}