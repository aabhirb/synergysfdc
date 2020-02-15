/**
* Created by abidap on 1/3/19.
*/

public with sharing class ProspectMatchMapViewCtrlr {

    @AuraEnabled
    public static SObject getContactDetails( Id contactId ){
        String sobjectType = getSObjectTypefromIdValue(contactId);
        List<SObject> lstRecords;
        if(!String.isBlank(contactId)){
            if('Contact'.equalsIgnoreCase(sobjectType))
                lstRecords = [Select id,name,RecordTypeId,RecordType.Name,Contact_Status__c from Contact where Id =: contactId];
            else if('Lead'.equalsIgnoreCase(sobjectType))
                lstRecords = [Select id,name,RecordTypeId,RecordType.Name from Lead where Id =: contactId];
        }
        if( lstRecords != null && !lstRecords.isEmpty() ){
            return lstRecords[0];
        }
        return null;
    }

    @AuraEnabled
    public static List < ProspectWrapper > getProspectMatches(Id opportunityId){

        List < ProspectWrapper > wrapperLst = new List < ProspectWrapper > ();
        system.debug('opportunityId =>'+opportunityId);
        String recordTypeStr = '';
        String typeOfSpecialistWanted;
        String specialtyPrimary;
        String specialtySecondary;

        if(!String.isBlank(opportunityId)){
            List <String> matchStageToAvoidLst = new List <String> { 'Temp Stage'};
            List <String> contactSPStatusToAvoidLst = new List <String> { 'Contract Denied' };
            List <String> contactDaysAvailabilityToAvoidLst = new List <String> { '0 - Not Available' };

            String sobjectType = getSObjectTypefromIdValue(opportunityId);
            List<Prospect_Match__c> matchLst = new List<Prospect_Match__c>();
            system.debug('sobjectType ==>'+sobjectType);

            if('Opportunity'.equalsIgnoreCase(sobjectType)){


            }else if('Contact'.equalsIgnoreCase(sobjectType)){

                List<Contact> contactLst = [Select id,name,RecordTypeId,RecordType.Name,SPSPECIALTY__c,SPSPECIALTY2__c,Type_of_Specialists_GP_want__c from Contact where Id =: opportunityId ];

                if(contactLst != null && !contactLst.isEmpty()){

                    recordTypeStr = contactLst[0].RecordType.Name;
                    typeOfSpecialistWanted = contactLst[0].Type_of_Specialists_GP_want__c; // Practice context
                    specialtyPrimary = contactLst[0].SPSPECIALTY__c; // Provider context
                    specialtySecondary = contactLst[0].SPSPECIALTY2__c;

                    if('Practice'.equalsIgnoreCase(recordTypeStr)){

                        matchLst = [ SELECT Id,Name,SP_Contact__r.MailingLatitude,SP_Contact__r.MailingLongitude,SP_Contact__c,GP_Contact__c,GP_lead__c,GP_Contact__r.Contact_Status__c,SP_Contact__r.Contact_Status__c,
                                SP_Contact__r.Name, SP_Contact__r.MailingStreet, SP_Contact__r.MailingCity, SP_Contact__r.MailingCountry,is_Queued__c,
                                SP_Contact__r.MailingState, SP_Contact__r.MailingPostalCode,GP_Account__c,Match_stage__c,
                                GP_Contact__r.Type_of_Specialists_GP_want__c,
                                GP_Account__r.Name, GP_Contact__r.Name,GP_Contact__r.MailingLatitude,GP_Contact__r.MailingLongitude,
                                GP_Contact__r.MailingStreet, GP_Contact__r.MailingCity, GP_Contact__r.MailingCountry,SP_Contact__r.Add_state_s_licensed__c,
                                GP_Contact__r.MailingState, GP_Contact__r.MailingPostalCode,Approximate_Distance__c,
                                SP_Lead__c,SP_Lead__r.Latitude,SP_Lead__r.Longitude,SP_Lead__r.SPSPECIALTY__c,SP_Lead__r.SPSPECIALTY2__c,SP_Lead__r.Status,GP_Lead__r.Status,
                                SP_Lead__r.Name, SP_Lead__r.Street, SP_Lead__r.City, SP_Lead__r.Country,SP_Contact__r.SPSPECIALTY__c,SP_Contact__r.SPSPECIALTY2__c,SP_Contact__r.Days_SP_Available_per_month__c,
                                SP_Lead__r.State, SP_Lead__r.PostalCode,Match_Type__c,GP_Contact__r.Account.Type_of_Specialist_Needed__c,GP_Lead__r.Type_of_Specialists_they_want__c,
                                GP_Contact__r.Account.Name,GP_Lead__r.Company
                        from
                                Prospect_Match__c
                        where
                        GP_Contact__c =: opportunityId
                        and SP_Contact__r.DoNotCall <> true
                        and GP_Contact__r.DoNotCall <> true
                        and Match_Stage__c NOT IN: matchStageToAvoidLst
                        and SP_Contact__r.Contact_Status__c NOT IN: contactSPStatusToAvoidLst ];
                        //and SP_Contact__r.Days_SP_Available_per_month__c NOT IN: contactDaysAvailabilityToAvoidLst ];

                    }else if('Provider'.equalsIgnoreCase(recordTypeStr)){

                        matchLst = [ SELECT Id,Name,SP_Contact__r.MailingLatitude,SP_Contact__r.MailingLongitude,SP_Contact__c,GP_Contact__c,GP_lead__c,SP_lead__c,GP_Contact__r.Contact_Status__c,SP_Contact__r.Contact_Status__c,
                                SP_Contact__r.Name, SP_Contact__r.MailingStreet, SP_Contact__r.MailingCity, SP_Contact__r.MailingCountry,is_Queued__c,
                                SP_Contact__r.MailingState, SP_Contact__r.MailingPostalCode,GP_Account__c,Match_stage__c,
                                GP_Contact__r.Type_of_Specialists_GP_want__c,
                                GP_Account__r.Name, GP_Contact__r.Name,GP_Contact__r.MailingLatitude,GP_Contact__r.MailingLongitude,
                                GP_Contact__r.MailingStreet, GP_Contact__r.MailingCity, GP_Contact__r.MailingCountry,SP_Contact__r.Add_state_s_licensed__c,
                                GP_Contact__r.MailingState, GP_Contact__r.MailingPostalCode,Approximate_Distance__c,
                                GP_Lead__r.Latitude,GP_Lead__r.Longitude,SP_Lead__r.SPSPECIALTY__c,SP_Lead__r.SPSPECIALTY2__c,SP_Lead__r.Status,GP_Lead__r.Status,
                                GP_Lead__r.Name, GP_Lead__r.Street, GP_Lead__r.City, GP_Lead__r.Country,SP_Contact__r.SPSPECIALTY__c,SP_Contact__r.SPSPECIALTY2__c,SP_Contact__r.Days_SP_Available_per_month__c,
                                GP_Lead__r.State, GP_Lead__r.PostalCode,Match_Type__c,GP_Contact__r.Account.Type_of_Specialist_Needed__c,GP_Lead__r.Type_of_Specialists_they_want__c,
                                GP_Contact__r.Account.Name,GP_Lead__r.Company
                        from
                                Prospect_Match__c
                        where
                        SP_Contact__c =: opportunityId and
                        GP_Contact__r.DoNotCall <> true and
                        SP_Contact__r.DoNotCall <> true and
                        Match_Stage__c NOT IN: matchStageToAvoidLst and
                        SP_Contact__r.Contact_Status__c NOT IN: contactSPStatusToAvoidLst
                        ];

                        //SP_Contact__r.Days_SP_Available_per_month__c NOT IN: contactDaysAvailabilityToAvoidLst

                    }


                }


            }
            else if('Lead'.equalsIgnoreCase(sobjectType)){

                List<Lead> leadLst = [Select id,name,RecordTypeId,RecordType.Name,SPSPECIALTY__c,SPSPECIALTY2__c,Type_of_Specialists_they_want__c from Lead where Id =: opportunityId ];

                if(leadLst != null && !leadLst.isEmpty()){

                    recordTypeStr = leadLst[0].RecordType.Name;
                    typeOfSpecialistWanted = leadLst[0].Type_of_Specialists_they_want__c; // Practice context
                    specialtyPrimary = leadLst[0].SPSPECIALTY__c; // Provider context
                    specialtySecondary = leadLst[0].SPSPECIALTY2__c;

                    if('Practice'.equalsIgnoreCase(recordTypeStr)){

                        matchLst = [ SELECT Id,Name,SP_Contact__r.MailingLatitude,SP_Contact__r.MailingLongitude,SP_Contact__c,GP_Contact__c,GP_lead__c,GP_Contact__r.Contact_Status__c,SP_Contact__r.Contact_Status__c,
                                SP_Contact__r.Name, SP_Contact__r.MailingStreet, SP_Contact__r.MailingCity, SP_Contact__r.MailingCountry,is_Queued__c,
                                SP_Contact__r.MailingState, SP_Contact__r.MailingPostalCode,GP_Account__c,Match_stage__c,
                                GP_Contact__r.Type_of_Specialists_GP_want__c,
                                GP_Account__r.Name, GP_Contact__r.Name,GP_Contact__r.MailingLatitude,GP_Contact__r.MailingLongitude,
                                GP_Contact__r.MailingStreet, GP_Contact__r.MailingCity, GP_Contact__r.MailingCountry,SP_Contact__r.Add_state_s_licensed__c,
                                GP_Contact__r.MailingState, GP_Contact__r.MailingPostalCode,Approximate_Distance__c,
                                SP_Lead__c,SP_Lead__r.Latitude,SP_Lead__r.Longitude,SP_Lead__r.SPSPECIALTY__c,SP_Lead__r.SPSPECIALTY2__c,SP_Lead__r.Status,GP_Lead__r.Status,
                                SP_Lead__r.Name, SP_Lead__r.Street, SP_Lead__r.City, SP_Lead__r.Country,SP_Contact__r.SPSPECIALTY__c,SP_Contact__r.SPSPECIALTY2__c,SP_Contact__r.Days_SP_Available_per_month__c,
                                SP_Lead__r.State, SP_Lead__r.PostalCode,Match_Type__c,GP_Contact__r.Account.Type_of_Specialist_Needed__c,GP_Lead__r.Type_of_Specialists_they_want__c,
                                GP_Contact__r.Account.Name,GP_Lead__r.Company
                        from
                                Prospect_Match__c
                        where
                        GP_Lead__c =: opportunityId
                        and SP_Contact__r.DoNotCall <> true
                        and GP_Contact__r.DoNotCall <> true
                        and Match_Stage__c NOT IN: matchStageToAvoidLst
                        and SP_Contact__r.Contact_Status__c NOT IN: contactSPStatusToAvoidLst
                        ];
                        //and SP_Contact__r.Days_SP_Available_per_month__c NOT IN: contactDaysAvailabilityToAvoidLst ];

                    }else if('Provider'.equalsIgnoreCase(recordTypeStr)){

                        matchLst = [ SELECT Id,Name,SP_Contact__r.MailingLatitude,SP_Contact__r.MailingLongitude,SP_Contact__c,GP_Contact__c,GP_lead__c,SP_lead__c,GP_Contact__r.Contact_Status__c,SP_Contact__r.Contact_Status__c,
                                SP_Contact__r.Name, SP_Contact__r.MailingStreet, SP_Contact__r.MailingCity, SP_Contact__r.MailingCountry,is_Queued__c,
                                SP_Contact__r.MailingState, SP_Contact__r.MailingPostalCode,GP_Account__c,Match_stage__c,
                                GP_Contact__r.Type_of_Specialists_GP_want__c,
                                GP_Account__r.Name, GP_Contact__r.Name,GP_Contact__r.MailingLatitude,GP_Contact__r.MailingLongitude,
                                GP_Contact__r.MailingStreet, GP_Contact__r.MailingCity, GP_Contact__r.MailingCountry,SP_Contact__r.Add_state_s_licensed__c,
                                GP_Contact__r.MailingState, GP_Contact__r.MailingPostalCode,Approximate_Distance__c,
                                GP_Lead__r.Latitude,GP_Lead__r.Longitude,SP_Lead__r.SPSPECIALTY__c,SP_Lead__r.SPSPECIALTY2__c,SP_Lead__r.Status,GP_Lead__r.Status,
                                GP_Lead__r.Name, GP_Lead__r.Street, GP_Lead__r.City, GP_Lead__r.Country,SP_Contact__r.SPSPECIALTY__c,SP_Contact__r.SPSPECIALTY2__c,SP_Contact__r.Days_SP_Available_per_month__c,
                                GP_Lead__r.State, GP_Lead__r.PostalCode,Match_Type__c,GP_Contact__r.Account.Type_of_Specialist_Needed__c,GP_Lead__r.Type_of_Specialists_they_want__c,
                                GP_Contact__r.Account.Name,GP_Lead__r.Company
                        from
                                Prospect_Match__c
                        where
                        SP_Lead__c =: opportunityId
                        and GP_Contact__r.DoNotCall <> true
                        and SP_Contact__r.DoNotCall <> true
                        and Match_Stage__c NOT IN: matchStageToAvoidLst
                        and SP_Contact__r.Contact_Status__c NOT IN: contactSPStatusToAvoidLst
                        ];

                        //SP_Contact__r.Days_SP_Available_per_month__c NOT IN: contactDaysAvailabilityToAvoidLst

                    }


                }


            }

            system.debug('matchLst =>'+matchLst);


            for(Prospect_Match__c match : matchLst){

                ProspectWrapper prospectWrapper = new ProspectWrapper();
                Location locationVar                  = new Location();
                System.debug('sobjectType =>'+sobjectType);
                System.debug('sobjectType =>'+match.Match_Type__c);
                if(('Contact'.equalsIgnoreCase(sobjectType) && 'Contact'.equalsIgnoreCase(match.Match_Type__c))
                        || ('Lead'.equalsIgnoreCase(sobjectType) && 'Lead'.equalsIgnoreCase(match.Match_Type__c))){

                    prospectWrapper.contactType               = ('Practice'.equalsIgnoreCase(recordTypeStr)) ? 'GP' : 'SP';
                    prospectWrapper.approximateDistance       = match.Approximate_Distance__c;
                    prospectWrapper.objectType                = match.Match_Type__c;
                    if('Lead'.equalsIgnoreCase(sobjectType))
                        prospectWrapper.objectType                = 'Contact';
                    prospectWrapper.isQueued                  =  match.is_Queued__c;

                    String statesLicensed                     = match.SP_Contact__r.Add_state_s_licensed__c;
                    if( !String.isBlank( match.GP_Contact__r.MailingState ) ){

                        String stateToSearch = ((match.GP_Contact__r.MailingState.trim()).length() != 2) ? match.GP_Contact__r.MailingState.trim() : Utility.stateCodeMap.get(match.GP_Contact__r.MailingState.trim());
                        if(statesLicensed != null && !statesLicensed.containsIgnoreCase(stateToSearch)){
                            continue;
                        }
                    }
                    System.debug('Came here');
                    if('Practice'.equalsIgnoreCase(recordTypeStr)){
                        System.debug('Came here 2');
                        if( !String.isBlank( typeOfSpecialistWanted )
                                &&
                                ( ( match.SP_Contact__r.SPSPECIALTY__c != null && typeOfSpecialistWanted.containsIgnoreCase(match.SP_Contact__r.SPSPECIALTY__c.substring(0,3)) )
                                        ||
                                        ( match.SP_Contact__r.SPSPECIALTY2__c != null && typeOfSpecialistWanted.containsIgnoreCase(match.SP_Contact__r.SPSPECIALTY2__c.substring(0,3)) )
                                ) ){

                            locationVar.Latitude                  = String.valueOf(match.SP_Contact__r.MailingLatitude );
                            locationVar.Longitude                 = String.valueOf(match.SP_Contact__r.MailingLongitude );

                            LocationWrapper locationWrapper       = new LocationWrapper();
                            locationWrapper.location              = locationVar;
                            locationWrapper.title                 = match.SP_Contact__r.Name;
                            prospectWrapper.wrapper               = locationWrapper;
                            String specialtyString                = '';

                            if( match.SP_Contact__r.SPSPECIALTY__c != null )
                                specialtyString                  += ( match.SP_Contact__r.SPSPECIALTY__c + ';' );

                            if( match.SP_Contact__r.SPSPECIALTY2__c != null )
                                specialtyString                  += match.SP_Contact__r.SPSPECIALTY2__c;

                            if(!String.isBlank(specialtyString))
                                prospectWrapper.specialtyType     = specialtyString;

                            prospectWrapper.sobjectIdToNavigate   = match.SP_Contact__c;

                            prospectWrapper.contactNameString     = match.SP_Contact__r.Name;
                            prospectWrapper.matchStageString      = match.Match_Stage__c;
                            prospectWrapper.prospectMatchId       = match.Id;
                            //prospectWrapper.nextMatchStageString  = getNextMatchAction(match.Match_Stage__c);
                            String addressString                  = '';

                            if(String.isNotBlank(match.SP_Contact__r.MailingStreet)){
                                addressString                     += match.SP_Contact__r.MailingStreet;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.SP_Contact__r.MailingCity)){
                                addressString                     += match.SP_Contact__r.MailingCity;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.SP_Contact__r.MailingState)){
                                addressString                     += match.SP_Contact__r.MailingState;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.SP_Contact__r.MailingPostalCode)){
                                addressString                     += match.SP_Contact__r.MailingPostalCode;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.SP_Contact__r.MailingCountry)){
                                addressString                     += match.SP_Contact__r.MailingCountry;

                            }else{
                                addressString                     += 'USA';
                            }

                            prospectWrapper.contactAddress        = addressString;
                            prospectWrapper.contactStatus         = match.SP_Contact__r.Contact_Status__c;
                            prospectWrapper.noOfDaysSPAvailable   = match.SP_Contact__r.Days_SP_Available_per_month__c;

                            wrapperLst.add(prospectWrapper);
                        }

                    }else{

                        String specialtyString = '';
                        if( match.GP_Contact__r.Type_of_Specialists_GP_want__c != null )
                            specialtyString += match.GP_Contact__r.Type_of_Specialists_GP_want__c;

                        if( ( !String.isBlank( specialtyPrimary )  && specialtyString.containsIgnoreCase(specialtyPrimary.substring(0,3)) )
                                ||
                                ( !String.isBlank( specialtySecondary ) && specialtyString.containsIgnoreCase(specialtySecondary.substring(0,3)))
                                ){

                            locationVar.Latitude                  = String.valueOf(match.GP_Contact__r.MailingLatitude );
                            locationVar.Longitude                 = String.valueOf(match.GP_Contact__r.MailingLongitude );

                            LocationWrapper locationWrapper       = new LocationWrapper();
                            locationWrapper.location              = locationVar;
                            locationWrapper.title                 = match.GP_Contact__r.Name;
                            prospectWrapper.wrapper               = locationWrapper;


                            if(!String.isBlank(specialtyString))
                                prospectWrapper.specialtyType     = specialtyString;

                            prospectWrapper.sobjectIdToNavigate   = match.GP_Contact__c;

                            prospectWrapper.contactNameString     = match.GP_Contact__r.Name;
                            prospectWrapper.matchStageString      = match.Match_Stage__c;
                            prospectWrapper.prospectMatchId       = match.Id;
                            //prospectWrapper.nextMatchStageString  = getNextMatchAction(match.Match_Stage__c);

                            String addressString                  = '';

                            if(String.isNotBlank(match.GP_Contact__r.MailingStreet)){
                                addressString                     += match.GP_Contact__r.MailingStreet;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.GP_Contact__r.MailingCity)){
                                addressString                     += match.GP_Contact__r.MailingCity;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.GP_Contact__r.MailingState)){
                                addressString                     += match.GP_Contact__r.MailingState;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.GP_Contact__r.MailingPostalCode)){
                                addressString                     += match.GP_Contact__r.MailingPostalCode;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.GP_Contact__r.MailingCountry)){
                                addressString                     += match.GP_Contact__r.MailingCountry;
                            }else{
                                addressString                     += 'USA';
                            }

                            prospectWrapper.contactAddress        = addressString;
                            prospectWrapper.contactStatus         = match.GP_Contact__r.Contact_Status__c;
                            prospectWrapper.practiceName          = match.GP_Contact__r.Account.Name;
                            wrapperLst.add(prospectWrapper);
                        }

                    }

                }
                else if('Contact'.equalsIgnoreCase(sobjectType) && 'Lead'.equalsIgnoreCase(match.Match_Type__c)){
                    prospectWrapper.contactType               = ('Practice'.equalsIgnoreCase(recordTypeStr)) ? 'GP' : 'SP';
                    prospectWrapper.approximateDistance       = match.Approximate_Distance__c;
                    prospectWrapper.objectType                = match.Match_Type__c;
                    prospectWrapper.isQueued                  =  match.is_Queued__c;
                    if('Practice'.equalsIgnoreCase(recordTypeStr)){

                        if( !String.isBlank( typeOfSpecialistWanted )
                                &&
                                (
                                        ( match.SP_Lead__r.SPSPECIALTY__c != null && typeOfSpecialistWanted.containsIgnoreCase(match.SP_Lead__r.SPSPECIALTY__c.substring(0,3)) )
                                                ||
                                                ( match.SP_Lead__r.SPSPECIALTY2__c != null && typeOfSpecialistWanted.containsIgnoreCase(match.SP_Lead__r.SPSPECIALTY2__c.substring(0,3)) )
                                ) ){
                            locationVar.Latitude                  = String.valueOf(match.SP_Lead__r.Latitude );
                            locationVar.Longitude                 = String.valueOf(match.SP_Lead__r.Longitude );

                            LocationWrapper locationWrapper       = new LocationWrapper();
                            locationWrapper.location              = locationVar;
                            locationWrapper.title                 = match.SP_Lead__r.Name;
                            prospectWrapper.wrapper               = locationWrapper;

                            String specialtyString                = '';

                            if( match.SP_Lead__r.SPSPECIALTY__c != null )
                                specialtyString                  += ( match.SP_Lead__r.SPSPECIALTY__c + ';' );

                            if( match.SP_Lead__r.SPSPECIALTY2__c != null )
                                specialtyString                  += ( match.SP_Lead__r.SPSPECIALTY2__c );

                            if(!String.isBlank(specialtyString))
                                prospectWrapper.specialtyType     = specialtyString;

                            prospectWrapper.sobjectIdToNavigate   = match.SP_Lead__c;

                            prospectWrapper.contactNameString     = match.SP_Lead__r.Name;
                            prospectWrapper.matchStageString      = match.Match_Stage__c;
                            prospectWrapper.prospectMatchId       = match.Id;

                            String addressString                  = '';

                            if(String.isNotBlank(match.SP_Lead__r.Street)){
                                addressString                     += match.SP_Lead__r.Street;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.SP_Lead__r.City)){
                                addressString                     += match.SP_Lead__r.City;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.SP_Lead__r.State)){
                                addressString                     += match.SP_Lead__r.State;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.SP_Lead__r.PostalCode)){
                                addressString                     += match.SP_Lead__r.PostalCode;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.SP_Lead__r.Country)){
                                addressString                     += match.SP_Lead__r.Country;
                            }else{
                                addressString                     += 'USA';
                            }

                            prospectWrapper.contactAddress        = addressString;
                            prospectWrapper.contactStatus         = match.SP_Lead__r.Status;

                            wrapperLst.add(prospectWrapper);
                        }

                    }else{

                        String specialtyString = '';
                        if( match.GP_lead__r.Type_of_Specialists_they_want__c != null )
                            specialtyString += match.GP_lead__r.Type_of_Specialists_they_want__c;

                        if( ( !String.isBlank( specialtyPrimary )  &&  specialtyString.containsIgnoreCase(specialtyPrimary.substring(0,3)) )
                                ||
                                ( !String.isBlank( specialtySecondary ) && specialtyString.containsIgnoreCase(specialtySecondary.substring(0,3)))
                                ){

                            locationVar.Latitude                  = String.valueOf(match.GP_Lead__r.Latitude );
                            locationVar.Longitude                 = String.valueOf(match.GP_Lead__r.Longitude );

                            LocationWrapper locationWrapper       = new LocationWrapper();
                            locationWrapper.location              = locationVar;
                            locationWrapper.title                 = match.GP_Lead__r.Name;
                            prospectWrapper.wrapper               = locationWrapper;



                            if(!String.isBlank(specialtyString))
                                prospectWrapper.specialtyType     = specialtyString;

                            prospectWrapper.sobjectIdToNavigate   = match.GP_lead__c;

                            prospectWrapper.contactNameString     = match.GP_Lead__r.Name;
                            prospectWrapper.matchStageString      = match.Match_Stage__c;
                            prospectWrapper.prospectMatchId       = match.Id;


                            String addressString                  = '';

                            if(String.isNotBlank(match.GP_Lead__r.Street)){
                                addressString                     += match.GP_Lead__r.Street;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.GP_Lead__r.City)){
                                addressString                     += match.GP_Lead__r.City;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.GP_Lead__r.State)){
                                addressString                     += match.GP_Lead__r.State;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.GP_Lead__r.PostalCode)){
                                addressString                     += match.GP_Lead__r.PostalCode;
                                addressString                     += ', ';
                            }

                            if(String.isNotBlank(match.GP_Lead__r.Country)){
                                addressString                     += match.GP_Lead__r.Country;
                            }else{
                                addressString                     += 'USA';
                            }

                            prospectWrapper.contactAddress        = addressString;
                            prospectWrapper.contactStatus         = match.GP_Lead__r.Status;
                            prospectWrapper.practiceName          = match.GP_Lead__r.Company;
                            wrapperLst.add(prospectWrapper);

                        }
                    }
                }
            }
            if(wrapperLst != null && !wrapperLst.isEmpty()){
                List<ProspectWrapper> queuedWrapperLst = new List<ProspectWrapper>();
                List<ProspectWrapper> regularWrapperLst = new List<ProspectWrapper>();

                for( ProspectWrapper wrapper :  wrapperLst ){
                    if(wrapper.isQueued != null && wrapper.isQueued){
                        queuedWrapperLst.add(wrapper);
                    }else{
                        regularWrapperLst.add(wrapper);
                    }
                }

                system.debug('regularWrapperLst =>'+JSON.serializePretty(regularWrapperLst));
                if(regularWrapperLst != null && !regularWrapperLst.isEmpty())
                    regularWrapperLst.sort();
                system.debug('regularWrapperLst =>'+regularWrapperLst);

                system.debug('queuedWrapperLst =>'+queuedWrapperLst);
                if(queuedWrapperLst != null && !queuedWrapperLst.isEmpty())
                    queuedWrapperLst.sort();
                system.debug('queuedWrapperLst =>'+queuedWrapperLst);

                queuedWrapperLst.addAll(regularWrapperLst);
                system.debug('queuedWrapperLst =>'+JSON.serializePretty(queuedWrapperLst));
                wrapperLst = queuedWrapperLst;
            }
            // wrapperLst.sort();
        }
        return wrapperLst;
    }

    public static String getSObjectTypefromIdValue( String idValue ){
        String strValue = idValue.substring(0,3);
        return Utility.mSoPrefixByNameMap.get(strValue);
    }


    @AuraEnabled
    public static Boolean startMatchProcess( List<Id> prospectMatchIdLst , String actionType){

        try{

            if(prospectMatchIdLst != null && !prospectMatchIdLst.isEmpty() ){
                List<Task> taskLst = new List<Task>();

                Map<Id,Prospect_Match__c> prospectMap = new Map<Id,Prospect_Match__c> ([ SELECT Id,name,Match_Stage__c,GP_Contact__c,SP_Contact__c
                from
                        Prospect_Match__c
                where
                        Id IN: prospectMatchIdLst  ]);
                for(Prospect_Match__c matchVar : prospectMap.values()){
                    matchVar.Match_Stage__c = (actionType.containsIgnoreCase('gp')) ? 'Match Email Sent to GP' : 'Match Email Sent to SP';
                    //Ankita A: 22 Jan 2020: Update the date/time when Match stage is updated to 
                    //Match Email Sent to GP/SP
                    matchVar.Match_Opt_in_Datetime__c = System.now(); //Set as current date/time
                    matchVar.is_Queued__c = false;

                    Id sobjectId = actionType.containsIgnoreCase('gp') ? matchVar.GP_Contact__c : matchVar.SP_Contact__c;
                    taskLst.add( Utility.createActivity( matchVar.Id ,
                            sobjectId , Utility.TaskStatus.COMPLETE , matchVar.Match_Stage__c  ,
                            matchVar.Match_Stage__c  ,null , Date.today() ) );
                }

                List<Prospect_Match__c> matchLst = prospectMap.values();
                update matchLst;

                if( taskLst != null && !taskLst.isEmpty() )
                    insert taskLst;

                //Id objectIdToAssociate , Id userIdToAssociate , Utility.TaskStatus statusEnum ,
                //                                        String subjectString , String descriptionString , String typeString , Date duedate


            }

        }catch(Exception ex){

            throw ex;
        }

        return true;
    }

    @AuraEnabled
    public static Boolean recalculateProspectMatches(Id sobjectId , Integer mileRadius ) {
        try{
            //Ankita A: 12 Feb 2020: According to object type, call the method to find Prospect matches
            if(String.isNotBlank(sobjectId)){
                String sobjectType = getSObjectTypefromIdValue(sobjectId);
                if(sobjectType.equalsIgnoreCase('Contact')){
                    CustomLeadConvertController.calculateProspectMatches(sobjectId , null , mileRadius );
                } else if(sobjectType.equalsIgnoreCase('Lead')){
                    CustomLeadConvertController.calculateProspectMatchesForLead(new List<Id>{sobjectId}, mileRadius);
                }
            }

        }catch(Exception ex){
            throw ex;
        }
        return true;
    }

    @AuraEnabled
    public static Boolean enQueueMatch( Id prospectMatchId ){
        try{
            String slackMsg = 'Following Possible Match has been Queued , Please Review and Send between \n $Provider$ and $Practice$ \n Specialty : $Specialty$ \n Provider :  $Link$ ';
            if( prospectMatchId != null ){
                List<Prospect_Match__c> matchLst = [SELECT Id,Name,GP_Contact_FIrst_Name__c,GP_Contact_Last_Name__c,SP_Contact_First_Name__c,SP_Contact_Last_Name__c,SP_Contact__r.Specialty_Primary_Value__c,SP_Contact__c from Prospect_Match__c where Id =: prospectMatchId];

                Prospect_Match__c match = new Prospect_Match__c(Id=prospectMatchId);
                match.is_Queued__c = true;

                update match;
                if(matchLst != null && !matchLst.isEmpty()){
                    slackMsg = slackMsg.replace( '$Provider$' , matchLst[0].SP_Contact_Last_Name__c );
                    slackMsg = slackMsg.replace( '$Practice$' , matchLst[0].GP_Contact_Last_Name__c );
                    slackMsg = slackMsg.replace( '$Specialty$' , matchLst[0].SP_Contact__r.Specialty_Primary_Value__c );
                    slackMsg = slackMsg.replace( '$Link$' , 'https://ascendorthodontics.lightning.force.com/'+matchLst[0].SP_Contact__c );
                }
                Map<String,Object> msg = new Map<String,Object>();
                msg.put('text', slackMsg );
                msg.put('mrkdwn', true);
                String body = JSON.serialize(msg);

                System.enqueueJob(new SlackCalloutProcessBuilder.QueueableSlackCall('https://hooks.slack.com/services/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', 'POST', body));

            }

            return true;

        }catch(DMLException ex){
            return false;
        }
        
    }
     

    /*private static String getNextMatchAction(String stageName){

if(orderedStageNameStringLst == null ){
orderedStageNameStringLst = new List<String>();
List<SelectOption> selectOptionlist = Utility.getPickListValues('Prospect_Match__c','Match_Stage__c');
for(SelectOption option : selectOptionlist){
orderedStageNameStringLst.add(option.getLabel());
}
}

Integer counter = 0;
for(String optionName : orderedStageNameStringLst){
if(stageName.equalsIgnoreCase(optionName)){
return (counter >= orderedStageNameStringLst.size() - 1) ?
'-' : orderedStageNameStringLst[++counter];
}
counter++;
}

return null;
}*/

    public class ProspectWrapper implements Comparable{
        @AuraEnabled
        public LocationWrapper wrapper;
        /*@AuraEnabled
public Boolean isEmailSent;*/
        @AuraEnabled
        public String contactNameString;
        @AuraEnabled
        public String matchStageString;
        /*@AuraEnabled
public String nextMatchStageString;*/
        @AuraEnabled
        public String contactAddress;
        @AuraEnabled
        public String prospectMatchId;
        @AuraEnabled
        public String contactType;
        @AuraEnabled
        public Decimal approximateDistance;
        @AuraEnabled
        public String objectType;
        @AuraEnabled
        public String specialtyType;
        @AuraEnabled
        public String sobjectIdToNavigate;
        @AuraEnabled
        public String contactStatus;
        @AuraEnabled
        public String noOfDaysSPAvailable;
        @AuraEnabled
        public Boolean isQueued;
        @AuraEnabled
        public String practiceName;

        public Integer compareTo(Object compareTo) {
            ProspectWrapper compareToEmp = (ProspectWrapper)compareTo;
            if (approximateDistance == compareToEmp.approximateDistance) return 0;
            if (approximateDistance > compareToEmp.approximateDistance) return 1;
            return -1;

        }
    }

    public class LocationWrapper {
        @AuraEnabled
        public Location location {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String icon {get;set;}

    }


    public class Location {
        @AuraEnabled
        public String Latitude {get;set;}
        @AuraEnabled
        public String Longitude {get;set;}

    }


}