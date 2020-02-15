public class SynergyLeadSMSScheduler implements Schedulable{
    
    ApexLogger.Logger logger;
    List<smagicinteract__SMS_Template__c> smsTemplates = [SELECT Id, smagicinteract__Name__c, smagicinteract__Text__c 
                                                              FROM smagicinteract__SMS_Template__c
                                                              WHERE smagicinteract__Name__c IN (
                                                                  'Practice Intake Reminder 1','Practice Intake Reminder 2',
                                                                  'Provider Intake Reminder 1', 'Provider Intake Reminder 2', 
                                                                  'Provider Intake Reminder 3'
                                                              )];
    public void execute(SchedulableContext SC) {
        logger = ApexLogger.createLogger('SynergyLeadSMSScheduler :'+System.now());
        //Query the SMS templates
        Map<String, smagicinteract__SMS_Template__c> nameToTemplateMap = new Map<String, smagicinteract__SMS_Template__c>();
        for(smagicinteract__SMS_Template__c template : smsTemplates){
            nameToTemplateMap.put(template.smagicinteract__Name__c, template);
        }
        
        //Get Practice Leads with status as Intake sent and call a method which sends sms
        Map<Id, Lead> prLeadIntakeSent4Days = new Map<Id, Lead>();
        Map<Id, Lead> prLeadIntakeSent20Days = new Map<Id, Lead>();
        //For Provider leads
        Map<Id, Lead> proLeadIntakeSent4Days = new Map<Id, Lead>();
        Map<Id, Lead> proLeadIntakeSent30Days = new Map<Id, Lead>();
        Map<Id, Lead> proLeadIntakeSent60Days = new Map<Id, Lead>();
        
        for(Lead leadObject : SynergySMSHelper.getPracticeIntakeSentLeads()){
            if(leadObject.Days_Since_Intake_Sent__c == 4){
                logger.log('Sending SMS 4 days after Intake sent and still incomplete to practice lead'+leadObject.Name);
                prLeadIntakeSent4Days.put(leadObject.Id, leadObject);
            } else if(leadObject.Days_Since_Intake_Sent__c == 20){
                logger.log('Sending SMS 20 days after Intake sent and still incomplete to practice lead '+leadObject.Name);
                prLeadIntakeSent20Days.put(leadObject.Id, leadObject);
            }
        }
        
        for(Lead leadObject : SynergySMSHelper.getProviderIntakeSentLeads()){
            if(leadObject.Days_Since_Intake_Sent__c == 4){
                logger.log('Sending SMS 4 days after Intake sent and still incomplete to provider lead'+leadObject.Name);
                proLeadIntakeSent4Days.put(leadObject.Id, leadObject);
            } else if(leadObject.Days_Since_Intake_Sent__c == 30){
                logger.log('Sending SMS 30 days after Intake sent and still incomplete to provider lead'+leadObject.Name);
                proLeadIntakeSent30Days.put(leadObject.Id, leadObject);
            } else if(leadObject.Days_Since_Intake_Sent__c == 60){
                logger.log('Sending SMS 60 days after Intake sent and still incomplete to provider lead'+leadObject.Name);
                proLeadIntakeSent60Days.put(leadObject.Id, leadObject);
            }
        }
        
        Boolean isError = false;
        try{
            SendSMSUtility.sendIntakeSMS(prLeadIntakeSent4Days, nameToTemplateMap.get('Practice Intake Reminder 1'), null);
        	SendSMSUtility.sendIntakeSMS(prLeadIntakeSent20Days, nameToTemplateMap.get('Practice Intake Reminder 2'), null);
            SendSMSUtility.sendIntakeSMS(proLeadIntakeSent4Days, nameToTemplateMap.get('Provider Intake Reminder 1'), null);
            SendSMSUtility.sendIntakeSMS(proLeadIntakeSent30Days, nameToTemplateMap.get('Provider Intake Reminder 2'), null);
            SendSMSUtility.sendIntakeSMS(proLeadIntakeSent60Days, nameToTemplateMap.get('Provider Intake Reminder 3'), null);
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