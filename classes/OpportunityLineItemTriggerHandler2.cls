/**
 * Created by abidap on 4/26/19.
 */

public with sharing class OpportunityLineItemTriggerHandler2 {
    public static Boolean isLogicExecuted = false;

    public static void sendBusinessEmails( List<Opportunity_Line_Item__c> newOLILst , Map<Id,Opportunity_Line_Item__c> oldOLIMap  ){
        List<Opportunity_Line_Item__c> oliLstToSendEmail = new List<Opportunity_Line_Item__c>();
        List<Opportunity_Line_Item__c> oliLstToSendPRPrelimEmail = new List<Opportunity_Line_Item__c>();
        List<Opportunity_Line_Item__c> oliLstToRequestPREmail = new List<Opportunity_Line_Item__c>();
        //Ankita A: Send an email to SC if Production report is not yet received
        List<Opportunity_Line_Item__c> invoiceLstForSC = new List<Opportunity_Line_Item__c>();

        //Ankita A: 4 Jan 2020: Changes made for sending follow up email to Practice for Production report request
        List<Opportunity_Line_Item__c> invoiceLstForProdReport = new List<Opportunity_Line_Item__c>();
  
        //Ankita A: 9 Jan 2020: Sending cancellation email when status is changed to Cancelled
        List<Opportunity_Line_Item__c> invoiceLstForCancellation = new List<Opportunity_Line_Item__c>();
        List<Opportunity_Line_Item__c> invoiceLstToSendToPractice = new List<Opportunity_Line_Item__c>();

        Set<Id> opptyIdToQuery = new Set<Id>();
        Map<Id,Opportunity> opportunityMap;

        if (!isLogicExecuted) {

            for( Opportunity_Line_Item__c lineItem : newOLILst ){
                if(lineItem.Schedule_Confirmation_Mail_Sent__c == true
                        && lineItem.Schedule_Confirmation_Mail_Sent__c != oldOLIMap.get(lineItem.Id).Schedule_Confirmation_Mail_Sent__c){
                    oliLstToSendEmail.add(lineItem);
                    opptyIdToQuery.add(lineItem.Opportunity__c);
                }else if(lineItem.Schedule_Confirmation_Mail_Sent_Prelim__c == true
                        && lineItem.Schedule_Confirmation_Mail_Sent_Prelim__c != oldOLIMap.get(lineItem.Id).Schedule_Confirmation_Mail_Sent_Prelim__c){
                    oliLstToSendPRPrelimEmail.add(lineItem);
                    opptyIdToQuery.add(lineItem.Opportunity__c);
                }else if( lineItem.Status__c == 'Production Report Requested' && oldOLIMap != null && lineItem.Status__c != oldOLIMap.get(lineItem.Id).Status__c ){
                    oliLstToRequestPREmail.add(lineItem);
                    opptyIdToQuery.add(lineItem.Opportunity__c);
                     //Ankita A: Send an email to SC if Production report is not yet received
                    //If Notify to SC value has changed and it's value is true
                } else if(lineItem.Notify_To_SC__c && lineItem.Notify_To_SC__c != oldOLIMap.get(lineItem.Id).Notify_To_SC__c){
                    //Add the invoice to List for sending email
                    invoiceLstForSC.add(lineItem);

                    //Ankita A: 4 Jan 2020: Changes made for sending follow up email to Practice for Production report request
                    //If Practice is yet not notified for Production report follow up
                } else if(lineItem.Practice_Post_Prod_FU_Sent__c && lineItem.Practice_Post_Prod_FU_Sent__c != oldOLIMap.get(lineItem.Id).Practice_Post_Prod_FU_Sent__c){
                    //Add the invoice to List for sending email
                    invoiceLstForProdReport.add(lineItem);
                    opptyIdToQuery.add(lineItem.Opportunity__c);
                    //Ankita A: 9 Jan 2020: Sending cancellation email when status is changed to Cancelled
                    //If lineitem status has changed and it's status is Cancelled
                } else if(lineItem.Status__c.equalsIgnoreCase('Cancelled') && oldOLIMap != null && lineItem.Status__c != oldOLIMap.get(lineItem.Id).Status__c){
                    //Add the invoice to List for sending email
                    invoiceLstForCancellation.add(lineItem);
                    opptyIdToQuery.add(lineItem.Opportunity__c);
                } else if(lineItem.Status__c.equalsIgnoreCase('Invoice Sent to Practice') && oldOLIMap != null && lineItem.Status__c != oldOLIMap.get(lineItem.Id).Status__c){
                    //Add the invoice to List for sending email
                    invoiceLstToSendToPractice.add(lineitem);
                    opptyIdToQuery.add(lineItem.Opportunity__c);
                }
            }


            List<Messaging.SingleEmailMessage> singleEmailMsgLst = new List<Messaging.SingleEmailMessage>();
            Map<String,Id> emailTemplateMap = new Map<String,Id>();

            for( EmailTemplate template : [ SELECT Id,Name,DeveloperName from EmailTemplate where
                                                    DeveloperName IN ('Specialists_Schedule_COnfirmation','Specialists_Schedule_Confirmation_Prelim','SP_Post_Production_1',
                                                                        'GP_Post_Production_1','SP_Post_Production_2','GP_Post_Production_2','SP_Tx_Date_Cancellation',
                                                                        'Prod_Report_Request_Reminder','Practice_Post_Production_FU') ] ){
                emailTemplateMap.put(template.DeveloperName , template.Id );
            }



            if(!opptyIdToQuery.isEmpty())
                opportunityMap = new Map<Id,Opportunity>( [SELECT Id,Name,Primary_Contact__c, Primary_Contact__r.Email, GP_Contact__c,GP_Contact__r.OM_EMail__c,
                                                                    (SELECT Id From Opportunity_Line_Item__r 
                                                                            where 
                                                                            Status__c NOT IN ('Scheduled', 'Cancelled')) from Opportunity where Id IN: opptyIdToQuery ] );

            if( !oliLstToSendEmail.isEmpty() ){
                 for(Opportunity_Line_Item__c lineItem : oliLstToSendEmail){
                     if(opportunityMap.containsKey( lineItem.Opportunity__c ) && !lineItem.Disable_Auto_Emails__c){
                        Messaging.SingleEmailMessage emailMessage = Utility.sendEmail( lineItem.Id ,  emailTemplateMap.get('Specialists_Schedule_COnfirmation') , opportunityMap.get( lineItem.Opportunity__c ).GP_Contact__c , 'SUPPORT');
                        //Prod Issue where Primary Contact Email is null
                        List<String> ccEmails = new List<String>{'Support@synergyspecialists.com' , 'julia@synergyspecialists.com'};
                        Opportunity opptObject = opportunityMap.get(lineItem.Opportunity__c);
                        //If GP Contact is not null and OM Email is not blank, then add 
                        if(opptObject.GP_Contact__c != null && String.isNotBlank(opptObject.GP_Contact__r.OM_EMail__c)) {
                            ccEmails.add(opptObject.GP_Contact__r.OM_EMail__c);
                        }

                        //If Primary Contact is not null and it's Email is not blank, then add
                        if(opptObject.Primary_Contact__c != null && String.isNotBlank(opptObject.Primary_Contact__r.Email)){
                            ccEmails.add(opptObject.Primary_Contact__r.Email);
                        }
                        emailMessage.setCcAddresses(ccEmails);
                        singleEmailMsgLst.add(emailMessage);
                     }
                 }

                if(!singleEmailMsgLst.isEmpty()){
                    Messaging.sendEmail(singleEmailMsgLst);
                }

                for(Opportunity_Line_Item__c lineItem : oliLstToSendEmail) {
                    Utility.synchActivity(lineItem.Id , lineItem.Opportunity__c );
                }
            }

            if( !oliLstToSendPRPrelimEmail.isEmpty() ){
                 for(Opportunity_Line_Item__c lineItem : oliLstToSendPRPrelimEmail){
                     if(opportunityMap.containsKey( lineItem.Opportunity__c ) && !lineItem.Disable_Auto_Emails__c ){
                         Messaging.SingleEmailMessage emailMessage = Utility.sendEmail( lineItem.Id ,  emailTemplateMap.get('Specialists_Schedule_Confirmation_Prelim') , opportunityMap.get( lineItem.Opportunity__c ).GP_Contact__c ,'SUPPORT' );
                         
                         //Prod Issue where Primary Contact Email is null
                        List<String> ccEmails = new List<String>{'Support@synergyspecialists.com' , 'julia@synergyspecialists.com'};
                        Opportunity opptObject = opportunityMap.get(lineItem.Opportunity__c);
                        //If OM Email is not blank, then add 
                        if(opptObject.GP_Contact__c != null && String.isNotBlank(opptObject.GP_Contact__r.OM_EMail__c)) {
                            ccEmails.add(opptObject.GP_Contact__r.OM_EMail__c);
                        }

                        //If Primary Contact Email is not blank, then add
                        if(opptObject.Primary_Contact__c != null && String.isNotBlank(opptObject.Primary_Contact__r.Email)){
                            ccEmails.add(opptObject.Primary_Contact__r.Email);
                        }
                        emailMessage.setCcAddresses(ccEmails);
                        singleEmailMsgLst.add(emailMessage);
                     }
                 }

                if(!singleEmailMsgLst.isEmpty()){
                    Messaging.sendEmail(singleEmailMsgLst);
                }

                for(Opportunity_Line_Item__c lineItem : oliLstToSendPRPrelimEmail) {
                    Utility.synchActivity(lineItem.Id , lineItem.Opportunity__c );
                }
            }

            if(!oliLstToRequestPREmail.isEmpty()){
                for(Opportunity_Line_Item__c lineItem : oliLstToRequestPREmail){
                    System.debug('Contains =>'+opportunityMap.containsKey( lineItem.Opportunity__c ));
                    if(opportunityMap.containsKey( lineItem.Opportunity__c ) ){
                        System.debug('Treatment Count =>'+opportunityMap.get( lineItem.Opportunity__c ).Opportunity_Line_Item__r);
                        if( opportunityMap.get( lineItem.Opportunity__c ).Opportunity_Line_Item__r != null && opportunityMap.get( lineItem.Opportunity__c ).Opportunity_Line_Item__r.size() <= 1){
                            if(!lineItem.Disable_Auto_Emails_Provider__c) {
                                Messaging.SingleEmailMessage emailMessage = Utility.sendEmail( lineItem.Id ,  emailTemplateMap.get('SP_Post_Production_1') , opportunityMap.get( lineItem.Opportunity__c ).Primary_Contact__c ,'SUPPORT');
                                emailMessage.setCcAddresses( new List<String>{ 'Support@synergyspecialists.com' , 'julia@synergyspecialists.com','docs@synergyspecialists.co' } );
                                emailMessage.setReplyTo('docs@synergyspecialists.co');
                                singleEmailMsgLst.add(emailMessage);
                            }

                            if(!lineItem.Disable_Follow_up__c) {

                                Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();


                                emailMessage = Utility.sendEmail( lineItem.Id ,  emailTemplateMap.get('GP_Post_Production_1') , opportunityMap.get( lineItem.Opportunity__c ).GP_Contact__c ,'SUPPORT');
                                if(String.isBlank(opportunityMap.get( lineItem.Opportunity__c ).GP_Contact__r.OM_EMail__c)) {
                                    emailMessage.setCcAddresses( new List<String>{ 'Support@synergyspecialists.com' , 'julia@synergyspecialists.com' , 'docs@synergyspecialists.co'} ); 
                                } else {
                                    emailMessage.setCcAddresses( new List<String>{ 'Support@synergyspecialists.com' , 'julia@synergyspecialists.com' , 'docs@synergyspecialists.co',opportunityMap.get( lineItem.Opportunity__c ).GP_Contact__r.OM_EMail__c} ); 
                                }
                                
                                emailMessage.setReplyTo('docs@synergyspecialists.co');
                                singleEmailMsgLst.add(emailMessage);

                            }

                        }else if(opportunityMap.get( lineItem.Opportunity__c ).Opportunity_Line_Item__r != null && opportunityMap.get( lineItem.Opportunity__c ).Opportunity_Line_Item__r.size() > 1 ){

                            
                            if(!lineItem.Disable_Auto_Emails_Provider__c) {
                                Messaging.SingleEmailMessage emailMessage = Utility.sendEmail( lineItem.Id ,  emailTemplateMap.get('SP_Post_Production_2') , opportunityMap.get( lineItem.Opportunity__c ).Primary_Contact__c,'SUPPORT' );
                                emailMessage.setCcAddresses( new List<String>{ 'Support@synergyspecialists.com' , 'julia@synergyspecialists.com', 'docs@synergyspecialists.co' } ); 
                                emailMessage.setReplyTo('docs@synergyspecialists.co');
                                singleEmailMsgLst.add(emailMessage);
                            }
                            if(!lineItem.Disable_Follow_up__c) {
                                Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();

                                emailMessage = Utility.sendEmail( lineItem.Id ,  emailTemplateMap.get('GP_Post_Production_2') , opportunityMap.get( lineItem.Opportunity__c ).GP_Contact__c ,'SUPPORT');
                                if(String.isBlank(opportunityMap.get( lineItem.Opportunity__c ).GP_Contact__r.OM_EMail__c)) {
                                    emailMessage.setCcAddresses( new List<String>{ 'Support@synergyspecialists.com' , 'julia@synergyspecialists.com' , 'docs@synergyspecialists.co'} ); 
                                } else {
                                    emailMessage.setCcAddresses( new List<String>{ 'Support@synergyspecialists.com' , 'julia@synergyspecialists.com' , 'docs@synergyspecialists.co',opportunityMap.get( lineItem.Opportunity__c ).GP_Contact__r.OM_EMail__c} ); 
                                }
                                emailMessage.setReplyTo('docs@synergyspecialists.co');
                                singleEmailMsgLst.add(emailMessage);
                            }
                            
                        }

                    }
                }

                if(!singleEmailMsgLst.isEmpty()){
                    Messaging.sendEmail(singleEmailMsgLst);
                }

                for(Opportunity_Line_Item__c lineItem : oliLstToRequestPREmail) {
                    Utility.synchActivity(lineItem.Id , lineItem.Opportunity__c );
                }
            }

            //Ankita A: Send an email to SC if Production report is not yet received
            //If the invoice list is not empty
            if(invoiceLstForSC.size() > 0){
                singleEmailMsgLst = new List<Messaging.SingleEmailMessage>();
                //Get the email Id of user support@ss.co
                User userObject = [SELECT Id, Name, Email FROM User WHERE Username LIKE 'support@synergyspecialists.co%' LIMIT 1];
                if(userObject != null){
                    for(Opportunity_Line_Item__c lineItem : invoiceLstForSC){
                        if(opportunityMap.containsKey( lineItem.Opportunity__c ) && !lineItem.Disable_Auto_Emails_Provider__c){
                            Messaging.SingleEmailMessage emailMessage = Utility.sendEmail(lineItem.Id, 
                                                                                        emailTemplateMap.get('Prod_Report_Request_Reminder'), 
                                                                                        opportunityMap.get( lineItem.Opportunity__c ).Primary_Contact__c,
                                                                                        false,'SUPPORT');

                            //Set the setSaveAsActivity as false as we are sending email to User
                            emailMessage.setSaveAsActivity(false);
                            emailMessage.setToAddresses(new List<String>{userObject.Email});
                            singleEmailMsgLst.add(emailMessage);
                        }
                    }
                    if(!singleEmailMsgLst.isEmpty()){
                        Messaging.sendEmail(singleEmailMsgLst);
                    }
                }
            }

             //Ankita A: 4 Jan 2020: Changes made for sending follow up email to Practice for Production report request
            if(invoiceLstForProdReport.size() > 0){
                singleEmailMsgLst = new List<Messaging.SingleEmailMessage>();
                for(Opportunity_Line_Item__c lineItem : invoiceLstForProdReport){
                    //Follow up checkbox is enabled
                    if(opportunityMap.containsKey(lineItem.Opportunity__c) && !lineItem.Disable_Auto_Emails__c){
                        Messaging.SingleEmailMessage emailMessage = Utility.sendEmail(lineItem.Id ,  
                                                                                        emailTemplateMap.get('Practice_Post_Production_FU'), 
                                                                                        opportunityMap.get(lineItem.Opportunity__c).GP_Contact__c ,'SUPPORT');
                        emailMessage.setCcAddresses(new List<String>{'Support@synergyspecialists.com'} );
                        //SetToAddress as Practice OM Email
                        //Get the Provider Practice OM email and split to get Practice OM Email
                        List<String> omEmailLst = lineItem.Provider_Practice_OM_Email__c.split('; ');
                        if(omEmailLst.size() > 1 && String.isNotBlank(omEmailLst[0])){
                            emailMessage.setToAddresses(new List<String>{omEmailLst[0]});
                        }
                        singleEmailMsgLst.add(emailMessage);
                    }
                }
                
                if(!singleEmailMsgLst.isEmpty()){
                    Messaging.sendEmail(singleEmailMsgLst);
                }
                
                //Done for creating activity
                for(Opportunity_Line_Item__c lineItem : oliLstToSendEmail) {
                    Utility.synchActivity(lineItem.Id , lineItem.Opportunity__c );
                }
            }
            
            //Ankita A: 9 Jan 2020: Sending cancellation email when status is changed to Cancelled
            if(invoiceLstForCancellation.size() > 0){
                singleEmailMsgLst = new List<Messaging.SingleEmailMessage>();
                for(Opportunity_Line_Item__c lineItem : invoiceLstForCancellation){
                    if(opportunityMap.containsKey(lineItem.Opportunity__c) && !lineItem.Disable_Auto_Emails_Provider__c){
                        Messaging.SingleEmailMessage emailMessage = Utility.sendEmail(lineItem.Id ,  
                                                                                        emailTemplateMap.get('SP_Tx_Date_Cancellation'), 
                                                                                        opportunityMap.get(lineItem.Opportunity__c).Primary_Contact__c);
                        //SetToAddress as Practice OM Email and Practice Email
                        List<String> toAddress = new List<String>();
                        toAddress.add(opportunityMap.get(lineItem.Opportunity__c).GP_Contact__c);
                        
                        //Get the Provider Practice OM email and split to get Practice OM Email
                        List<String> omEmailLst = lineItem.Provider_Practice_OM_Email__c.split('; ');
                        if(omEmailLst.size() > 1 && String.isNotBlank(omEmailLst[0])){
                            toAddress.add(omEmailLst[0]);
                        }
                        emailMessage.setToAddresses(toAddress);
                        emailMessage.setCcAddresses(new List<String>{'Support@synergyspecialists.com', 'nina@synergyspecialists.com'});
                        singleEmailMsgLst.add(emailMessage);
                    }
                }
                
                if(!singleEmailMsgLst.isEmpty()){
                    Messaging.sendEmail(singleEmailMsgLst);
                }
                
                //Done for creating activity
                for(Opportunity_Line_Item__c lineItem : oliLstToSendEmail) {
                    Utility.synchActivity(lineItem.Id , lineItem.Opportunity__c );
                }
            }

            if (!invoiceLstToSendToPractice.isEmpty()) {
                singleEmailMsgLst = new List<Messaging.SingleEmailMessage>();
                for(Opportunity_Line_Item__c lineItem : invoiceLstToSendToPractice){
                    if(opportunityMap.containsKey(lineItem.Opportunity__c) && !lineItem.Disable_Auto_Emails__c){
                        Opportunity opptObject = opportunityMap.get(lineItem.Opportunity__c);
                        if(String.isNotBlank(opptObject.GP_Contact__r.Email)) {
                                Messaging.SingleEmailMessage emailMessage = Utility.sendEmail(lineItem.Id ,  
                                                                        emailTemplateMap.get('Send_Invoice_For_Payment_CL'), 
                                                                        opptObject.GP_Contact__c,
                                                                        !opptObject.GP_Contact__r.HasOptedOutOfEmail,'SUPPORT');
                                
                            
                            //SetToAddress as GP Email and Practice OM Email
                            List<String> toAddress = new List<String>();

          
                            //If GP Contact is not null and OM Email is not blank, then add 
                            if(opptObject.GP_Contact__c != null && String.isNotBlank(opptObject.GP_Contact__r.OM_EMail__c)) {
                                toAddress.add(opptObject.GP_Contact__r.OM_EMail__c);
                                emailMessage.setToAddresses(toAddress);
                            }
                            
                            //Masking
                            emailMessage.setCcAddresses(new List<String>{'Support@synergyspecialists.com'});
                            singleEmailMsgLst.add(emailMessage);
                        }
                    }
                }

                 Messaging.sendEmail(singleEmailMsgLst);
                    
                //Done for creating activity
                for(Opportunity_Line_Item__c lineItem : oliLstToSendEmail) {
                    Utility.synchActivity(lineItem.Id , lineItem.Opportunity__c );
                }
            }
            
            isLogicExecuted = true;
        }
        
    }


    public static void prepopulateInvoiceName( List<Opportunity_Line_Item__c> newOLILst ){
        if( newOLILst != null && !newOLILst.isEmpty() ){
            Set<Id> opptyIdSet = new Set<Id>();

            for( Opportunity_Line_Item__c lineItemVar : newOLILst ){
                opptyIdSet.add(lineItemVar.Opportunity__c);
            }

            if(!opptyIdSet.isEmpty()){
                Map<Id,Opportunity> opptyMap = new Map<Id,Opportunity>([SELECT Id,Name,Primary_Contact__r.Name,Disable_Auto_Emails__c,Disable_Auto_Emails_Provider__c,
                        GP_Contact__r.Account.Name
                from Opportunity
                where Id IN: opptyIdSet ]);

                for( Opportunity_Line_Item__c lineItemVar : newOLILst ){
                    if(opptyMap.containsKey(lineItemVar.Opportunity__c) && lineItemVar.Treatment_Date__c != null){
                        String dateFormatString ='dd-MMM-yyyy';
                        Date d = lineItemVar.Treatment_Date__c;
                        Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
                        String dateString = dt.format(dateFormatString);
                        system.debug(dateString);
                        String oliTxDate    = dateString;
                        String providerName = opptyMap.get(lineItemVar.Opportunity__c).Primary_Contact__r.Name;
                        String practiceName = opptyMap.get(lineItemVar.Opportunity__c).GP_Contact__r.Account.Name;

                        String opptyNameStr = '';
                        opptyNameStr        += (!String.isBlank(oliTxDate)) ? oliTxDate : '';
                        opptyNameStr        += (!String.isBlank(providerName)) ? (',Dr.'+providerName) : '';
                        opptyNameStr        += (!String.isBlank(practiceName)) ? ('-'+practiceName) : '';

                        if(!String.isBlank(opptyNameStr)){
                            lineItemVar.Name = (!String.isBlank(opptyNameStr) && opptyNameStr.length() > 78 ) ? opptyNameStr.substring(0,78) : opptyNameStr ;
                        }

                        lineItemVar.Disable_Auto_Emails__c = opptyMap.get(lineItemVar.Opportunity__c).Disable_Auto_Emails__c;
                        lineItemVar.Disable_Auto_Emails_Provider__c = opptyMap.get(lineItemVar.Opportunity__c).Disable_Auto_Emails_Provider__c;
                    }
                }

            }
        }
    }

    public static void calculateInvoiceAmount( List<Opportunity_Line_Item__c> newOLILst ){

        for( Opportunity_Line_Item__c lineItemVar : newOLILst ){
           lineItemVar.Total_Cost_Owed_By_Practice_Calc__c = lineItemVar.Bone_Graft_Cost_Practice_Owes__c +
                                                             lineItemVar.HA_Cost_Owed_By_Practice__c +
                                                             lineItemVar.Implant_Cost_Owed_By_Practice__c +
                                                             lineItemVar.Membrane_Cost_Owed_By_Practice__c +
                                                             lineItemVar.Assistant_Cost_Owed_By_Practice__c ;

            lineItemVar.Total_Cost_Practice_Owes_Calc__c   = lineItemVar.Bone_Graft_Practice_Owes__c +
                                                             lineItemVar.HA_Cost_Practice_Owes__c +
                                                             lineItemVar.Implant_Cost_Practice_Owes__c +
                                                             lineItemVar.Membrane_Cost_Practice_Owes__c +
                                                             lineItemVar.Assistant_Cost_Practice_Owes__c +
                                                             lineItemVar.Other_Cost__c;
        }

    }

    //Ankita A: 9 Nov 2019 Concierge Changes
    public static void createConciergeDetail(List<Opportunity_Line_Item__c> invoiceLst){
        //List of Conceirge Details record for insertion
        List<Concierge_Details__c> conciergeLst = new List<Concierge_Details__c>();
        
        //Create a Mapping of Invoice Object and Conceirge record
        Map<Id, Concierge_Details__c> invoiceConceirgeMapping = new Map<Id, Concierge_Details__c>();
        //Query Invoice object whose status is Scheduled and 
        //Check if Opportunity's Concierge Needed is true because if a new invoice is created, we need to populate concierge for it as well 
        //Ankita A: 2 Dec 2019: Concierge Changes
        for(Opportunity_Line_Item__c invoiceObj : [SELECT Id, Concierge_Details__c, Treatment_Date__c, Opportunity__c, Opportunity__r.Driver_Name__c FROM Opportunity_Line_Item__c WHERE Status__c = 'Scheduled' AND Opportunity__r.Concierge_Needed__c = true AND ID IN: invoiceLst]){
            //If Conceirge record doesn't exist
            if(invoiceObj.Concierge_Details__c == null){
                //Create a Conceirge record and pre-populate values
                Concierge_Details__c conciergeObject = new Concierge_Details__c(
                                    Drop_Off_Time__c = Datetime.newInstance(invoiceObj.Treatment_Date__c, Time.newInstance(8, 0, 0, 0)),
                                    Driver_Name__c = invoiceObj.Opportunity__r.Driver_Name__c);
                conciergeLst.add(conciergeObject);
                invoiceConceirgeMapping.put(invoiceObj.Id, conciergeObject);
            }
                                                       
        }
        insert invoiceConceirgeMapping.values();
        
        //Update Concierge_Details__c on Invoice object
        List<Opportunity_Line_Item__c> invoicesToUpdate = new List<Opportunity_Line_Item__c>();
        for(Opportunity_Line_Item__c invoice : [SELECT Id, Concierge_Details__c, Concierge_Needed__c FROM Opportunity_Line_Item__c WHERE Id IN: invoiceConceirgeMapping.keySet()]){
            invoice.Concierge_Details__c = invoiceConceirgeMapping.get(invoice.Id).Id;
            invoice.Concierge_Needed__c = true;
            invoicesToUpdate.add(invoice);                                      
        }
        update invoicesToUpdate;
    }

    //Ankita A: Send an email and slack if Production report is not yet received
    public static void postToSlack(List<Opportunity_Line_Item__c> newInvoiceLst, Map<Id,Opportunity_Line_Item__c> oldInvoiceLst){
        String slackUrl = System.Label.Slack_API;
        String method = 'POST';
        List<Opportunity_Line_Item__c> invoiceLstToSendMsg = new List<Opportunity_Line_Item__c>();
        //If the checkbox value Notify_to_SC is updated and it's value is true
        for(Opportunity_Line_Item__c invoice : newInvoiceLst){
            if(invoice.Notify_to_SC__c != oldInvoiceLst.get(invoice.Id).Notify_to_SC__c && invoice.Notify_to_SC__c){
                invoiceLstToSendMsg.add(invoice);
            }
        }

        List<String> msgLst = new List<String>();
        for(Opportunity_Line_Item__c invoice : invoiceLstToSendMsg){
            String slackMsg = invoice.Name + ' Production report request not yet received, 5 days to Tx Day.' 
                            + '\n' + invoice.Invoice_PDF_URL__c 
                            + '\n' + '@Julia Akhmerova  @Faye';
            Map<String,Object> msg = new Map<String,Object>();
            msg.put('text', slackMsg);
            msg.put('mrkdwn', true);
            msgLst.add(JSON.serialize(msg));
        }
        if(msgLst.size() > 0){
            System.enqueueJob(new SlackCalloutProcessBuilder.MultipleSlackCall(slackUrl, method, msgLst));
        }
        
    } 
}