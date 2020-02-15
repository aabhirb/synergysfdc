@isTest
public class SendSMSBatchSchedulerTest {
    
    @testSetup
    private static void createTestData(){
        //Create opportunity object
        Contact contactObj = new Contact(firstname = 'John', lastname='Smith', email = 'abc@test.com', MobilePhone = '1234567890');
        insert contactObj;
        
        Opportunity opptObject = new Opportunity(Name='Test Opportunity',StageName='Closed Won', Probability = 100, CloseDate=system.today());
        opptObject.Primary_Contact__c = contactObj.Id;
        insert opptObject;
        
        //Create Concierge Detail object and link it with the Invoice
        Concierge_Details__c conciergeDetail1 = new Concierge_Details__c(Driver_Name__c = 'John Smith',
                                                                       Driver_Needed__c	= true,
                                                                       Drop_Off_Time__c = DateTime.now(),
                                                                       is_Car_Confirmed__c = true,
                                                                       is_Hotel_Confirmed__c = true,
                                                                       is_Flight_Confirmed__c = true
                                                                       );
        insert conciergeDetail1;
        Opportunity_Line_Item__c invoiceObj1 = new Opportunity_Line_Item__c(
                                                Opportunity__c = opptObject.Id,
                                                Treatment_Date__c = System.today() + 3,
                                                Invoice_Due_Date__c = System.today(),
                                                Status__c = 'Invoice Approved',
        										Concierge_Details__c = conciergeDetail1.Id);
        insert invoiceObj1;
        
        //Insert SMS templates
        String textTemplate = 'Dear Dr. {!opportunity_line_item__c.Opportunity__r.Primary_Contact__r.lastname}, Synergy Concierge has made reservation for you.';
        smagicinteract__SMS_Template__c template1 = new smagicinteract__SMS_Template__c(
            smagicinteract__Name__c = 'Reservation Reminder Car',
            smagicinteract__ObjectName__c = 'opportunity_line_item__c',
            smagicinteract__Text__c = textTemplate
        );
        smagicinteract__SMS_Template__c template2 = new smagicinteract__SMS_Template__c(
            smagicinteract__Name__c = 'Reservation Reminder Hotel',
            smagicinteract__ObjectName__c = 'opportunity_line_item__c',
            smagicinteract__Text__c = textTemplate
        );
        smagicinteract__SMS_Template__c template3 = new smagicinteract__SMS_Template__c(
            smagicinteract__Name__c = 'Reservation Reminder Flight',
            smagicinteract__ObjectName__c = 'opportunity_line_item__c',
            smagicinteract__Text__c = textTemplate
        );
        
        List<smagicinteract__SMS_Template__c> templates = new List<smagicinteract__SMS_Template__c>{
            template1,
                template2,
                template3
        };
            insert templates;
        //Insert smagicinteract__SMS_SenderId__c record
        smagicinteract__SMS_SenderId__c senderObject = new smagicinteract__SMS_SenderId__c(
            smagicinteract__senderId__c = '13108072208',
            smagicinteract__Email_Notification_Template__c = 'default',
            smagicinteract__Used_For__c = 'Both'
        );
        insert senderObject;
    }
    
    testMethod private static void schedulerTest(){
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        SendSMSBatchScheduler schedulerObj = new SendSMSBatchScheduler();
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, schedulerObj);
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        schedulerObj.execute(null);
        Test.stopTest();
        
        Integer count = [SELECT Count() FROM smagicinteract__smsMagic__c];
        System.debug(count);
        //SMS History record will be inserted as all the checkboxes are checked
        System.assertEquals(3, count);
        Integer count2 = [SELECT Count() FROM Task];
        System.debug(count2);
        //Task record will be inserted as all the checkboxes are checked
        System.assertEquals(3, count2);

    }
    

}