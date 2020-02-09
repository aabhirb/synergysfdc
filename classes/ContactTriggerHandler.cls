/**
 * Created by abidap on 1/24/19.
 */

public with sharing class ContactTriggerHandler {
    static Id gpContactRecordTypeId = Utility.getsObjectRecordTypeId(Contact.SObjectType, 'Practice');
    static Id spContactRecordTypeId = Utility.getsObjectRecordTypeId(Contact.SObjectType, 'Provider');
    static List<Constant__c> constantLst;
    public static Boolean isAddressChangeInitiated = false;

    public static Map<String,String> ASARestrictiveMapping = new Map<String,String>{
            'No ASA' => 'No ASA',
            'A' => 'The State of {0} generally disapproves of restrictive covenants and will closely scrutinize such agreements. To that end, the parties agree that (1) the restrictions are not greater than necessary to protect the employer’s legitimate interest, and (2) the employer’s legitimate interest outweigh the hardship to the employee and injury to the public. The parties also intend that the following covenant is reasonable with respect to geography and timing in order to protect the employer’s legitimate business interest in protecting the intellectual property of Manager.',
            'B' => 'The State of {0} recognizes reasonable restrictive covenants, and these provisions are intended to reasonably protect the intellectual property of Administrator.'
    };

    public static void updateProspectMatch(List<Contact> contactLst , Map<Id,Contact> oldContactMap ){


        Set<Id> contactIdSet = new Set<Id> ();

        for( Contact contactObj :  contactLst ){
            if(contactObj.RecordTypeId == spContactRecordTypeId && contactObj.Contact_Status__c == 'Contract Signed'
                    && ( oldContactMap == null || oldContactMap.get( contactObj.Id ).Contact_Status__c != contactObj.Contact_Status__c )  ){
                contactIdSet.add( contactObj.Id );
            }
        }

        List <Prospect_Match__c> prospectMatchLst =  [ SELECT id,name from Prospect_Match__c where SP_Contact__c IN: contactIdSet ] ;

        for( Prospect_Match__c match : prospectMatchLst ){

            match.Is_SP_Contract_Signed__c = true;
        }

        update prospectMatchLst;

    }

    public static void onAddressChangeForContact( List<Contact> contactLst , Map<Id,Contact> oldCOntactMap ){
        List<SObject> sobjectLstToGeoCodeAndUpdate = new List<SObject>();
        for( Contact contactObj : contactLst ){

            if( isAddressChanged( contactObj , oldContactMap.get(contactObj.Id) ) ){
                sobjectLstToGeoCodeAndUpdate.add(contactObj);
            }
        }

        if( !sobjectLstToGeoCodeAndUpdate.isEmpty() ){

            GeoCodeAddressAsynch asynchInst = new GeoCodeAddressAsynch();
            asynchInst.sobjectLst = sobjectLstToGeoCodeAndUpdate;
            asynchInst.sobjectType = 'Contact';
            asynchInst.executeProspectMatchRefresh = true;
            System.enqueueJob( asynchInst );
            isAddressChangeInitiated = true;
        }

    }

    public static void geoCodeIncorrectAddress( List<Contact> contactLst ){
        List<SObject> sobjectLstToGeoCode = new List<SObject>();

        for( Contact contactObj :  contactLst ){
            if( contactObj.MailingLatitude == null && contactObj.MailingLongitude == null
                    && ( contactObj.MailingCity != null || contactObj.MailingStreet != null || contactObj.MailingState != null ) ){
                sobjectLstToGeoCode.add(contactObj);
            }
        }

        if(!sobjectLstToGeoCode.isEmpty()){
            GeoCodeAddressAsynch asynchInst = new GeoCodeAddressAsynch();
            asynchInst.sobjectLst = sobjectLstToGeoCode;
            asynchInst.sobjectType = 'Contact';
            //Ankita A: Added value as true for Boolean
            asynchInst.executeProspectMatchRefresh = true;
            System.enqueueJob( asynchInst );
        }
    }

    public static void setASAMappingValues ( List<Contact> contactLst  ){
        for( Contact contact :  contactLst ){
            if(contact.RecordTypeId == spContactRecordTypeId){
                //TODO : Make entity change here
                State_ASA_Mapping__c asaMapping = Utility.getASAMappingRecord( contact.MailingState );
                contact.Board__c = ( asaMapping != null ) ? ( asaMapping.Board__c ):'';
                String restrictiveVal = ( asaMapping != null ) ? ( asaMapping.Restrictive__c ):'';
                if( String.isNotBlank(restrictiveVal) ){
                    contact.Restrictive__c = ASARestrictiveMapping.containsKey(restrictiveVal) ? ASARestrictiveMapping.get(restrictiveVal).replace('{0}',contact.MailingState) : '';
                }
            }
        }
    }

    public static void setCompensation( List<Contact> contactLst ){
        if(constantLst == null){
            constantLst = [SELECT Id,Name,Value__c from Constant__c where Name like 'PF_%'];
        }
        if(contactLst.size() > 0){
            //Ankita A: Too many SOQL error
            //List<Constant__c> constantLst = [SELECT Id,Name,Value__c from Constant__c where Name like 'PF_%'];
            for( Contact contact :  contactLst){
                if (contact.RecordTypeId == spContactRecordTypeId){
                    for( Constant__c constValue : constantLst){
                        if(String.isNotBlank(constValue.Name) && String.isNotBlank(contact.SPSPECIALTY__c)
                                && constValue.Name.subString(3,constValue.Name.length()).containsIgnoreCase(contact.SPSPECIALTY__c)){
                            if(String.isBlank(contact.Compensation_daily__c))
                                contact.Compensation_daily__c = constValue.Value__c;
                        }
                    }
    
                    if( String.isBlank( contact.Contact_Type__c ) ) {
                        contact.Contact_Type__c = 'SP Contact';
                    }
    
                }else if (contact.RecordTypeId == gpContactRecordTypeId){
    
                    if( String.isBlank( contact.Contact_Type__c ) ) {
                        contact.Contact_Type__c = 'GP Contact';
                    }
                }
            }
        }
        
    }

    private static Boolean isAddressChanged( Contact newContact , Contact oldContact ){
        return ( newContact.MailingStreet != oldContact.MailingStreet ||
                newContact.MailingCity != oldContact.MailingCity ||
                newContact.MailingState != oldContact.MailingState ||
                newContact.MailingPostalCode != oldContact.MailingPostalCode );
    }

    public static void onOMEMailAddressChangeForContact( List<Contact> contactLst , Map<Id,Contact> oldContactMap ) {
        Map<Id,Contact> gpContactIdMap = new Map<Id,Contact>();

        for(Contact contactObj : contactLst) {
            if( contactObj.RecordTypeId == gpContactRecordTypeId &&
                    contactObj.OM_Email__c != oldContactMap.get(contactObj.Id).OM_Email__c ) {
                gpContactIdMap.put(contactObj.Id,contactObj );
            }
        }

        List<Opportunity> opptyLstToUpdate = new List<Opportunity>();

        for( Opportunity opp :  [SELECT Id,Name,OM_Email__c,GP_COntact__c from Opportunity WHERE GP_Contact__c IN: gpContactIdMap.keySet()]) {
            if(opp.OM_Email__c != gpContactIdMap.get(opp.GP_COntact__c).OM_Email__c) {
                opp.OM_Email__c = gpContactIdMap.get(opp.GP_COntact__c).OM_Email__c;
                opptyLstToUpdate.add(opp);
            }
        }

        if(!opptyLstToUpdate.isEmpty()) {
            update opptyLstToUpdate;
        }
    }
}