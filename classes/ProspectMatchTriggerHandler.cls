/**
 * Created by abidap on 2/14/19.
 */

public with sharing class ProspectMatchTriggerHandler {

    public static void processAfterUpdate( List<Prospect_Match__c> newProspectLst , Map<Id,Prospect_Match__c> oldProspectMap ){

        List<Prospect_Match__c> matchLstToConvert = new List <Prospect_Match__c> ();
        List<Prospect_Match__c> signedSPLstToEmail = new List <Prospect_Match__c> ();
        List<Prospect_Match__c> notSignedSPLstToEmail = new List <Prospect_Match__c> ();
        List<Prospect_Match__c> newGPLstToEmail = new List <Prospect_Match__c> ();
        List<Prospect_Match__c> existingGPLstToEmail = new List <Prospect_Match__c> ();
        List<Id> idsToSendToSP = new List<Id>();
        for( Prospect_Match__c match : newProspectLst ){

            if( 'Match Approved'.equalsIgnoreCase(match.Match_Stage__c)  && match.Match_Stage__c != oldProspectMap.get( match.Id ).Match_Stage__c ){
                matchLstToConvert.add( match );
            }

            /*
            (Prospect Match: Match StageEQUALSMatch Email Sent to SP) AND (Prospect Match: Match TypeEQUALSContact) AND ( (Prospect Match: Is SP Contract SignedEQUALSTrue) OR (Prospect Match: SP StatusEQUALSContract Signed) )
             */
            system.debug('Match STage =>'+match.Match_Stage__c);
            system.debug('Match Type  =>'+match.Match_Type__c);
            system.debug('SP Status   =>'+match.SP_Status__c);

            if(  ( match.Is_SP_Contract_Signed__c != oldProspectMap.get( match.Id ).Is_SP_Contract_Signed__c || match.Match_Stage__c != oldProspectMap.get( match.Id ).Match_Stage__c )
                        && 'Match Email Sent to SP'.equalsIgnoreCase( match.Match_Stage__c )
                        && 'Contact'.equalsIgnoreCase( match.Match_Type__c )
                        &&  match.Is_SP_Contract_Signed__c == true ){
                signedSPLstToEmail.add( match );
            }else if(  match.Match_Stage__c != oldProspectMap.get( match.Id ).Match_Stage__c
                        && 'Match Email Sent to SP'.equalsIgnoreCase( match.Match_Stage__c )
                        && 'Contact'.equalsIgnoreCase( match.Match_Type__c )
                        && !'Contract Signed'.equalsIgnoreCase( match.SP_Status__c )
                    ){
                notSignedSPLstToEmail.add( match );
            }else if(  match.Match_Stage__c != oldProspectMap.get( match.Id ).Match_Stage__c
                        && 'Match Email Sent to GP'.equalsIgnoreCase( match.Match_Stage__c )
                        && match.is_Practice_Existing_Customer__c == false
                        && match.First_Response__c == false
                    ){
                //GP_Start_Match_HTML
                newGPLstToEmail.add(match);
                idsToSendToSP.add(match.Id);

            }else if(  match.Match_Stage__c != oldProspectMap.get( match.Id ).Match_Stage__c
                        && 'Match Email Sent to GP'.equalsIgnoreCase( match.Match_Stage__c )
                        && ( match.is_Practice_Existing_Customer__c == true || match.First_Response__c == true )
                    ) {
                //GP_ASA_Signed_OptIn_to_Match
                existingGPLstToEmail.add(match);
            }
        }

        if(!matchLstToConvert.isEmpty()){
            ProspectMatchTriggerHandler.createOpportunity( matchLstToConvert );
        }

        if(!signedSPLstToEmail.isEmpty()){
            ProspectMatchTriggerHandler.sendSPOptInEmail( signedSPLstToEmail , true );
        }

        if(!notSignedSPLstToEmail.isEmpty()){
            Set<Id> spContactIdSet = new Set<Id>();
            Set<Id> gpContactIdSet = new Set<Id>();
            for( Prospect_Match__c matchNotSigned : notSignedSPLstToEmail ){
                spContactIdSet.add(matchNotSigned.SP_Contact__c);
                gpContactIdSet.add(matchNotSigned.GP_Contact__c);
            }

            system.debug('spContactIdSet =>'+spContactIdSet);
            system.debug('gpContactIdSet =>'+gpContactIdSet);

            List<Prospect_Match__c> matchLstNotSignedSentToday = [SELECT Id,Name,SP_Contact__c
                                                                        from Prospect_Match__c
                                                                            where ( SP_Contact__c IN: spContactIdSet
                                                                                        OR
                                                                                    GP_Contact__c IN: gpContactIdSet )
                                                                                    and Id NOT IN: notSignedSPLstToEmail and
                                                                                  Match_Stage__c = 'Match Email Sent to SP' and LastModifiedDate = TODAY ];

            system.debug('matchLstNotSignedSentToday =>'+matchLstNotSignedSentToday);
            system.debug('notSignedSPLstToEmail =>'+notSignedSPLstToEmail);
            if( matchLstNotSignedSentToday != null && !matchLstNotSignedSentToday.isEmpty() ){
                for( Prospect_Match__c match : matchLstNotSignedSentToday ){
                    if(spContactIdSet.contains(match.SP_Contact__c)){
                        //notSignedSPLstToEmail.remove(match);
                        system.debug('notSignedSPLstToEmail =>'+notSignedSPLstToEmail);
                        system.debug('match =>'+match);
                        notSignedSPLstToEmail = removeMatch(notSignedSPLstToEmail,match);

                        system.debug('notSignedSPLstToEmail =>'+notSignedSPLstToEmail);
                    }
                }
            }

            system.debug('notSignedSPLstToEmail =>'+notSignedSPLstToEmail);

            if(notSignedSPLstToEmail != null && !notSignedSPLstToEmail.isEmpty() ){
                ProspectMatchTriggerHandler.sendSPOptInEmail( notSignedSPLstToEmail , false );
            }
        }

        if(!newGPLstToEmail.isEmpty()){
            ProspectMatchTriggerHandler.sendGPEmail( newGPLstToEmail , false );
        }

        if(!existingGPLstToEmail.isEmpty()){
            ProspectMatchTriggerHandler.sendGPEmail( existingGPLstToEmail , true );
        }

        if(!idsToSendToSP.isEmpty()){
            ProspectMatchTriggerHandler.updateToSP(JSON.serialize(idsToSendToSP));
        }
    }

    private static List<Prospect_Match__c> removeMatch( List<Prospect_Match__c> matchLst , Prospect_Match__c matchToRemove){
        List<Prospect_Match__c> matchLstToReturn = new List<Prospect_Match__c>();

        for(Prospect_Match__c match : matchLst ){
            if( match.SP_Contact__c != matchToRemove.SP_Contact__c ){
                matchLstToReturn.add(match);
            }
        }

        return matchLstToReturn;
    }
    
    @Future(callout=true)
    public static void updateToSP( String idLstStr ){
        List<Id> idLst = (List<Id>) JSON.deserialize(idLstStr,List<Id>.class);
        List<Prospect_Match__c> matchLst = new List <Prospect_Match__c>();
        for(Id idVar : idLst){
            Prospect_Match__c match = new Prospect_Match__c();
            match.Id = idVar;
            match.Match_Stage__c = 'Match Email Sent to SP';
            matchLst.add(match);
        }

        update matchLst;
    }

    /*
       @Description :  Sends EMail to SP when Contract is signed / not signed
    */
    public static void sendSPOptInEmail( List<Prospect_Match__c> newProspectLst, Boolean isContractSigned ){
        try{
            system.debug('inside sendSPOptInEmail');
            String templateName = ( isContractSigned ) ? 'SP_ASA_Signed_OptIn_to_Match' : 'SP_Start_Match_HTML';
            List<EmailTemplate> etLst = [SELECT id FROM EmailTemplate WHERE developerName =: templateName ];
            List<Messaging.SingleEmailMessage> emailLst = new List<Messaging.SingleEmailMessage>();

            for( Prospect_Match__c match : newProspectLst ){
                Messaging.SingleEmailMessage emailToSend = Utility.sendEmail( match.Id, etLst[0].Id , match.SP_Contact__c );
                emailToSend.setCcAddresses(System.Label.Email_Cust_CC_Address.split(','));
                emailLst.add( emailToSend );
            }
            system.debug('inside sendSPOptInEmail'+emailLst);

            if( !emailLst.isEmpty() ){
                Messaging.sendEmail( emailLst );
            }

        }catch(Exception ex){
            // Add Logger
            ApexLogger.Logger logger = ApexLogger.createLogger('ProspectMatchTriggerHandler:Failures');
            logger.log('Method : sendSPOptInEmail ');
            logger.log('Exception : '+ex.getMessage());
            logger.log('Exception Stack Trace String : '+ex.getStackTraceString() );

            system.debug( ex.getMessage() + ex.getStackTraceString() );

            ApexLogger.commitLogs();
        }

    }

    /*
      @Description :  Sends EMail to GP if existing or not
   */
    public static void sendGPEmail( List<Prospect_Match__c> newProspectLst, Boolean isExisting ){
        try{
            system.debug('inside sendGPEmail');
            String templateName = ( isExisting ) ? 'GP_ASA_Signed_OptIn_to_Match' : 'GP_Start_Match_HTML';
            List<EmailTemplate> etLst = [SELECT id FROM EmailTemplate WHERE developerName =: templateName ];
            List<Messaging.SingleEmailMessage> emailLst = new List<Messaging.SingleEmailMessage>();

            for( Prospect_Match__c match : newProspectLst ){
                Messaging.SingleEmailMessage emailToSend = Utility.sendEmail( match.Id, etLst[0].Id , match.GP_Contact__c );
                List<String> ccAddressStrings = System.Label.Email_Cust_CC_Address.split(',');
                if( match.OM_Email__c != null )
                    ccAddressStrings.add(match.OM_Email__c); 
                emailToSend.setCcAddresses(ccAddressStrings);
                emailLst.add( emailToSend );
            }
            system.debug('inside sendGPEmail'+emailLst);

            if( !emailLst.isEmpty() ){
                Messaging.sendEmail( emailLst );
            }

        }catch(Exception ex){
            // Add Logger
            ApexLogger.Logger logger = ApexLogger.createLogger('ProspectMatchTriggerHandler:Failures');
            logger.log('Method : sendGPEmail ');
            logger.log('Exception : '+ex.getMessage());
            logger.log('Exception Stack Trace String : '+ex.getStackTraceString() );

            system.debug( ex.getMessage() + ex.getStackTraceString() );

            ApexLogger.commitLogs();
        }

    }
    public static void createOpportunity( List<Prospect_Match__c> newProspectLst ){
        List<Opportunity> opptyLst = new List <Opportunity>();
        Set<Id> contactIdSet = new Set<Id>();
        for( Prospect_Match__c match : newProspectLst ){
            String opptyName = 'Dr.' + match.SP_Contact_Last_Name__c +'@'+ match.GP_Account_Name__c + '-' + match.GP_Contact_Last_Name__c ;
            opptyLst.add( new Opportunity (
                                            Name = opptyName ,
                                            GP_Contact__c = match.GP_Contact__c, Primary_Contact__c = match.SP_Contact__c,
                                            AccountId = match.SP_Account__c , StageName = 'Matched' , CloseDate = Date.today().addDays(3),
                                            RecordTypeId = Utility.getsObjectRecordTypeId(Opportunity.SObjectType , 'Traditional'),
                                            OM_Email__c = match.OM_Email__c
                                          )
                        );

            if( match.GP_Contact__c != null )
                contactIdSet.add(match.GP_Contact__c);

            if( match.SP_Contact__c != null )
                contactIdSet.add(match.SP_Contact__c);
        }

        if(!opptyLst.isEmpty()){
            insert opptyLst;
        }

        if( contactIdSet != null && contactIdSet.size() != 0 ){
            List<Contact> contactLstToUpdate = new List<Contact> ();

            for( Id contactId : contactIdSet ){
                contactLstToUpdate.add(new Contact( Id = contactId , is_Customer__c = true ));
            }

            update contactLstToUpdate;
        }

        if(!newProspectLst.isEmpty())
        sendSPGPIntoEmail( newProspectLst );
    }

    public static void sendSPGPIntoEmail( List<Prospect_Match__c> newProspectLst ){
        try{
            system.debug('inside sendSPGPIntoEmail');
            List<EmailTemplate> etLst = [SELECT id FROM EmailTemplate WHERE developerName = 'SP_GP_Intro_Email'];
            List<Messaging.SingleEmailMessage> emailLst = new List<Messaging.SingleEmailMessage>();

            for( Prospect_Match__c match : newProspectLst ){
                Messaging.SingleEmailMessage email = Utility.sendEmail( match.Id, etLst[0].Id , match.SP_Contact__c );
                //email.setCcAddresses( new List<String>{ match.GP_Contact__c } );
                //email.setCcAddresses(System.Label.Email_Cust_CC_Address.split(','));
                List<String> strLst = new List<String>();
                if(match.GP_Contact__c != null)
                    strLst.add(match.GP_Contact__c);

                if(match.OM_Email__c != null)
                    strLst.add(match.OM_Email__c);

                strLst.addAll(System.Label.Email_Cust_CC_Address.split(','));
                email.setCcAddresses(strLst);
                emailLst.add( email );
            }
            system.debug('inside sendSPOptInEmail'+emailLst);

            if( !emailLst.isEmpty() ){
                Messaging.sendEmail( emailLst );
            }

        }catch(Exception ex){
            // Add Logger
            ApexLogger.Logger logger = ApexLogger.createLogger('ProspectMatchTriggerHandler:Failures');
            logger.log('Method : sendSPGPIntoEmail ');
            logger.log('Exception : '+ex.getMessage());
            logger.log('Exception Stack Trace String : '+ex.getStackTraceString() );

            system.debug( ex.getMessage() + ex.getStackTraceString() );

            ApexLogger.commitLogs();
        }

    }
}