@isTest
public class SynergyProviderSchedulerTest {
	
    public  static String CRON_EXP = '0 0 0 15 3 ? *';
    
    @testSetup
    private static void createTestData(){
        //Create Opportunity object
        Opportunity opptObject = createOpp();

        Opportunity_Line_Item__c invoiceObj = new Opportunity_Line_Item__c(
                                                Opportunity__c = opptObject.Id,
                                                Treatment_Date__c = System.Today() - 20,
                                                Invoice_Due_Date__c = System.today(),
                                                Status__c = 'Scheduled');
        
        List<Opportunity_Line_Item__c> invoiceLst = new List<Opportunity_Line_Item__c>{invoiceObj};
            insert invoiceLst;
    }
    
    public static testMethod void testPostiveCase(){
        Test.startTest();        
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new SynergyProviderScheduler());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        //Assert
		System.assertEquals(1, [SELECT Count() FROM EmailMessage]);
    }
    
    public static testMethod void createFutureInvoice(){
        //Opportunity has both past and future invoice within next 60 days
        Opportunity opptObject = [SELECT Id FROM Opportunity LIMIT 1];
		
        Opportunity_Line_Item__c invoiceObj = new Opportunity_Line_Item__c(
                                                Opportunity__c = opptObject.Id,
                                                Treatment_Date__c = System.Today() + 20,
                                                Invoice_Due_Date__c = System.today(),
                                                Status__c = 'Scheduled');
        
        insert invoiceObj;
        Test.startTest();        
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new SynergyProviderScheduler());
        Test.stopTest();
        //Assert
		System.assertEquals(0, [SELECT Count() FROM EmailMessage]);
        
    }
  
    public static Opportunity createOpp(){
        Account acc = new Account();
        acc.Name = 'Connecticut Hospitals';
        insert acc;
        
        Contact con = new Contact();
        con.firstname = 'John';
        con.lastname = 'Smith';
        con.AccountId = acc.Id;
        con.Email = 'johnsmith@test.com';
        insert con;
        
        Contact con2 = new Contact();
        con2.firstname = 'Harry';
        con2.lastname = 'Abel';
        con2.Email = 'harryabel@test.com';
        insert con2;
        
        Opportunity opp = new Opportunity();
        opp.name = 'John - Harry Match';
        opp.AccountId = acc.Id;
        opp.GP_Contact__c = con.Id;
        opp.closedate = Date.Today();
        opp.Primary_Contact__c = con2.Id;
        opp.stagename = 'Tx Day Schedule';
        insert opp;
        
        return opp;
    }
}