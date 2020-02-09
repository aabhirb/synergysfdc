/**
 * Created by abidap on 3/24/19.
 */

trigger LeadTrigger on Lead (after update) {
    LeadTriggerHandler.geoCodeIncorrectAddress(Trigger.new);
    LeadTriggerHandler.triggerIntakeFollowUp(Trigger.new,Trigger.oldMap);
    //LeadTriggerHandler.createFollowUpTasks(Trigger.new,Trigger.oldMap);
    LeadTriggerHandler.completeFollowUpTasks(Trigger.new,Trigger.oldMap);
    LeadTriggerHandler.logCustomerAgreement(Trigger.new,Trigger.oldMap);    
    
}