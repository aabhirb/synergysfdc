@isTest
public class ConfirmInvoiceContollerTest {
    
    @testSetup
    private static void createTestData(){
        //Create invoice object
        
        Opportunity opptObject = new Opportunity(Name='Test Opportunity',
                                                 StageName='Closed Won', 
                                                 Probability = 100, 
                                                 CloseDate=system.today());
        insert opptObject;
        Opportunity_Line_Item__c invoiceObj1 = new Opportunity_Line_Item__c(
                                                Opportunity__c = opptObject.Id,
                                                Treatment_Date__c = System.today(),
                                                Production_Amount__c = 500,
                                                Compensation__c = 50);
        insert invoiceObj1;
    }
    
    testMethod private static void testStatusUpdation(){
        Opportunity_Line_Item__c invoice = [SELECT Id FROM Opportunity_Line_Item__c LIMIT 1];
        Test.startTest();
        PageReference pageReference = Page.ConfirmInvoice;
        Test.setCurrentPage(pageReference);
        ApexPages.currentPage().getParameters().put('oliId', invoice.Id);
        ConfirmInvoiceController controllerObj = new ConfirmInvoiceController();
        String status = ConfirmInvoiceController.onclickOfAction(String.valueOf(invoice.Id));
        
        //Assert
        invoice = [SELECT Id, Status__c FROM Opportunity_Line_Item__c LIMIT 1];
        System.assertEquals('Invoice Sent to Practice', invoice.Status__c);
        System.assertEquals('SUCCESS', status);
        
    }
    
}