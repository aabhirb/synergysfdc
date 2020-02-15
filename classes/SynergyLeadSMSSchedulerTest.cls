@isTest
public class SynergyLeadSMSSchedulerTest {

    @testSetup
    private static void createTestData(){
        Id practiceRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Practice').getRecordTypeId();
		Id providerRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        
        {
            //Create Practice leads with Intake Sent status, mobilephone, optout as false
            Lead leadObj1 = new Lead(LastName = 'TestLead1' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = practiceRecordType, Status = 'Intake Sent', MobilePhone = '7878787878', 
                                     Intake_Sent_Datetime__c = System.now(), smagicinteract__SMSOptOut__c = false
                                    );
            Lead leadObj2 = new Lead(LastName = 'TestLead2' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = practiceRecordType, Status = 'Intake Sent', MobilePhone = '7878787878', 
                                     Intake_Sent_Datetime__c = System.now() - 4, smagicinteract__SMSOptOut__c = false
                                    );
            Lead leadObj3 = new Lead(LastName = 'TestLead3' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = practiceRecordType, Status = 'Intake Sent', MobilePhone = '7878787878', 
                                     Intake_Sent_Datetime__c = System.now() - 20, smagicinteract__SMSOptOut__c = false
                                    );
             //Create Practice leads with Intake Sent status, mobilephone, optout as true
            Lead leadObj4 = new Lead(LastName = 'TestLead4' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = practiceRecordType, Status = 'Intake Sent', MobilePhone = '7878787878', 
                                     Intake_Sent_Datetime__c = System.now(), smagicinteract__SMSOptOut__c = true
                                    );
            Lead leadObj5 = new Lead(LastName = 'TestLead5' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = practiceRecordType, Status = 'Intake Sent', MobilePhone = '7878787878', 
                                     Intake_Sent_Datetime__c = System.now() - 4, smagicinteract__SMSOptOut__c = true
                                    );
            Lead leadObj6 = new Lead(LastName = 'TestLead6' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = practiceRecordType, Status = 'Intake Sent', MobilePhone = '7878787878', 
                                     Intake_Sent_Datetime__c = System.now() - 20, smagicinteract__SMSOptOut__c = true
                                    );
             //Create Practice leads with Intake Sent status, no mobilephone, optout as false
            Lead leadObj7 = new Lead(LastName = 'TestLead7' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = providerRecordType, Status = 'Intake Sent', 
                                     Intake_Sent_Datetime__c = System.now(), smagicinteract__SMSOptOut__c = false
                                    );
            Lead leadObj8 = new Lead(LastName = 'TestLead8' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = practiceRecordType, Status = 'Intake Sent',
                                     Intake_Sent_Datetime__c = System.now() - 4, smagicinteract__SMSOptOut__c = false
                                    );
            Lead leadObj9 = new Lead(LastName = 'TestLead9' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = practiceRecordType, Status = 'Intake Sent',
                                     Intake_Sent_Datetime__c = System.now() - 20, smagicinteract__SMSOptOut__c = false
                                    );
        
            //Create Provider leads with Intake Sent status, mobilephone, optout as false
            Lead leadObj11 = new Lead(LastName = 'TestLead1' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = providerRecordType, Status = 'Intake Sent', MobilePhone = '7878787878', 
                                     Intake_Sent_Datetime__c = System.now() - 4, smagicinteract__SMSOptOut__c = false
                                    );
            Lead leadObj12 = new Lead(LastName = 'TestLead2' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = providerRecordType, Status = 'Intake Sent', MobilePhone = '7878787878', 
                                     Intake_Sent_Datetime__c = System.now() - 30, smagicinteract__SMSOptOut__c = false
                                    );
            Lead leadObj13 = new Lead(LastName = 'TestLead3' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = providerRecordType, Status = 'Intake Sent', MobilePhone = '7878787878', 
                                     Intake_Sent_Datetime__c = System.now() - 60, smagicinteract__SMSOptOut__c = false
                                    );
             //Create Provider leads with Intake Sent status, mobilephone, optout as true
            Lead leadObj14 = new Lead(LastName = 'TestLead4' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = providerRecordType, Status = 'Intake Sent', MobilePhone = '7878787878', 
                                     Intake_Sent_Datetime__c = System.now() - 4, smagicinteract__SMSOptOut__c = true
                                    );
            Lead leadObj15 = new Lead(LastName = 'TestLead5' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = providerRecordType, Status = 'Intake Sent', MobilePhone = '7878787878', 
                                     Intake_Sent_Datetime__c = System.now() - 30, smagicinteract__SMSOptOut__c = true
                                    );
            Lead leadObj16 = new Lead(LastName = 'TestLead6' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = providerRecordType, Status = 'Intake Sent', MobilePhone = '7878787878', 
                                     Intake_Sent_Datetime__c = System.now() - 60, smagicinteract__SMSOptOut__c = true
                                    );
            //Create Provider leads with Intake Sent status, no mobilephone, optout as false
            Lead leadObj17 = new Lead(LastName = 'TestLead7' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = providerRecordType, Status = 'Intake Sent',
                                     Intake_Sent_Datetime__c = System.now() - 4, smagicinteract__SMSOptOut__c = false
                                    );
            Lead leadObj18 = new Lead(LastName = 'TestLead8' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = providerRecordType, Status = 'Intake Sent',  
                                     Intake_Sent_Datetime__c = System.now() - 30, smagicinteract__SMSOptOut__c = false
                                    );
            Lead leadObj19 = new Lead(LastName = 'TestLead9' , Company = 'TestCompany' , email = 'testLead@company.com',
                                     RecordTypeId = providerRecordType, Status = 'Intake Sent', 
                                     Intake_Sent_Datetime__c = System.now() - 60, smagicinteract__SMSOptOut__c = false
                                    );
            List<Lead> leadLst = new List<Lead>{
                leadObj1, leadObj2, leadObj3,
                leadObj4, leadObj5, leadObj6,
                leadObj7, leadObj8, leadObj9,
                leadObj11, leadObj12, leadObj13,
                leadObj14, leadObj15, leadObj16,
                leadObj19, leadObj18, leadObj17
            };
                insert leadLst;
        }
        //Insert smagicinteract__SMS_SenderId__c record
        smagicinteract__SMS_SenderId__c senderObject = new smagicinteract__SMS_SenderId__c(
            smagicinteract__senderId__c = '12133194239',
            smagicinteract__Email_Notification_Template__c = 'default',
            smagicinteract__Used_For__c = 'Both'
        );
        insert senderObject;
        //Create SMS templates
        List<smagicinteract__SMS_Template__c> templatesToInsert = new List<smagicinteract__SMS_Template__c>();
        templatesToInsert.add(createTemplate('Practice Intake Reminder 1'));
        templatesToInsert.add(createTemplate('Practice Intake Reminder 2'));
        templatesToInsert.add(createTemplate('Provider Intake Reminder 1'));
        templatesToInsert.add(createTemplate('Provider Intake Reminder 2'));
        templatesToInsert.add(createTemplate('Provider Intake Reminder 3'));
        templatesToInsert.add(createTemplate('Practice Intake Sent'));
         
        insert templatesToInsert;
    }

    testMethod private static void testPracticeLeadsWithIntakeSent20Mins(){
        List<Lead> leadToUpdate = new List<Lead>();
        for(Lead leadObj : [SELECT Id, Send_Intake_SMS__c FROM Lead WHERE Days_Since_Intake_Sent__c = 0]){
            leadObj.Send_Intake_SMS__c = true;
            leadToUpdate.add(leadObj);
        }
        update leadToUpdate;

        //Assert
        //One record of SMS history object will be inserted
        System.assertEquals(1, [SELECT Count() FROM smagicinteract__smsmagic__c]);
        List<Task> tasksLst = [SELECT Id, Subject FROM Task WHERE WhoId IN: leadToUpdate AND Subject LIKE '%SMS%'];
        System.assertEquals(1, tasksLst.size());
        System.assertEquals('Practice Intake Sent SMS' , tasksLst[0].Subject);
    }
	
    testMethod private static void testScheduler(){
        String CRON_EXP = '0 0 8 * * ?';
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new SynergyLeadSMSScheduler());
        Test.stopTest();
        //Assert
        //Five records of SMS history object will be inserted
        System.assertEquals(5, [SELECT Count() FROM smagicinteract__smsmagic__c]);

        //Assert for each Task
        Task taskObject = [SELECT Id, Subject FROM Task WHERE Who.RecordType.Name = 'Practice' AND WhoId
                                IN (SELECT Id FROM Lead WHERE Days_Since_Intake_Sent__c = 4) AND Subject LIKE '%SMS%'];
        System.assertEquals('Practice Intake Reminder 1 SMS' , taskObject.Subject);

        taskObject = [SELECT Id, Subject FROM Task WHERE Who.RecordType.Name = 'Practice' AND WhoId
                            IN (SELECT Id FROM Lead WHERE Days_Since_Intake_Sent__c = 20) AND Subject LIKE '%SMS%'];
        System.assertEquals('Practice Intake Reminder 2 SMS' , taskObject.Subject);

        taskObject = [SELECT Id, Subject FROM Task WHERE Who.RecordType.Name = 'Provider' AND WhoId
                            IN (SELECT Id FROM Lead WHERE Days_Since_Intake_Sent__c = 4) AND Subject LIKE '%SMS%'];
        System.assertEquals('Provider Intake Reminder 1 SMS' , taskObject.Subject);

        taskObject = [SELECT Id, Subject FROM Task WHERE Who.RecordType.Name = 'Provider' AND WhoId
                            IN (SELECT Id FROM Lead WHERE Days_Since_Intake_Sent__c = 30) AND Subject LIKE '%SMS%'];
        System.assertEquals('Provider Intake Reminder 2 SMS' , taskObject.Subject);

        taskObject = [SELECT Id, Subject FROM Task WHERE Who.RecordType.Name = 'Provider' AND WhoId
                            IN (SELECT Id FROM Lead WHERE Days_Since_Intake_Sent__c = 60) AND Subject LIKE '%SMS%'];
        System.assertEquals('Provider Intake Reminder 3 SMS' , taskObject.Subject);
    }

    private static smagicinteract__SMS_Template__c createTemplate(String templateName){
        String textTemplate = 'Hi Dr. {!lead.lastname}, this is {!lead.lead_entered_by__c} from Synergy Specialists. '
                    + 'We wanted to be sure you received our email with the application link. '
                    + 'If not, please let us know.';

        smagicinteract__SMS_Template__c template = new smagicinteract__SMS_Template__c(
                smagicinteract__Name__c = templateName,
                smagicinteract__ObjectName__c = 'lead',
                smagicinteract__Text__c = textTemplate
            );
        return template;
    }
}