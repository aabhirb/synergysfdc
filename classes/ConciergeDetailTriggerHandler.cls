public class ConciergeDetailTriggerHandler {
    
    //Updating 
    public static List<smagicinteract__SMS_Template__c> smsTemplates = new List<smagicinteract__SMS_Template__c>();
    public static void isPodNeededUpdated(Map<Id, Concierge_Details__c> oldMap, List<Concierge_Details__c> conciergeNewLst){
        //Check if the Pod Needed field is updated or not
        List<Concierge_Details__c> lstConciergeDetails = new List<Concierge_Details__c>();
        for(Concierge_Details__c conciergeObj : conciergeNewLst){
            //If the POD_Needed__c field is changed 
            if(conciergeObj.POD_Needed__c != oldMap.get(conciergeObj.Id).POD_Needed__c){
                //Add the concierge object to the list for creation of Pod Tracker object
                lstConciergeDetails.add(conciergeObj);
            }
        }
        //Create the Pod Tracker object for the concierge details
        createPodTracker(lstConciergeDetails);
    }
    
    public static void createPodTracker(List<Concierge_Details__c> conciergeLst){
        List<POD_Tracker__c> podTrackers = [SELECT Id, Last_Count__c FROM POD_Tracker__c];
        List<POD_Tracker__c> podTrackersToInsert = new List<POD_Tracker__c>();
        
        //Error list
        List<String> errorList = new List<String>();
        for(Opportunity_Line_Item__c invoice : [SELECT Id, Treatment_Date__c, Concierge_Details__c,
                                                Opportunity__r.GP_Contact__r.Account.Name
                                                FROM Opportunity_Line_Item__c WHERE Concierge_Details__c IN: conciergeLst AND Concierge_Details__r.Pod_Needed__c = true]){
            Boolean isPodTrackerBooked = false;
            for(POD_Tracker__c podTracker : podTrackers){
                if((podTracker.Last_Count__c == invoice.Treatment_Date__c) || 
                   (podTracker.Last_Count__c == invoice.Treatment_Date__c + 1) ||
                   (podTracker.Last_Count__c == invoice.Treatment_Date__c - 1)){
                       isPodTrackerBooked = true;
                       errorList.add('POD is already booked on ' +podTracker.Last_Count__c 
                                     +' at ' +invoice.Opportunity__r.GP_Contact__r.Account.Name + '\n');
                       break;
                   }
            }
            //If Pod tracker is not Booked within that treatment date
            if(!isPodTrackerBooked){
                //Create record of Pod Tracker
                POD_Tracker__c podTrackerObj = new POD_Tracker__c(Concierge_Details__c = invoice.Concierge_Details__c,
                                                                  Last_Count__c = invoice.Treatment_Date__c);
                podTrackersToInsert.add(podTrackerObj);            
            }
        }
        
        insert podTrackersToInsert;
        //Handle errors for Concierge record for which Pod trackers could not be inserted
        if(errorList.size() > 0){
            throw (new TriggerException('Error: ' +errorList));
        }
    }
	
    public static void isConfirmationChckboxUpdated(Map<Id, Concierge_Details__c> oldMap, List<Concierge_Details__c> conciergeNewLst){
        List<Concierge_Details__c> carResvConciergeLst = new List<Concierge_Details__c>(); 
        List<Concierge_Details__c> hotelResvConciergeLst = new List<Concierge_Details__c>(); 
        List<Concierge_Details__c> flightResvConciergeLst = new List<Concierge_Details__c>(); 
        
        for(Concierge_Details__c conciergeDetail : conciergeNewLst){
            //If Car confirmed is updated add it to the set of sending SMS
            if(conciergeDetail.is_Car_Confirmed__c != oldMap.get(conciergeDetail.Id).is_Car_Confirmed__c){
                carResvConciergeLst.add(conciergeDetail);
            }
            //If Hotel Confirmed is updated add it to the set of sending SMS
            if(conciergeDetail.is_Hotel_Confirmed__c != oldMap.get(conciergeDetail.Id).is_Hotel_Confirmed__c
              && conciergeDetail.is_Hotel_Confirmed__c){
                hotelResvConciergeLst.add(conciergeDetail);
            }
            //If Flight confirmed is updated add it to the set of sending SMS
            if(conciergeDetail.is_Flight_Confirmed__c != oldMap.get(conciergeDetail.Id).is_Flight_Confirmed__c
              && conciergeDetail.is_Flight_Confirmed__c){
                flightResvConciergeLst.add(conciergeDetail);
            }
        }
        //Pass the set to send SMS
        sendReservationSMS(carResvConciergeLst, true, false, false);
        sendReservationSMS(hotelResvConciergeLst, false, true, false);
        sendReservationSMS(flightResvConciergeLst, false, false, true);
    }
    
    public static void sendReservationSMS(List<Concierge_Details__c> conciergeLst, Boolean sendCarResv, Boolean sendHotelResv, Boolean sendFlightResv){
        List<Concierge_Details__c> carResvConciergeLst = new List<Concierge_Details__c>(); 
        List<Concierge_Details__c> hotelResvConciergeLst = new List<Concierge_Details__c>(); 
        List<Concierge_Details__c> flightResvConciergeLst = new List<Concierge_Details__c>(); 
        for(Concierge_Details__c conciergeDetail: conciergeLst){
            if(conciergeDetail.is_Car_Confirmed__c && sendCarResv){
                carResvConciergeLst.add(conciergeDetail);
            }
            if(conciergeDetail.is_Hotel_Confirmed__c && sendHotelResv){
                hotelResvConciergeLst.add(conciergeDetail);
            }
            if(conciergeDetail.is_Flight_Confirmed__c && sendFlightResv){
                flightResvConciergeLst.add(conciergeDetail);
            }
        }
        
        //If one of the sms concierge list is not empty
        if(!carResvConciergeLst.isEmpty() || !hotelResvConciergeLst.isEmpty() || !flightResvConciergeLst.isEmpty()){
            if(smsTemplates.isEmpty()){
               smsTemplates = [SELECT Id, smagicinteract__Name__c, smagicinteract__Text__c 
                                                              FROM smagicinteract__SMS_Template__c
                                                              WHERE smagicinteract__Name__c IN (
                                                                  'Concierge Car Reservation',
                                                                  'Concierge Hotel Reservation',
                                                                  'Concierge Flight Reservation'
                                                              )];
            } 
            Map<String, smagicinteract__SMS_Template__c> nameToTemplateMap = new Map<String, smagicinteract__SMS_Template__c>();
            for(smagicinteract__SMS_Template__c template : smsTemplates){
                nameToTemplateMap.put(template.smagicinteract__Name__c, template);
            }
            //Call a method which sends sms
            try{
                if(!carResvConciergeLst.isEmpty()){
                    System.debug('calling send sms');
                    SendSMSUtility.sendConciergeReservationSMS(carResvConciergeLst, nameToTemplateMap.get('Concierge Car Reservation'));
                }
                if(!hotelResvConciergeLst.isEmpty()){
                    SendSMSUtility.sendConciergeReservationSMS(hotelResvConciergeLst, nameToTemplateMap.get('Concierge Hotel Reservation'));
                }
                if(!flightResvConciergeLst.isEmpty()){
                    SendSMSUtility.sendConciergeReservationSMS(flightResvConciergeLst, nameToTemplateMap.get('Concierge Flight Reservation'));
                }
            } catch(Exception e){
                //Throw the caught exception
                throw (new TriggerException('Error: ' +e.getMessage()));
            }
            
        }
    }
    
    public class TriggerException extends Exception {}
}