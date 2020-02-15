public class SynergyOpptSMSScheduler implements Schedulable{
   
    ApexLogger.Logger logger;
    List<smagicinteract__SMS_Template__c> smsTemplates = [SELECT Id, smagicinteract__Name__c, smagicinteract__Text__c 
                                                              FROM smagicinteract__SMS_Template__c
                                                              WHERE smagicinteract__Name__c IN (
                                                                  'GP Introduction Follow up 2',
                                                                  'SP Introduction Follow up 2',
                                                                  'Provider Meeting Follow Up', 'Practice Meeting Follow Up',
                                                                  'Practice Tx Date Reminder'
                                                              )];
    public void execute(SchedulableContext SC) {
        logger = ApexLogger.createLogger('SynergyOpptSMSScheduler :'+System.now());
        Boolean isError = false;

        try {
            //Query the SMS templates
            Map<String, smagicinteract__SMS_Template__c> nameToTemplateMap = new Map<String, smagicinteract__SMS_Template__c>();
            for(smagicinteract__SMS_Template__c template : smsTemplates){
                nameToTemplateMap.put(template.smagicinteract__Name__c, template);
            }
            
            Map<Id, Opportunity> introFollowupToGP2days = new Map<Id, Opportunity>();        
            Map<Id, Opportunity> introFollowupToSP2days = new Map<Id, Opportunity>();
            
            Map<Id, Opportunity> gpWithMeetingScheduled = new Map<Id, Opportunity>();
            Map<Id, Opportunity> spWithMeetingScheduled = new Map<Id, Opportunity>();
        
            Map<Id, Opportunity> gpWithNoTxScheduled = new Map<Id, Opportunity>();
            
            //2 days after Intro sent out to GP
            for(Opportunity opptObject : SynergySMSHelper.getIntroducedGPs()){
                if(opptObject.Days_Since_Intro_Sent__c == 2){
                    logger.log('Sending SMS to GP 2 days after Introduction is sent '+opptObject.GP_Contact__r.Name);
                    introFollowupToGP2days.put(opptObject.Id, opptObject);
                }
            }
            //2 days after Intro sent out to SP
            for(Opportunity opptObject : SynergySMSHelper.getIntroducedSPs()){
                if(opptObject.Days_Since_Intro_Sent__c == 2){
                    logger.log('Sending SMS to SP 2 days after Introduction is sent '+opptObject.Primary_Contact__r.Name);
                    introFollowupToSP2days.put(opptObject.Id, opptObject);
                }
            }
            
            for(Opportunity opptObject : SynergySMSHelper.getGPsWithMeetingScheduled()){
                if(opptObject.Meeting_Date__c != null && opptObject.Meeting_Date__c.date() == System.today() - 1){
                    logger.log('Sending SMS to GP 1 day after Meeting date '+opptObject.GP_Contact__r.Name);
                    gpWithMeetingScheduled.put(opptObject.Id, opptObject);
                }
            }
            
            for(Opportunity opptObject : SynergySMSHelper.getSPsWithMeetingScheduled()){
                if(opptObject.Meeting_Date__c != null && opptObject.Meeting_Date__c.date() == System.today() - 1){
                    logger.log('Sending SMS to SP 1 day after Meeting date '+opptObject.Primary_Contact__r.Name);
                    spWithMeetingScheduled.put(opptObject.Id, opptObject);
                }
            }
            
            //Ankita A: 3 days after Preparation Email sent and no Tx dates booked
            for(Opportunity opptObject : SynergySMSHelper.getGpWithNoTxScheduled()){
                if(opptObject.Prep_Completion_Date__c == System.today() - 3){
                    logger.log('Sending SMS to GP, 3 days after Preparation Email sent and no Tx dates booked '+opptObject.GP_Contact__r.Name);
                    gpWithNoTxScheduled.put(opptObject.Id, opptObject);
                }
            }
            SendSMSUtility.sendFollowupSMS(introFollowupToGP2days, nameToTemplateMap.get('GP Introduction Follow up 2'), false);//isSP = false
            SendSMSUtility.sendFollowupSMS(gpWithMeetingScheduled, nameToTemplateMap.get('Practice Meeting Follow Up'), false);//isSP = false
            
            SendSMSUtility.sendFollowupSMS(introFollowupToSP2days, nameToTemplateMap.get('SP Introduction Follow up 2'), true);//isSP = true
            SendSMSUtility.sendFollowupSMS(spWithMeetingScheduled, nameToTemplateMap.get('Provider Meeting Follow Up'), true);//isSP = true
            
            SendSMSUtility.sendFollowupSMS(gpWithNoTxScheduled, nameToTemplateMap.get('Practice Tx Date Reminder'), false);//isSP = false
    
                
        } catch(Exception e){
            isError = true;
            logger.logException(e);
        }
        //Check if errorLst has any records
        List<String> errorLst = SendSMSUtility.errorLst;
        if(errorLst.size() > 0){
            isError = true;
            logger.log(string.join(errorLst, ' \n'));
        }
        logger.setStatus(isError ? 'Error' : 'Success');
		ApexLogger.commitLogs();
    }

}