public class SynergyProspectMatchSMSScheduler implements Schedulable{
    
    ApexLogger.Logger logger;
    List<smagicinteract__SMS_Template__c> smsTemplates = [SELECT Id, smagicinteract__Name__c, smagicinteract__Text__c 
                                                              FROM smagicinteract__SMS_Template__c
                                                              WHERE smagicinteract__Name__c IN (
                                                                  'Match Opt in Reminder to GP','Match Opt in Reminder to SP'
                                                              )];
    public void execute(SchedulableContext SC) {
        logger = ApexLogger.createLogger('SynergyProspectMatchSMSScheduler :'+System.now());
        Boolean isError = false;
        try{
            //Query the SMS templates
            Map<String, smagicinteract__SMS_Template__c> nameToTemplateMap = new Map<String, smagicinteract__SMS_Template__c>();
            for(smagicinteract__SMS_Template__c template : smsTemplates){
                nameToTemplateMap.put(template.smagicinteract__Name__c, template);
            }
            
            //Get Practice Leads with status as Intake sent and call a method which sends sms
            Map<Id, Prospect_Match__c> matchOptInSentGPs = new Map<Id, Prospect_Match__c>();
            Map<Id, Prospect_Match__c> matchOptInSentSPs = new Map<Id, Prospect_Match__c>();
            
            for(Prospect_Match__c matchVar : SynergySMSHelper.getMatchOptInSentGP()){
                if(matchVar.Days_Since_Match_Opt_in__c == 2){
                    logger.log('Sending SMS 2 days after Match Opt-in sent to GP '+matchVar.Name);
                    matchOptInSentGPs.put(matchVar.Id, matchVar);
                }
            }
            
            for(Prospect_Match__c matchVar : SynergySMSHelper.getMatchOptInSentSP()){
                if(matchVar.Days_Since_Match_Opt_in__c == 2){
                    logger.log('Sending SMS 2 days after Match Opt-in sent to SP '+matchVar.Name);
                    matchOptInSentSPs.put(matchVar.Id, matchVar);
                }
            }
            
            SendSMSUtility.sendOptInSMS(matchOptInSentGPs, nameToTemplateMap.get('Match Opt in Reminder to GP'), false); //isSP = false
            SendSMSUtility.sendOptInSMS(matchOptInSentSPs, nameToTemplateMap.get('Match Opt in Reminder to SP'), true); //isSP = true
        } catch(Exception e){
            isError = true;
            logger.logException(e);
            System.debug('e  '+e.getStackTraceString());
        }
        logger.setStatus(isError ? 'Error' : 'Success');
		ApexLogger.commitLogs();
    }

}