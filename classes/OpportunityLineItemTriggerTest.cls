@IsTest
public class OpportunityLineItemTriggerTest {
    
    //Changes added by Ankita
    @testSetup
    private static void createTestData(){
        //Create a record of Invoice object with status as Scheduled and Opportunity with concierge needed as true
        Contact contactObj = new Contact(firstname = 'John', lastname='Smith', email = 'abc@test.com');
        insert contactObj;
        
        Opportunity opptObject = new Opportunity(Name='Test Opportunity',
                                                 StageName='Closed Won', 
                                                 Probability = 100, 
                                                 CloseDate=system.today(),
                                                 Concierge_Needed__c = true);
        opptObject.Primary_Contact__c = contactObj.Id;
        opptObject.GP_Contact__c = contactObj.id;
        insert opptObject;
        //Create invoice object with status as Scheduled and Concierge_Needed__c as false
        Opportunity_Line_Item__c invoiceObj1 = new Opportunity_Line_Item__c(
                                                Opportunity__c = opptObject.Id,
                                                Treatment_Date__c = System.today(),
                                                Invoice_Due_Date__c = System.today(),
                                                Status__c = 'Scheduled',
        										Concierge_Needed__c = false);
        insert invoiceObj1;
    }
    private static testMethod void doTest() {    
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity_line_item__c> oliList = new List<Opportunity_line_item__c>();
        Map<Id,Opportunity_line_item__c> mapOfOli = new Map<Id,Opportunity_line_item__c>();
        
        Contact con = new Contact(firstname = 'abc', lastname='test', email = 'abc@test.com');
        insert con;
        
        Opportunity opp = new Opportunity(Name='test opp',StageName='Closed Won', Probability = 100, CloseDate=system.today());
        opp.Primary_Contact__c = con.Id;
        opp.GP_Contact__c = con.id;
        insert opp;
        
        Opportunity opp1 = new Opportunity(Name='test opp1',StageName='Closed Won',Probability = 100, CloseDate=system.today());
        insert opp1;
        
        oppList.add(opp);
        oppList.add(opp1);
        

        Opportunity_Line_Item__c oli = new Opportunity_Line_Item__c(
            Opportunity__c = opp.Id,
            Treatment_Date__c = system.today(),
            Invoice_Due_Date__c = system.today(),
            Membrane_Cost__c = 50,
            Schedule_Confirmation_Mail_Sent__c = false,
            Status__c = 'Invoice Approved',
            Invoice_Approval_Follow_Up_Sent__c = false
        );
        insert oli;
        
        oli.Schedule_Confirmation_Mail_Sent__c = false;
        oli.Status__c = 'Production Report Requested';
        update oli;
        
        oli.Schedule_Confirmation_Mail_Sent__c = true;
        update oli;     
        
        Opportunity_Line_Item__c oli2 = new Opportunity_Line_Item__c(
            Opportunity__c = opp.Id,
            Treatment_Date__c = system.today(),
            Invoice_Due_Date__c = system.today(),
            Membrane_Cost__c = 50,
            Schedule_Confirmation_Mail_Sent__c = false,
            Status__c = 'Invoice Sent for Payment',
            Invoice_Approval_Follow_Up_Sent__c = true,
            Invoice_Payment_Follow_Up_2_Sent__c= true
        );
        insert oli2;
        
        oli2.Invoice_Payment_Follow_Up_Sent__c = false;
        oli2.Invoice_Payment_Follow_Up_2_Sent__c = false;
        oli2.Status__c = 'Production Report Requested';
        update oli2;     
        
        oli2.Invoice_Payment_Follow_Up_Sent__c = false;
        oli2.Invoice_Payment_Follow_Up_2_Sent__c = true;
        oli2.Status__c = 'Invoice Sent for Payment';
        update oli2;
        
        oli2.Invoice_Payment_Follow_Up_Sent__c = true;
        oli2.Invoice_Payment_Follow_Up_2_Sent__c = false;
        update oli2;
        
        Opportunity_Line_Item__c oli4 = new Opportunity_Line_Item__c(
            Opportunity__c = opp.Id,
            Treatment_Date__c = system.today(),
            Invoice_Due_Date__c = system.today(),
            Membrane_Cost__c = 50,
            Schedule_Confirmation_Mail_Sent__c = false,
            Status__c = 'Invoice Sent for Payment',
            Invoice_Payment_Follow_Up_2_Sent__c= true
        );
        insert oli4;
        
        oli4.Invoice_Payment_Follow_Up_2_Sent__c = false;
        update oli4;     
        
        oli4.Invoice_Payment_Follow_Up_2_Sent__c = true;
        update oli4;   
        Opportunity_Line_Item__c oli3 = new Opportunity_Line_Item__c(
            Opportunity__c = opp.Id,
            Treatment_Date__c = system.today(),
            Invoice_Due_Date__c = system.today(),
            Membrane_Cost__c = 50,
            Schedule_Confirmation_Mail_Sent__c = false,
            Status__c = 'Invoice Sent for Approval',
            Invoice_Approval_Follow_Up_Sent__c = false
        );
        
        insert oli3;        
        
        oli3.Invoice_Approval_Follow_Up_Sent__c = true;
        update oli3;
        
        oli3.Status__c = 'Scheduled';
        update oli3;
        
        oliList.add(oli2);
        oliList.add(oli3);

    }
    
    testMethod private static void updateConciergeNeeded(){
        Opportunity_Line_Item__c invoiceObj = [SELECT Id, Concierge_Needed__c 
                                               FROM Opportunity_Line_Item__c LIMIT 1];
        invoiceObj.Concierge_Needed__c = true;
        Test.startTest();
        update invoiceObj;
        Test.stopTest();
        //Check if Concierge Detail object is created or not and linked with the invoice
        List<Concierge_Details__c> conciergeDetails = [SELECT Id FROm Concierge_Details__c];
        System.assertEquals(1, conciergeDetails.size());
        invoiceObj = [SELECT Id, Concierge_Details__c FROM Opportunity_Line_Item__c LIMIT 1];
        System.assertEquals(conciergeDetails[0].Id, invoiceObj.Concierge_Details__c);
                
    }
    
    testMethod private static void createInvoiceAndCheckConcierge(){
        //Insert a new Invoice object and check if Concierge is populated or not
        Opportunity opptObject = [SELECT Id FROM Opportunity WHERE Concierge_Needed__c = true LIMIT 1];
       	//Create an invoice object
       	//Create invoice object with status as Scheduled and Concierge_Needed__c as false
        Opportunity_Line_Item__c invoiceObj1 = new Opportunity_Line_Item__c(
                                                Opportunity__c = opptObject.Id,
                                                Treatment_Date__c = System.today(),
                                                Invoice_Due_Date__c = System.today() + 1,
                                                Status__c = 'Scheduled',
        										Concierge_Needed__c = false);
        Test.startTest();
        insert invoiceObj1;
        Test.stopTest();
        
        //Check if Concierge Detail object is populated on the invoice
        Date invoiceDueDate = System.today() + 1;
        Opportunity_Line_Item__c invoiceObj = [SELECT Id, Concierge_Details__c FROM Opportunity_Line_Item__c 
                                               WHERE Invoice_Due_Date__c =: invoiceDueDate LIMIT 1];
        System.assert(invoiceObj.Concierge_Details__c != null);
    }
    
    //Ankita A: Stripe payment test method
    /*testMethod private static void sendStripePaymentEmail(){
        Opportunity_Line_Item__c invoiceObj = [SELECT Id, SP_Confirms_Invoice__c 
                                               FROM Opportunity_Line_Item__c LIMIT 1];
        invoiceObj.SP_Confirms_Invoice__c = true;
        Test.startTest();
        update invoiceObj;
        Test.stopTest();
        //Check if EmailMessage is inserted or not
        List<EmailMessage> emailMsgs = [SELECT Id FROM EmailMessage];
		System.assertEquals(1, emailMsgs.size());
       
    }*/
}