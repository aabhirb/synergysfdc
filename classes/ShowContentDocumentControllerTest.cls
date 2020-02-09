@isTest
public class ShowContentDocumentControllerTest {

    @testSetup
    private static void createTestData(){
        //Create custom setting
        Misc_Configuration__c configObject = new Misc_Configuration__c(Universal_Password__c = 'testpassword');
        insert configObject;
        
        //Create a record of Invoice object
        Contact contactObj = new Contact(firstname = 'John', lastname='Smith', email = 'abc@test.com',
                                        OM_Email__c = 'abc_om@test.com', Practice_Email__c = 'abc_pr@test.com');
        insert contactObj;
        
        Opportunity opptObject = new Opportunity(Name='Test Opportunity',
                                                 StageName='Closed Won', 
                                                 Probability = 100, 
                                                 CloseDate=system.today(),
                                                 Primary_Contact__c = contactObj.Id, 
                                                 GP_Contact__c = contactObj.id);
        insert opptObject;
        //Create invoice object with status as Scheduled
        Opportunity_Line_Item__c invoiceObj1 = new Opportunity_Line_Item__c(
                                                Opportunity__c = opptObject.Id,
                                                Treatment_Date__c = System.today(),
                                                Invoice_Due_Date__c = System.today(),
                                                Status__c = 'Scheduled');
        insert invoiceObj1;
        
        //Create a file and generate it's public url
        ContentVersion conVer = new ContentVersion(ContentLocation = 'S', PathOnClient = 'Test fileName.pdf', Title = 'Test fileName',
                                                   VersionData = EncodingUtil.base64Decode('Test content'),
                                                   Content_Type__c = 'Production Report'); 
        insert conVer;
        
        // First get the content document Id from ContentVersion
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink(ContentDocumentId = conDoc, LinkedEntityId = invoiceObj1.Id, 
                                                          ShareType = 'I', Visibility = 'AllUsers');
        insert cDe;
        
		conVer.Is_Approved__c = true;
		update conVer;
    }
    
    testMethod private static void testUrlRedirection(){
        Opportunity_Line_Item__c invoiceObj1 = [SELECT Id, Production_Report_PDF_URL__c FROM Opportunity_Line_Item__c LIMIT 1];

        //Fetch the public url
        Test.startTest();
        PageReference pageReference = Page.ShowContentDocument;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('contentUrl', invoiceObj1.Production_Report_PDF_URL__c);
        ShowContentDocumentController controllerObj = new ShowContentDocumentController();
        pageReference = controllerObj.urlRedirection();
        Test.stopTest();
        
        //Assert statements
        
    }
    
    testMethod private static void testUrlRedirectionWithPwd(){
        Opportunity_Line_Item__c invoiceObj1 = [SELECT Id, Production_Report_PDF_URL__c FROM Opportunity_Line_Item__c LIMIT 1];

        //Fetch the public url
        Test.startTest();
        PageReference pageReference = Page.ShowContentDocument;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('contentUrl', invoiceObj1.Production_Report_PDF_URL__c);
        ShowContentDocumentController controllerObj = new ShowContentDocumentController();
        controllerObj.password = 'testpassword';
        pageReference = controllerObj.urlRedirection();
        Test.stopTest();
        
        //Assert statements
        System.assertEquals(invoiceObj1.Production_Report_PDF_URL__c, pageReference.getUrl());
    }
    
}