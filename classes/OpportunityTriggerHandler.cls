/**
 * Created by abidap on 12/27/18.
 */

public with sharing class OpportunityTriggerHandler {
    /*
     * @Author : AB
     * @Description : This method is used to create Prospect Match records everytime Opportunity records are created in SFDC
     * @business UseCase : Everytime SP lead is converted to Opportunity on Opportunity creation, system will query and associate nearest GP Contacts.
     * @Assumptions      : Process using Batch size 1 for bulk because of limit on SOQL and use of geolocation
     *                     Do not do opportunity insert from future , need to handle future scenario
     */
    public static void createProspectMatches(List<Opportunity> newOpptyLst){


        if(newOpptyLst != null && !newOpptyLst.isEmpty()){
            Set<Id> opptyIdSet = new Set <Id>();
            Decimal mileRadius = 50;
            for( Opportunity oppty : newOpptyLst){
                opptyIdSet.add(oppty.Id);
                if(oppty.Mile_Radius__c != null){
                    mileRadius = oppty.Mile_Radius__c;
                }

            }

            //createProspectFuture( opptyIdSet , mileRadius );
        }
    }

    //@Future(callout=true)
    public static void createProspectFuture(Set<Id> opportunityIdSet , Decimal mileRadius){
        /*Map<Id,Id> opportunityToContactMap = new Map<Id,Id>();
        Map<Id,Id> contactToOpportunityMap = new Map<Id,Id>();
        List<Future_Match__c> matchLst = new List<Future_Match__c>();
        ApexLogger.Logger logger = ApexLogger.createLogger('CreateProspectFuture '+system.now());

        logger.log('Received opportunityIdSet : '+opportunityIdSet);

        try{

            if(opportunityIdSet != null && !opportunityIdSet.isEmpty()){
                List<Opportunity> opptyLst = [
                                                    SELECT Id,Primary_Contact__c,Name,SP_Specialist_Type__c,States_Licensed__c,Mile_Radius__c
                                                    from
                                                            Opportunity
                                                    where
                                                            Id IN : opportunityIdSet
                                              ];

                Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>(opptyLst);

                logger.log('Opportunity lst received OpptyIDSet  : '+opptyLst);

                if(opptyLst != null && !opptyLst.isEmpty()){

                    for(Opportunity oppty : opptyLst){
                        opportunityToContactMap.put(oppty.Id, oppty.Primary_Contact__c);
                        contactToOpportunityMap.put(oppty.Primary_Contact__c, oppty.Id);
                    }

                    if(opportunityToContactMap != null && !opportunityToContactMap.values().isEmpty()){

                        Map<Id,Contact> contactMap = new Map<Id,Contact>( [  SELECT Id,name,MailingLatitude,MailingLongitude,AccountId
                                                                                    from Contact
                                                                                    where
                                                                                    Id IN: opportunityToContactMap.values() ]);

                        logger.log('Contact Lst Received : '+contactMap);

                        String soql_String = 'SELECT Id,Name,AccountId from Contact where ';
                        Integer counter = 0;
                        Integer mileRadiusInt = Integer.valueOf(mileRadius);

                        for(Contact contactObj : contactMap.values()){
                            Integer mileRadiusValue = 50;
                            Opportunity opptyMapped = opptyMap.get(contactToOpportunityMap.get(contactObj.Id));
                            mileRadiusValue = (opptyMapped.Mile_Radius__c != null) ? Integer.valueOf(opptyMapped.Mile_Radius__c) : 50 ;
                            system.debug('mileRadiusValue ==>'+mileRadiusValue);
                            soql_String += 'DISTANCE(MailingAddress,GEOLOCATION('+contactObj.MailingLatitude+','+contactObj.MailingLongitude+'),\'mi\') < :mileRadiusValue';

                            if(counter != ( contactMap.values().size() - 1 ) ) {
                                soql_String += ' AND ';
                                counter++;
                            }

                            soql_String += ' AND ( Account.Type_of_Specialist_Needed__c = null OR ( Account.Type_of_Specialist_Needed__c != null AND Account.Type_of_Specialist_Needed__c includes (\'' + opptyMapped.SP_Specialist_Type__c + '\')) )';
                            if(opptyMapped.States_Licensed__c != null)
                                soql_String += ' AND ( MailingState != null AND MailingState in: (\'' + opptyMapped.States_Licensed__c + '\')) ';

                        }
                        Id accountGPRecordTypeId = Utility.getsObjectRecordTypeId(Account.SObjectType, 'Dental Host Office (HO) / GP');

                        soql_String += ' AND Account.RecordTypeId = \''+accountGPRecordTypeId+'\'';

                        system.debug('soql_String =>'+soql_String);
                        logger.log('soql_String formed : '+soql_String);

                        List<Contact> contactLst = Database.query(soql_String);

                        system.debug('contactLst =>'+contactLst);
                        logger.log('contactLst Received : '+contactLst);

                        if(contactLst != null && !contactLst.isEmpty()){
                            for( Id opptyId : opportunityIdSet){
                                for(Contact contactObj : contactLst){
                                    matchLst.add(new Future_Match__c( Contact__c = contactObj.Id,  Opportunity__c = opptyId , Account__c = contactObj.AccountId ));
                                }
                            }
                        }

                        logger.log('matchLst To insert : '+matchLst);

                        if(matchLst != null && !matchLst.isEmpty()){
                            insert matchLst;
                        }

                        logger.log('Successfull execution');
                        logger.setStatus('SUCCESS');
                    }
                }

            }

        }catch(Exception ex){
            logger.log('Failed with exception : '+ex.getMessage()+'\n'+ex.getStackTraceString());
            logger.setStatus('FAILURE');
            logger.logException(ex);
        }finally {
            ApexLogger.commitLogs();
        }*/

    }
    
    
    //Ankita A: 9 Nov 2019 Concierge Changes 
    // 6 Jan , Update logic for Payment Term Updates
    public static void isConciergeUpdated(Map<Id, Opportunity> oldMap, List<Opportunity> oppNewList){
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        List<Opportunity> lstOpportunityForPaymentTerms = new List<Opportunity>();
        List<Opportunity> lstOpportunityForDisableEmails = new List<Opportunity>();

        for(Opportunity oppObject : oppNewList){
            //If the Concierge_Needed__c field is changed && it's value is true
            if(oppObject.Concierge_Needed__c != oldMap.get(oppObject.Id).Concierge_Needed__c && oppObject.Concierge_Needed__c){
                   //Add the opportunity object to the list
                   lstOpportunity.add(oppObject);
            }else if(oppObject.Payment_Terms__c != oldMap.get(oppObject.Id).Payment_Terms__c && oppObject.Payment_Terms__c != null ) {
                lstOpportunityForPaymentTerms.add(oppObject);
            }else if( (oppObject.Disable_Auto_Emails__c != oldMap.get(oppObject.Id).Disable_Auto_Emails__c) || (oppObject.Disable_Auto_Emails_Provider__c != oldMap.get(oppObject.Id).Disable_Auto_Emails_Provider__c)  ) {
                lstOpportunityForDisableEmails.add(oppObject);
            }
        }

        if(!lstOpportunity.isEmpty()) {
            //Update the Invoice object with Concierge details
            updateInvoices(lstOpportunity);
        }


        if(!lstOpportunityForPaymentTerms.isEmpty()) {
            //Update the Invoice object with Concierge details
            updateInvoicesForPaymentTerms(lstOpportunityForPaymentTerms);
        }
        
        if (!lstOpportunityForDisableEmails.isEmpty()) {
            updateInvoiceForDisableAutoEmails(lstOpportunityForDisableEmails);
        }
    }
    
    public static void updateInvoices(List<Opportunity> lstOpportunity){
        Set<Id> opportunityIds = new Set<Id>();
        for(Opportunity oppObject : lstOpportunity){
            //If Concierge Needed is true for an Opportunity, add it to the set
            if(oppObject.Concierge_Needed__c){
                opportunityIds.add(oppObject.Id);
            }
        }
        
        //If the set contains opportunity Ids
        if(!opportunityIds.isEmpty()){
            List<Opportunity_Line_Item__c> invoicesToUpdate = new List<Opportunity_Line_Item__c>();
            //Query all the invoice objects associated with these Opportunities
            for(Opportunity_Line_Item__c invoice : [SELECT Id, Concierge_Needed__c
                                                        FROM Opportunity_Line_Item__c 
                                                        WHERE Opportunity__c IN: opportunityIds
                                                        AND Concierge_Needed__c = false AND Status__c = 'Scheduled']){
                //Update the Concierge_Needed__c as true and add it to a list
                invoice.Concierge_Needed__c = true;
                invoicesToUpdate.add(invoice);
            }
            
            update invoicesToUpdate;
        }
        
    }

    public static void updateInvoicesForPaymentTerms(List<Opportunity> lstOpportunity){
        
        
        //If the set contains opportunity Ids
        if(!lstOpportunity.isEmpty()){
            List<Opportunity_Line_Item__c> invoicesToUpdate = new List<Opportunity_Line_Item__c>();
            //Query all the invoice objects associated with these Opportunities
            for(Opportunity_Line_Item__c invoice : [SELECT Id, Concierge_Needed__c,Treatment_Date__c,Opportunity__r.Payment_Terms__c
                                                        FROM Opportunity_Line_Item__c 
                                                        WHERE Opportunity__c IN: lstOpportunity
                                                          AND Status__c = 'Scheduled']){
                if(invoice.Opportunity__r.Payment_Terms__c != null && invoice.Treatment_Date__c != null ) {
                    invoice.Invoice_Due_Date__c = invoice.Treatment_Date__c.addDays(Integer.valueOf(invoice.Opportunity__r.Payment_Terms__c));
                    invoicesToUpdate.add(invoice);
                }
            }
            
            update invoicesToUpdate;
        }
        
    }
    

    public static void updateInvoiceForDisableAutoEmails(List<Opportunity>  lstOpportunityForDisableEmails) {
        //If the set contains opportunity Ids
        if(!lstOpportunityForDisableEmails.isEmpty()){
            List<Opportunity_Line_Item__c> invoicesToUpdate = new List<Opportunity_Line_Item__c>();
            //Query all the invoice objects associated with these Opportunities
            for(Opportunity_Line_Item__c invoice : [SELECT Id, Concierge_Needed__c,Treatment_Date__c,Opportunity__r.Payment_Terms__c,Opportunity__r.Disable_Auto_Emails__c,
                                                        Opportunity__r.Disable_Auto_Emails_Provider__c
                                                        FROM Opportunity_Line_Item__c 
                                                        WHERE Opportunity__c IN: lstOpportunityForDisableEmails
                                                      ]){
                
                    invoice.Disable_Auto_Emails__c = invoice.Opportunity__r.Disable_Auto_Emails__c;
                    invoice.Disable_Auto_Emails_Provider__c = invoice.Opportunity__r.Disable_Auto_Emails_Provider__c;
                    invoicesToUpdate.add(invoice);
                
            }
            
            update invoicesToUpdate;
        } 
    }
    
    //Ankita A: 14 Nov Member Introduction: Citagenix Email changes
    public static void sendBusinessEmails(Map<Id, Opportunity> oldMap, List<Opportunity> oppNewList){
        List<Opportunity> lstOpportunityToEmail = new List<Opportunity>();
        for(Opportunity oppObject : oppNewList){
            System.debug('oppObject --- '+oppObject);
            //If the Invoices created field is changed and it equals to 1 and 
            //Member introduction email is not sent and
            //Primary specialty of Provider is Periodontist, Oral Surgeon, or Advanced GP with Implant Advanced Skill
            if(oppObject.Invoices_Created__c != oldMap.get(oppObject.Id).Invoices_Created__c 
               && oppObject.Invoices_Created__c == 1 && !oppObject.is_Member_Intro_Email_Sent__c && 
              (String.isNotBlank(oppObject.Contact_Specialty_Primary_Value__c) && 
              (oppObject.Contact_Specialty_Primary_Value__c.equalsIgnoreCase('Periodontist') || 
               oppObject.Contact_Specialty_Primary_Value__c.equalsIgnoreCase('Oral Surgeon') ||
               oppObject.Contact_Specialty_Primary_Value__c.equalsIgnoreCase('GP Implant')))){
                  //Add the opportunity object to the list for sending emails
                  lstOpportunityToEmail.add(oppObject);
               }
        }
        System.debug('lstOpportunityToEmail  ----' +lstOpportunityToEmail);

        //Create a map to store the email template developer name along with it's Id
        Map<String,Id> emailTemplateMap = new Map<String,Id>();
        for(EmailTemplate template : [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE 
                                        DeveloperName IN ('SP_Member_Introduction_Citaganix')]){
            emailTemplateMap.put(template.DeveloperName , template.Id);
        }
        

        List<Messaging.SingleEmailMessage> singleEmailMsgLst = new List<Messaging.SingleEmailMessage>();
        for(Opportunity opptObject : [SELECT Id, Primary_Contact__c, GP_Contact__c, GP_Contact__r.Email FROM Opportunity WHERE Id IN: lstOpportunityToEmail]){
            //Create emailMessage contents
            Messaging.SingleEmailMessage emailMessage = Utility.sendEmail(opptObject.Id,
                                                                          emailTemplateMap.get('SP_Member_Introduction_Citaganix'),
                                                                          opptObject.Primary_Contact__c);
            //CC the Practice contact as well if it has email address
            if(opptObject.GP_Contact__c != null && String.isNotBlank(opptObject.GP_Contact__r.Email)){
                emailMessage.setCcAddresses(new List<String>{opptObject.GP_Contact__c}); // 'breeves@citagenix.com'
            }
            
            singleEmailMsgLst.add(emailMessage);
        }

        //If the email message list is not empty, then send email
        if(!singleEmailMsgLst.isEmpty()){
            Messaging.sendEmail(singleEmailMsgLst);
            List<EmailMessage> emailMsg = [SELECT Id FROM EmailMessage];
            System.debug('emailMsg '+emailMsg.size());
            //create activity for opportunities and Update the is_Member_Intro_Email_Sent__c as true
            List<Opportunity> opptsToUpdate = new List<Opportunity>();
            for(Opportunity opptObject : [SELECT Id, Primary_Contact__c, is_Member_Intro_Email_Sent__c FROM Opportunity WHERE 
                                          Id IN: lstOpportunityToEmail]) {
                //Cannot add Contact as related Id here
                Utility.synchActivity(opptObject.Id, opptObject.Id);
                opptObject.is_Member_Intro_Email_Sent__c = true;
                opptsToUpdate.add(opptObject);                              
            }
            update opptsToUpdate;
        }
    }

    public static void populateOppDatetimeFields(Map<Id, Opportunity> oldMap, List<Opportunity> oppNewList){
        List<Opportunity> opptsToUpdated = new List<Opportunity>();
       
        for(Opportunity opptObject : [SELECT Id, StageName, Introduction_Datetime__c, Prep_Completion_Date__c, Specialist_Package__c FROM Opportunity WHERE Id IN: oppNewList]){
            Boolean isUpdated = false;
            //If stagename is updated to Introduced
            if(opptObject.StageName.equalsIgnoreCase('Introduced') && opptObject.StageName != oldMap.get(opptObject.Id).StageName){
                opptObject.Introduction_Datetime__c = System.now();
                isUpdated = true;
            }
            
            //If specialist package sent is true, update the date value
            if(opptObject.Specialist_Package__c && opptObject.Specialist_Package__c != oldMap.get(opptObject.Id).Specialist_Package__c){
                opptObject.Prep_Completion_Date__c = System.today();
                isUpdated = true;
            }
            
            if(isUpdated){
                opptsToUpdated.add(opptObject);
            }
        }
        
        update opptsToUpdated;
    }

    //Ankita A: Send SMS to SP and GP 1 hour after intro sent out
    public static void sendBusinessSMS(Map<Id, Opportunity> oldMap, List<Opportunity> oppNewList){
        ApexLogger.Logger logger = ApexLogger.createLogger('Synergy Opportunity SMS :'+System.now());
        Map<Id, Opportunity> introFollowUpToGP1hr = new Map<Id, Opportunity>();
        Map<Id, Opportunity> introFollowupToSP1hr = new Map<Id, Opportunity>();

        //Capture the opportunities with Send Introduction SMS as true
        for(Opportunity opptObject : [SELECT Id, Send_Introduction_SMS__c,
                                        GP_Contact__c, GP_Contact__r.Name, GP_Contact__r.MobilePhone, 
                                        Primary_Contact__c, Primary_Contact__r.Name, Primary_Contact__r.MobilePhone,
                                        GP_Contact__r.smagicinteract__SMSOptOut__c, Primary_Contact__r.smagicinteract__SMSOptOut__c
                                        FROM Opportunity
                                        WHERE Id IN: oppNewList
                                    ]){
            //If Send Introduction SMS is true and it's value has changed
            if(opptObject.Send_Introduction_SMS__c && opptObject.Send_Introduction_SMS__c != oldMap.get(opptObject.Id).Send_Introduction_SMS__c){

                //If GP contact has not opted out for SMS and MobilePhone is present, add to the list for sending SMS
                if(!opptObject.GP_Contact__r.smagicinteract__SMSOptOut__c && String.isNotBlank(opptObject.GP_Contact__r.MobilePhone)){
                    logger.log('Sending SMS to GP 1 hour after Introduction is sent '+opptObject.GP_Contact__r.Name);
                    introFollowUpToGP1hr.put(opptObject.Id, opptObject);
                }
                //If SP contact has not opted out for SMS and MobilePhone is present, add to the list for sending SMS
                if(!opptObject.Primary_Contact__r.smagicinteract__SMSOptOut__c && String.isNotBlank(opptObject.Primary_Contact__r.MobilePhone)){
                    logger.log('Sending SMS to SP 1 hour after Introduction is sent '+opptObject.Primary_Contact__r.Name);
                    introFollowupToSP1hr.put(opptObject.Id, opptObject);
                }
            }
        }

        //If the introFollowUpToGP1hr or introFollowupToSP1hr map has any elements
        if(introFollowUpToGP1hr.size() > 0 || introFollowupToSP1hr.size() > 0){
            //Query the SMS template
            List<smagicinteract__SMS_Template__c> smsTemplates = [SELECT Id, smagicinteract__Name__c, smagicinteract__Text__c 
                                                                    FROM smagicinteract__SMS_Template__c
                                                                    WHERE smagicinteract__Name__c IN 
                                                                    ('GP Introduction Follow up 1', 'SP Introduction Follow up 1')
                                                                ];
            Map<String, smagicinteract__SMS_Template__c> nameToTemplateMap = new Map<String, smagicinteract__SMS_Template__c>();
            for(smagicinteract__SMS_Template__c template : smsTemplates){
                nameToTemplateMap.put(template.smagicinteract__Name__c, template);
            }
            Boolean isError = false;
            try{
                //Call utility method to send SMS
                SendSMSUtility.sendFollowupSMS(introFollowupToGP1hr, nameToTemplateMap.get('GP Introduction Follow up 1'), false); //isSP = false
                SendSMSUtility.sendFollowupSMS(introFollowupToSP1hr, nameToTemplateMap.get('SP Introduction Follow up 1'), true);//isSP = true

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
    
    
}