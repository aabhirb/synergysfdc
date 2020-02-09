trigger Opportunity_Line_Item_Trigger on Opportunity_Line_Item__c (after insert, after update, before insert , before update ) {
	
 	//Ankita A: 9 Nov 2019 Concierge Changes 
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        OpportunityLineItemTriggerHandler.createConciergeDetail(Trigger.new);
    }

    system.debug('Trigger =>'+Trigger.New);
    switch on Trigger.operationType{
        when AFTER_INSERT{
            OpportunityLineItemTriggerHandler.sendBusinessEmails(Trigger.New , Trigger.oldMap );
        }
        when  AFTER_UPDATE{
            OpportunityLineItemTriggerHandler.postToSlack(Trigger.New, Trigger.oldMap);
            OpportunityLineItemTriggerHandler.sendBusinessEmails(Trigger.New , Trigger.oldMap );
        }

        when BEFORE_INSERT{
            OpportunityLineItemTriggerHandler.prepopulateInvoiceName(Trigger.New);
            //OpportunityLineItemTriggerHandler.calculateInvoiceAmount( Trigger.New );
        }

        when BEFORE_UPDATE{
            //OpportunityLineItemTriggerHandler.calculateInvoiceAmount( Trigger.New );
        }
    }

}