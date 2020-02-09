/**
 * Created by abidap on 4/19/19.
 */

trigger ProposedDateTrigger on Proposed_Date__c (after insert, after update, before insert) {

    switch on Trigger.operationType{
        when BEFORE_INSERT{
            ProposedDateTriggerHandler.prePopulateContacts(Trigger.New);
        }
        when AFTER_INSERT {
            ProposedDateTriggerHandler.synchOpportunityChecklist(Trigger.New, Trigger.oldMap);
        }
        when AFTER_UPDATE {
            ProposedDateTriggerHandler.synchOpportunityChecklist(Trigger.New, Trigger.oldMap);
        }

    }
}