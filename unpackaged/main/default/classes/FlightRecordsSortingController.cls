/* 
    * Class Name : FlightRecordsSortingController
    * Description : Class for FlightRecordsSortingController.
    * Created Date : 17/01/2024
*/
public class FlightRecordsSortingController {
    public static String recordId {get; set;}
    public List<Flight_Booking__c> relatedFlightRecords {get{
        
        return relatedFlightRecords = [SELECT Id,Airline__r.Name,Departure_City__c,Departure_Airport__c,Departure_Date__c,DepartureTimeForEmail__c,Arrival_City__c,Arrival_Airport__c,Arrival_Date__c,ArrivalDateforEmail__c
        FROM Flight_Booking__c
        WHERE Logbook__c =: recordId  Order by Departure_Date__c,DepartureTimeForEmail__c];
    } private set;}
}