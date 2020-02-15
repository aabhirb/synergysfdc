/**l
 * Created by abidap on 3/24/19.
 */

trigger LeadTrigger on Lead (after insert, after update) {
    //Ankita A: 12 Feb 2020: Calculate Prospect Matches for Lead when new Lead enters the system
    if(trigger.isAfter && trigger.isInsert ){
        CustomLeadConvertController.calculateProspectMatchesForLead(new List<Id>(Trigger.newMap.keyset()), null);
    }
    LeadTriggerHandler.geoCodeIncorrectAddress(Trigger.new);
    
    if(trigger.isAfter && trigger.isUpdate ){
        //Ankita A: 10 Feb 2020: Populate date/time when status is changed
    	LeadTriggerHandler.populateDateTime(Trigger.new, Trigger.oldMap);
        LeadTriggerHandler.createProspectMatches(Trigger.new, Trigger.oldMap);
        
    }
    LeadTriggerHandler.triggerIntakeFollowUp(Trigger.new,Trigger.oldMap);
    //LeadTriggerHandler.createFollowUpTasks(Trigger.new,Trigger.oldMap);
    LeadTriggerHandler.completeFollowUpTasks(Trigger.new,Trigger.oldMap);
    LeadTriggerHandler.logCustomerAgreement(Trigger.new,Trigger.oldMap);    
    
}