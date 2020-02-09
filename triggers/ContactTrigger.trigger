/**
 * Created by abidap on 1/24/19.
 */

trigger ContactTrigger on Contact (after insert, after update , before insert, before update) {
    if(Trigger.isAfter){

        ContactTriggerHandler.updateProspectMatch(Trigger.New , Trigger.oldMap ); // Triggered after insert and after update

        if(Trigger.isUpdate){ // Only after  update
            ContactTriggerHandler.onAddressChangeForContact( Trigger.New , Trigger.oldMap );
            ContactTriggerHandler.onOMEMailAddressChangeForContact( Trigger.New , Trigger.oldMap );
        }

        if( !ContactTriggerHandler.isAddressChangeInitiated ){ // Triggered after insert and after update
            ContactTriggerHandler.geoCodeIncorrectAddress( Trigger.New  );
        }
    }else if( Trigger.isBefore){
        ContactTriggerHandler.setASAMappingValues(Trigger.New ); // // Triggered before  insert and before update
        ContactTriggerHandler.setCompensation(Trigger.New ); // // Triggered before  insert and before update
    }

}