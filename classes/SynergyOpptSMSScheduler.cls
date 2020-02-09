public class SynergyOpptSMSScheduler {
   
    ApexLogger.Logger logger;
    List<smagicinteract__SMS_Template__c> smsTemplates = [SELECT Id, smagicinteract__Name__c, smagicinteract__Text__c 
                                                              FROM smagicinteract__SMS_Template__c
                                                              WHERE smagicinteract__Name__c IN (
                                                                  'GP Introduction Follow up 1','GP Introduction Follow up 1',
                                                                  'SP Introduction Follow up 1', 'SP Introduction Follow up 2',
                                                                  'Provider Meeting Follow Up', 'Practice Meeting Follow Up'
                                                              )];
    public void execute(SchedulableContext SC) {
        logger = ApexLogger.createLogger('SynergyOpptSMSScheduler :'+System.now());
        //Query the SMS templates
        Map<String, smagicinteract__SMS_Template__c> nameToTemplateMap = new Map<String, smagicinteract__SMS_Template__c>();
        for(smagicinteract__SMS_Template__c template : smsTemplates){
            nameToTemplateMap.put(template.smagicinteract__Name__c, template);
        }
        
        //Get Practice Leads with status as Intake sent and call a method which sends sms
        Map<Id, Opportunity> introFollowUpToGP1hr = new Map<Id, Opportunity>();
        Map<Id, Opportunity> introFollowupToGP2days = new Map<Id, Opportunity>();
        
        Map<Id, Opportunity> introFollowupToSP1hr = new Map<Id, Opportunity>();
        Map<Id, Opportunity> introFollowupToSP2days = new Map<Id, Opportunity>();
        
        Map<Id, Opportunity> gpWithMeetingScheduled = new Map<Id, Opportunity>();
        Map<Id, Opportunity> spWithMeetingScheduled = new Map<Id, Opportunity>();
        
        for(Opportunity opptObject : SynergySMSHelper.getIntroducedGPs()){
            if(opptObject.Days_Since_Intro_Sent__c == 0.04){
                logger.log('Sending SMS to GP 1 hour after Introduction is sent '+opptObject.GP_Contact__r.Name);
                introFollowupToGP1hr.put(opptObject.Id, opptObject);
            } else if(opptObject.Days_Since_Intro_Sent__c == 2){
                logger.log('Sending SMS to GP 2 days after Introduction is sent '+opptObject.GP_Contact__r.Name);
                introFollowupToGP2days.put(opptObject.Id, opptObject);
            }
        }
        
        for(Opportunity opptObject : SynergySMSHelper.getIntroducedSPs()){
            if(opptObject.Days_Since_Intro_Sent__c == 0.1){
                logger.log('Sending SMS to GP 1 hour after Introduction is sent '+opptObject.Primary_Contact__r.Name);
                introFollowupToSP1hr.put(opptObject.Id, opptObject);
            } else if(opptObject.Days_Since_Intro_Sent__c == 2){
                logger.log('Sending SMS to GP 2 days after Introduction is sent '+opptObject.Primary_Contact__r.Name);
                introFollowupToSP2days.put(opptObject.Id, opptObject);
            }
        }
        
        for(Opportunity opptObject : SynergySMSHelper.getGPsWithMeetingScheduled()){
            if(Date.valueOf(opptObject.Meeting_Date__c) == System.today() - 1){
                logger.log('Sending SMS to GP 1 day after Meeting date '+opptObject.Primary_Contact__r.Name);
                gpWithMeetingScheduled.put(opptObject.Id, opptObject);
            }
        }
        
        for(Opportunity opptObject : SynergySMSHelper.getSPsWithMeetingScheduled()){
            if(Date.valueOf(opptObject.Meeting_Date__c) == System.today() - 1){
                logger.log('Sending SMS to SP 1 day after Meeting date '+opptObject.Primary_Contact__r.Name);
                spWithMeetingScheduled.put(opptObject.Id, opptObject);
            }
        }
        Boolean isError = false;
        try{
            SendSMSUtility.sendFollowupSMS(introFollowupToGP1hr, nameToTemplateMap.get('GP Introduction Follow up 1'), false); //isSP = false
            SendSMSUtility.sendFollowupSMS(introFollowupToGP2days, nameToTemplateMap.get('GP Introduction Follow up 2'), false);//isSP = false
            SendSMSUtility.sendFollowupSMS(gpWithMeetingScheduled, nameToTemplateMap.get('Practice Meeting Follow Up'), true);//isSP = false
            
            SendSMSUtility.sendFollowupSMS(introFollowupToSP1hr, nameToTemplateMap.get('SP Introduction Follow up 1'), true);//isSP = true
            SendSMSUtility.sendFollowupSMS(introFollowupToSP2days, nameToTemplateMap.get('SP Introduction Follow up 2'), true);//isSP = true
            SendSMSUtility.sendFollowupSMS(spWithMeetingScheduled, nameToTemplateMap.get('Provider Meeting Follow Up'), true);//isSP = true

        } catch(Exception e){
            isError = true;
            logger.logException(e);
        }
        logger.setStatus(isError ? 'Error' : 'Success');
		ApexLogger.commitLogs();
    }

}