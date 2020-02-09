/* Class Name - FinancialDisclosureHandler_Test
Created by - Sujata P Galinde
Description - Test class for FinancialDisclosureHandler
*/
@isTest
public class FinancialDisclosureHandler_Test {
    
    static testMethod void updateFinancialDisclosure() 
    {
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        
        Opportunity testOpportunity = new Opportunity(
            StageName = 'Sourcing Demand',
            CloseDate = system.today(),
            AccountID = testAccount.id,
            Name = 'Test Opportunity Triggers',
            Financial_Discloser_Sent__c=true
        );
        insert testOpportunity;
        
        Test.StartTest();
        //update Financial_Discloser_Sent__c field of the opportunity based on Opportunity Id
        FinancialDisclosureHandler.MarkFinancialDisclosure(testOpportunity.Id);
        Test.StopTest();
    }
}