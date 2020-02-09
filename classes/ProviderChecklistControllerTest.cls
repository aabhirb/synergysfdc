@isTest
public class ProviderChecklistControllerTest {

    @TestSetup
    private static void createTestData(){
        Contact contactObj = new Contact(
            FirstName = 'John',
            LastName = 'Smith',
            Email = 'test1@test.com',
            MobilePhone = '985666612'
        );
        insert contactObj;
    }

    @isTest
    static void testCheckboxWrapper(){
        Contact contactObj = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        List<ProviderChecklistController.CheckboxWrapper> wrapperLst = ProviderChecklistController.getCheckboxWrapper(String.valueOf(contactObj.Id));
        Test.stopTest();
        System.assertEquals(5, wrapperLst.size());
        
    }

    @isTest
    static void testUpdateContactObj(){
        Contact contactObj = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        ProviderChecklistController.updateCheckbox(String.valueOf(contactObj.Id), 'Stripe_Account_Created__c', true);
        Test.stopTest();
        contactObj = [SELECT Id, Stripe_Account_Created__c FROM Contact LIMIT 1];
        System.assertEquals(true, contactObj.Stripe_Account_Created__c);

    }
}