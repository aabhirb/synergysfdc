@isTest
public class OpportunityTriggerTest {

    @testSetup
    private static void createTestData(){
        //Create opportunity object with Concierge Needed as false
        Contact contactObj = new Contact(firstname = 'John', lastname='Smith', email = 'abc@test.com');
        insert contactObj;
                
        Opportunity opptObject = new Opportunity(Name='Test Opportunity',
                                                 StageName='Closed Won', 
                                                 Probability = 100, 
                                                 CloseDate=system.today());
        opptObject.Primary_Contact__c = contactObj.Id;
        opptObject.GP_Contact__c = contactObj.id;
        opptObject.Concierge_Needed__c = false;
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
    
    private testMethod static void updateConciergeNeeded(){
        //Query the oportunity
        Opportunity opptObject = [SELECT Id, Concierge_Needed__c FROM Opportunity LIMIT 1];
        //Update the concierge needed as true and check if the Invoice is also updated or not
        opptObject.Concierge_Needed__c = true;
        Test.startTest();
        update opptObject;
        Test.stopTest();
        Opportunity_Line_Item__c invoice = [SELECT Id, Concierge_Needed__c FROM Opportunity_Line_Item__c
                                           WHERE Opportunity__c =: opptObject.Id];
        System.assertEquals(true, invoice.Concierge_Needed__c);
    }
    
    private testMethod static void testSendBusiness(){
        //Create opportunity object and specialty as Periodontist
        Contact contactObj = new Contact(firstname = 'John', lastname='Smith', email = 'abc@test.com', SPSPECIALTY__c = 'Perio');
        insert contactObj;
        Contact contactObj2 = new Contact(firstname = 'Harry', lastname='Smith');
        insert contactObj2;

        Opportunity opptObject = new Opportunity(Name='John Smith Opp',
                                                 StageName='Closed Won', 
                                                 Probability = 100, 
                                                 CloseDate=system.today());
        opptObject.Primary_Contact__c = contactObj.Id;
        opptObject.GP_Contact__c = contactObj2.id;
        opptObject.Concierge_Needed__c = false;
        insert opptObject;
        //Create invoice object with status as Scheduled
        Opportunity_Line_Item__c invoiceObj1 = new Opportunity_Line_Item__c(
                                                Opportunity__c = opptObject.Id,
                                                Treatment_Date__c = System.today(),
                                                Invoice_Due_Date__c = System.today(),
                                                Status__c = 'Scheduled');
        //Insert first invoice object with status as Scheduled
        Test.startTest();
        insert invoiceObj1;
        Test.stopTest();
        //Check if the email is sent or not by querying is_Member_Intro_Email_Sent__c field on Opportunity object
        Opportunity newOpptObject = [SELECT Id, is_Member_Intro_Email_Sent__c FROM Opportunity WHERE Name = 'John Smith Opp' LIMIT 1];
        System.assertEquals(true, newOpptObject.is_Member_Intro_Email_Sent__c);
        
    }
}