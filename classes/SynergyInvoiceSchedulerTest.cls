@isTest
public class SynergyInvoiceSchedulerTest{
    public  static String CRON_EXP = '0 0 0 15 3 ? *';
    
    public static testMethod void scheduleTest(){
        //Create Opportunity object
        Opportunity opptObject = createOpp();
        
        Opportunity_Line_Item__c oli = new Opportunity_Line_Item__c();
        oli.Opportunity__c= opptObject.Id;
        oli.Name = 'test oli';
        oli.Schedule_Confirmation_Mail_Sent__c = false;
        oli.Treatment_Date__c = Date.today() ;
        oli.Invoice_Due_Date__c = Date.today();
        oli.Status__c = 'Scheduled';
        insert oli;
        
        Opportunity_Line_Item__c oli2 = new Opportunity_Line_Item__c();
        oli2.Opportunity__c= opptObject.Id;
        oli2.Name = 'test oli2';
        oli2.Schedule_Confirmation_Mail_Sent__c = false;
        oli2.Treatment_Date__c = Date.Today().addDays(3);
        oli2.Status__c = 'Scheduled';
        insert oli2;
      
        Opportunity_Line_Item__c oli3 = new Opportunity_Line_Item__c();
        oli3.Opportunity__c= opptObject.Id;
        oli3.Name = 'test oli3';
        oli3.Schedule_Confirmation_Mail_Sent__c = false;
        //oli3.Invoice_Sent_for_Approval_Date__c = Date.Today().addDays(-2);
        oli3.Treatment_Date__c = Date.Today().addDays(-1);
        oli3.Status__c = 'Completed';
        insert oli3;
      
       
        Opportunity_Line_Item__c oli4 = new Opportunity_Line_Item__c();
        oli4.Opportunity__c= opptObject.Id;
        oli4.Name = 'test oli4';
        oli4.Invoice_Sent_for_Approval_Date__c = Date.Today().addDays(-2);
        oli4.Status__c = 'Invoice Sent for Approval';
        insert oli4;
 
        Opportunity_Line_Item__c oli5 = new Opportunity_Line_Item__c();
        oli5.Opportunity__c= opptObject.Id;
        oli5.Name = 'test oli5';
        oli5.Invoice_Due_Date__c = Date.Today();
        oli5.Status__c = 'Invoice Sent for Payment';
        insert oli5;
        
        Opportunity_Line_Item__c oli6 = new Opportunity_Line_Item__c();
        oli6.Opportunity__c= opptObject.Id;
        oli6.Name = 'test oli6';
        oli6.Invoice_Due_Date__c = Date.Today().addDays(-3);
        oli6.Status__c = 'Invoice Sent for Payment';
        //insert oli6;
        
        //Ankita A: Changes related to Prod reminder email
        Opportunity_Line_Item__c invoiceObj = new Opportunity_Line_Item__c(
                                                Opportunity__c = opptObject.Id,
                                                Treatment_Date__c = System.Today() + 5,
                                                Invoice_Due_Date__c = System.today(),
                                                Status__c = 'Production Report Requested');
        
        Opportunity_Line_Item__c invoiceObj2 = new Opportunity_Line_Item__c(
                                                Opportunity__c = opptObject.Id,
                                                Treatment_Date__c = System.Today() + 5,
                                                Invoice_Due_Date__c = System.today(),
                                                Status__c = 'Production Report Requested');
        
        //Ankita A: Changes related to Production report request email
        Opportunity_Line_Item__c invoiceObj3 = new Opportunity_Line_Item__c(
                                                Opportunity__c = opptObject.Id,
                                                Treatment_Date__c = System.Today() - 5,
                                                Invoice_Due_Date__c = System.today(),
                                                Status__c = 'Production Report Requested');
        List<Opportunity_Line_Item__c> invoiceLst = new List<Opportunity_Line_Item__c>{invoiceObj,
            invoiceObj2,
            invoiceObj3};
                insert invoiceLst;
        Test.startTest();        
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new SynergyInvoiceScheduler());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }
  
    public static Opportunity createOpp(){
        Account acc = new Account();
        acc.Name = 'test account';
        insert acc;
        
        Contact con = new Contact();
        con.firstname = 'test';
        con.lastname = 'contact';
        con.AccountId = acc.Id;
        con.Email = 'test2@test.com';
        insert con;
        
        Contact con2 = new Contact();
        con2.firstname = 'primary';
        con2.lastname = 'contact';
        con2.Email = 'test@test.com';
        insert con2;
        
        Opportunity opp = new Opportunity();
        opp.name = 'test';
        opp.AccountId = acc.Id;
        opp.GP_Contact__c = con.Id;
        opp.closedate = Date.Today();
        opp.Primary_Contact__c = con2.Id;
        opp.stagename = 'Tx Day Schedule';
        insert opp;
             
        return opp;
    }
}