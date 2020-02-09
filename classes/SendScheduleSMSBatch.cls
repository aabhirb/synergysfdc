global class SendScheduleSMSBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date threeDaysBeforeTxDate = System.today() + 3;
        List<String> fields = new List<String>{
            'Concierge_Details__c',
            'Concierge_Details__r.is_Car_Confirmed__c',
            'Concierge_Details__r.is_Hotel_Confirmed__c',
            'Concierge_Details__r.is_Flight_Confirmed__c'   
        };
            
        String query = 'SELECT Id, ' + String.join(fields, ', ')
            + ' FROM Opportunity_Line_Item__c WHERE Treatment_Date__c = :threeDaysBeforeTxDate' ;
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity_Line_Item__c> scope){
		List<Concierge_Details__c> carRemConciergeLst = new List<Concierge_Details__c>(); 
        List<Concierge_Details__c> hotelRemConciergeLst = new List<Concierge_Details__c>(); 
        List<Concierge_Details__c> flightRemConciergeLst = new List<Concierge_Details__c>(); 
        
        for(Opportunity_Line_Item__c invoice: scope){
            if(invoice.Concierge_Details__r.is_Car_Confirmed__c){
                carRemConciergeLst.add(invoice.Concierge_Details__r);
            }
            if(invoice.Concierge_Details__r.is_Hotel_Confirmed__c){
                hotelRemConciergeLst.add(invoice.Concierge_Details__r);
            }
            if(invoice.Concierge_Details__r.is_Flight_Confirmed__c){
                flightRemConciergeLst.add(invoice.Concierge_Details__r);
            }
        }
        //If one of the sms concierge list is not empty
        if(!carRemConciergeLst.isEmpty() || !hotelRemConciergeLst.isEmpty() || !flightRemConciergeLst.isEmpty()){
            List<smagicinteract__SMS_Template__c> smsTemplates = [SELECT Id, smagicinteract__Name__c, smagicinteract__Text__c 
                                                              FROM smagicinteract__SMS_Template__c
                                                              WHERE smagicinteract__Name__c IN (
                                                                  'Reservation Reminder Car',
                                                                  'Reservation Reminder Hotel',
                                                                  'Reservation Reminder Flight'
                                                              )];
            Map<String, smagicinteract__SMS_Template__c> nameToTemplateMap = new Map<String, smagicinteract__SMS_Template__c>();
            for(smagicinteract__SMS_Template__c template : smsTemplates){
                nameToTemplateMap.put(template.smagicinteract__Name__c, template);
            }
            //Call a method which sends sms
            if(!carRemConciergeLst.isEmpty()){
                SendSMSUtility.sendConciergeReservationSMS(carRemConciergeLst, nameToTemplateMap.get('Reservation Reminder Car'));
            }
            if(!hotelRemConciergeLst.isEmpty()){
                SendSMSUtility.sendConciergeReservationSMS(hotelRemConciergeLst, nameToTemplateMap.get('Reservation Reminder Hotel'));
            }
            if(!flightRemConciergeLst.isEmpty()){
                SendSMSUtility.sendConciergeReservationSMS(flightRemConciergeLst, nameToTemplateMap.get('Reservation Reminder Flight'));
            }
            
        }
    }
    
    global void finish(Database.BatchableContext BC){
        // send batch execution email;
    }
}