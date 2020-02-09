global class ProviderOnboardingEmailServiceApex implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        ApexLogger.Logger logger = ApexLogger.createLogger('ProviderEmailService '+System.now());
    
        try {
            //Ankita A: 25 Nov: For Provider onboarding Email
            //Get the custom label which contains the subject
            String onboardingEmail = System.Label.PO_Email_Subject;

            //Custom Label for Production report
            String prEmail = System.Label.PR_Email_Subject;

            String emailaddress = email.fromAddress;
            String body = email.plainTextBody;
            String subject = email.subject;
            //Ankita A: 20 Dec: Changes
            //If the email is not from synergyspecialists.co (not an internal email)
            String internalEmailId = 'synergyspecialists.co';
            if( String.isNotBlank(subject) &&
                    ( isPresent(subject,prEmail.split(';')) ) &&
                    !emailaddress.containsIgnoreCase(internalEmailId)){
                String conid;
                String opportunityId;
                String invoiceId;
                List<Attachment> attachments = new List<Attachment>();

                logger.log('\n Received Subject : '+subject);
                logger.log('\n Received Email from Address : '+emailaddress);
                logger.log('\n Received Email from Body : '+body);

                Map<Id,Contact> contactMap = new Map<Id,Contact>();
                List<Contact> conUpdate = new List<Contact>();

                contactMap = new Map<Id,Contact> ( [Select id,email,MobilePhone,RecordType.Name from Contact where email = :emailaddress ] );

                logger.log('\n Received contactMap : '+contactMap);

                logger.log('\n Getting Opportunities : ');

                for( Opportunity opportunity : [ SELECT Id,Name,GP_Contact__c, Primary_Contact__c,
                                                            (SELECT Id, Name
                                                                    from Opportunity_Line_Item__r
                                                                    where Status__c = 'Production Report Requested'
                                                                    Order By CreatedDate
                                                                    DESC )
                                                            from Opportunity
                                                            where
                                                            ( Primary_Contact__c IN: contactMap.keySet()
                                                                OR
                                                             GP_Contact__c IN: contactMap.KeySet()
                                                            )
                                                            AND Lines_Expecting_PR_ER__c <> 0
                                                ]){

                    if( contactMap.containsKey(opportunity.GP_Contact__c) || contactMap.containsKey(opportunity.Primary_Contact__c) ){
                        logger.log('\n Opportunity Found :'+opportunity);
                        conId = ( contactMap.containsKey(opportunity.GP_Contact__c) ? contactMap.get(opportunity.GP_Contact__c).Id :  contactMap.get(opportunity.Primary_Contact__c).Id);
                        opportunityId = opportunity.Id;
                        invoiceId   = !opportunity.Opportunity_Line_Item__r.isEmpty() ? opportunity.Opportunity_Line_Item__r[0].Id : null;
                    }
                }


                system.debug('conId ==>'+conId);
                system.debug('opportunityId ==>'+opportunityId);
                logger.log('\n conId :'+conId);
                logger.log('\n opportunityId :'+opportunityId);

                //Ankita A: If no contact is found, add the file to a folder
                String linkedEntityId;
                if(String.isNotBlank(invoiceId)) {
                    linkedEntityId = invoiceId;      
                } else {
                    //Query the Library with name as Provider onboarding and set the linkedEntityId
                    List<ContentWorkspace> contentWorkspaceLst = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name LIKE 'Production Reports%' ];
                    if(contentWorkspaceLst.size() > 0){
                        linkedEntityId = contentWorkspaceLst[0].Id;
                    }
                }

                // Attachments Store
                If (email.textAttachments != null) {
                    for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                       	//Ankita A: 6 Feb 2020: Removed creating attachment records

                        ContentVersion conVer = new ContentVersion();
                        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                        conVer.PathOnClient = tAttachment.fileName; // The files name, extension is very important here which will help the file in preview.
                        conVer.Title = tAttachment.fileName; // Display name of the files
                        conVer.Content_Source__c = 'Email';
                        conVer.VersionData = Blob.valueOf(tAttachment.body); //Ankita A: 4 Feb No need of decoding
                        insert conVer;

                        // First get the content document Id from ContentVersion
                        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

                        //Create ContentDocumentLink
                        ContentDocumentLink cDe = new ContentDocumentLink();
                        cDe.ContentDocumentId = conDoc;
                        cDe.LinkedEntityId = linkedEntityId; // you can use objectId,GroupId etc
                        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
                        cDe.Visibility = 'AllUsers';
                        insert cDe;
                    }
                } else if (email.binaryAttachments != null) {
                    for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
						//Ankita A: 6 Feb 2020: Removed creating attachment records
                        
                        ContentVersion conVer = new ContentVersion();
                        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                        conVer.PathOnClient = bAttachment.fileName; // The files name, extension is very important here which will help the file in preview.
                        conVer.Title = bAttachment.fileName; // Display name of the files
                        conVer.Content_Source__c = 'Email';
                        conVer.VersionData = (bAttachment.body); // converting your binary string to Blog
                        insert conVer;

                        // First get the content document Id from ContentVersion
                        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

                        //Create ContentDocumentLink
                        ContentDocumentLink cDe = new ContentDocumentLink();
                        cDe.ContentDocumentId = conDoc;
                        cDe.LinkedEntityId = linkedEntityId; // you can use objectId,GroupId etc
                        cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
                        cDe.Visibility = 'AllUsers';
                        insert cDe;
                    }
                }

                //Task Create
                Task t = new Task();
                t.Subject = 'Email Recived From' + ' ' + email.fromName;
                t.Status = 'Completed';
                t.TaskSubtype = 'Email';
                t.Description = body;
                t.WhoId = conid;
                t.whatId = opportunityId;
                insert t;

                logger.log('\n Attachment and Task creation completed ');
                logger.setStatus('SUCCESS');
            
                //If the subject contains Provider Onboarding or the email has attachments
            } else if((String.isNotBlank(subject) && (subject.containsIgnoreCase(onboardingEmail)) && !emailaddress.containsIgnoreCase(internalEmailId))
                || email.binaryAttachments != null || email.textAttachments != null){
                
                logger.log('\n Received Subject : '+subject);
                logger.log('\n Received Email from Address : '+emailaddress);
                logger.log('\n Received Email from Body : '+body);
                
                String contactName = parseSubject(subject);
                System.debug('contactName  --- '+contactName);
                //Parse to get exact Provider
                List<Contact> contactLst = Database.query('SELECT Id, Name, Email FROM Contact WHERE email = \'' 
                                                 + emailaddress + '\' AND Name LIKE \'%' +contactName +
                                                 '%\'');
                Boolean isContactFound = false;
                Contact contact;
                Id linkedEntityId;
                if(contactLst.size() > 0){
                    contact = contactLst[0];
                    //If contact is found, set the Boolean value as true
                    isContactFound = true;
                    logger.log('\n Received contact : '+contact);
                    //Set the LinkedEntityId as that of Contact.Id
                    linkedEntityId = contact.Id;      
                } else {
                    //Query the Library with name as Provider onboarding and set the linkedEntityId
                    List<ContentWorkspace> contentWorkspaceLst = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name LIKE 'Provider Onboarding%' ];
                    if(contentWorkspaceLst.size() > 0){
                        linkedEntityId = contentWorkspaceLst[0].Id;
                    }
                    
                }

                //Attachments Store
                System.debug(email.textAttachments + 'email.textAttachments -- ');
                List<ContentVersion> contentVersions = new List<ContentVersion>();
                if (email.textAttachments != null){
                    for(Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                        ContentVersion conVer = new ContentVersion();
                        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                        conVer.PathOnClient = tAttachment.fileName; // The files name, extension is very important here which will help the file in preview.
                        if(isContactFound){
                            //Remove the extension and append the Contact name
                            conVer.Title = tAttachment.fileName.substringBefore('.') + '_' + contact.Name; // Display name of the files
							conVer.Content_Source__c = 'Email';                          
                            conVer.Content_Type__c = getContentType(tAttachment.fileName);
                          
                        } else {
                            //If contact record is not found, don't append anything
                            conVer.Title = tAttachment.fileName;// Display name of the files
                        }
                        
                        conVer.VersionData = Blob.valueOf(tAttachment.body); //Ankita A: 4 Feb No need of decoding
                        contentVersions.add(conVer);
                    }
                }
                if (email.binaryAttachments != null) {
                    for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                        ContentVersion conVer = new ContentVersion();
                        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                        conVer.PathOnClient = bAttachment.fileName; // The files name, extension is very important here which will help the file in preview.
                        if(isContactFound){
                            //Remove the extension and append the Contact name
                            conVer.Title = bAttachment.fileName.substringBefore('.') + '_' + contact.Name; // Display name of the files
                          	conVer.Content_Source__c = 'Email';
                            conVer.Content_Type__c = getContentType(bAttachment.fileName);
                        } else {
                            //If contact record is not found, don't append anything
                            conVer.Title = bAttachment.fileName;// Display name of the files
                        }
                        
                        conVer.VersionData = (bAttachment.body); // converting your binary string to Blog
                        contentVersions.add(conVer);
                        
                    }
                }
                    
                //Insert the Content version
                insert contentVersions;
                //Create list of content document links
                List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();                
                for(ContentVersion conVer : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN:contentVersions]){
                    //Create ContentDocumentLink for Contact
                    ContentDocumentLink cDe = new ContentDocumentLink();
                    cDe.ContentDocumentId = conVer.ContentDocumentId; //get the content document Id from ContentVersion
                    cDe.LinkedEntityId = linkedEntityId; //It will either have library id or contact id
                    cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
                    cDe.Visibility = 'AllUsers';
                    contentDocLinks.add(cDe);
                }
                insert contentDocLinks;
                //Task Create
                Task t = new Task();
                t.Subject = 'Email Received From' + ' ' + email.fromName;
                t.Status = 'Completed';
                t.TaskSubtype = 'Email';
                t.Description = body;
                if(contact != null){
                    t.WhoId = contact.Id;
                }
                
                insert t;
                
                logger.log('\n Attachment and Task creation completed ');
                logger.setStatus('SUCCESS');
            
            } else if ( !emailaddress.containsIgnoreCase(internalEmailId) ) { // Blank or unknown subject

                 List<Contact> contactLst = Database.query('SELECT Id, Name, Email FROM Contact WHERE email = \'' 
                                                 + emailaddress + '\'');
                Boolean isContactFound = false;
                Contact contact;
                Id linkedEntityId;
                if(contactLst.size() > 0){
                    contact = contactLst[0];
                    //If contact is found, set the Boolean value as true
                    isContactFound = true;
                    logger.log('\n Received contact : '+contact);
                    //Set the LinkedEntityId as that of Contact.Id
                    linkedEntityId = contact.Id;      
                } else {
                    //Query the Library with name as Provider onboarding and set the linkedEntityId
                    List<ContentWorkspace> contentWorkspaceLst = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name LIKE 'Provider Onboarding%' ];
                    if(contentWorkspaceLst.size() > 0){
                        linkedEntityId = contentWorkspaceLst[0].Id;
                    }
                    
                }

                //Attachments Store
                System.debug(email.textAttachments + 'email.textAttachments -- ');
                List<ContentVersion> contentVersions = new List<ContentVersion>();
                if (email.textAttachments != null){
                    for(Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                        ContentVersion conVer = new ContentVersion();
                        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                        conVer.PathOnClient = tAttachment.fileName; // The files name, extension is very important here which will help the file in preview.
                        if(isContactFound){
                            //Remove the extension and append the Contact name
                            conVer.Title = tAttachment.fileName.substringBefore('.') + '_' + contact.Name; // Display name of the files
                          	conVer.Content_Source__c = 'Email';
                            conVer.Content_Type__c = getContentType(tAttachment.fileName);
                        } else {
                            //If contact record is not found, don't append anything
                            conVer.Title = tAttachment.fileName;// Display name of the files
                        }
                        
                        conVer.VersionData = Blob.valueOf(tAttachment.body); //Ankita A: 4 Feb No need of decoding
                        contentVersions.add(conVer);
                    }
                }
                if (email.binaryAttachments != null) {
                    for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                        ContentVersion conVer = new ContentVersion();
                        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                        conVer.PathOnClient = bAttachment.fileName; // The files name, extension is very important here which will help the file in preview.
                        if(isContactFound){
                            //Remove the extension and append the Contact name
                            conVer.Title = bAttachment.fileName.substringBefore('.') + '_' + contact.Name; // Display name of the files
                          	conVer.Content_Source__c = 'Email';
                            conVer.Content_Type__c = getContentType(bAttachment.fileName);
                        } else {
                            //If contact record is not found, don't append anything
                            conVer.Title = bAttachment.fileName;// Display name of the files
                        }
                        
                        conVer.VersionData = (bAttachment.body); // converting your binary string to Blog
                        contentVersions.add(conVer);
                        
                    }
                }
                    
                //Insert the Content version
                insert contentVersions;
                //Create list of content document links
                List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();                
                for(ContentVersion conVer : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN:contentVersions]){
                    //Create ContentDocumentLink for Contact
                    ContentDocumentLink cDe = new ContentDocumentLink();
                    cDe.ContentDocumentId = conVer.ContentDocumentId; //get the content document Id from ContentVersion
                    cDe.LinkedEntityId = linkedEntityId; //It will either have library id or contact id
                    cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
                    cDe.Visibility = 'AllUsers';
                    contentDocLinks.add(cDe);
                }
                insert contentDocLinks;
                //Task Create
                Task t = new Task();
                t.Subject = 'Email Received From' + ' ' + email.fromName;
                t.Status = 'Completed';
                t.TaskSubtype = 'Email';
                t.Description = body;
                if(contact != null){
                    t.WhoId = contact.Id;
                }
                
                insert t;
                
                logger.log('\n Attachment and Task creation completed ');
                logger.setStatus('SUCCESS');
            }
           
        } catch(Exception e) {
            System.debug(e);
            logger.setStatus('Error');
            logger.logException(e);
        } finally {
            ApexLogger.commitLogs();
        }
        return result;
    }
    
    private static String getContentType(String fileName){
        if(String.isNotBlank(fileName) && fileName.containsIgnoreCase('Fee Schedule')){
            return 'Fee Schedule';
        } else if(String.isNotBlank(fileName) && fileName.containsIgnoreCase('Scheduling')){
            return 'Scheduling Guidelines';
        } else if(String.isNotBlank(fileName) && fileName.containsIgnoreCase('Questionnaire')){
            return 'Questionnaire';
        }
        return '';
    }
    
    //This method will parse the subject to get the Name of the contact
    private static String parseSubject(String subject){
        if(String.isNotBlank(subject)){
            List<String> lstString = subject.split(' ');
            for(Integer i = 0; i < lstString.size(); i++){
                System.debug('i  '+i + 'lstString[i]' +lstString[i]);
            }
            //Get the Name of the contact
            String contactName = lstString[lstString.size() - 2] + ' ' + lstString[lstString.size() - 1];
            return contactName; 
        }
        return '';
    }

    private static Boolean isPresent( String subject , List<String> wordLst ){
        for(String word : wordLst ){
            if(subject.containsIgnoreCase(word))
                return true;
        }
        return false;
    }

}