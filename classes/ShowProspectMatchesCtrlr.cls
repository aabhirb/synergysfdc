/**
 * Created by abidap on 1/13/19.
 */

public with sharing class ShowProspectMatchesCtrlr {
    public String opportunityId {get;set;}
    public String matchId {get;}
    public String matchIdSP {get;}
    public String matchIdSPGP {get;}
    public String gpSpecialty {get;set;}
    public String spSpecialty {get;set;}
    public String url {get;set;}
    public String gpAddress {get;set;}
    public String redirectURL {get;set;}


    public List<Prospect_Match__c> matchLst {get;set;}
    public Prospect_Match__c matchToInitiate  {get;set;}

    public void setOpportunityId(String opptytId){
        //opportunityId = opptytId;
        matchLst      = new List<Prospect_Match__c>();
        matchLst      = [Select Id,name,SP_Contact__r.Name, GP_Account__r.Name, SP_Contact__r.Email , SP_Contact__r.Phone ,
                                SP_Contact__r.MailingStreet , SP_Contact__r.MailingCity , SP_Contact__r.MailingState, SP_Contact__r.MailingCountry,SP_Contact__r.MailingPostalCode,Specialist_Specialty__c
                                from
                                        Prospect_Match__c
                                where
                                SP_Contact__c =: opptytId
                        ];
 
    }

    public void setMatchId(String matchIdParam){
        //opportunityId = opptytId;
        spSpecialty = '';
        List<Prospect_Match__c> matchLstQueried      = new List<Prospect_Match__c>();
        matchLstQueried                              = [Select Id,name,SP_Contact__r.Name, GP_Account__r.Name, SP_Contact__r.Email , SP_Contact__r.Phone ,GP_Contact_Last_Name__c,GP_Contact__r.Account.Type_of_Specialist_Needed__c,
                                                                SP_Contact__r.MailingStreet , SP_Contact__r.MailingCity , SP_Contact__r.MailingState, SP_Contact__r.MailingCountry,SP_Contact__r.MailingPostalCode,Specialist_Specialty__c,
                                                                SP_Contact__r.SPSPECIALTY__c,SP_Contact__r.SPSPECIALTY2__c,Match_stage__c,SP_Contact__r.Preferred_Contact_Time__c,SP_Contact__r.Preferred_Contact_Method__c,GP_Contact__r.Preferred_Contact_Method__c,GP_Contact__r.Preferred_Contact_Time__c,GP_Contact__r.OM_Phone__c,GP_Contact__r.OM_Name__c,GP_Contact__r.Phone,GP_Contact__r.Formulated_MailingAddress__c
                                                                from
                                                                        Prospect_Match__c
                                                                where
                                                                        Id =: matchIdParam
                                                        ];
        if( matchLstQueried != null && !matchLstQueried.isEmpty()){
            matchToInitiate                         = matchLstQueried[0];
            gpSpecialty                             = matchToInitiate.GP_Contact__r.Account.Type_of_Specialist_Needed__c;
            if(String.isNotBlank(matchToInitiate.SP_Contact__r.SPSPECIALTY__c)){
                spSpecialty                         += matchToInitiate.SP_Contact__r.SPSPECIALTY__c;
            }

            if(String.isNotBlank(matchToInitiate.SP_Contact__r.SPSPECIALTY2__c)){
                spSpecialty                         += ' and '+matchToInitiate.SP_Contact__r.SPSPECIALTY2__c;
            }

            url = 'https://internalsynergyspecialists.secure.force.com/match?matchId='+matchToInitiate.Id+'&type=gp';
        }

    }

    public void setMatchIdSP(String matchIdParam){
        //opportunityId = opptytId;
        spSpecialty = '';
        List<Prospect_Match__c> matchLstQueried      = new List<Prospect_Match__c>();

        matchLstQueried                              = [Select Id,Name,SP_Contact__r.MailingLatitude,SP_Contact__r.MailingLongitude,SP_Contact__c,GP_Contact__c,GP_lead__c,GP_Contact__r.Account.Insurance_Accepted__c,
                                                                SP_Contact__r.Name, SP_Contact__r.MailingStreet, SP_Contact__r.MailingCity, SP_Contact__r.MailingCountry,GP_Contact__r.LastName,
                                                                SP_Contact__r.MailingState, SP_Contact__r.MailingPostalCode,GP_Account__c,Match_stage__c,SP_Contact__r.MobilePhone,
                                                                GP_Account__r.Name, GP_Contact__r.Name,GP_Contact__r.MailingLatitude,GP_Contact__r.MailingLongitude,
                                                                GP_Contact__r.MailingStreet, GP_Contact__r.MailingCity, GP_Contact__r.MailingCountry,GP_Contact__r.Account.Name,
                                                                GP_Contact__r.MailingState, GP_Contact__r.MailingPostalCode,Approximate_Distance__c,SP_Contact__r.Account.Name,
                                                                SP_Lead__c,SP_Lead__r.Latitude,SP_Lead__r.Longitude,SP_Lead__r.SPSPECIALTY__c,SP_Lead__r.SPSPECIALTY2__c,
                                                                SP_Lead__r.Name, SP_Lead__r.Street, SP_Lead__r.City, SP_Lead__r.Country,SP_Contact__r.SPSPECIALTY__c,SP_Contact__r.SPSPECIALTY2__c,
                                                                SP_Lead__r.State, SP_Lead__r.PostalCode,Match_Type__c,GP_Contact__r.Account.Type_of_Specialist_Needed__c,GP_Lead__r.Type_of_Specialists_they_want__c,Specialist_Specialty__c,SP_Contact__r.Preferred_Contact_Time__c,SP_Contact__r.Preferred_Contact_Method__c,
                                                                GP_Contact__r.Preferred_Contact_Method__c,GP_Contact__r.Preferred_Contact_Time__c,GP_Contact__r.OM_Phone__c,GP_Contact__r.OM_Name__c,GP_Contact__r.Phone,GP_Contact__r.Formulated_MailingAddress__c
                                                                from
                                                                        Prospect_Match__c 
                                                                where
                                                                        Id =: matchIdParam
                                                        ];

        if( matchLstQueried != null && !matchLstQueried.isEmpty()){
            matchToInitiate                         = matchLstQueried[0];
            gpSpecialty                             = matchToInitiate.GP_Contact__r.Account.Type_of_Specialist_Needed__c;
            if(String.isNotBlank(matchToInitiate.SP_Contact__r.SPSPECIALTY__c)){
                spSpecialty                         += matchToInitiate.SP_Contact__r.SPSPECIALTY__c;
            }

            if(String.isNotBlank(matchToInitiate.SP_Contact__r.SPSPECIALTY2__c)){
                spSpecialty                         += ' and '+matchToInitiate.SP_Contact__r.SPSPECIALTY2__c;
            }

            gpAddress                               = '';



            if(String.isNotBlank(matchToInitiate.GP_Contact__r.MailingStreet)){
                gpAddress                     += matchToInitiate.GP_Contact__r.MailingStreet;
                gpAddress                     += ', ';
            }

            if(String.isNotBlank(matchToInitiate.GP_Contact__r.MailingCity)){
                gpAddress                     += matchToInitiate.GP_Contact__r.MailingCity;
                gpAddress                     += ', ';
            }

            if(String.isNotBlank(matchToInitiate.GP_Contact__r.MailingState)){
                gpAddress                     += matchToInitiate.GP_Contact__r.MailingState;
                gpAddress                     += ', ';
            }

            if(String.isNotBlank(matchToInitiate.GP_Contact__r.MailingPostalCode)){
                gpAddress                     += matchToInitiate.GP_Contact__r.MailingPostalCode;
                gpAddress                     += ', ';
            }

            if(String.isNotBlank(matchToInitiate.GP_Contact__r.MailingCountry)){
                gpAddress                     += matchToInitiate.GP_Contact__r.MailingCountry;
            }else{
                gpAddress                     += 'USA';
            }

            url = 'https://internalsynergyspecialists.secure.force.com/match?matchId='+matchToInitiate.Id+'&type=sp';
        }

    }

    public void setMatchIdSPGP( String matchIdParam ){

        spSpecialty = '';
        List<Prospect_Match__c> matchLstQueried      = new List<Prospect_Match__c>();

        matchLstQueried                              = [Select Id,Name,SP_Contact__r.MailingLatitude,SP_Contact__r.MailingLongitude,SP_Contact__c,GP_Contact__c,GP_lead__c,GP_Contact__r.Account.Insurance_Accepted__c,
                                                                        SP_Contact__r.Name, SP_Contact__r.MailingStreet, SP_Contact__r.MailingCity, SP_Contact__r.MailingCountry,GP_Contact__r.LastName,SP_Contact__r.MobilePhone,
                                                                        SP_Contact__r.MailingState, SP_Contact__r.MailingPostalCode,GP_Account__c,Match_stage__c,GP_Contact__r.Account.Website,SP_Contact__r.Email,GP_Contact__r.MobilePhone,
                                                                        GP_Account__r.Name, GP_Contact__r.Name,GP_Contact__r.MailingLatitude,GP_Contact__r.MailingLongitude,
                                                                        GP_Contact__r.MailingStreet, GP_Contact__r.MailingCity, GP_Contact__r.MailingCountry,SP_Contact__r.LastName,
                                                                        GP_Contact__r.MailingState, GP_Contact__r.MailingPostalCode,Approximate_Distance__c,SP_Contact__r.Account.Name,
                                                                        SP_Lead__c,SP_Lead__r.Latitude,SP_Lead__r.Longitude,SP_Lead__r.SPSPECIALTY__c,SP_Lead__r.SPSPECIALTY2__c,GP_Contact__r.Email,
                                                                        SP_Lead__r.Name, SP_Lead__r.Street, SP_Lead__r.City, SP_Lead__r.Country,SP_Contact__r.SPSPECIALTY__c,SP_Contact__r.SPSPECIALTY2__c,GP_Contact__r.Account.Name,
                                                                        SP_Lead__r.State, SP_Lead__r.PostalCode,Match_Type__c,GP_Contact__r.Account.Type_of_Specialist_Needed__c,GP_Lead__r.Type_of_Specialists_they_want__c,Specialist_Specialty__c,SP_Contact__r.Preferred_Contact_Time__c,SP_Contact__r.Preferred_Contact_Method__c,
                                                                        GP_Contact__r.Preferred_Contact_Method__c,GP_Contact__r.Preferred_Contact_Time__c,GP_Contact__r.OM_Phone__c,GP_Contact__r.OM_Name__c,GP_Contact__r.Phone,GP_Contact__r.Formulated_MailingAddress__c
                                                                        from
                                                                                Prospect_Match__c
                                                                        where
                                                                                Id =: matchIdParam
                                                                        ];

        if( matchLstQueried != null && !matchLstQueried.isEmpty()){

            matchToInitiate                         = matchLstQueried[0];
            gpSpecialty                             = matchToInitiate.GP_Contact__r.Account.Type_of_Specialist_Needed__c;
            if(String.isNotBlank(matchToInitiate.SP_Contact__r.SPSPECIALTY__c)){
                spSpecialty                         += matchToInitiate.SP_Contact__r.SPSPECIALTY__c;
            }

            if(String.isNotBlank(matchToInitiate.SP_Contact__r.SPSPECIALTY2__c)){
                spSpecialty                         += ' and '+matchToInitiate.SP_Contact__r.SPSPECIALTY2__c;
            }

            gpAddress                               = '';



            if(String.isNotBlank(matchToInitiate.GP_Contact__r.MailingStreet)){
                gpAddress                     += matchToInitiate.GP_Contact__r.MailingStreet;
                gpAddress                     += ', ';
            }

            if(String.isNotBlank(matchToInitiate.GP_Contact__r.MailingCity)){
                gpAddress                     += matchToInitiate.GP_Contact__r.MailingCity;
                gpAddress                     += ', ';
            }

            if(String.isNotBlank(matchToInitiate.GP_Contact__r.MailingState)){
                gpAddress                     += matchToInitiate.GP_Contact__r.MailingState;
                gpAddress                     += ', ';
            }

            if(String.isNotBlank(matchToInitiate.GP_Contact__r.MailingPostalCode)){
                gpAddress                     += matchToInitiate.GP_Contact__r.MailingPostalCode;
                gpAddress                     += ', ';
            }

            if(String.isNotBlank(matchToInitiate.GP_Contact__r.MailingCountry)){
                gpAddress                     += matchToInitiate.GP_Contact__r.MailingCountry;
            }else{
                gpAddress                     += 'USA';
            }

            url = 'https://internalsynergyspecialists.secure.force.com/match?matchId='+matchToInitiate.Id+'&type=sp';

            List<Opportunity> opptyLst = [SELECT Id,Name from Opportunity
                                                        where GP_Contact__c =: matchToInitiate.GP_Contact__c
                                                                and
                                                              Primary_Contact__c =: matchToInitiate.SP_Contact__c ];

            if( opptyLst != null && !opptyLst.isEmpty() ){
                opportunityId = opptyLst [0].Id;
                redirectURL   = 'https://internalsynergyspecialists.secure.force.com/schedule?opportunityId='+opportunityId;
            }
        }
    }

}