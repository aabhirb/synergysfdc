trigger RecipientStatusTrigger on dsfs__DocuSign_Recipient_Status__c (before insert, before update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        List<dsfs__DocuSign_Recipient_Status__c> recipientStatusToUpdate = new List<dsfs__DocuSign_Recipient_Status__c>(); 
        for(dsfs__DocuSign_Recipient_Status__c rs: Trigger.New){
            if(Trigger.isInsert){
                if(String.isNotBlank(rs.dsfs__Envelope_Id__c))
                    recipientStatusToUpdate.add(rs);
            }else{
                dsfs__DocuSign_Recipient_Status__c oldrs = Trigger.oldMap.get(rs.Id);
                
                if(rs.dsfs__Envelope_Id__c != oldrs.dsfs__Envelope_Id__c)
                {
                    recipientStatusToUpdate.add(rs);
                }  
            }
        }
        System.debug('recipientStatusToUpdate :'+ recipientStatusToUpdate);
        if(recipientStatusToUpdate.size()>0){
            RecipientStatusTriggerHandler.DocumentNameOnRs(recipientStatusToUpdate);
        }
        
    }
}