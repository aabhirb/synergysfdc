/**
* @author abhishek
* @date 2019-09-20
*
* @description : .
*/
public with sharing class ContentVersionTriggerHandler {

    public static void createPublicURLandPassword(List<ContentVersion> newContentVersions, Map<Id,ContentVersion> oldContentVersionMap) {
        Set<Id> versionIdSet = new Set<Id>();

        for( ContentVersion version : newContentVersions ) {
            if( isApproved(version, oldContentVersionMap.get(version.Id) ) ) {
                versionIdSet.add(version.Id);
            }
        }

        insertContentDistribution(versionIdSet);
    }

    @future(callout=true)
    public static void insertContentDistribution( Set<Id> versionIdSet ) {

        List<ContentDistribution> distributionLst = new List<ContentDistribution>();
        ContentDistribution distribution ;
        //Updating logic to set password value only for Production report 
        for( ContentVersion version : [SELECT Id, Content_Type__c FROM ContentVersion WHERE Id IN: versionIdSet]) {
            distribution = new ContentDistribution();
            distribution.ContentVersionId = version.Id;
            distribution.PreferencesAllowOriginalDownload = distribution.PreferencesAllowViewInBrowser
                                                          = distribution.PreferencesLinkLatestVersion
                                                          = distribution.PreferencesNotifyOnVisit = true;
            //Ankita A: 19 Jan 2020 Set the Password required as false as we don't want to create Pwd
            distribution.PreferencesPasswordRequired = false;
            distribution.Name = 'Document';
            distributionLst.add(distribution);
        }

        insert distributionLst;

        System.debug('distributionLst inserted ');
        System.debug('versionIdSet => '+versionIdSet);

        Map<Id,ContentVersion> contentVersionMap = new Map<Id,ContentVersion> ( [
                                                                                    SELECT
                                                                                    Id,ContentDocumentId,Content_Type__c
                                                                                    FROM ContentVersion
                                                                                    WHERE
                                                                                    Id IN: versionIdSet
                                                                                    AND Is_Approved__c = TRUE
                                                                                ] );

        System.debug('contentVersionMap '+contentVersionMap);

        Map<Id,ContentDistribution> versionIdToDistributionMap = new Map<Id,ContentDistribution>();
        for( ContentDistribution distributionVar : [
                                                    SELECT
                                                    Id,ContentVersionId,DistributionPublicUrl,
                                                    Password,PreferencesPasswordRequired
                                                    FROM ContentDistribution
                                                    WHERE ContentVersionId IN: versionIdSet
                                                ]) {
            versionIdToDistributionMap.put(distributionVar.ContentVersionId,distributionVar);
        }

        System.debug('versionIdToDistributionMap '+versionIdToDistributionMap);

        Map<Id,Id> documentIdToVersionIdMap = new Map<Id,Id>();

        for( ContentVersion version : contentVersionMap.values() ) {
            documentIdToVersionIdMap.put(version.ContentDocumentId,version.Id);
        }

        System.debug('documentIdToVersionIdMap '+documentIdToVersionIdMap);

        Map<Id,Id> invoiceIdToContentDocumentId = new Map<Id,Id>();

        for( ContentDocument document : [
                                            SELECT Id,
                                            (   SELECT
                                                Id,LinkedEntityId
                                                FROM ContentDocumentLinks
                                            )
                                            FROM ContentDocument
                                            WHERE
                                            Id IN:documentIdToVersionIdMap.keySet()
                                        ]) {

            System.debug('document.ContentDocumentLinks =>'+document.ContentDocumentLinks);

            if(!document.ContentDocumentLinks.isEmpty()) {
                System.debug('document.ContentDocumentLinks =>'+document.ContentDocumentLinks);
                for(ContentDocumentLink link : document.ContentDocumentLinks) {

                    invoiceIdToContentDocumentId.put(link.LinkedEntityId,document.Id);
                }
            }
        }

        System.debug('invoiceIdToContentDocumentId '+invoiceIdToContentDocumentId);

        Map<Id,Opportunity_Line_Item__c> invoiceMap = new Map<Id,Opportunity_Line_Item__c> (
                                                                                            [
                                                                                                SELECT
                                                                                                Id
                                                                                                FROM Opportunity_Line_Item__c
                                                                                                WHERE
                                                                                                Id IN: invoiceIdToContentDocumentId.keySet()
                                                                                            ]
                                                                                            );

        System.debug('invoiceMap =>'+invoiceMap);

        List<Opportunity_Line_Item__c> invoiceLstToUpdate = new List<Opportunity_Line_Item__c>();

        for(Id invoiceId : invoiceMap.keySet()) {
            Opportunity_Line_Item__c invoiceToUpdate = invoiceMap.get(invoiceId);
            System.debug('invoiceToUpdate =>'+invoiceToUpdate);
            Id versionId = documentIdToVersionIdMap.get(invoiceIdToContentDocumentId.get(invoiceId));
            ContentVersion version = contentVersionMap.get(versionId);
            System.debug('version =>'+version);
            if(version.Content_Type__c == 'Invoice') {
                invoiceToUpdate.Invoice_PDF_URL__c = versionIdToDistributionMap.get(version.Id).DistributionPublicUrl;
                //Ankita A: We don't need password
                //invoiceToUpdate.Invoice_PDF_Password__c = versionIdToDistributionMap.get(version.Id).Password;
                invoiceLstToUpdate.add(invoiceToUpdate);
            }else if(version.Content_Type__c == 'Production Report') {
                invoiceToUpdate.Production_Report_PDF_URL__c = versionIdToDistributionMap.get(version.Id).DistributionPublicUrl;
                //Ankita A: 19 Jan 2020 We don't need password
                //invoiceToUpdate.Production_Report_PDF_Password__c = versionIdToDistributionMap.get(version.Id).Password;
                invoiceLstToUpdate.add(invoiceToUpdate);
            }else if(version.Content_Type__c == 'Expense Report') {
                invoiceToUpdate.Expense_Report_PDF__c = versionIdToDistributionMap.get(version.Id).DistributionPublicUrl;
                //Ankita A: We don't need password
                //invoiceToUpdate.Expense_Report_PDF_Password__c = versionIdToDistributionMap.get(version.Id).Password;
                invoiceLstToUpdate.add(invoiceToUpdate);
            }
        }

        System.debug('invoiceLstToUpdate =>'+invoiceLstToUpdate);

        if(!invoiceLstToUpdate.isEmpty()) {
            update invoiceLstToUpdate;
        }


    }

    private static Boolean isApproved(ContentVersion newContentVersion, ContentVersion oldContentVersion) {
        return ( newContentVersion.is_Approved__c != oldContentVersion.is_Approved__c
                    && newContentVersion.is_Approved__c );
    }
    
    //Ankita A: 25 Nov: Provider Onboarding Email changes
    public static void createPublicUrl(List<ContentVersion> newContentVersions){
        Set<Id> versionIdSet = new Set<Id>();
        for(ContentVersion version: newContentVersions){
            //If the content type is valid
            if(isValidContentType(version)){
                versionIdSet.add(version.Id);
            }
        }
        
        updateContactLinks(versionIdSet);
    }
    
    @future(callout = true)
    public static void updateContactLinks(Set<Id> versionIdSet){
        //Create distribution list for every ContentVersion
        List<ContentDistribution> distributionLst = new List<ContentDistribution>();
        for( Id versionId : versionIdSet ) {
            ContentDistribution distribution = new ContentDistribution();
            distribution.ContentVersionId = versionId;
            distribution.PreferencesAllowOriginalDownload = distribution.PreferencesAllowViewInBrowser
                                                          = distribution.PreferencesLinkLatestVersion
                                                          = distribution.PreferencesNotifyOnVisit = true;
            distribution.Name = 'Document';
            distributionLst.add(distribution);
        }
        insert distributionLst;
        Map<Id,ContentVersion> contentVersionMap = new Map<Id,ContentVersion> ([
                                                                                    SELECT
                                                                                    Id, ContentDocumentId, Content_Type__c
                                                                                    FROM ContentVersion
                                                                                    WHERE
                                                                                    Id IN: versionIdSet
                                                                                ] );
        
        //Create a Map of Version Id with Content Distribution public ur;
        Map<Id,String> versionIdToUrlMap = new Map<Id,String>();
        for( ContentDistribution distributionVar : [SELECT Id, ContentVersionId, DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId IN: versionIdSet]) {
            versionIdToUrlMap.put(distributionVar.ContentVersionId, distributionVar.DistributionPublicUrl);
        }
        System.debug('versionIdToUrlMap '+versionIdToUrlMap);
        //Create a Map of document Id with it's Content Version Id
        Map<Id,Id> documentIdToVersionIdMap = new Map<Id,Id>();
        for( ContentVersion version : contentVersionMap.values() ) {
            documentIdToVersionIdMap.put(version.ContentDocumentId, version.Id);
        }
        System.debug('documentIdToVersionIdMap '+documentIdToVersionIdMap);
        //Create a map of Contact Id's with list of Content Documents
        Map<Id,List<Id>> contactIdToContentDocumentsId = new Map<Id,List<Id>>();
        Set<Id> setContentDocumentId = documentIdToVersionIdMap.keySet();
        if(setContentDocumentId.size() > 0){
            for(ContentDocumentLink cde : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink
                                           WHERE ContentDocumentId IN: setContentDocumentId]){
        //If the map already contains the LinkedEntityId
        //Get the object Name from LinkedEntityId
        String objectName;
        if(contactIdToContentDocumentsId.containsKey(cde.LinkedEntityId)){
                  List<Id> contentDocumentIds = contactIdToContentDocumentsId.get(cde.LinkedEntityId);
                  contentDocumentIds.add(cde.ContentDocumentId);
                  contactIdToContentDocumentsId.put(cde.LinkedEntityId, contentDocumentIds);
              } else {
          contactIdToContentDocumentsId.put(cde.LinkedEntityId, new List<Id>{cde.ContentDocumentId});
        }
                                               
      }
      }
        //Contact Map
        Map<Id,Contact> contactMap = new Map<Id,Contact> ([SELECT Id FROM Contact WHERE Id IN: contactIdToContentDocumentsId.keySet()]);
                                                                                               
        List<Contact> contactLstToUpdate = new List<Contact>();
        for(Id contactId : contactMap.keySet()) {
            Contact contactToUpdate = contactMap.get(contactId);
            System.debug('contactToUpdate =>'+contactToUpdate);
            for(Id cde : contactIdToContentDocumentsId.get(contactId)){
                Id versionId = documentIdToVersionIdMap.get(cde);            
                ContentVersion version = contentVersionMap.get(versionId);
                if(version.Content_Type__c.equalsIgnoreCase('Fee Schedule')) {
                    contactToUpdate.Fee_Schedule_URL__c = versionIdToUrlMap.get(version.Id);
                }else if(version.Content_Type__c.equalsIgnoreCase('Scheduling Guidelines')) {
                    contactToUpdate.Scheduling_Guidelines_URL__c = versionIdToUrlMap.get(version.Id);
                }else if(version.Content_Type__c.equalsIgnoreCase('Questionnaire')) {
                    contactToUpdate.Questionnaire_URL__c = versionIdToUrlMap.get(version.Id);
                }
            }
            contactLstToUpdate.add(contactToUpdate);
        }
        update contactLstToUpdate;
    }
    
    
    private static Boolean isValidContentType(ContentVersion version) {
        //return true if Content type is either Fee Schedule or Scheduling guidelines or questionnaire
        return (String.isNotBlank(version.Content_Type__c) && 
            (version.Content_Type__c.equalsIgnoreCase('Fee Schedule') || 
             version.Content_Type__c.equalsIgnoreCase('Scheduling Guidelines') || 
             version.Content_Type__c.equalsIgnoreCase('Questionnaire')));
    }

}