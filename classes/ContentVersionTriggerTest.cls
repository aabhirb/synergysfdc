@isTest(seeAllData=false)
public class ContentVersionTriggerTest {
    static testMethod void testContent(){
        Account acc = new Account();
        acc.Name = 'test account';
        insert acc;
        
        Contact con = new Contact();
        con.firstname = 'test';
        con.lastname = 'contact';
        con.AccountId = acc.Id;
        con.Email = 'test2@test.com';
        insert con;
        
        Contact con2 = new Contact();
        con2.firstname = 'primary';
        con2.lastname = 'contact';
        con2.Email = 'test@test.com';
        insert con2;
        
        Opportunity opp = new Opportunity();
        opp.name = 'test';
        opp.AccountId = acc.Id;
        opp.GP_Contact__c = con.Id;
        opp.closedate = Date.Today();
        opp.Primary_Contact__c = con2.Id;
        opp.stagename = 'Tx Day Schedule';
        insert opp;
        
        Opportunity_Line_Item__c oli = new Opportunity_Line_Item__c();
        oli.Opportunity__c= opp.Id;
        oli.Name = 'test oli';
        oli.Schedule_Confirmation_Mail_Sent__c = false;
        oli.Treatment_Date__c = Date.today();
        oli.Invoice_Due_Date__c = Date.today();
        oli.Status__c = 'Scheduled';
        insert oli;
        //List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Test.startTest();
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            is_Approved__c = false,
            Content_Type__c ='Invoice',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        
        ContentVersion cvObject = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionInsert.Id LIMIT 1];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = oli.id;
        cdl.ContentDocumentId = cvObject.ContentDocumentId;
        cdl.shareType = 'V';
        insert cdl;
        
        contentVersionInsert.Title = 'test123';
        contentVersionInsert.Is_Approved__c = true;
        update contentVersionInsert;
        
        
        Test.stopTest();
        List<ContentDocumentLink> cdlink = [Select id, LinkedEntityId from ContentDocumentLink where LinkedEntityId=:oli.id];
        System.assertEquals(cdlink.size(), 1);
    }
    
}