@isTest
public class SendInvoiceEmailCtrlTest {

    @testSetup private static void createTestData(){
        //Create Invoice
        Account accountObj = new Account(Name = 'test account');
        insert accountObj;
        
        Contact contactObj1 = new Contact(firstname = 'JOhn', lastname = 'Smith', AccountId = accountObj.Id, Email = 'test2@test.com');
        insert contactObj1;
        
        Contact contactObj2 = new Contact(firstname = 'Harry', lastname = 'Abel', AccountId = accountObj.Id, Email = 'test2@test.com');
        insert contactObj2;
        
        Opportunity opp = new Opportunity();
        opp.name = 'test';
        opp.AccountId = accountObj.Id;
        opp.GP_Contact__c = contactObj1.Id;
        opp.closedate = Date.Today();
        opp.Primary_Contact__c = contactObj2.Id;
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
        //Create three attachments for invoice
        ContentVersion conVer = new ContentVersion(ContentLocation = 'S', PathOnClient = 'Production report.pdf', Title = 'Production report',
                                                  Is_Approved__c = true);
        conVer.VersionData = EncodingUtil.base64Decode('Test content'); 
        conVer.Content_Type__c = 'Production Report';
        
        ContentVersion conVer2 = new ContentVersion(ContentLocation = 'S', PathOnClient = 'Expense Report.pdf', Title = 'Expense report',
                                                  Is_Approved__c = true);
        conVer2.VersionData = EncodingUtil.base64Decode('Test content'); 
        conVer2.Content_Type__c = 'Expense Report';
        
        ContentVersion conVer3 = new ContentVersion(ContentLocation = 'S', PathOnClient = 'Invoice.pdf', Title = 'Invoice',
                                                  Is_Approved__c = true);
        conVer3.VersionData = EncodingUtil.base64Decode('Test content'); 
        conVer3.Content_Type__c = 'Invoice';
        
        List<ContentVersion> contentVersions = new List<ContentVersion>{conVer, conVer2, conVer3};
            insert contentVersions;
        //Create list of content document links
        List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();                
        for(ContentVersion version : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN:contentVersions]){
            //Create ContentDocumentLink for Contact
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = version.ContentDocumentId; //get the content document Id from ContentVersion
            cDe.LinkedEntityId = oli.Id; //It will either have library id or contact id
            cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
            cDe.Visibility = 'AllUsers';
            contentDocLinks.add(cDe);
        }
        insert contentDocLinks;
        
    }
    
    testMethod private static void testContentGeneration(){
        Opportunity_Line_Item__c invoice = [SELECT Id FROM Opportunity_Line_Item__c LIMIT 1];
        String wrapperStr = SendInvoiceEmailCtrlr.generateEmailContent(invoice.Id);
        //Assert statements
        SendInvoiceEmailCtrlr.EmailContentWrapper emailContentWrapper = (SendInvoiceEmailCtrlr.EmailContentWrapper) JSON.deserialize(
                                    wrapperStr, SendInvoiceEmailCtrlr.EmailContentWrapper.class);
        System.assertEquals('SUCCESS', emailContentWrapper.status);
        
        //Check whether invoice is updated or not
        invoice = [SELECT Id, Status__c FROM Opportunity_Line_Item__c LIMIT 1];
        System.assertEquals('Invoice Sent to Provider', invoice.Status__c);
    }
    
    testMethod private static void testMissingProdReport(){
        ContentVersion conVer = [SELECT Id, Is_Approved__c FROM ContentVersion WHERE Content_Type__c = 'Production Report'];
        conVer.Is_Approved__c = false;
        update conVer;
        Opportunity_Line_Item__c invoice = [SELECT Id FROM Opportunity_Line_Item__c LIMIT 1];
        String wrapperStr = SendInvoiceEmailCtrlr.generateEmailContent(invoice.Id);
        //Assert statements
        SendInvoiceEmailCtrlr.EmailContentWrapper emailContentWrapper = (SendInvoiceEmailCtrlr.EmailContentWrapper) JSON.deserialize(
                                    wrapperStr, SendInvoiceEmailCtrlr.EmailContentWrapper.class);
        System.assert(emailContentWrapper.status == 'SUCCESS');
        
        //Check whether invoice is updated or not
        invoice = [SELECT Id, Status__c FROM Opportunity_Line_Item__c LIMIT 1];
        //Invoice will be updated as we need to check only for Invoice report
        System.assertEquals('Invoice Sent to Provider', invoice.Status__c);
    }
    
    testMethod private static void testMissingExpenseReport(){
        ContentVersion conVer = [SELECT Id, Is_Approved__c FROM ContentVersion WHERE Content_Type__c = 'Expense Report'];
        conVer.Is_Approved__c = false;
        update conVer;
        Opportunity_Line_Item__c invoice = [SELECT Id FROM Opportunity_Line_Item__c LIMIT 1];
        Test.startTest();
        String wrapperStr = SendInvoiceEmailCtrlr.generateEmailContent(invoice.Id);
        Test.stopTest();
        //Assert statements
        SendInvoiceEmailCtrlr.EmailContentWrapper emailContentWrapper = (SendInvoiceEmailCtrlr.EmailContentWrapper) JSON.deserialize(
                                    wrapperStr, SendInvoiceEmailCtrlr.EmailContentWrapper.class);
        System.assert(emailContentWrapper.status == 'SUCCESS');
        
        //Check whether invoice is updated or not
        invoice = [SELECT Id, Status__c FROM Opportunity_Line_Item__c LIMIT 1];
        //Invoice will be updated as we need to check only for Invoice report
        System.assertEquals('Invoice Sent to Provider', invoice.Status__c);
    }
    
    testMethod private static void testMissingInvoiceReport(){
        ContentVersion conVer = [SELECT Id, Is_Approved__c FROM ContentVersion WHERE Content_Type__c = 'Invoice'];
        conVer.Is_Approved__c = false;
        update conVer;
        Opportunity_Line_Item__c invoice = [SELECT Id FROM Opportunity_Line_Item__c LIMIT 1];
        String wrapperStr = SendInvoiceEmailCtrlr.generateEmailContent(invoice.Id);
        //Assert statements
        SendInvoiceEmailCtrlr.EmailContentWrapper emailContentWrapper = (SendInvoiceEmailCtrlr.EmailContentWrapper) JSON.deserialize(
                                    wrapperStr, SendInvoiceEmailCtrlr.EmailContentWrapper.class);
        System.assert(emailContentWrapper.status != 'SUCCESS');
        
        //Check whether invoice is updated or not
        invoice = [SELECT Id, Status__c FROM Opportunity_Line_Item__c LIMIT 1];
        System.assert(invoice.Status__c != 'Invoice Sent to Provider');
    }
}