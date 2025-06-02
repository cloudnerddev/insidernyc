/* 
    * Class Name : ItineraryTemplateController
    * Description : Class for ItineraryTemplateController.
    * Created Date : 13/04/2023
*/
public with sharing class ItineraryTemplateController {
    public Itinerary__c thisItinerary {get; set;} 
    public String currentRecordId {get; set;}   
    public List<Case> relatedLogBooks {get; set;} 
    public Map<String, LogBook_Record__mdt> metadataLogBooks {get; set;} 
    public List<WrapperForImage> imgWrapper {get;set;}
    public List<Flight_Booking__c> relatedflightBooks {get; set;} 
    public List<WrapperForHeader> headerList {get; set;}   
    public String Amenity_Order_RI {get; set;}
    public String Service_Booking_RI {get; set;}
    public String Charter_RI {get; set;}
    public String Car_Rental_RI {get; set;}
    public String Car_Service_RI {get; set;}
    public String DiningReservation_RI {get; set;}
    public String Errand_RI {get; set;}
    public String Event_Booking_RI {get; set;}
    public String Event_Tickets_RI {get; set;}
    public String Flight_Booking_Single_Person_RI {get; set;}
    public String Floral_Booking_RI {get; set;}
    public String General_Initial_Request_RI {get; set;}
    public String Hotel_Booking_RI {get; set;}
    public String House_Villa_Booking_RI {get; set;}
    public String Nightclub_Lounge_Reservation_RI {get; set;}
    public String Research_RI {get; set;}
    public String Tour_Booking_RI {get; set;}
    public String Train_Booking_RI {get; set;}
    public String Messenger_Service_RI {get; set;}
    public String Travel_Planning_RI {get; set;}
    public ItineraryTemplateController() {
        currentRecordId = ApexPages.currentPage().getParameters().get('id');
        relatedflightBooks = new List<Flight_Booking__c>();
        relatedLogBooks = new List<Case>();
        metadataLogBooks = new Map<String, LogBook_Record__mdt>();
        headerList = new List<WrapperForHeader>();
        getItinerary();
    }
    /* ***********************************************************************************************************************        
        @Method_Name : getItinerary       
        @Method_Description : Method is used to get data to show it on VF page as a PDF.    
    ************************************************************************************************************************** */
    public void getItinerary(){
        metadataLogBooks = LogBook_Record__mdt.getAll();
        Amenity_Order_RI = metadataLogBooks.get('Amenity_Order').Record_Type_Id__c;
        Service_Booking_RI = metadataLogBooks.get('Service_Booking').Record_Type_Id__c;
        Charter_RI = metadataLogBooks.get('Charter').Record_Type_Id__c;
        Car_Rental_RI = metadataLogBooks.get('Car_Rental').Record_Type_Id__c;
        Car_Service_RI = metadataLogBooks.get('Car_Service').Record_Type_Id__c;
        DiningReservation_RI = metadataLogBooks.get('DiningReservation').Record_Type_Id__c;
        Errand_RI = metadataLogBooks.get('Errand').Record_Type_Id__c;
        Event_Booking_RI = metadataLogBooks.get('Event_Booking').Record_Type_Id__c;
        Event_Tickets_RI = metadataLogBooks.get('Event_Tickets').Record_Type_Id__c;
        Flight_Booking_Single_Person_RI = metadataLogBooks.get('Flight_Booking_Single_Person').Record_Type_Id__c;
        Floral_Booking_RI = metadataLogBooks.get('Floral_Booking').Record_Type_Id__c;
        General_Initial_Request_RI = metadataLogBooks.get('General_Initial_Request').Record_Type_Id__c;
        Hotel_Booking_RI = metadataLogBooks.get('Hotel_Booking').Record_Type_Id__c;
        House_Villa_Booking_RI = metadataLogBooks.get('House_Villa_Booking').Record_Type_Id__c;
        Nightclub_Lounge_Reservation_RI = metadataLogBooks.get('Nightclub_Lounge_Reservation').Record_Type_Id__c;
        Research_RI = metadataLogBooks.get('Research').Record_Type_Id__c;
        Tour_Booking_RI = metadataLogBooks.get('Tour_Booking').Record_Type_Id__c;
        Train_Booking_RI = metadataLogBooks.get('Train_Booking').Record_Type_Id__c;
        Messenger_Service_RI = metadataLogBooks.get('Messenger_Service').Record_Type_Id__c;
        Travel_Planning_RI = metadataLogBooks.get('Travel_Planning').Record_Type_Id__c;

        thisItinerary = [SELECT Id, Name, Start_Date__c, End_Date__c,Intro_Picture__c FROM Itinerary__c WHERE Id =:currentRecordId];

        relatedLogBooks = [SELECT   Id,
                                    Currency__c,
                                    Date__c,
                                    Description,
                                    Description__c,
                                    Subject,
                                    Check_In_Date__c,
                                    Check_In_Time__c,
                                    Check_In_Day__c ,
                                    Check_Out_Date__c,
                                    Check_Out_Day__c,
                                    Check_Out_Time__c,
                                    of_Nights__c,
                                    Room_Type__c,
                                    Room_Rate__c,
                                    Cancellation_Policy__c,
                                    Order_Confirmation__c,
                                    Vendor_Address__c,
                                    Vendor_Phone_Formatted__c,
                                    Confirmed_With__c, 
                                    CaseNumber,Reference_Date__c,
                                    Vendor_Phone__c,
                                    Time__c,
                                    Time_real__c,
                                    Vendor__c,
                                    Vendor__r.Name,
                                    Items_Ordered__c,
                                    Recipient_Name__c,
                                    Recipient_s_Address__c,
                                    Note_Card__c,
                                    Total_Price__c,
                                    Special_Requests_Notes__c,
                                    Delivery_Date__c,
                                    Return_Policy__c,
                                    Reconfirmed_With__c,
                                    Vendor_Cross_Streets__c,
                                    Insider_Amenities_Include__c,
                                    Membership_Number__c,
                                    Number_in_Party__c,
                                    Day_of_Week_Date__c,
                                    Guest_Information_Special_Instructions__c,
                                    Appointment_Address__c,
                                    Resy_Language__c,
                                    Type_of_Vehicle__c,
                                    Pickup_Day__c,
                                    Pickup_Time__c,
                                    Pickup_Location_Phone__c,
                                    Pick_Up_Location_and_Address__c,
                                    Pickup_Location_Phone_Formatted__c,
                                    Number_of_Days_Rental__c,
                                    Drop_off_Date__c,
                                    Drop_Off_Day__c,
                                    Drop_off_Time__c,
                                    Delivery_Location_and_Address_text__c,
                                    Price_per_Day__c,
                                    Membership_Status__c,
                                    Rewards_Program_Phone__c,
                                    RecordType.Name,
                                    Contact.FirstName,
                                    Contact.LastName,
                                    Person_Using__r.FirstName,
                                    Person_Using__r.LastName,
                                    Number_of_Passengers__c,
                                    Passenger_Cell__c,
                                    Wait_Return__c,
                                    Airline_Flight_Origin_City__c,
                                    Name_of_Boat_Yacht__c,
                                    Day_of_Departure__c,
                                    Departure_Time__c,
                                    Departure_Location__c,
                                    Itinerary_Stops__c,
                                    Day_of_Destination_Arrival__c,
                                    Destination_Arrival_Time__c,
                                    Arrival_Location__c,
                                    Type_of_Vessel__c,
                                    On_Site_Contact__c,
                                    Event__c,
                                    Venue__c,
                                    Venue__r.Name,
                                    Venue_Address__c,
                                    Venue_Cross_Streets__c,
                                    Number_of_Tickets__c,
                                    Package_Pass_Name__c,
                                    Package_Pass_Details__c,
                                    Section_For_Email__c,
                                    Seat_Location__c,
                                    Notes_Pickup_Instructions__c,
                                    Villa_House_Details__c,
                                    Rental_Address__c,
                                    Male_Female_Ratio__c,
                                    Table_Minimum_excluding_tax_gratuity__c,
                                    Meeting_Location__c,
                                    Meeting_Address_and_Cross_Streets__c,
                                    Day_of_Booking__c,
                                    Time_of_Booking__c,
                                    Duration__c,
                                    Number_of_people__c,
                                    Price_per_Person__c,
                                    Departure_City__c,
                                    Train_Line_Number__c,
                                    Ticket__c,
                                    Seat__c,
                                    Destination_City__c,
                                    Price_per_Ticket__c,
                                    Refundable__c,
                                    Recipient_Name__r.FirstName,
                                    Recipient_Name__r.LastName,
                                    Delivery_Day__c,
                                    Person_Using_Name__c,
                                    Menu_Pricing_Minimum__c,
                                    Recipient_s_Phone_Formatted__c,
                                    Confirmation_Date_for_Email__c,
                                    Reconfirmation_Date_for_Email__c,
                                    Pickup_Date__c,
                                    Date_of_Departure__c,
                                    Destination_Arrival_Date__c,
                                    Section__c,
                                    DateofBooking__c,
                                    Row__c,
                                    Vendor__r.Itinerary_Image__c, 
                                    Itinerary_Image__c,
                                    Items_Ordered_Type_of_Arrangements_rich__c,
                                    Return_policy_rich__c,
                                    Special_Requests_Notes_rich__c,
                                    Description_rich__c,
                                    Cancellation_Policy_rich__c,
                                    Guest_Information_Special_rich__c,
                                    Menu_Pricing_Minimum_rich__c,
                                    Instructions_rich__c,
                                    Location_Note_rich__c,
                                    Package_pass_details_rich__c,
                                    Refundable_Non_Refundable_rich__c,
                                    Insider_amenities_include_rich__c,
                                    House_or_villa_name_rich__c,
                                    Villa_house_details_rich__c,
                                    Delivery_Instructions_rich__c,
                                    Table_Minimum_rich__c,
                                    Occasion_reason_rich__c,
                                    Research_rich__c,
                                    X24_hour_contact_rich__c,
                                    Trip_information_rich__c,
                                    Flight_information_rich__c,
                                    Traveler_information_rich__c,
                                    Trip_information__c,
                                    Flight_information__c,
                                    Traveler_information__c,
                                    Dynamic_Subject__c,
                                    Departure_Location_and_Address__c,
                                    Destination_Location_and_Address__c,
                                    Destination_Phone__c,
                                    RecordTypeId,
                                    Itinerary_Header__c,
                                    Itinerary_Middle__c,
                                    Itinerary_footer__c,
                                    SortTime__c,
                                    (SELECT    Id,
                                        Departure_Date__c,
                                        Airline__r.Name,
                                        Name,
                                        Refundable__c,
                                        Departure_City__c,
                                        Arrival_Airport__c,
                                        Arrival_City__c,
                                        Departure_Airport__c,
                                        Duration__c,
                                        Arrival_Date__c FROM Flight_Bookings__r),
                                    (SELECT Id,
                                        Flight__c,
                                        Contact_Name__c,
                                        Seat__c,
                                        Class__c,
                                        Ticket_Number__c,
                                        Frequent_Flyer_Number__r.Name,
                                        Global_Entry_TSA__c,
                                        Notes__c FROM Passengers__r) FROM Case WHERE Itinerary__c =:currentRecordId Order by Reference_Date__c Asc, SortTime__c];

        List<string> allflight  = new List<string>();
        imgWrapper = new List<WrapperForImage>();
        Boolean ifPage = false;
        Datetime withBoth;
        for(Case ca:relatedLogBooks){
            if(ca.SortTime__c != null){
                withBoth = Datetime.newInstance(ca.Reference_Date__c, ca.SortTime__c);
            } else {
                withBoth = Datetime.newInstance(ca.Reference_Date__c, Time.newInstance(0, 0, 0, 0));
            }
            if(ca.RecordTypeId == Flight_Booking_Single_Person_RI){
                allflight.add(ca.Id);
            }else{
                headerList.add(new WrapperForHeader(withBoth, ca.Dynamic_Subject__c, ca.SortTime__c));
                /*if(ca.RecordTypeId == Car_Rental_RI|| ca.RecordTypeId == Car_Service_RI || ca.RecordTypeId == Charter_RI || ca.RecordTypeId == Event_Tickets_RI|| ca.RecordTypeId == Research_RI|| ca.RecordTypeId == Messenger_Service_RI|| ca.RecordTypeId == Travel_Planning_RI){
                    //Static Resource
                    imgWrapper.add(new WrapperForImage(ca, null, true, false, false, ifPage, ca.Reference_Date__c, ca.SortTime__c));
                }else */
                if(ca.Itinerary_Image__c != null ){
                    //Child
                    imgWrapper.add(new WrapperForImage(ca, null, false, false, true, ifPage, withBoth, ca.SortTime__c));
                }else if(ca.Itinerary_Image__c == null && ca.Vendor__r.Itinerary_Image__c != null){
                    //Parent
                    imgWrapper.add(new WrapperForImage(ca, null, false, true, false, ifPage, withBoth, ca.SortTime__c));
                }else{
                    imgWrapper.add(new WrapperForImage(ca, null, false, false, false, ifPage, withBoth, ca.SortTime__c));
                }
            }
            ifPage = true;
        }
        relatedflightBooks = [SELECT    Id,
                                        Departure_Date__c,
                                        Airline__r.Name,
                                        Name,
                                        Refundable__c,
                                        Departure_City__c,
                                        Arrival_Airport__c,
                                        Arrival_City__c,
                                        Departure_Airport__c,
                                        Duration__c,
                                        Arrival_Date__c,
                                        Departure_Terminal__c,
                                        DepartureTimeForEmail__c,
                                        ArrivalDateforEmail__c,
                                        Arrival_Terminal__c,
                                        Notes__c,DepartureTime__c,
                                        Name_for_Itinerary__c,
                                        Logbook__c
                                        FROM Flight_Booking__c WHERE Logbook__c IN :allflight ORDER BY Departure_Date__c ];
        for(Flight_Booking__c fl:relatedflightBooks){
            headerList.add(new WrapperForHeader(fl.DepartureTimeForEmail__c, fl.Name_for_Itinerary__c, fl.DepartureTime__c));
            
            for(Case ca:relatedLogBooks){
                if(fl.Logbook__c == ca.Id){
                    if(ca.Itinerary_Image__c != null ){
                        //Child
                        imgWrapper.add(new WrapperForImage(ca, fl, false, false, true, ifPage, fl.DepartureTimeForEmail__c, fl.DepartureTime__c));
                    }else if(ca.Itinerary_Image__c == null && ca.Vendor__r.Itinerary_Image__c != null){
                        //Parent
                        imgWrapper.add(new WrapperForImage(ca, fl, false, true, false, ifPage, fl.DepartureTimeForEmail__c, fl.DepartureTime__c));
                    }else{
                        imgWrapper.add(new WrapperForImage(ca, fl, false, false, false, ifPage, fl.DepartureTimeForEmail__c, fl.DepartureTime__c));
                    }
                }
            }
        }
        headerList.sort();
        imgWrapper.sort();
    }
    /* **********************************************************************************************************    
        @WrapperClass_Name : WrapperForImage   
        @WrapperClass_Description : Wrapper to store Image & Logbook records.    
    ********************************************************************************************************** */
    public class WrapperForImage implements Comparable  {
        
        public Case relatedLog {get; set;}
        public boolean isParentImage {get; set;}
        public boolean isChildImage {get; set;}
        public boolean isStaticResource {get; set;} 
        public boolean isPageBreak {get; set;} 
        public DateTime Reference_Date {get; set;}
        public Flight_Booking__c relatedFlight {get; set;}
        public Time sTime {get; set;}
        public WrapperForImage(Case ca, Flight_Booking__c relatedFlight, Boolean staRs, Boolean isParent, Boolean isChild, Boolean isPageBreak, DateTime Reference_Date, Time sTime){
            this.isParentImage = isParent;
            this.isChildImage = isChild;
            this.isStaticResource = staRs;
            this.relatedLog = ca;
            this.isPageBreak = isPageBreak;
            this.Reference_Date = Reference_Date;
            this.relatedFlight = relatedFlight;
            this.sTime = sTime;
        }
        public integer compareTo(Object instance){
            WrapperForImage that = (WrapperForImage)instance;
            if (this.Reference_Date > that.Reference_Date) return 1;
            else if (this.Reference_Date < that.Reference_Date) return -1;
            else {
                // First value the same, consider second value
                if (this.sTime > that.sTime) {
                    return 1;
                } else if (this.sTime < that.sTime) {
                    return -1;
                } else {
                    return 0;
                }          
            } 
        }
    }
    /* **********************************************************************************************************    
        @WrapperClass_Name : WrapperForHeader   
        @WrapperClass_Description : Wrapper to store Hearder details.    
    ********************************************************************************************************** */
    public class WrapperForHeader implements Comparable{
        
        public DateTime Reference_Date {get; set;}
        public String subject {get; set;}
        public Time sTime {get; set;}
        public WrapperForHeader(DateTime Reference_Date, String subject, Time sTime){
            this.Reference_Date = Reference_Date;
            this.subject = subject;
            this.sTime = sTime;
        }
        public integer compareTo(Object instance){
            WrapperForHeader that = (WrapperForHeader)instance;
            if (this.Reference_Date > that.Reference_Date) return 1;
            if (this.Reference_Date < that.Reference_Date) return -1;
            else {
                // First value the same, consider second value
                if (this.sTime < that.sTime) return 1;
                else if (this.sTime > that.sTime)  return -1;
                else return 0;         
            } 
        }
    }
}