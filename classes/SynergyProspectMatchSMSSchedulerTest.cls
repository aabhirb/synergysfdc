@isTest
public class SynergyProspectMatchSMSSchedulerTest {

    public static final String MATCH_SENT_TO_SP = 'Match Email Sent to SP';
    public static final String MATCH_SENT_TO_GP = 'Match Email Sent to GP';
    @TestSetup
    static void makeData(){
        Account accObject = new Account(Name = 'Test account');
        insert accObject;

        List<Prospect_Match__c> matchesToInsert = new List<Prospect_Match__c>();

        //Create GP and SP with mobilephone and optout as false
        Contact contact1 = new Contact(LastName = 'Contact1', email = 'abc@test.com', 
        MobilePhone = '7878787878', smagicinteract__SMSOptOut__c = false);
        insert contact1;
        matchesToInsert.add(createProspectMatch(contact1.Id, accObject.Id, MATCH_SENT_TO_GP));
        matchesToInsert.add(createProspectMatch(contact1.Id, accObject.Id, MATCH_SENT_TO_SP));

        //Create GP and SP with mobilephone and optout as true
        Contact contact2 = new Contact(LastName = 'Contact2', email = 'abc2@test.com', 
        MobilePhone = '7878787878', smagicinteract__SMSOptOut__c = true);
        insert contact2;
        matchesToInsert.add(createProspectMatch(contact2.Id, accObject.Id, MATCH_SENT_TO_GP));
        matchesToInsert.add(createProspectMatch(contact2.Id, accObject.Id, MATCH_SENT_TO_SP));

        //Create GP and SP no mobilephone and optout as false
        Contact contact3 = new Contact(LastName = 'Contact3', email = 'abc3@test.com', 
        MobilePhone = ' ', smagicinteract__SMSOptOut__c = false);
        insert contact3;
        matchesToInsert.add(createProspectMatch(contact3.Id, accObject.Id, MATCH_SENT_TO_GP));
        matchesToInsert.add(createProspectMatch(contact3.Id, accObject.Id, MATCH_SENT_TO_SP));

        insert matchesToInsert;
        
        //Create SMS templates and senderId
        //Insert smagicinteract__SMS_SenderId__c record
        smagicinteract__SMS_SenderId__c senderObject = new smagicinteract__SMS_SenderId__c(
            smagicinteract__senderId__c = '12133194239',
            smagicinteract__Email_Notification_Template__c = 'default',
            smagicinteract__Used_For__c = 'Both'
        );
        insert senderObject;
        //Create SMS templates
        List<smagicinteract__SMS_Template__c> templatesToInsert = new List<smagicinteract__SMS_Template__c>();
        templatesToInsert.add(createTemplate('Match Opt in Reminder to GP'));
        templatesToInsert.add(createTemplate('Match Opt in Reminder to SP'));
        insert templatesToInsert;
    }

    @IsTest
    static void testScheduler(){
        
        String CRON_EXP = '0 0 8 * * ?';
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new SynergyProspectMatchSMSScheduler());
        Test.stopTest();
        //Two record of SMS history object will be inserted
        System.assertEquals(2, [SELECT Count() FROM smagicinteract__smsmagic__c]);
        List<Task> tasksLst = [SELECT Id, Subject FROM Task WHERE Subject LIKE '%SMS%'];
        System.assertEquals(2, tasksLst.size());
        
    }
    private static Prospect_Match__c createProspectMatch(Id contactId, Id accountId, String stage){
        Prospect_Match__c match = new Prospect_Match__c(GP_Contact__c = contactId,
                SP_Contact__c = contactId,
                GP_Account__c = accountId,
                Match_Stage__c = stage,
                Match_Opt_in_Datetime__c = System.now() - 2
        );
        return match;
    }

    private static smagicinteract__SMS_Template__c createTemplate(String templateName){
        String textTemplate = 'Hi Dr. {!prospect_match__c.gp_contact_last_name__c} this is '
                    + '{!prospect_match__c.GP_Contact__r.contact_entered_by__c} from Synergy Specialists. '
                    + 'We emailed you details on a {!prospect_match__c.GP_Contact__r.sp_specialist_type__c} who '
                    + 'is available to match with your practice. Since their schedules fill up quickly, we\'d '
                    + 'like to enquire if you were interested in an introduction. Please let us know at your '
                    + 'convenience. Thank you.';

        smagicinteract__SMS_Template__c template = new smagicinteract__SMS_Template__c(
                smagicinteract__Name__c = templateName,
                smagicinteract__ObjectName__c = 'prospect_match__c',
                smagicinteract__Text__c = textTemplate
            );
        return template;
    }

}