trigger ProspectMatchTrigger on Prospect_Match__c ( Before insert, After insert, Before update , after Update ) {

    if( Trigger.isAfter && Trigger.isUpdate){
        ProspectMatchTriggerHandler.processAfterUpdate( Trigger.new , Trigger.oldMap );
    }

}