/* Class Name - RecipientStatusTriggerTest
Created by - Sujata P Galinde
Description - Test class for Docu Sign Recipient Status Trigger and Recipient Status Trigger handler
*/

@isTest
public class RecipientStatusTriggerTest {
    private static testmethod void testUpdateRSEnvelope(){
        
        Test.startTest();
        //Update Recipient Status to add Envelope Id
        dsfs__DocuSign_Recipient_Status__c recStatus = [Select Id from dsfs__DocuSign_Recipient_Status__c];
        recStatus.dsfs__Envelope_Id__c= '1234-5678';
        update recStatus;
        
        //Get Document Name from Recipient Status
        recStatus = [Select Id, Document_Name__c from dsfs__DocuSign_Recipient_Status__c];
        //Check Document Name 
        System.assertEquals('Salesforce ASA Template', recStatus.Document_Name__c);
        Test.stopTest();
    }
    @testSetup 
    private static void createTestData(){
        
        //Create and Insert Status
        dsfs__DocuSign_Status__c status = new dsfs__DocuSign_Status__c();
        Database.SaveResult statusRes = Database.insert(status);
        
       //Create and Insert Envelope
        dsfs__DocuSign_Envelope__c env = new dsfs__DocuSign_Envelope__c(
        	dsfs__DocuSign_Email_Subject__c = 'Subject',
            dsfs__DocuSign_Envelope_ID__c = '1234-5678'
        );
        Database.SaveResult envRes = Database.insert(env);
        
        //Create and Insert Envelope Document
        dsfs__DocuSign_Envelope_Document__c envdoc = new dsfs__DocuSign_Envelope_Document__c(
        	dsfs__DocuSign_EnvelopeID__c=env.ID,
        	dsfs__Document_Name__c = 'Salesforce ASA Template');
        insert envdoc;
        
        //Create and Insert Recipient Status
        dsfs__DocuSign_Recipient_Status__c obj = new dsfs__DocuSign_Recipient_Status__c(
            dsfs__Parent_Status_Record__c =statusRes.Id,
            Name='test obj',
            dsfs__DocuSign_Recipient_Id__c ='123' 
        );
        insert obj;
    }
    
    
}