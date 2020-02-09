/* Class Name - RecipientStatusTriggerHandler
Created by - Sujata P Galinde
Description - Class for Docu Sign Recipient Status Trigger handler
*/

public class RecipientStatusTriggerHandler {
    //To update Recipient Status document name which matches with its respective Envelope Id
    
    public static void DocumentNameOnRs(List<dsfs__DocuSign_Recipient_Status__c> recipientStatusToUpdate){
        Map<String, String> mapOfEnvelopeId = new Map<String, String>();
        List<String> lstOfEnvelopeId = new List<String>();
        
        //To get list of all envelopeIds' from recipientStatusToUpdate
        for(dsfs__DocuSign_Recipient_Status__c rs : recipientStatusToUpdate){
            lstOfEnvelopeId.add(rs.dsfs__Envelope_Id__c); 
        }
        
        //Get all records of Envelope Document where envelopeId matches with Rascipient Status envelopeId
        List<dsfs__DocuSign_Envelope_Document__c> lstEnvelopeDocument = new List<dsfs__DocuSign_Envelope_Document__c> ();
        if(lstOfEnvelopeId.size()>0)
            lstEnvelopeDocument  = [Select Id, dsfs__DocuSign_EnvelopeID__r.dsfs__DocuSign_Envelope_ID__c, dsfs__Document_Name__c from dsfs__DocuSign_Envelope_Document__c where dsfs__DocuSign_EnvelopeID__r.dsfs__DocuSign_Envelope_ID__c in:lstOfEnvelopeId];
        
        //Store all envelopeId and Document Name in map
        for(dsfs__DocuSign_Envelope_Document__c ed: lstEnvelopeDocument){
            if(ed.dsfs__DocuSign_EnvelopeID__c !=null && ed.dsfs__DocuSign_EnvelopeID__r.dsfs__DocuSign_Envelope_ID__c!=null){
                mapOfEnvelopeId.put(ed.dsfs__DocuSign_EnvelopeID__r.dsfs__DocuSign_Envelope_ID__c.toUpperCase(), (String)ed.dsfs__Document_Name__c); 
                System.debug((String)ed.dsfs__DocuSign_EnvelopeID__r.dsfs__DocuSign_Envelope_ID__c + ' = ' + (String)ed.dsfs__Document_Name__c); 
            }
        }
        List<dsfs__DocuSign_Recipient_Status__c> list_RSToUpdate = new List<dsfs__DocuSign_Recipient_Status__c>();

        //Update the Recipient Status record with new document name
        System.debug(mapOfEnvelopeId);
        for (dsfs__DocuSign_Recipient_Status__c r : recipientStatusToUpdate)
        {
            System.debug(r.dsfs__Envelope_Id__c);
            System.debug(mapOfEnvelopeId.get((String)r.dsfs__Envelope_Id__c));
            if(String.isBlank(r.dsfs__Envelope_Id__c) || (!mapOfEnvelopeId.containsKey(r.dsfs__Envelope_Id__c.toUpperCase())))
                r.Document_Name__c = '';
            else
                r.Document_Name__c = mapOfEnvelopeId.get(r.dsfs__Envelope_Id__c.toUpperCase());
            list_RSToUpdate.add(r);
        }
    }
}