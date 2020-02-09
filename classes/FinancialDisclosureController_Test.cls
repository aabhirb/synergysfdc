/* Class Name - FinancialDisclosureController_Test
Created by - Sujata P Galinde
Description - Test class for FinancialDisclosurePDFController, FinancialDisclosureAttachmentController.
*/
@isTest
public class FinancialDisclosureController_Test {
    
    static testMethod void showFinancialDisclosurePDF() 
    {
        Opportunity Opty = [SELECT Id FROM OPPORTUNITY WHERE NAME='Test Opportunity Triggers'];
        Test.StartTest();
        //create page reference to refer VF page
        Test.setCurrentPageReference(new PageReference('Page.FinancialDisclosurePDF'));
        System.currentPageReference().getParameters().put('optyId', String.valueOf(Opty.Id));
        System.currentPageReference().getParameters().put('isPrime', String.valueOf(true));
        
        //FinancialDisclosurePDF Controller 
        FinancialDisclosurePDFController FDC = new FinancialDisclosurePDFController();
        String aString = FDC.OpportunityID;
        Opportunity opt = FDC.OpportunityDetails;
        Boolean isPrimeCnt = FDC.isPrimaryContact;
        
        //FinancialDisclosureAttachment Controller
        FinancialDisclosureAttachmentController Specialist = new FinancialDisclosureAttachmentController();
        Specialist.opportunityObjectId = String.valueOf(Opty.Id);
        String synrgySpel = Specialist.opportunityObjectId;
        
        Test.StopTest();
    }
    
    @testSetup static void setup() {
        //create account
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        
        //create contact
        Contact testContact1 = new Contact(
            AccountId=testAccount.Id,
            FirstName = 'John',
            LastName = 'Watson',
            Email='test@gmail.com',
            MailingStreet='Dehu',
            MailingCity='Pune',
            MailingCountry='India',
            MailingPostalCode='41107',
            Net_Terms__c=50,
            SPSPECIALTY__c='Ortho'
        );
        insert testContact1;
        
        Contact testContact2 = new Contact(
            AccountId=testAccount.Id,
            FirstName = 'David',
            LastName = 'Watson',
            Email='firstOne@gmail.com',
            MailingStreet='Dighi',
            MailingCity='Pune',
            MailingCountry='India',
            MailingPostalCode='41111',
            Net_Terms__c=60,
            SPSPECIALTY__c='Endo'
        );
        insert testContact2;
        
        //create opportunity
        Opportunity testOpportunity = new Opportunity(
            StageName = 'Sourcing Demand',
            CloseDate = system.today(),
            AccountID = testAccount.id,
            Name = 'Test Opportunity Triggers',
            Compensation__c=40,
            Provider_Per_Diem__c=50,
            Practice_Earning_Retention__c=60,
            GP_Contact__c=testContact2.Id
        );
        insert testOpportunity;
        
    }
    
}