trigger OpportunityTrigger on Opportunity (before insert, after insert, after update) {
    //Ankita A: 9 Nov 2019 Concierge Changes 
    if(trigger.isAfter && trigger.isInsert){
        //Update invoice records for after insert trigger
        OpportunityTriggerHandler.updateInvoices(Trigger.new);
    } else if(trigger.isAfter && trigger.isUpdate){
        //Ankita A: 23 Jan 2020: Update date/time fields when stage is updated	
        OpportunityTriggerHandler.populateOppDatetimeFields(Trigger.oldMap, Trigger.new);
        
        //Check if the ConciergeNeeded field is updated or not
        OpportunityTriggerHandler.isConciergeUpdated(Trigger.oldMap, Trigger.new);
        //Ankita A: 14 Nov Member Introduction: Citagenix Email changes
        //Send Member introduction email to the Provider specialist
        OpportunityTriggerHandler.sendBusinessEmails(Trigger.oldMap, Trigger.new);
    }
    
    if(trigger.isAfter && trigger.isInsert ){
        //OpportunityTriggerHandler.createProspectMatches(Trigger.new); 
    }else if(trigger.isAfter && trigger.isUpdate){
       /* List<Opportunity> milesUpdatedOppty = new List<Opportunity>();

        for( Integer ind = 0 ; ind < Trigger.new.size() ; ind ++ ){
            Opportunity newOpportunity = Trigger.new [ind];
            if( newOpportunity.Mile_Radius__c != Trigger.oldMap.get(newOpportunity.Id).Mile_Radius__c ){
                milesUpdatedOppty.add(newOpportunity);
            }
        }

        if( milesUpdatedOppty != null && !milesUpdatedOppty.isEmpty() ){
            OpportunityTriggerHandler.createProspectMatches(milesUpdatedOppty);
        }*/
    }
}