/**
 * Created by abidap on 12/27/18.
 */

public with sharing class CustomLeadConvertController {


    public class LeadConvertException extends Exception{}

    /*
    * @Description : This is the convert lead button which will be called from the Custom Convert button
    *               STEP 1 : Lead Record Type : GP
    *                       1.a Create a Account and Contact
    *               STEP 2 : Lead Record Type : SP
    *                       1.a Create a Account and Contact
    *                               If SP has entity associated with it , we will create Account with that Name
    *                               Else we will stamp it with Lead First Name and LAst Name
    */
    @AuraEnabled
    public static LeadConvertWrapper convertLead( Id leadId ){

        LeadConvertWrapper resultWrapper;
        //system.debug(resultWrapper.accountObject);
        List<Lead> leadLst = [Select id,name,RecordType.DeveloperName,Entity__c,Entity_Legal_Name__c,SPSPECIALTY__c,Distance_Ready_To_Travel__c,Type_of_Specialists_they_want__c,Street,City,State,PostalCode,Status from Lead where id =: leadId ];
        String validationResult = validateFields(leadLst[0]);
        if(validationResult != null){
            resultWrapper = new LeadConvertWrapper();
            resultWrapper.validationErrorString = validationResult;
            return resultWrapper;
        }
        if(leadLst != null && !leadLst.isEmpty()){
            Lead leadSobject = leadLst[0];

            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadSobject.id);

            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Boolean isGPFlow = 'Dental_Host_Office_HO_GP'.equalsIgnoreCase(leadSobject.RecordType.DeveloperName);
            Boolean isSPFlow = 'SP_Specialists'.equalsIgnoreCase(leadSobject.RecordType.DeveloperName);
            Boolean isVCFlow = 'Vendor_Consultant'.equalsIgnoreCase(leadSobject.RecordType.DeveloperName);
            //lc.setDoNotCreateOpportunity(( isGPFlow )? true : false); // @Modified By AB to align with new changes in Req
            lc.setDoNotCreateOpportunity( true );
            Database.LeadConvertResult lcr = Database.convertLead(lc);

            if(lcr.isSuccess()){
                resultWrapper = new LeadConvertWrapper();

                Account acctObj    = [Select id,name from Account where Id =: lcr.getAccountId() Limit 1];
                resultWrapper.accountObject = acctObj;

                Contact contactObj = [Select id,name,Email from Contact where Id =: lcr.getContactId() Limit 1];
                resultWrapper.contactObject = contactObj;


                if(isGPFlow){
                    acctObj.RecordTypeId = Utility.getsObjectRecordTypeId(Account.SObjectType,'Practice');
                }else if(isSPFlow){
                    acctObj.RecordTypeId = Utility.getsObjectRecordTypeId(Account.SObjectType,'Provider');
                }else if(isVCFlow){
                    acctObj.RecordTypeId = Utility.getsObjectRecordTypeId(Account.SObjectType,'Vendor');
                }

                if(!isGPFlow){
                    if(leadSobject.Entity__c){
                        acctObj.Name = leadSobject.Name;
                    }
                }

                update acctObj;

                contactObj.Contact_Type__c = ( isGPFlow ) ? 'GP Contact' : 'SP Contact';
                if(isGPFlow){
                    contactObj.RecordTypeId = Utility.getsObjectRecordTypeId(Contact.SObjectType,'Practice');
                }else if(isSPFlow){
                    contactObj.RecordTypeId =  Utility.getsObjectRecordTypeId(Contact.SObjectType,'Provider');
                }else if(isVCFlow){
                    contactObj.RecordTypeId =  Utility.getsObjectRecordTypeId(Contact.SObjectType,'Vendor / Consultant');
                }

                update contactObj;

                if(!isVCFlow)
                calculateProspectMatches( contactObj.Id , contactObj.Contact_Type__c , null );

                /*if(lcr.getOpportunityId() != null){

                    Opportunity opptyObj = [Select id,name from Opportunity where Id =: lcr.getOpportunityId() Limit 1];
                    opptyObj.Primary_Contact__c = contactObj.Id;
                    update opptyObj;
                    resultWrapper.opportunityObject = opptyObj;
                }*/

            }else{
                String errorMsg = '';
                for(Database.Error error : lcr.getErrors()){
                    errorMsg += (error.getFields()+':'+error.getMessage());
                }

                throw new LeadConvertException(errorMsg);
            }
        }

        return resultWrapper;
    }

    private static String validateFields( Lead leadObj ){

        List<FieldWrapper> spfieldWrapperLst = new List<FieldWrapper>();
        spfieldWrapperLst.add(new FieldWrapper('SPSPECIALTY__c','Specialty - Primary'));
        spfieldWrapperLst.add(new FieldWrapper('Distance_Ready_To_Travel__c','Distance Provider Willing to Travel'));
        //spfieldWrapperLst.add(new FieldWrapper('Street','Address'));
        spfieldWrapperLst.add(new FieldWrapper('City','Address'));
        spfieldWrapperLst.add(new FieldWrapper('State','Address'));
        spfieldWrapperLst.add(new FieldWrapper('PostalCode','Address'));

        List<FieldWrapper> gpfieldWrapperLst = new List<FieldWrapper>();
       // gpfieldWrapperLst.add(new FieldWrapper('Type_of_Specialists_they_want__c','Type of specialists Practice wants ?'));
       // gpfieldWrapperLst.add(new FieldWrapper('Street','Address'));
        gpfieldWrapperLst.add(new FieldWrapper('City','Address'));
        gpfieldWrapperLst.add(new FieldWrapper('State','Address'));
        gpfieldWrapperLst.add(new FieldWrapper('PostalCode','Address'));

        Boolean isGPFlow = 'Dental_Host_Office_HO_GP'.equalsIgnoreCase(leadObj.RecordType.DeveloperName);
        Boolean isSPFlow = 'SP_Specialists'.equalsIgnoreCase(leadObj.RecordType.DeveloperName);
        Boolean isVCFlow = 'Vendor_Consultant'.equalsIgnoreCase(leadObj.RecordType.DeveloperName);
        if( isSPFlow ){
            for( FieldWrapper spFieldVar :  spfieldWrapperLst ){
                if( leadObj.get(spFieldVar.fieldAPIName) == null ){
                    return 'Validation Error : Please Fill '+spFieldVar.fieldLabel+' before converting to contact.';
                }
            }
        }else if(isGPFlow){

            for( FieldWrapper gpFieldVar :   gpfieldWrapperLst ){
                if( leadObj.get(gpFieldVar.fieldAPIName) == null ){
                    return 'Validation Error : Please Fill '+gpFieldVar.fieldLabel+' before converting to contact.';
                }
            }

        }

        if( leadObj.Status == 'Intake Sent' ){
            return 'You can not convert with this status \'Intake Sent\'. Please follow up to get the intake or update the status to Intake Complete manually.';
        }

        return null;
    }

    public class FieldWrapper{
        public String fieldAPIName {get;set;}
        public String fieldLabel {get;set;}

        public FieldWrapper( String fieldAPINameParam , String fieldLabelParam ){
            fieldAPIName = fieldAPINameParam;
            fieldLabel   = fieldLabelParam;
        }
    }
    public class LeadConvertWrapper{
        @AuraEnabled
        public Account accountObject ;
        @AuraEnabled
        public Contact contactObject ;
        @AuraEnabled
        public Opportunity opportunityObject;
        @AuraEnabled
        public String validationErrorString;
    }
   
    public static void calculateProspectMatches( String contactId , String contactTypeStr , Integer mileRadius ){
        List<String> contactStatusesToExclude = new List <String>{ 'Matched - Off Market' , 'Unmatched - Off Market ' };
        if(!String.isBlank( contactId ) ){

            List<Contact> contactLst = [ Select Id,Name,AccountId,MailingStreet,MailingCity,MailingState,MailingPostalCode,Type_of_Specialists_GP_want__c,
                                                MailingAddress,MailingLatitude,MailingLongitude,Distance_Ready_To_Travel__c,Contact_Status__c,
                                                Account.Type_of_Specialist_Needed__c,SPSPECIALTY__c,SPSPECIALTY2__c,Contact_Type__c
                                                from Contact
                                                where Id =: contactId ];

            Set<Id> SPContactIdSet = new Set <Id>();
            Set<Id> GPContactIdSet = new Set <Id>();
            Set<Id> GPLeadIdSet = new Set <Id>();
            Set<Id> SPLeadIdSet = new Set <Id>();

            if( contactLst != null && !contactLst.isEmpty() ){

                Contact contactToSearch = contactLst[0];

                system.debug('contactToSearch :=> '+contactToSearch);

                contactTypeStr = (contactTypeStr != null) ? contactTypeStr : contactToSearch.Contact_Type__c;

                Id recordTypeIdToSearch = ('GP Contact'.equalsIgnoreCase(contactTypeStr)) ? Utility.getsObjectRecordTypeId(Contact.SObjectType,'Provider') : Utility.getsObjectRecordTypeId(Contact.SObjectType,'Practice') ;
                Id leadRecordTypeIdToSearch = ('GP Contact'.equalsIgnoreCase(contactTypeStr)) ? Utility.getsObjectRecordTypeId(Lead.SObjectType,'Provider') : Utility.getsObjectRecordTypeId(Lead.SObjectType,'Practice') ;
                system.debug('recordTypeIdToSearch :=> '+recordTypeIdToSearch);

                if('GP Contact'.equalsIgnoreCase(contactTypeStr)){
                    for(Prospect_Match__c match : [SELECT Id,Name,SP_Contact__c,SP_Lead__c,GP_Lead__c from Prospect_Match__c where GP_Contact__c =: contactId ]){
                        SPContactIdSet.add(match.SP_Contact__c);
                        SPLeadIdSet.add(match.SP_Lead__c);
                    }
                }else{
                    for(Prospect_Match__c match : [SELECT Id,Name,GP_Contact__c,SP_Lead__c,GP_Lead__c from Prospect_Match__c where SP_Contact__c =: contactId ]){
                        GPContactIdSet.add(match.GP_Contact__c);
                        GPLeadIdSet.add(match.GP_Lead__c);
                    }
                }

                if(contactToSearch.MailingLatitude != null && contactToSearch.MailingLongitude != null){

                    List<Contact> nearByContactLstFound;
                    List<Lead> nearByLeadLstFound;

                    if('GP Contact'.equalsIgnoreCase(contactTypeStr)){

                        mileRadius = (mileRadius != null) ? mileRadius : 120;
                        // This will basically search for SPs with distance < 120 default and statuses not in exclude list
                        nearByContactLstFound  = [SELECT Id,Name,AccountId,MailingLatitude,MailingLongitude,Contact_status__c,Account.Type_of_Specialist_Needed__c,SPSPECIALTY__c,SPSPECIALTY2__c
                                                            from Contact
                                                            where
                                                            RecordTypeId =: recordTypeIdToSearch
                                                            and
                                                            DISTANCE(MailingAddress,GEOLOCATION( :contactToSearch.MailingLatitude , :contactToSearch.MailingLongitude ) ,'mi') < :mileRadius
                                                            and
                                                            Contact_status__c NOT IN : contactStatusesToExclude
                                                            ];

                        nearByLeadLstFound    = [SELECT Id,Name,Type_of_Specialists_they_want__c,SPSPECIALTY__c,SPSPECIALTY2__c,Latitude,Longitude
                                                        from Lead
                                                        where
                                                        RecordTypeId =: leadRecordTypeIdToSearch
                                                        and
                                                        DISTANCE(Address,GEOLOCATION( :contactToSearch.MailingLatitude , :contactToSearch.MailingLongitude ) ,'mi') < :mileRadius
                                                        and
                                                        isConverted = false ];


                    }else{

                        // This will basically search for GPs with distance < what SPs have defined in Distance_Ready_To_Travel__c and statuses not in exclude list

                        String SPDistanceToTravel = contactToSearch.Distance_Ready_To_Travel__c;

                        Integer higherOffset = 120;
                        if(SPDistanceToTravel != null){

                            if('Less than 10 miles'.equalsIgnoreCase(SPDistanceToTravel)){
                                higherOffset = 10;
                            }else if('Less than 20 miles'.equalsIgnoreCase(SPDistanceToTravel)){
                                higherOffset = 20;
                            }else if('Less than 30 miles'.equalsIgnoreCase(SPDistanceToTravel)){
                                higherOffset = 30;
                            }else if('Less than 40 miles'.equalsIgnoreCase(SPDistanceToTravel)){
                                higherOffset = 40;
                            }else if('Less than 50 miles'.equalsIgnoreCase(SPDistanceToTravel)){
                                higherOffset = 50;
                            }
                        }

                        higherOffset = (mileRadius != null) ? mileRadius : higherOffset;

                        nearByContactLstFound  = [SELECT Id,Name,AccountId,MailingLatitude,MailingLongitude,Contact_status__c,Account.Type_of_Specialist_Needed__c,SPSPECIALTY__c,SPSPECIALTY2__c,Type_of_Specialists_GP_want__c
                                                            from Contact
                                                            where
                                                            RecordTypeId =: recordTypeIdToSearch
                                                            and
                                                            DISTANCE(MailingAddress,GEOLOCATION( :contactToSearch.MailingLatitude , :contactToSearch.MailingLongitude ) ,'mi') < :higherOffset
                                                            and
                                                            Contact_status__c NOT IN : contactStatusesToExclude
                                                            ];

                        nearByLeadLstFound    = [SELECT Id,Name,Type_of_Specialists_they_want__c,SPSPECIALTY__c,SPSPECIALTY2__c,Latitude,Longitude
                                                        from Lead
                                                        where
                                                        RecordTypeId =: leadRecordTypeIdToSearch
                                                        and
                                                        DISTANCE(Address,GEOLOCATION( :contactToSearch.MailingLatitude , :contactToSearch.MailingLongitude ) ,'mi') < :higherOffset
                                                        and
                                                        isConverted = false ];

                    }

                    system.debug('nearByContactLstFound =>'+nearByContactLstFound);
                    system.debug('nearByLeadLstFound =>'+nearByLeadLstFound);
                    List<Prospect_Match__c> prospectMatches = new List<Prospect_Match__c>();

                    for(Contact contact : nearByContactLstFound){
                        if('GP Contact'.equalsIgnoreCase(contactTypeStr)){
                            if(!SPContactIdSet.contains(contact.Id)){
                                if(contactToSearch.MailingLatitude != null && contactToSearch.MailingLatitude != null && contact.MailingLatitude != null && contact.MailingLongitude != null ){

                                    if(
                                            (
                                                contactToSearch.Type_of_Specialists_GP_want__c != null &&
                                                    (
                                                        (contact.SPSPECIALTY__c != null && String.valueOf(contactToSearch.Type_of_Specialists_GP_want__c).containsIgnoreCase(contact.SPSPECIALTY__c))
                                                            ||
                                                        (contact.SPSPECIALTY2__c != null && String.valueOf(contactToSearch.Type_of_Specialists_GP_want__c).containsIgnoreCase(contact.SPSPECIALTY2__c))
                                                    )

                                            )
                                    ){
                                        Location locationToSearch = Location.newInstance(contactToSearch.MailingLatitude, contactToSearch.MailingLongitude);
                                        Location contactLocation  = Location.newInstance(contact.MailingLatitude, contact.MailingLongitude); 

                                        prospectMatches.add(new Prospect_Match__c ( Match_Type__c = 'Contact', SP_Account__c = contact.AccountId , SP_Contact__c = contact.Id ,
                                                                                    GP_Account__c = (contactToSearch.AccountId != null) ? contactToSearch.AccountId : System.Label.Default_Account , Is_SP_Contract_Signed__c = 'Contract Signed'.equalsIgnoreCase(contact.Contact_status__c) ,
                                                                                    GP_Contact__c = contactToSearch.Id , Approximate_Distance__c = Location.getDistance(locationToSearch,contactLocation,'mi')));
                                    }

                                }

                            }
                        }else{
                            if(!GPContactIdSet.contains(contact.Id)) {
                                if(contactToSearch.MailingLatitude != null && contactToSearch.MailingLatitude != null && contact.MailingLatitude != null && contact.MailingLongitude != null ) {

                                    if(
                                            

                                            (
                                                    contact.Type_of_Specialists_GP_want__c != null
                                                            &&
                                                            ( (contactToSearch.SPSPECIALTY__c != null && String.valueOf(contact.Type_of_Specialists_GP_want__c).containsIgnoreCase(contactToSearch.SPSPECIALTY__c))
                                                                    || ( contactToSearch.SPSPECIALTY2__c != null && String.valueOf(contact.Type_of_Specialists_GP_want__c).containsIgnoreCase(contactToSearch.SPSPECIALTY2__c) )
                                                            )

                                            )

                                    ){

                                        Location locationToSearch = Location.newInstance(contactToSearch.MailingLatitude, contactToSearch.MailingLongitude);
                                        Location contactLocation = Location.newInstance(contact.MailingLatitude, contact.MailingLongitude);
                                        prospectMatches.add(new Prospect_Match__c ( Match_Type__c = 'Contact', GP_Account__c = (contact.AccountId != null) ? contact.AccountId : System.Label.Default_Account, GP_Contact__c = contact.Id, SP_Account__c = contactToSearch.AccountId, SP_Contact__c = contactToSearch.Id , Approximate_Distance__c = Location.getDistance(locationToSearch,contactLocation,'mi') ));

                                    }
                                }
                            }
                        }
                    }

                    for(Lead leadObj : nearByLeadLstFound){
                        if('GP Contact'.equalsIgnoreCase(contactTypeStr)){
                            if(!SPLeadIdSet.contains(leadObj.Id)){
                                system.debug('Inside if 1');
                                if(contactToSearch.MailingLatitude != null && contactToSearch.MailingLatitude != null && leadObj.Latitude != null && leadObj.Longitude != null ){

                                    if(contactToSearch.Type_of_Specialists_GP_want__c != null &&
                                            ( (leadObj.SPSPECIALTY__c != null && String.valueOf(contactToSearch.Type_of_Specialists_GP_want__c).containsIgnoreCase(leadObj.SPSPECIALTY__c))
                                                    || (leadObj.SPSPECIALTY2__c != null && String.valueOf(contactToSearch.Type_of_Specialists_GP_want__c).containsIgnoreCase(leadObj.SPSPECIALTY2__c))
                                            )
                                            ){
                                        Location locationToSearch = Location.newInstance(contactToSearch.MailingLatitude, contactToSearch.MailingLongitude);
                                        Location contactLocation  = Location.newInstance(leadObj.Latitude, leadObj.Longitude);

                                        prospectMatches.add(new Prospect_Match__c ( Match_Type__c = 'Lead', SP_Lead__c = leadObj.Id , SP_Contact__c = System.Label.Default_Contact , GP_Account__c = System.Label.Default_Account , GP_Contact__c = contactToSearch.Id , Approximate_Distance__c = Location.getDistance(locationToSearch,contactLocation,'mi')));
                                    }

                                }

                            }
                        }else{
                            if(!GPLeadIdSet.contains(leadObj.Id)) {
                                system.debug('Inside if 2');
                                if(contactToSearch.MailingLatitude != null && contactToSearch.MailingLatitude != null && contact.MailingLatitude != null && contact.MailingLongitude != null ) {

                                    if(leadObj.Type_of_Specialists_they_want__c != null &&
                                            ( (contactToSearch.SPSPECIALTY__c != null && String.valueOf(leadObj.Type_of_Specialists_they_want__c).containsIgnoreCase(contactToSearch.SPSPECIALTY__c))
                                                    || ( contactToSearch.SPSPECIALTY2__c != null && String.valueOf(leadObj.Type_of_Specialists_they_want__c).containsIgnoreCase(contactToSearch.SPSPECIALTY2__c) )
                                            )
                                            ){

                                        Location locationToSearch = Location.newInstance(contactToSearch.MailingLatitude, contactToSearch.MailingLongitude);
                                        Location contactLocation = Location.newInstance(leadObj.Latitude, leadObj.Longitude);
                                        prospectMatches.add(new Prospect_Match__c ( Match_Type__c = 'Lead', GP_Account__c = System.Label.Default_Account , GP_Lead__c = leadObj.Id, SP_Contact__c = contactToSearch.Id , Approximate_Distance__c = Location.getDistance(locationToSearch,contactLocation,'mi') ));

                                    }
                                }

                            }
                        }
                    }

                    system.debug('prospectMatches ==>'+prospectMatches);

                    if(!prospectMatches.isEmpty()){
                        insert prospectMatches;
                    }
                }

            }
        }


    }

    //Ankita A: 12 Feb 2020: Added method to find Prospect Matches for Lead
    public static void calculateProspectMatchesForLead(List<Id> leadIds, Integer mileRadius){

        //Find existing SP Contact for GP Leads and GP Contact for SP Leads
        List<Lead> leadLst = [SELECT Id, Name, RecordType.Name, RecordTypeId, Street, City, State, PostalCode, Address, Latitude, Longitude,
                                Distance_Ready_To_Travel__c, Status, Type_of_Specialists_they_want__c, 
                                SPSPECIALTY__c, SPSPECIALTY2__c
                                FROM Lead WHERE Id IN: leadIds];
        List<Id> gpLeads = new List<Id>();
        List<Id> spLeads = new List<Id>();
        List<Prospect_Match__c> prospectMatches = new List<Prospect_Match__c>();

        for(Lead leadObject : leadLst){
            String leadTypeStr = leadObject.RecordType.Name.equalsIgnoreCase('Practice') ? 'GP Lead' : 'SP Lead';
            if(leadTypeStr.equalsIgnoreCase('GP Lead')){
                gpLeads.add(leadObject.Id);
            } else {
                spLeads.add(leadObject.Id);
            }
        }

        //Create mapping of GP Lead with List of SP Contact
        Map<Id, List<Id>> mapGpLeadWithSPContacts = new Map<Id, List<Id>>();
        for(Prospect_Match__c match : [SELECT Id, Name, SP_Contact__c, SP_Lead__c, GP_Lead__c from Prospect_Match__c where GP_Lead__c IN: gpLeads]){
            if(mapGpLeadWithSPContacts.containsKey(match.GP_Lead__c)){
                List<Id> spContactIds = mapGpLeadWithSPContacts.get(match.GP_Lead__c);
                spContactIds.add(match.SP_Contact__c);
                mapGpLeadWithSPContacts.put(match.GP_Lead__c, spContactIds);
            } else {
                mapGpLeadWithSPContacts.put(match.GP_Lead__c, new List<Id>{match.SP_Contact__c});
            }
        }

        //Create mapping of SP Lead with List of Gp Contacts 
        Map<Id, List<Id>> mapSpLeadWithGPContacts = new Map<Id, List<Id>>();
        for(Prospect_Match__c match : [SELECT Id,Name,GP_Contact__c,SP_Lead__c,GP_Lead__c from Prospect_Match__c where SP_Lead__c IN: spLeads]){
            if(mapSpLeadWithGPContacts.containsKey(match.SP_Lead__c)){
                List<Id> gpContactIds = mapSpLeadWithGPContacts.get(match.SP_Lead__c);
                gpContactIds.add(match.GP_Contact__c);
                mapSpLeadWithGPContacts.put(match.SP_Lead__c, gpContactIds);
            } else {
                mapSpLeadWithGPContacts.put(match.SP_Lead__c, new List<Id>{match.GP_Contact__c});
            }
        }

        for(Lead leadToSearch : leadLst){
            Set<Id> SPContactIdSet = new Set <Id>();
            Set<Id> GPContactIdSet = new Set <Id>();
            System.debug('leadToSearch :=> '+leadToSearch);
            String leadTypeStr = leadToSearch.RecordType.Name.equalsIgnoreCase('Practice') ? 'GP Lead' : 'SP Lead';
            //If lead is of type Practice, then we need to find Contact of type Provider for Prospect Match
            //If lead is of type Provider, then we need to find Contact of type Practice for Prospect Match
            Id contactRecordTypeIdToSearch = (leadTypeStr.equalsIgnoreCase('GP Lead')) ? 
                                            Utility.getsObjectRecordTypeId(Contact.SObjectType,'Provider') : 
                                            Utility.getsObjectRecordTypeId(Contact.SObjectType,'Practice') ;
            System.debug('contactRecordTypeIdToSearch :=> '+contactRecordTypeIdToSearch);

            //Find existing Prospect matches for the given leadId
            if(leadTypeStr.equalsIgnoreCase('GP Lead') && mapGpLeadWithSPContacts.containsKey(leadToSearch.Id)){
                SPContactIdSet.addAll(mapGpLeadWithSPContacts.get(leadToSearch.Id));
                
            } else if(leadTypeStr.equalsIgnoreCase('SP Lead') && mapSpLeadWithGPContacts.containsKey(leadToSearch.Id)){
                GPContactIdSet.addAll(mapSpLeadWithGPContacts.get(leadToSearch.Id));
            }

            if(leadToSearch.Latitude != null && leadToSearch.Longitude != null){
                List<Contact> nearByContactLstFound = new List<Contact>();

                if(leadTypeStr.equalsIgnoreCase('GP Lead')){
                    mileRadius = (mileRadius != null) ? mileRadius : 120;
                    // This will basically search for SPs with distance < 120 default
                    nearByContactLstFound  = [SELECT Id, Name, AccountId, MailingLatitude, MailingLongitude, Contact_status__c, Account.Type_of_Specialist_Needed__c,SPSPECIALTY__c,SPSPECIALTY2__c
                                                        from Contact
                                                        where
                                                        RecordTypeId =: contactRecordTypeIdToSearch
                                                        and
                                                        DISTANCE(MailingAddress,GEOLOCATION( :leadToSearch.Latitude , :leadToSearch.Longitude ) ,'mi') < :mileRadius
                                                        ]; //Not used the condition Contact_status__c NOT IN : contactStatusesToExclude
                } else {
                    // This will basically search for GPs with distance < what SPs have defined in 
                    //Distance_Ready_To_Travel__c

                    String SPDistanceToTravel = leadToSearch.Distance_Ready_To_Travel__c;

                    Integer higherOffset = 120;
                    if(SPDistanceToTravel != null){

                        if('Less than 10 miles'.equalsIgnoreCase(SPDistanceToTravel)){
                            higherOffset = 10;
                        }else if('Less than 20 miles'.equalsIgnoreCase(SPDistanceToTravel)){
                            higherOffset = 20;
                        }else if('Less than 30 miles'.equalsIgnoreCase(SPDistanceToTravel)){
                            higherOffset = 30;
                        }else if('Less than 40 miles'.equalsIgnoreCase(SPDistanceToTravel)){
                            higherOffset = 40;
                        }else if('Less than 50 miles'.equalsIgnoreCase(SPDistanceToTravel)){
                            higherOffset = 50;
                        }
                    }

                    higherOffset = (mileRadius != null) ? mileRadius : higherOffset;
                    
                    nearByContactLstFound  = [SELECT Id,Name,AccountId,MailingLatitude,MailingLongitude,Contact_status__c,Account.Type_of_Specialist_Needed__c,SPSPECIALTY__c,SPSPECIALTY2__c,Type_of_Specialists_GP_want__c
                                                        from Contact
                                                        where
                                                        RecordTypeId =: contactRecordTypeIdToSearch
                                                        and
                                                        DISTANCE(MailingAddress,GEOLOCATION( :leadToSearch.Latitude , :leadToSearch.Longitude ) ,'mi') < :higherOffset
                                                        ]; //Not used the condition Contact_status__c NOT IN : contactStatusesToExclude
                                                        System.debug('nearByContactLstFound =>'+nearByContactLstFound);
                }
                System.debug('nearByContactLstFound =>'+nearByContactLstFound);

                for(Contact contact : nearByContactLstFound){
                    if(leadTypeStr.equalsIgnoreCase('GP Lead') ){
                        if(!SPContactIdSet.contains(contact.Id)){
                            if(leadToSearch.Latitude != null && leadToSearch.Longitude != null && contact.MailingLatitude != null && contact.MailingLongitude != null ){

                                if(String.isNotBlank(leadToSearch.Type_of_Specialists_they_want__c) &&
                                    (
                                        (contact.SPSPECIALTY__c != null && String.valueOf(leadToSearch.Type_of_Specialists_they_want__c).containsIgnoreCase(contact.SPSPECIALTY__c))
                                            ||
                                        (contact.SPSPECIALTY2__c != null && String.valueOf(leadToSearch.Type_of_Specialists_they_want__c).containsIgnoreCase(contact.SPSPECIALTY2__c))
                                    )

                                ){
                                    Location locationToSearch = Location.newInstance(leadToSearch.Latitude, leadToSearch.Longitude);
                                    Location contactLocation  = Location.newInstance(contact.MailingLatitude, contact.MailingLongitude); 

                                    prospectMatches.add(new Prospect_Match__c ( 
                                            Match_Type__c = 'Lead', 
                                            SP_Contact__c = contact.Id,
                                            SP_Account__c = contact.AccountId, 
                                            GP_Account__c = System.Label.Default_Account,
                                            GP_Lead__c = leadToSearch.Id, 
                                            Approximate_Distance__c = Location.getDistance(locationToSearch,contactLocation,'mi')
                                            ));
                                }

                            }
                        }

                    }else {
                        if(!GPContactIdSet.contains(contact.Id)) {
                            if(leadToSearch.Latitude != null && leadToSearch.Longitude != null && contact.MailingLatitude != null && contact.MailingLongitude != null ){

                                if(
                                    (
                                            contact.Type_of_Specialists_GP_want__c != null
                                                    &&
                                                    ( (leadToSearch.SPSPECIALTY__c != null && String.valueOf(contact.Type_of_Specialists_GP_want__c).containsIgnoreCase(leadToSearch.SPSPECIALTY__c))
                                                            || ( leadToSearch.SPSPECIALTY2__c != null && String.valueOf(contact.Type_of_Specialists_GP_want__c).containsIgnoreCase(leadToSearch.SPSPECIALTY2__c) )
                                                    )

                                    )

                                ){

                                    Location locationToSearch = Location.newInstance(leadToSearch.Latitude, leadToSearch.Longitude);
                                    Location contactLocation = Location.newInstance(contact.MailingLatitude, contact.MailingLongitude);
                                    prospectMatches.add(new Prospect_Match__c ( 
                                        Match_Type__c = 'Contact', 
                                        GP_Account__c = (contact.AccountId != null) ? contact.AccountId : System.Label.Default_Account, 
                                        GP_Contact__c = contact.Id, 
                                        SP_Lead__c = leadToSearch.Id , 
                                        SP_Contact__c = System.Label.Default_Contact,
                                        Approximate_Distance__c = Location.getDistance(locationToSearch,contactLocation,'mi') ));

                                }
                            }
                        }
                    }
                }
            }
        }

        system.debug('prospectMatches ==>'+prospectMatches);
        insert prospectMatches;
    }

    @AuraEnabled
    public static void updateAddressOnLead( String addressListJSON, String leadId ){
        List<AddressWrapper> addressLst = (List<AddressWrapper>) JSON.deserialize(addressListJSON,List<AddressWrapper>.class);

        if(!String.isBlank(leadId)){

            List<Lead> leadLst = [Select id,Name,Street,City,State,PostalCode,Latitude,Longitude,SP_Entity_State__c,SP_Entity_Street__c,SP_Entity_Zip__c,SP_Entity_City__c,SP_Practise_Address__c from Lead where id =: leadId ];

            if(leadLst != null && !leadLst.isEmpty()){
                for(AddressWrapper addressWrapperInst : addressLst){
                    if('Home Address'.equalsIgnoreCase(addressWrapperInst.addressType) || 'Address'.equalsIgnoreCase(addressWrapperInst.addressType) ){
                        leadLst[0].Street = addressWrapperInst.street;
                        leadLst[0].State  = addressWrapperInst.state;
                        leadLst[0].City   = addressWrapperInst.city;
                        leadLst[0].PostalCode = addressWrapperInst.zip;
                        leadLst[0].latitude = Double.valueOf(addressWrapperInst.latVal);
                        leadLst[0].longitude = Double.valueOf(addressWrapperInst.longVal);
                    }else if('Entity Address'.equalsIgnoreCase(addressWrapperInst.addressType)){

                        leadLst[0].SP_Entity_Street__c = addressWrapperInst.street;
                        leadLst[0].SP_Entity_State__c  = addressWrapperInst.state;
                        leadLst[0].SP_Entity_City__c   = addressWrapperInst.city;
                        leadLst[0].SP_Entity_Zip__c = addressWrapperInst.zip;

                    }else if('Practice Address'.equalsIgnoreCase(addressWrapperInst.addressType)){

                        leadLst[0].SP_Practise_Address__c = addressWrapperInst.fullAddress;
                    }else if('Non Compete Address'.equalsIgnoreCase(addressWrapperInst.addressType)){

                        leadLst[0].Non_Compete_Zip__c = addressWrapperInst.fullAddress;
                    }
                }

                update leadLst;
            }
        }
    }

    @AuraEnabled
    public static Lead loadLeadData( String leadId){

        return [Select Id,Name,RecordType.Name from Lead where Id =: leadId Limit 1 ];
    }

    @AuraEnabled
    public static String initiateEmailInvocation( String recordIdString , String specialtiesSelected ){

        system.debug('recordIdString =>'+recordIdString);

        if( !String.isBlank( recordIdString ) ){

            List <Lead> LeadLst = [SELECT Id,name,RecordType.DeveloperName,Email from Lead where Status = 'Initial' AND Id =: recordIdString ];

            if( LeadLst == null || LeadLst.size() == 0 ) {
                return null;
            }else{

                LeadLst[0].Status = 'Intake Sent';
                leadLst[0].Specialties_sent_for_intake__c = specialtiesSelected;
				update LeadLst;
                String emailTemplateToFetch = '';

                if ( LeadLst[0].RecordType.DeveloperName == 'Dental_Host_Office_HO_GP') {
                    emailTemplateToFetch = 'GP_About_us_2';
                }else if ( LeadLst[0].RecordType.DeveloperName == 'SP_Specialists'){
                    emailTemplateToFetch = 'Initiate_Match_SP_Email';
                }

                Messaging.SingleEmailMessage messageToGetBody = Messaging.renderStoredEmailTemplate([select id from EmailTemplate where DeveloperName=:emailTemplateToFetch].id, LeadLst[0].Id, LeadLst[0].Id);

                // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
                // contents to a new SingleEmailMessage. Then send those new messages.
                List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();

                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setHTMLBody(messageToGetBody.getHTMLBody());
                    emailToSend.setTargetObjectId(LeadLst[0].id);
                    emailToSend.setSubject(messageToGetBody.getSubject());
                    emailToSend.setCcAddresses(System.Label.Email_Cust_CC_Address.split(','));
                    OrgWideEmailAddress  owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='hello@synergyspecialists.co'];
                    emailToSend.setOrgWideEmailAddressId(owea.Id);
                    lstMsgsToSend.add(emailToSend);

                Messaging.sendEmail(lstMsgsToSend);





                return 'SUCCESS';
            }
        }

        return null;
    }

    public class AddressWrapper{
        public String street;
        public String city;
        public String zip;
        public String state;
        public String addressType;
        public String latVal;
        public String longVal;
        public String fullAddress;
    }
    
  
}