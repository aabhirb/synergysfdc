/**
 * Created by abidap on 4/19/19.
 */

public inherited sharing class ProposedDateTriggerHandler {

    public static void synchOpportunityChecklist( List<Proposed_Date__c> newdateLst , Map<Id,Proposed_Date__c> oldDateMap ) {

        List<Proposed_Date__c> proposedDateLst = new List<Proposed_Date__c>();
        List<Proposed_Date__c> proposedDateLstForOLI = new List<Proposed_Date__c>();
        Map<Id, Opportunity> opptyMapToUpdate = new Map<Id, Opportunity>();
        Map<Id, Id> proposedDateToOpptyMap = new Map<Id, Id>();
        Map<Id, Opportunity> opportunityMap ;
        List<Proposed_Date__c> proposedDateToRemindLst = new List<Proposed_Date__c>();
        List<Proposed_Date__c> proposedDateToGPLst = new List<Proposed_Date__c>();
        List<Proposed_Date__c> proposedDateToSPLst = new List<Proposed_Date__c>();
        List<Proposed_Date__c> proposedDateToConfirmLst = new List<Proposed_Date__c>();
        List<Proposed_Date__c> txProposedDateToGPLst = new List<Proposed_Date__c>();
        List<Proposed_Date__c> txProposedDateToSPLst = new List<Proposed_Date__c>();
        List<Proposed_Date__c> txProposedDateToConfirmLst = new List<Proposed_Date__c>();

        for (Proposed_Date__c proposedDateVar : newdateLst) {

            if ('Approved'.equalsIgnoreCase(proposedDateVar.Status__c)
                    && ('Meeting'.equalsIgnoreCase(proposedDateVar.Type__c) || 'Treatment'.equalsIgnoreCase(proposedDateVar.Type__c))
                    && ( oldDateMap == null || proposedDateVar.Status__c != oldDateMap.get(proposedDateVar.Id).Status__c) ) {

                proposedDateLst.add(proposedDateVar);
                proposedDateToOpptyMap.put(proposedDateVar.Id, proposedDateVar.Related_Opportunity__c);
                
                if('Treatment'.equalsIgnoreCase(proposedDateVar.Type__c)
                    && proposedDateVar.Send_Tx_Date_Confirmation__c
                    &&( oldDateMap == null ||  proposedDateVar.Send_Tx_Date_Confirmation__c != oldDateMap.get(proposedDateVar.Id).Send_Tx_Date_Confirmation__c ) ){
                        txProposedDateToConfirmLst.add(proposedDateVar);
                }
                
                if('Meeting'.equalsIgnoreCase(proposedDateVar.Type__c)
                    && proposedDateVar.Send_Meeting_Date_Confirmation__c
                    && ( oldDateMap == null || proposedDateVar.Send_Meeting_Date_Confirmation__c != oldDateMap.get(proposedDateVar.Id).Send_Meeting_Date_Confirmation__c ) ){
                    proposedDateToConfirmLst.add(proposedDateVar);
                }
            } else if ('Request Meeting Outcome'.equalsIgnoreCase(proposedDateVar.Status__c) && 'Meeting'.equalsIgnoreCase(proposedDateVar.Type__c)
                    && ( oldDateMap == null ||  proposedDateVar.Status__c != oldDateMap.get(proposedDateVar.Id).Status__c) ) {
                proposedDateToRemindLst.add(proposedDateVar); //ProposedDateTrigger Triggers email after 1 day from the Meeting Date asking out come
                proposedDateToOpptyMap.put(proposedDateVar.Id, proposedDateVar.Related_Opportunity__c);
                proposedDateLst.add(proposedDateVar);
            } else if ('Meeting'.equalsIgnoreCase(proposedDateVar.Type__c)
                    && proposedDateVar.Send_Meeting_Date_to_SP__c
                    && ( oldDateMap == null || proposedDateVar.Send_Meeting_Date_to_SP__c != oldDateMap.get(proposedDateVar.Id).Send_Meeting_Date_to_SP__c) ) {
                //'Proposed By GP'.equalsIgnoreCase( proposedDateVar.Status__c) &&
                proposedDateToSPLst.add(proposedDateVar);
            } else if ('Meeting'.equalsIgnoreCase(proposedDateVar.Type__c)
                    && proposedDateVar.Send_Meeting_Date_to_GP__c
                    && ( oldDateMap == null || proposedDateVar.Send_Meeting_Date_to_GP__c != oldDateMap.get(proposedDateVar.Id).Send_Meeting_Date_to_GP__c) ) {
                //'Proposed By SP'.equalsIgnoreCase( proposedDateVar.Status__c) &&
                proposedDateToGPLst.add(proposedDateVar);
            }else if('Meeting'.equalsIgnoreCase(proposedDateVar.Type__c)
                    && proposedDateVar.Send_Meeting_Date_Confirmation__c
                    && ( oldDateMap == null || proposedDateVar.Send_Meeting_Date_Confirmation__c != oldDateMap.get(proposedDateVar.Id).Send_Meeting_Date_Confirmation__c ) ){
                proposedDateToConfirmLst.add(proposedDateVar);
            }else if ('Treatment'.equalsIgnoreCase(proposedDateVar.Type__c)
                    && proposedDateVar.Send_Tx_Date_to_GP__c
                    && ( oldDateMap == null ||  proposedDateVar.Send_Tx_Date_to_GP__c != oldDateMap.get(proposedDateVar.Id).Send_Tx_Date_to_GP__c) ) {
                //'Proposed By GP'.equalsIgnoreCase( proposedDateVar.Status__c) &&
                txProposedDateToGPLst.add(proposedDateVar);
            } else if ('Treatment'.equalsIgnoreCase(proposedDateVar.Type__c)
                    && proposedDateVar.Send_Tx_Date_to_SP__c
                    && ( oldDateMap == null ||  proposedDateVar.Send_Tx_Date_to_SP__c != oldDateMap.get(proposedDateVar.Id).Send_Tx_Date_to_SP__c) ) {
                //'Proposed By SP'.equalsIgnoreCase( proposedDateVar.Status__c) &&
                txProposedDateToSPLst.add(proposedDateVar);
            }else if('Treatment'.equalsIgnoreCase(proposedDateVar.Type__c)
                    && proposedDateVar.Send_Tx_Date_Confirmation__c
                    &&( oldDateMap == null ||  proposedDateVar.Send_Tx_Date_Confirmation__c != oldDateMap.get(proposedDateVar.Id).Send_Tx_Date_Confirmation__c ) ){
                txProposedDateToConfirmLst.add(proposedDateVar);
            }

        }

        system.debug('proposedDateToSPLst =>'+proposedDateToSPLst);
        system.debug('proposedDateToGPLst =>'+proposedDateToGPLst);
        system.debug('proposedDateToConfirmLst =>'+proposedDateToConfirmLst);

        if (!proposedDateToOpptyMap.keySet().isEmpty()) {

            opportunityMap = new Map<Id, Opportunity> ([SELECT Id,Name,StageName,Payment_Terms__c,Compensation__c from Opportunity where Id IN:proposedDateToOpptyMap.values()]);
            Set<String> opptyStageToIgnoreSet = new Set<String> { 'Closed Won','Tx Day Schedule','Treatment Scheduled','Closed Lost','Prep Started' };
 
            for (Proposed_Date__c dateVar : proposedDateLst) {
                if (proposedDateToOpptyMap.containsKey(dateVar.Id)) {
                    if (opportunityMap.containsKey(proposedDateToOpptyMap.get(dateVar.Id))) {
                        Opportunity opptyVar = opportunityMap.get(proposedDateToOpptyMap.get(dateVar.Id));
                        
                            if ('Meeting'.equalsIgnoreCase(dateVar.Type__c)) {
                                if(!opptyStageToIgnoreSet.contains(opptyVar.StageName)) {
                                    if ('Approved'.equalsIgnoreCase(dateVar.Status__c)) {
                                            opptyVar.Meeting_Date_Set__c = true;
                                            opptyVar.Meeting_Date__c = dateVar.Start_Time__c;
                                            opptyVar.StageName = 'Meeting Scheduled';
                                    } else if ('Request Meeting Outcome'.equalsIgnoreCase(dateVar.Status__c)) {
                                            opptyVar.StageName = 'Meeting Completed';
                                    }
                                    opptyMapToUpdate.put(opptyVar.Id, opptyVar);
                                }

                            } else if ('Treatment'.equalsIgnoreCase(dateVar.Type__c)) {
                                if(!opptyStageToIgnoreSet.contains(opptyVar.StageName)) {
                                    opptyVar.Tx_Date_Scheduled__c = true;
                                    opptyMapToUpdate.put(opptyVar.Id, opptyVar);
                                }
                                
                                proposedDateLstForOLI.add(dateVar);
                            }
                    }
                }
            }

        }

        List<Messaging.SingleEmailMessage> emailLst = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> etLst = [
                SELECT id,DeveloperName
                FROM EmailTemplate
                WHERE developerName
                        IN ('GP_Send_Meeting_Outcome_and_Tx_Dates_CL', 'SP_Send_Meeting_Outcome_and_Tx_Dates_CL','Meeting_Date_Confirmed_by_GP_CL',
                                'Meeting_Date_Proposed_by_GP_CL', 'Meeting_Date_Proposed_by_SP_CL',
                                'GP_Meeting_Date_Confirmation_CL', 'Meeting_Date_Confirmed_by_SP_CL',
                                'SP_Tx_Date_Confirm_CL','GP_Tx_Date_COnfirmation_CL','SP_Tx_Date_Proposed_CL','GP_Tx_Date_Proposed_CL')
        ];

        Map<Id, Proposed_Date__c> proposedDateMap = new Map<Id, Proposed_Date__c>([SELECT Id, GP_Contact__c, GP_Contact__r.OM_Email__c, GP_Contact__r.Practice_Email__c, SP_Contact__c FROM Proposed_Date__c WHERE Id IN: newdateLst]);
        
        if (!proposedDateToRemindLst.isEmpty()) {
            for (Proposed_Date__c dateVar : proposedDateToRemindLst) {
                Id sendGPEMailTemplateId, sendSPEMailTemplateId ;
                for (EmailTemplate template : etLst) {
                    if (template.DeveloperName == 'GP_Send_Meeting_Outcome_and_Tx_Dates_CL') {
                        sendGPEMailTemplateId = template.id;
                        Messaging.SingleEmailMessage emailToSend = Utility.sendEmail(dateVar.Id, template.Id, dateVar.GP_Contact__c);
                        List<String> ccEmails = System.Label.Email_Cust_CC_Address.split(',');
                        //Ankita A: Set cc addresses
                        if(proposedDateMap.containsKey(dateVar.Id) && proposedDateMap.get(dateVar.Id).GP_Contact__c != null
                            && String.isNotBlank(proposedDateMap.get(dateVar.Id).GP_Contact__r.OM_Email__c)){
                                //Add the OM Email to cc List
                                ccEmails.add(proposedDateMap.get(dateVar.Id).GP_Contact__r.OM_Email__c);
                        }

                        if(proposedDateMap.containsKey(dateVar.Id) && proposedDateMap.get(dateVar.Id).GP_Contact__c != null
                            && String.isNotBlank(proposedDateMap.get(dateVar.Id).GP_Contact__r.Practice_Email__c)){
                                //Add the Other email to cc List
                                ccEmails.add(proposedDateMap.get(dateVar.Id).GP_Contact__r.Practice_Email__c);
                        }
                        emailToSend.setCcAddresses(ccEmails);
                        emailLst.add(emailToSend);
                    } else if (template.DeveloperName == 'SP_Send_Meeting_Outcome_and_Tx_Dates_CL') {
                        sendSPEMailTemplateId = template.id;
                        Messaging.SingleEmailMessage emailToSend = Utility.sendEmail(dateVar.Id, template.Id, dateVar.SP_Contact__c);
                        emailToSend.setCcAddresses(System.Label.Email_Cust_CC_Address.split(','));
                        emailLst.add(emailToSend);
                    }
                }
            }
        }

        if (!proposedDateToGPLst.isEmpty()) {
            for (Proposed_Date__c dateVar : proposedDateToGPLst) {

                for (EmailTemplate template : etLst) {
                    if (template.DeveloperName == 'Meeting_Date_Proposed_by_SP_CL') {
                        Messaging.SingleEmailMessage emailToSend = Utility.sendEmail(dateVar.Id, template.Id, dateVar.GP_Contact__c);
                        List<String> ccEmails = System.Label.Email_Cust_CC_Address.split(',');
                        //Ankita A: Set cc addresses
                        if(proposedDateMap.containsKey(dateVar.Id) && proposedDateMap.get(dateVar.Id).GP_Contact__c != null
                            && String.isNotBlank(proposedDateMap.get(dateVar.Id).GP_Contact__r.OM_Email__c)){
                                //Add the OM Email to cc List
                                ccEmails.add(proposedDateMap.get(dateVar.Id).GP_Contact__r.OM_Email__c);
                        }

                        if(proposedDateMap.containsKey(dateVar.Id) && proposedDateMap.get(dateVar.Id).GP_Contact__c != null
                            && String.isNotBlank(proposedDateMap.get(dateVar.Id).GP_Contact__r.Practice_Email__c)){
                                //Add the Other email to cc List
                                ccEmails.add(proposedDateMap.get(dateVar.Id).GP_Contact__r.Practice_Email__c);
                        }
                        emailToSend.setCcAddresses(ccEmails);
                        emailLst.add(emailToSend);
                    }
                }
            }
        }


        if (!proposedDateToSPLst.isEmpty()) {
            for( Proposed_Date__c dateVar : proposedDateToSPLst ){

                for(EmailTemplate template : etLst){
                    if( template.DeveloperName == 'Meeting_Date_Proposed_by_GP_CL' ){
                        Messaging.SingleEmailMessage emailToSend = Utility.sendEmail( dateVar.Id  , template.Id , dateVar.SP_Contact__c   );
                        emailToSend.setCcAddresses(System.Label.Email_Cust_CC_Address.split(','));
                        emailLst.add( emailToSend );
                    }
                }
            }
        }

        if (!txProposedDateToGPLst.isEmpty()) {
            for( Proposed_Date__c dateVar : txProposedDateToGPLst ){

                for(EmailTemplate template : etLst){
                    if( template.DeveloperName == 'GP_Tx_Date_Proposed_CL' ){
                        Messaging.SingleEmailMessage emailToSend = Utility.sendEmail( dateVar.Id  , template.Id , dateVar.GP_Contact__c   );
                        List<String> ccEmails = System.Label.Email_Cust_CC_Address.split(',');
                        //Ankita A: Set cc addresses
                        if(proposedDateMap.containsKey(dateVar.Id) && proposedDateMap.get(dateVar.Id).GP_Contact__c != null
                            && String.isNotBlank(proposedDateMap.get(dateVar.Id).GP_Contact__r.OM_Email__c)){
                                //Add the OM Email to cc List
                                ccEmails.add(proposedDateMap.get(dateVar.Id).GP_Contact__r.OM_Email__c);
                        }

                        if(proposedDateMap.containsKey(dateVar.Id) && proposedDateMap.get(dateVar.Id).GP_Contact__c != null
                            && String.isNotBlank(proposedDateMap.get(dateVar.Id).GP_Contact__r.Practice_Email__c)){
                                //Add the Other email to cc List
                                ccEmails.add(proposedDateMap.get(dateVar.Id).GP_Contact__r.Practice_Email__c);
                        }
                        emailToSend.setCcAddresses(ccEmails);
                        emailLst.add( emailToSend );
                    }
                }
            }
        }

        if (!txProposedDateToSPLst.isEmpty()) {
            for( Proposed_Date__c dateVar : txProposedDateToSPLst ){

                for(EmailTemplate template : etLst){
                    if( template.DeveloperName == 'SP_Tx_Date_Proposed_CL' ){
                        Messaging.SingleEmailMessage emailToSend = Utility.sendEmail( dateVar.Id  , template.Id , dateVar.SP_Contact__c   );
                        emailToSend.setCcAddresses(System.Label.Email_Cust_CC_Address.split(','));
                        emailLst.add( emailToSend );
                    }
                }
            }
        }


        if (!proposedDateToConfirmLst.isEmpty()) {
            for( Proposed_Date__c dateVar : proposedDateToConfirmLst ){

                for(EmailTemplate template : etLst){
                    if( template.DeveloperName == 'Meeting_Date_Confirmed_by_GP_CL' ){
                        Messaging.SingleEmailMessage emailToSend = Utility.sendEmail( dateVar.Id  , template.Id , dateVar.SP_Contact__c   );
                        emailToSend.setCcAddresses(System.Label.Email_Cust_CC_Address.split(','));
                        emailLst.add( emailToSend );
                    }

                    if( template.DeveloperName == 'Meeting_Date_Confirmed_by_SP_CL' ){
                        Messaging.SingleEmailMessage emailToSend = Utility.sendEmail( dateVar.Id  , template.Id , dateVar.GP_Contact__c   );
                        List<String> ccEmails = System.Label.Email_Cust_CC_Address.split(',');
                        //Ankita A: Set cc addresses
                        if(proposedDateMap.containsKey(dateVar.Id) && proposedDateMap.get(dateVar.Id).GP_Contact__c != null
                            && String.isNotBlank(proposedDateMap.get(dateVar.Id).GP_Contact__r.OM_Email__c)){
                                //Add the OM Email to cc List
                                ccEmails.add(proposedDateMap.get(dateVar.Id).GP_Contact__r.OM_Email__c);
                        }

                        if(proposedDateMap.containsKey(dateVar.Id) && proposedDateMap.get(dateVar.Id).GP_Contact__c != null
                            && String.isNotBlank(proposedDateMap.get(dateVar.Id).GP_Contact__r.Practice_Email__c)){
                                //Add the Other email to cc List
                                ccEmails.add(proposedDateMap.get(dateVar.Id).GP_Contact__r.Practice_Email__c);
                        }
                        emailToSend.setCcAddresses(ccEmails);
                        emailLst.add( emailToSend );
                    }
                }
            }
        }

        if (!txProposedDateToConfirmLst.isEmpty()) {
            for( Proposed_Date__c dateVar : txProposedDateToConfirmLst ){

                for(EmailTemplate template : etLst){
                    if( template.DeveloperName == 'GP_Tx_Date_COnfirmation_CL' ){
                        Messaging.SingleEmailMessage emailToSend = Utility.sendEmail( dateVar.Id  , template.Id , dateVar.GP_Contact__c   );
                        List<String> ccEmails = System.Label.Email_Cust_CC_Address.split(',');
                        //Ankita A: Set cc addresses
                        if(proposedDateMap.containsKey(dateVar.Id) && proposedDateMap.get(dateVar.Id).GP_Contact__c != null
                            && String.isNotBlank(proposedDateMap.get(dateVar.Id).GP_Contact__r.OM_Email__c)){
                                //Add the OM Email to cc List
                                ccEmails.add(proposedDateMap.get(dateVar.Id).GP_Contact__r.OM_Email__c);
                        }

                        if(proposedDateMap.containsKey(dateVar.Id) && proposedDateMap.get(dateVar.Id).GP_Contact__c != null
                            && String.isNotBlank(proposedDateMap.get(dateVar.Id).GP_Contact__r.Practice_Email__c)){
                                //Add the Other email to cc List
                                ccEmails.add(proposedDateMap.get(dateVar.Id).GP_Contact__r.Practice_Email__c);
                        }
                        emailToSend.setCcAddresses(ccEmails);
                        emailLst.add( emailToSend );
                    }

                    if( template.DeveloperName == 'SP_Tx_Date_Confirm_CL' ){
                        Messaging.SingleEmailMessage emailToSend = Utility.sendEmail( dateVar.Id  , template.Id , dateVar.SP_Contact__c   );
                        emailToSend.setCcAddresses(System.Label.Email_Cust_CC_Address.split(','));
                        emailLst.add( emailToSend );
                    }
                }
            }
        }



        system.debug('emailLst =>'+emailLst);

        if( !emailLst.isEmpty() ){
            Messaging.sendEmail( emailLst );
        }

        if(!proposedDateToRemindLst.isEmpty()){
            for( Proposed_Date__c dateVar : proposedDateToRemindLst ){
                Utility.synchActivity( dateVar.Id , dateVar.Related_Opportunity__c );
            }
        }

        if(!proposedDateToGPLst.isEmpty()){
            for( Proposed_Date__c dateVar : proposedDateToGPLst ){
                Utility.synchActivity( dateVar.Id , dateVar.Related_Opportunity__c );
            }
        }

        if(!proposedDateToSPLst.isEmpty()){
            for( Proposed_Date__c dateVar : proposedDateToSPLst ){
                Utility.synchActivity( dateVar.Id , dateVar.Related_Opportunity__c );
            }
        }

        if(!proposedDateToConfirmLst.isEmpty()){
            for( Proposed_Date__c dateVar : proposedDateToConfirmLst ){
                Utility.synchActivity( dateVar.Id , dateVar.Related_Opportunity__c );
            }
        }


        if(!txProposedDateToGPLst.isEmpty()){
            for( Proposed_Date__c dateVar : proposedDateToGPLst ){
                Utility.synchActivity( dateVar.Id , dateVar.Related_Opportunity__c );
            }
        }

        if(!txProposedDateToSPLst.isEmpty()){
            for( Proposed_Date__c dateVar : proposedDateToSPLst ){
                Utility.synchActivity( dateVar.Id , dateVar.Related_Opportunity__c );
            }
        }

        if(!txProposedDateToConfirmLst.isEmpty()){
            for( Proposed_Date__c dateVar : txProposedDateToConfirmLst ){
                Utility.synchActivity( dateVar.Id , dateVar.Related_Opportunity__c );
            }
        }


        if( opptyMapToUpdate != null &&  !opptyMapToUpdate.values().isEmpty()){
            update opptyMapToUpdate.values();
        }

        if( proposedDateLstForOLI != null &&  !proposedDateLstForOLI.isEmpty()){
            createOpportunityProduct(proposedDateLstForOLI , opportunityMap );
        }

    }


    private static void createOpportunityProduct( List<Proposed_Date__c> proposedDateLst , Map<Id,Opportunity> opportunityMap ){

        List<Opportunity_Line_Item__c> opportunityLineItemsLst = new List<Opportunity_Line_Item__c>();

        for( Proposed_Date__c dateVar : proposedDateLst ){
            Map<String,Id> productMap = Utility.getProductMap(new Set<String>{'DE-01'});
            Opportunity_Line_Item__c lineItem = new Opportunity_Line_Item__c();
            lineItem.Opportunity__c       = dateVar.Related_Opportunity__c;
            lineItem.Status__c           = 'Scheduled';
            lineItem.Treatment_Date__c   = Date.valueOf( dateVar.Start_Time__c );
            lineItem.Created_By__c   = dateVar.Created_By__c;

            if(opportunityMap.containsKey(dateVar.Related_Opportunity__c) && opportunityMap.get(dateVar.Related_Opportunity__c).Payment_Terms__c != null )
                lineItem.Invoice_Due_Date__c = Date.valueOf( dateVar.Start_Time__c ).addDays(Integer.valueOf( opportunityMap.get(dateVar.Related_Opportunity__c).Payment_Terms__c) );

            if(opportunityMap.containsKey(dateVar.Related_Opportunity__c) && opportunityMap.get(dateVar.Related_Opportunity__c).Compensation__c != null )
                lineItem.Compensation__c = opportunityMap.get(dateVar.Related_Opportunity__c).Compensation__c;

            //lineItem.UnitPrice
            opportunityLineItemsLst.add(lineItem);
        }

        if(!opportunityLineItemsLst.isEmpty()){
            insert opportunityLineItemsLst;
        }
    }

    public static void prePopulateContacts(List<Proposed_Date__c> proposedDateLst){

        if( proposedDateLst != null && !proposedDateLst.isEmpty() ){

            Set<Id>    opptyIdSet     = new Set<Id>();

            for( Proposed_Date__c dateVar : proposedDateLst ){
                opptyIdSet.add(dateVar.Related_Opportunity__c);
            }

            system.debug('opptyIdSet =>'+opptyIdSet);
            Id proposedDateMeetingRTId = Utility.getsObjectRecordTypeId(Proposed_Date__c.SObjectType,'Meeting');
            Id proposedDateTxRTId = Utility.getsObjectRecordTypeId(Proposed_Date__c.SObjectType,'Treatment');

            if(!opptyIdSet.isEmpty()){
                Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([ SELECT Id,Name,StageName,GP_Contact__c,Primary_Contact__c,
                        GP_Contact__r.LastName,Primary_Contact__r.LastName
                from
                        Opportunity
                where
                        Id in: opptyIdSet ]);

                system.debug('opportunityMap =>'+opportunityMap);

                for( Proposed_Date__c dateVar : proposedDateLst ){
                    system.debug('opportunityMap =>'+opportunityMap.containsKey(dateVar.Related_Opportunity__c));
                    if(opportunityMap.containsKey(dateVar.Related_Opportunity__c)){
                        dateVar.GP_Contact__c = opportunityMap.get(dateVar.Related_Opportunity__c).GP_Contact__c;
                        dateVar.SP_Contact__c = opportunityMap.get(dateVar.Related_Opportunity__c).Primary_Contact__c;
                        if( dateVar.RecordTypeId == proposedDateMeetingRTId ){
                            dateVar.Type__c = 'Meeting';
                            DateTime dateTimeVal = dateVar.Start_Time__c;
                            String dateValStr = '';
                            if(dateTimeVal != null ){
                                Date dateVal = date.newinstance(dateTimeVal.year(), dateTimeVal.month(), dateTimeVal.day());
                                system.debug(String.valueOf(dateVal).substring(0,10));
                                dateValStr   = String.valueOf(dateVal).substring(0,10);
                            }
                            String proposedDateString = 'Mt-'+dateValStr+','+opportunityMap.get(dateVar.Related_Opportunity__c).Primary_Contact__r.LastName+'-'+opportunityMap.get(dateVar.Related_Opportunity__c).GP_Contact__r.LastName;
                            dateVar.Name    = (proposedDateString.length() > 79 ) ? proposedDateString.substring(0,79) : proposedDateString ;
                            if(dateVar.End_Time__c == null && dateVar.Start_Time__c != null){
                                dateVar.End_Time__c =  dateVar.Start_Time__c.addHours(1);
                            }
                        }else if(dateVar.RecordTypeId == proposedDateTxRTId){
                            dateVar.Type__c = 'Treatment';

                            DateTime dateTimeVal = dateVar.Start_Time__c;
                            String dateValStr = '';
                            if(dateTimeVal != null ){
                                Date dateVal = date.newinstance(dateTimeVal.year(), dateTimeVal.month(), dateTimeVal.day());
                                system.debug(String.valueOf(dateVal).substring(0,10));
                                dateValStr   = String.valueOf(dateVal).substring(0,10);
                            }

                            String proposedDateString = 'Tx-'+dateValStr+','+opportunityMap.get(dateVar.Related_Opportunity__c).Primary_Contact__r.LastName+'-'+opportunityMap.get(dateVar.Related_Opportunity__c).GP_Contact__r.LastName;
                            dateVar.Name    = (proposedDateString.length() > 79 ) ? proposedDateString.substring(0,79) : proposedDateString ;
                            if(dateVar.End_Time__c == null && dateVar.Start_Time__c != null){
                                dateVar.End_Time__c =  dateVar.Start_Time__c.addHours(5);
                            }
                        }
                    }
                    system.debug('dateVar =>'+dateVar);
                }


            }
        }
    }
}