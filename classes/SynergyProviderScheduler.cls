public class SynergyProviderScheduler implements Schedulable{
    
    ApexLogger.Logger logger = ApexLogger.createLogger('SynergyProviderScheduler :'+Date.Today());
    
    // Code for scheduling this class on first business day of every month 
    /*
        SynergyProviderScheduler scheduler = new SynergyProviderScheduler();
        String cronExp = '0 0 8 1W * ?'; //Class runs  on  1st day of every month at 8 AM
        System.schedule('Provider Monthly Tx day request', cronExp, scheduler);  
	*/
    
    public void execute(SchedulableContext SC) {
        try{
            sendProviderTxRequestEmail();
            logger.setStatus('SUCCESS');
        } catch(Exception e){
            logger.logException(e);
        } finally{
			ApexLogger.commitLogs();        
        }
        
    }
    
    private void sendProviderTxRequestEmail(){
        //Query closed/won Oppt
        Set<Id> contactIds = new Set<Id>();
        logger.log('Sending email to Providers which as closed/won Opportunity with invoices '
                   + 'with Tx Date in last 90 days (Not cancelled) and does not have anything Tx date scheduled for Next 60 days');
        //Get list of closed/won Oppt with invoices with Tx Date in last 90 days (Not cancelled)
        //and does not have anything Tx date scheduled for Next 60 days
        for(Opportunity oppt : [SELECT Id, StageName, Primary_Contact__c, Primary_Contact__r.Name
                                FROM Opportunity WHERE isWon = true AND 
								Id IN (SELECT Opportunity__c FROM Opportunity_Line_Item__c WHERE Treatment_Date__c = LAST_90_DAYS AND Status__c != 'Cancelled') AND 
								Id NOT IN (SELECT Opportunity__c FROM Opportunity_Line_Item__c WHERE Treatment_Date__c = NEXT_N_DAYS:60)]){
			//Get Provider 
			contactIds.add(oppt.Primary_Contact__c);
			logger.log('Sending Email for : '+oppt.Primary_Contact__r.Name + '\n');
        }
        Map<String,Id> emailTemplateMap = new Map<String,Id>();
        for( EmailTemplate template : [ SELECT Id,Name,DeveloperName from EmailTemplate where
                                                DeveloperName IN ('Provider_Monthly_Tx_day_Request')]){
            emailTemplateMap.put(template.DeveloperName , template.Id);
        }
        List<Messaging.SingleEmailMessage> singleEmailMsgLst = new List<Messaging.SingleEmailMessage>();
        for(Id contactId : contactIds){
            Messaging.SingleEmailMessage emailMessage = Utility.sendEmail(null,  
                                                                          emailTemplateMap.get('Provider_Monthly_Tx_day_Request'),
                                                                          contactId);
            singleEmailMsgLst.add(emailMessage);
        }
        
        if(!singleEmailMsgLst.isEmpty()){
            Messaging.sendEmail(singleEmailMsgLst);
        }
            
        //Done for creating activity
        for(Id contactId : contactIds){
            Utility.synchActivity(contactId, contactId);
        }
    }

}