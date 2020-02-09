/**
 * Created by abidap on 3/24/19.
 */

public with sharing class LeadTriggerHandler {
    public static Id providerRecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType , 'Provider' );
    public static void geoCodeIncorrectAddress( List<Lead> leadLst ){
        List<SObject> sobjectLstToGeoCode = new List<SObject>();

        for( Lead leadObj :  leadLst ){
            if( leadObj.Latitude == null && leadObj.Longitude == null
                    && ( leadObj.City != null || leadObj.Street != null || leadObj.State != null ) ){
                sobjectLstToGeoCode.add(leadObj);
            }
        }

        GeoCodeAddressAsynch asynchInst = new GeoCodeAddressAsynch();
        asynchInst.sobjectLst = sobjectLstToGeoCode;
        asynchInst.sobjectType = 'Lead';

        System.enqueueJob( asynchInst );


    }

    public static void triggerIntakeFollowUp( List<Lead> leadLst , Map<Id,Lead> oldLeadMap ){

        Id spFollowUpTemplateId;
        Id gpFollowUpTemplateId;

        for( EmailTemplate template : [select id,DeveloperName from EmailTemplate where DeveloperName IN ('SP_Intake_Follow_up','GP_Intake_Follow_up') ]){
            if( template.DeveloperName == 'SP_Intake_Follow_up' ){
                spFollowUpTemplateId = template.Id;
            }else if(template.DeveloperName == 'GP_Intake_Follow_up' ){
                gpFollowUpTemplateId = template.Id;
            }
        }

        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();

        for( Lead leadObj :  leadLst ){

            if(leadObj.Status == 'Intake Sent' &&
                    leadObj.Intake_Followup_Sent__c == true && leadObj.Intake_Followup_Sent__c != oldLeadMap.get(leadObj.Id).Intake_Followup_Sent__c  ){

                Id templateIdToUse = ( leadObj.RecordTypeId == Utility.getsObjectRecordTypeId(Lead.SObjectType,'Practice') ) ? gpFollowUpTemplateId : spFollowUpTemplateId;
                Messaging.SingleEmailMessage messageToGetBody = Messaging.renderStoredEmailTemplate( templateIdToUse ,leadObj.Id, leadObj.Id);

                // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
                // contents to a new SingleEmailMessage. Then send those new messages.
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setHTMLBody(messageToGetBody.getHTMLBody());
                emailToSend.setTargetObjectId(leadObj.id);
                emailToSend.setSubject(messageToGetBody.getSubject());
                emailToSend.setCcAddresses(System.Label.Email_Cust_CC_Address.split(','));
                OrgWideEmailAddress  owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='hello@synergyspecialists.co'];
                emailToSend.setOrgWideEmailAddressId(owea.Id);

                lstMsgsToSend.add(emailToSend);


            }
        }

        if( !lstMsgsToSend.isEmpty() ){

            Messaging.sendEmail( lstMsgsToSend );
        }

        //Ankita A: 6 Feb 2020: Send Intake Sent SMS to Practice leads
        ApexLogger.Logger logger = ApexLogger.createLogger('Synergy Lead SMS :'+System.now());
        Map<Id, Lead> prLeadIntakeSent20Mins = new Map<Id, Lead>();
        for(Lead leadObject : [SELECT Id, MobilePhone, Name, Send_Intake_SMS__c FROM Lead 
                                    WHERE Id IN: leadLst AND MobilePhone != null AND smagicinteract__SMSOptOut__c = false]){
            //If Send Intake SMS field is true and it's value has changed
            if(leadObject.Send_Intake_SMS__c && leadObject.Send_Intake_SMS__c != oldLeadMap.get(leadObject.Id).Send_Intake_SMS__c){
                logger.log('Sending SMS 20 min after intake sent to practice lead '+leadObject.Name);
                prLeadIntakeSent20Mins.put(leadObject.Id, leadObject);
            }
        }
        //If the prLeadIntakeSent map contains any elements
        if(prLeadIntakeSent20Mins.size() > 0){
            //Query the SMS template
            List<smagicinteract__SMS_Template__c> smsTemplates = [SELECT Id, smagicinteract__Name__c, smagicinteract__Text__c 
                                                                    FROM smagicinteract__SMS_Template__c
                                                                    WHERE smagicinteract__Name__c IN ('Practice Intake Sent')
                                                                ];
            Map<String, smagicinteract__SMS_Template__c> nameToTemplateMap = new Map<String, smagicinteract__SMS_Template__c>();
            for(smagicinteract__SMS_Template__c template : smsTemplates){
                nameToTemplateMap.put(template.smagicinteract__Name__c, template);
            }
            Boolean isError = false;
            try{
                //Call utility method to send SMS
                SendSMSUtility.sendIntakeSMS(prLeadIntakeSent20Mins, nameToTemplateMap.get('Practice Intake Sent'), null);
            } catch(Exception e){
                isError = true;
                logger.logException(e);
            }
            logger.setStatus(isError ? 'Error' : 'Success');
            ApexLogger.commitLogs();
        }
    }


    public static void completeFollowUpTasks( List<Lead> newLeads , Map<Id,Lead> oldMap ){

        List<Lead> leadsToFollowUp = new List<Lead>();
        Set<Id> wonLeadIdSet = new Set<Id>();
        Set<Id> lostLeadIdSet = new Set<Id>();
        Id providerRecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType , 'Provider' );
        for( Lead leadObj :  newLeads ){

            if( leadObj.Status == 'Intake Complete' && leadObj.Status != oldMap.get(leadObj.Id).Status && leadObj.RecordTypeId == providerRecordTypeId ){
                leadsToFollowUp.add(leadObj);
                wonLeadIdSet.add(leadObj.Id);
            }else if( leadObj.Status == 'DNC' && leadObj.Status != oldMap.get(leadObj.Id).Status && leadObj.RecordTypeId == providerRecordTypeId ){
                leadsToFollowUp.add(leadObj);
                lostLeadIdSet.add(leadObj.Id);
            }else if( leadObj.isConverted == true && leadObj.isConverted != oldMap.get(leadObj.Id).isConverted && leadObj.RecordTypeId == providerRecordTypeId ){
                leadsToFollowUp.add(leadObj);
                wonLeadIdSet.add(leadObj.Id);
            }
        }


        List<Task> taskLstToUpdate = new List<Task>();

        for( Task taskObj :  [ SELECT id,WhoId from Task where Type = 'Intake Follow Up' and status = 'Open' and WhoId IN: leadsToFollowUp ] ){
            taskObj.Status = (wonLeadIdSet.contains(taskObj.WhoId)) ? 'Completed - Won' : 'Completed - Lost';
            taskLstToUpdate.add(taskObj);
        }



        if( !taskLstToUpdate.isEmpty() ){
            update taskLstToUpdate;
        }
    }

    public static void createFollowUpTasks( List<Lead> newLeads , Map<Id,Lead> oldMap ) {

        List<Lead> leadsToFollowUp = new List<Lead>();

        for( Lead leadObj :  newLeads ){

            if( leadObj.Status == 'Intake Sent' && leadObj.Status != oldMap.get(leadObj.Id).Status && leadObj.RecordTypeId == providerRecordTypeId ){
                leadsToFollowUp.add(leadObj);
            }
        }

        List<Task> taskLstToInsert = new List<Task>();
        if ( ! leadsToFollowUp.isEmpty() ) {

            for( Lead leadObj : leadsToFollowUp ){

                taskLstToInsert.add(
                                        new Task(
                                                Status = 'Open' , Subject = 'Attempt #1 - Dr. '+leadObj.LastName+' Follow up - Intake not filled.' , Type = 'Intake Follow Up' , WhoId = leadObj.Id , IsReminderSet = true ,
                                                ActivityDate = Date.today().addDays(4) , Description = ( 'Attempt #1 \n Dr. '+leadObj.LastName+' has not filled the intake form , Please follow up. Follow up after 4 days.')  , OwnerId = System.Label.UserId_Dr_Ury
                                            )
                                    );

                taskLstToInsert.add(
                        new Task(
                                Status = 'Open' , Subject = 'Attempt #2 - Dr. '+leadObj.LastName+' Follow up - Intake not filled.' , Type = 'Intake Follow Up' , WhoId = leadObj.Id , IsReminderSet = true ,
                                ActivityDate = Date.today().addDays(8) , Description = ( 'Attempt #1 \n Dr. '+leadObj.LastName+' has not filled the intake form , Please follow up. Follow up after 8 days. ')  , OwnerId = System.Label.UserId_Dr_Ury
                        )
                );

                taskLstToInsert.add(
                        new Task(
                                Status = 'Open' , Subject = 'Attempt #3 - Dr. '+leadObj.LastName+' Follow up - Intake not filled.' , Type = 'Intake Follow Up' , WhoId = leadObj.Id , IsReminderSet = true ,
                                ActivityDate = Date.today().addDays(12) , Description = ( 'Attempt #1 \n Dr. '+leadObj.LastName+' has not filled the intake form , Please follow up. Follow up after 12 days. Final Follow Up ')  , OwnerId = System.Label.UserId_Dr_Ury
                        )
                );

            }
        }

        if( !taskLstToInsert.isEmpty() ){
            insert taskLstToInsert;
        }
    }

    public static void logCustomerAgreement( List<Lead> newLeads , Map<Id,Lead> oldMap ) {

        List<Lead> leadsToFollowUp = new List<Lead>();
        Id templateIdToUse = null;
        List<EmailTemplate> templateLst = [Select id,DeveloperName from EmailTemplate where DeveloperName =  'Customer_Interest_Email'];
        templateIdToUse = (templateLst != null && !templateLst.isEmpty() ) ? templateLst[0].Id : null;
        // Send Customer Agreement EMail
        for (Lead leadObj : newLeads) {

            if (leadObj.Status == 'Intake Sent' && leadObj.Ready_For_Conversion__c == true
                        && leadObj.Ready_For_Conversion__c != oldMap.get(leadObj.Id).Ready_For_Conversion__c && leadObj.RecordTypeId == providerRecordTypeId) {
                leadsToFollowUp.add(leadObj);
            }
        }

        if( !leadsToFollowUp.isEmpty() ){

            List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();

            for( Lead leadObj : leadsToFollowUp ){

                //Messaging.SingleEmailMessage messageToGetBody = Messaging.renderStoredEmailTemplate( templateIdToUse ,leadObj.Id, leadObj.Id);

                // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
                // contents to a new SingleEmailMessage. Then send those new messages.
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                //emailToSend.setHTMLBody(messageToGetBody.getHTMLBody());
                // Step 4. Set email contents - you can use variables!
                emailToSend.setSubject('Dr.'+leadObj.LastName+'- Interested to sign up with Synergy');
                String body = 'Hi Team,<br/>';
                body += 'As per my conversation with Dr. '+leadObj.LastName+', he / she is interested to sign up with Synergy.<br/>';
                body += 'Please proceed with conversion and docusign.<br/>';
                body += 'https://ascendorthodontics--devchavi.my.salesforce.com/'+leadObj.Id;

                body += '<br/>Thanks,';

                emailToSend.setHtmlBody(body);
                //emailToSend.setTargetObjectId(leadObj.id);
                emailToSend.setToAddresses(System.Label.Email_Cust_Agreement_To_Address.split(','));
                
                emailToSend.setCcAddresses(System.Label.Email_Cust_Agreement_To_CC_Address.split(','));

                lstMsgsToSend.add(emailToSend);
            }

            if( !lstMsgsToSend.isEmpty() ){

                Messaging.sendEmail( lstMsgsToSend );
            }

            List<Task> taskLstToUpdate = new List<Task>();

            for( Task taskObj :  [ SELECT id,WhoId from Task where Type = 'Intake Follow Up' and status = 'Open' and WhoId IN: leadsToFollowUp ] ){
                taskObj.Status = 'Completed - Won';
                taskLstToUpdate.add(taskObj);
            }

            if( !taskLstToUpdate.isEmpty() ){
                update taskLstToUpdate;
            }
        }
        // Close Complete - won all Open Tasks
    }
}