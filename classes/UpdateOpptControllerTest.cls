@isTest
public class UpdateOpptControllerTest {

    @testSetup
    private static void createTestData(){
        Opportunity opp = new Opportunity(
            Name='test opp',
            StageName='Closed Won', 
            Probability = 100, 
            CloseDate=system.today());
    	insert opp;
    }
    
    private static testMethod void testUpdateOnboardingChecklist(){
        Opportunity opptObject = [SELECT Id FROM Opportunity LIMIT 1];
        //Call the UpdateOpptController to update the Onboarding checklist
        UpdateOpptController.updateOnboardingChecklist(String.valueOf(opptObject.Id), 'Supplies');
        //Check whether the field has been updated or not
		Opportunity opptObject2 = [SELECT Onboarding_Checklist__c FROM Opportunity LIMIT 1];
        System.assertEquals('Supplies', opptObject2.Onboarding_Checklist__c);
    }
}