@isTest
public class SynergyOpptSMSSchedulerTest {

    @testSetup
    private static void createTestData(){
        List<Opportunity> opptsToInsert = new List<Opportunity>();
        {
            //Create opportunity with GP and SP with mobilephone and optout as false
            Contact contact1 = new Contact(LastName = 'Contact1', email = 'abc@test.com', 
                                    MobilePhone = '7878787878', smagicinteract__SMSOptOut__c = false);
            insert contact1;
            //Create Opportunity with stage name as Introduced
            opptsToInsert.add(createOppWithIntroducedStage(contact1.Id, System.now()));
            opptsToInsert.add(createOppWithIntroducedStage(contact1.Id, System.now() - 2));

            //Create Opportunity with Stage as Meeting scheduled and meeting date
            opptsToInsert.add(createOppWithMeetingScheduled(contact1.Id, System.now() - 1));
            opptsToInsert.add(createOppWithMeetingScheduled(contact1.Id, null));

            //Create Opportunity with Preparation Email sent out
            opptsToInsert.add(createOppWithPrepCompleted(contact1.Id, System.today() - 3));
            opptsToInsert.add(createOppWithPrepCompleted(contact1.Id, null));
        }

        {
            //Create opportunity with GP and SP with mobilephone and optout as true
            Contact contact2 = new Contact(LastName = 'Contact2', email = 'abc2@test.com', 
                                    MobilePhone = '7878787878', smagicinteract__SMSOptOut__c = true);
            insert contact2;
            //Create Opportunity with stage name as Introduced
            opptsToInsert.add(createOppWithIntroducedStage(contact2.Id, System.now()));
            opptsToInsert.add(createOppWithIntroducedStage(contact2.Id, System.now() - 2));

            //Create Opportunity with Stage as Meeting scheduled and meeting date
            opptsToInsert.add(createOppWithMeetingScheduled(contact2.Id, System.now() - 1));
            opptsToInsert.add(createOppWithMeetingScheduled(contact2.Id, null));

            //Create Opportunity with Preparation Email sent out
            opptsToInsert.add(createOppWithPrepCompleted(contact2.Id, System.today() - 3));
            opptsToInsert.add(createOppWithPrepCompleted(contact2.Id, null));
        }

        {
            //Create opportunity with GP and SP no mobilephone and optout as false
            Contact contact3 = new Contact(LastName = 'Contact3', email = 'abc3@test.com', 
                                    MobilePhone = ' ', smagicinteract__SMSOptOut__c = false);
            insert contact3;
            //Create Opportunity with stage name as Introduced
            opptsToInsert.add(createOppWithIntroducedStage(contact3.Id, System.now()));
            opptsToInsert.add(createOppWithIntroducedStage(contact3.Id, System.now() - 2));

            //Create Opportunity with Stage as Meeting scheduled and meeting date
            opptsToInsert.add(createOppWithMeetingScheduled(contact3.Id, System.now() - 1));
            opptsToInsert.add(createOppWithMeetingScheduled(contact3.Id, null));

            //Create Opportunity with Preparation Email sent out
            opptsToInsert.add(createOppWithPrepCompleted(contact3.Id, System.today() - 3));
            opptsToInsert.add(createOppWithPrepCompleted(contact3.Id, null));
        }

        insert opptsToInsert;

        {
            //Insert smagicinteract__SMS_SenderId__c record
            smagicinteract__SMS_SenderId__c senderObject = new smagicinteract__SMS_SenderId__c(
                smagicinteract__senderId__c = '12133194239',
                smagicinteract__Email_Notification_Template__c = 'default',
                smagicinteract__Used_For__c = 'Both'
            );
            insert senderObject;
            //Create SMS templates
            List<smagicinteract__SMS_Template__c> templatesToInsert = new List<smagicinteract__SMS_Template__c>();
            templatesToInsert.add(createTemplate('GP Introduction Follow up 1'));
            templatesToInsert.add(createTemplate('GP Introduction Follow up 2'));
            templatesToInsert.add(createTemplate('SP Introduction Follow up 1'));
            templatesToInsert.add(createTemplate('SP Introduction Follow up 2'));
            templatesToInsert.add(createTemplate('Provider Meeting Follow Up'));
            templatesToInsert.add(createTemplate('Practice Meeting Follow Up'));
            templatesToInsert.add(createTemplate('Practice Tx Date Reminder'));
            insert templatesToInsert;
        }
    }

    testMethod private static void testUpdationofSendIntroSMSCheckbox(){
        List<Opportunity> opptToUpdate = new List<Opportunity>();
        for(Opportunity opptObject : [SELECT Id, Send_Introduction_SMS__c FROM Opportunity WHERE Days_Since_Intro_Sent__c = 0]){
            opptObject.Send_Introduction_SMS__c = true;
            opptToUpdate.add(opptObject);
        }
        update opptToUpdate;
        //Two record of SMS history object will be inserted
        System.assertEquals(2, [SELECT Count() FROM smagicinteract__smsmagic__c]);
        List<Task> tasksLst = [SELECT Id, Subject FROM Task WHERE WhatId IN: opptToUpdate];
        System.assertEquals(2, tasksLst.size());
    }

    testMethod private static void testScheduler(){
        String CRON_EXP = '0 0 8 * * ?';
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new SynergyOpptSMSScheduler());
        Test.stopTest();
        //Five record of SMS history object will be inserted
        System.assertEquals(5, [SELECT Count() FROM smagicinteract__smsmagic__c]);
        List<Task> tasksLst = [SELECT Id, Subject FROM Task WHERE Subject LIKE '%SMS%'];
        System.assertEquals(5, tasksLst.size());
    }

    private static Opportunity createOppWithIntroducedStage(Id contactId, DateTime introDateTime){
        Opportunity opptObject = new Opportunity(Name='Test Opportunity',
                                                    StageName='Introduced', 
                                                    Probability = 100, 
                                                    CloseDate = System.today(),
                                                    Primary_Contact__c = contactId,
                                                    GP_Contact__c = contactId,
                                                    Introduction_Datetime__c = introDateTime
                                                );
        return opptObject;
    }

    private static Opportunity createOppWithMeetingScheduled(Id contactId, DateTime meetingdate){
        Opportunity opptObject = new Opportunity(Name='Test Opportunity',
                                                    StageName='Meeting Scheduled', 
                                                    Probability = 100,
                                                    CloseDate = System.today(),
                                                    Primary_Contact__c = contactId,
                                                    GP_Contact__c = contactId,
                                                    Meeting_Date_Set__c = true,
                                                    Meeting_Date__c = meetingdate
                                                );
        return opptObject;
    }

    private static Opportunity createOppWithPrepCompleted(Id contactId, Date prepDate){
        Opportunity opptObject = new Opportunity(Name='Test Opportunity',
                                                    StageName='Prep started', 
                                                    Probability = 100,
                                                    CloseDate = System.today(),
                                                    Primary_Contact__c = contactId,
                                                    GP_Contact__c = contactId,
                                                    Specialist_Package__c = true,
                                                    Prep_Completion_Date__c = prepDate
                                                );
        return opptObject;
    }

    private static smagicinteract__SMS_Template__c createTemplate(String templateName){
        String textTemplate = 'Hi Dr. {!opportunity.sp_lastname__c}, this is {!opportunity.owner__c} '
                            + ' from Synergy Specialists. We sent out an introduction to Dr. {!opportunity.od_lastname__c} '
                            + ' at {!opportunity.GP_Contact__r.Account.name} recently.';

        smagicinteract__SMS_Template__c template = new smagicinteract__SMS_Template__c(
                smagicinteract__Name__c = templateName,
                smagicinteract__ObjectName__c = 'opportunity',
                smagicinteract__Text__c = textTemplate
            );
        return template;
    }
    

}