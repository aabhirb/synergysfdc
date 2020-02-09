trigger ConciergeDetailTrigger on Concierge_Details__c (after insert, after update) {

    if(trigger.isAfter && trigger.isInsert){
        //Create Pod tracker object
        ConciergeDetailTriggerHandler.createPodTracker(Trigger.new);
        ConciergeDetailTriggerHandler.sendReservationSMS(Trigger.new, true, true, true);
        
    } else if(trigger.isAfter && trigger.isUpdate){
        //Check if the Pod Needed field is updated or not
        ConciergeDetailTriggerHandler.isPodNeededUpdated(Trigger.oldMap, Trigger.new);
        ConciergeDetailTriggerHandler.isConfirmationChckboxUpdated(Trigger.oldMap, Trigger.new);
    }
}