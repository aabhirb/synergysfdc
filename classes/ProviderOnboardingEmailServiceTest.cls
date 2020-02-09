@isTest
public class ProviderOnboardingEmailServiceTest {
    
    @testSetup
    private static void createTestData(){
        //Create a contact
        Contact contactObj = new Contact();
        contactObj.firstName = 'John Smith';
        contactObj.lastName = 'SP';
        //contactObj.Suffix = ;
        contactObj.Email = 'test1@test.com';
        contactObj.HasOptedOutOfEmail = true;
        contactObj.MobilePhone = '985666612';
        insert contactObj;
    }

   
    private static testMethod void testProviderOnboardingEmails() {
        //Create InboundEmail
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        email.subject = 'Onboarding Checklist | Dr. John Smith SP';
        email.plainTextBody = 'Test Email Body';
        email.fromAddress = 'test1@test.com';
        
        //Create Attachment
        Messaging.InboundEmail.TextAttachment attachment = new Messaging.InboundEmail.TextAttachment();
        attachment.body = 'My attachment\'s text';
        attachment.fileName = 'Fee Schedule.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachment };   
        
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            Content_Source__c = 'Email',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
 
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(documents.size(), 1);
        
        Messaging.InboundEmail.BinaryAttachment attachment2 = new Messaging.InboundEmail.BinaryAttachment();
        attachment2.body = blob.valueOf('my attachment\'s text');
        attachment2.fileName = 'Scheduling Guidelines Schedule.txt';
        attachment2.mimeTypeSubType = 'text/plain';
       
        Messaging.InboundEmail.BinaryAttachment attachment3 = new Messaging.InboundEmail.BinaryAttachment();
        attachment3.body = blob.valueOf('my attachment\'s text');
        attachment3.fileName = 'Personality Working Style Questionnaire.txt';
        attachment3.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment2, attachment3 };   
            
		Test.startTest();
        ProviderOnboardingEmailServiceApex obj= new ProviderOnboardingEmailServiceApex();
        obj.handleInboundEmail(email, envelope);
        Test.stopTest();
        
        //Asserts
        Contact contactObj = [SELECT Id, Name, Fee_Schedule_URL__c, Scheduling_Guidelines_URL__c, Questionnaire_URL__c FROM Contact WHERE 
                               Email = 'test1@test.com' LIMIT 1];
        //Urls are generated from the reply
        if(contactObj != null){
            System.debug(' contactObj ' +contactObj);
            System.assert(String.isNotBlank(contactObj.Fee_Schedule_URL__c));
            System.assert(String.isNotBlank(contactObj.Scheduling_Guidelines_URL__c));
            System.assert(String.isNotBlank(contactObj.Questionnaire_URL__c));
        }
        //Check if files are created for Contact object
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion];
        System.assertEquals(4, contentVersions.size());
    }   
    
    testMethod private static void testNoContactFound(){
                
        //Create InboundEmail
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        email.subject = 'Onboarding Checklist';
        email.plainTextBody = 'Test Email Body';
        email.fromAddress = 'test1@test.com';
        
        //Create Attachment
        Messaging.InboundEmail.TextAttachment attachment = new Messaging.InboundEmail.TextAttachment();
        attachment.body = 'my attachment\'s text';
        attachment.fileName = 'Fee Schedule.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachment };   
        
        
        Messaging.InboundEmail.BinaryAttachment attachment2 = new Messaging.InboundEmail.BinaryAttachment();
        attachment2.body = blob.valueOf('my attachment text');
        attachment2.fileName = 'Scheduling Guidelines Schedule.txt';
        attachment2.mimeTypeSubType = 'text/plain';

        Messaging.InboundEmail.BinaryAttachment attachment3 = new Messaging.InboundEmail.BinaryAttachment();
        attachment3.body = blob.valueOf('my attachment\'s text');
        attachment3.fileName = 'Personality Working Style Questionnaire.txt';
        attachment3.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment2, attachment3 };   
        
		Test.startTest();
        ProviderOnboardingEmailServiceApex obj= new ProviderOnboardingEmailServiceApex();
        obj.handleInboundEmail(email, envelope);
        Test.stopTest();
    }
}