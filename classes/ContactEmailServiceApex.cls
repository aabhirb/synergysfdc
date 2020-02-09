global class ContactEmailServiceApex implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
            Messaging.InboundEnvelope envelope) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        ApexLogger.Logger logger = ApexLogger.createLogger('ContactEmailServiceApex '+system.now());

        Try {
            List<Attachment> attachments = new List<Attachment>();
            //Custom Label
            String customlabelstr = System.Label.PR_Email_Subject;
            String emailadd = email.fromAddress;
            String body;
            String subject = email.subject;
            String emailaddress;
            String conid;
            String opportunityId;
            String invoiceId;

            //Ankita A: 20 Dec: Changes
            //If the email is not from synergyspecialists.co (not an internal email)
            String internalEmailId = 'synergyspecialists.co';
            
            if( String.isNotBlank(subject) &&
                    ( isPresent(subject,customlabelstr.split(';')) ) &&
                    !emailadd.containsIgnoreCase(internalEmailId)){

                logger.log('\n Received Subject : '+subject);
                logger.log('\n Received Email from Address : '+emailadd);
                logger.log('\n Received Email from Body : '+body);



                Map<Id,Contact> contactMap = new Map<Id,Contact>();
                List<Contact> conUpdate = new List<Contact>();
                List<Attachment> AttachmentList = new List<Attachment>();

                emailaddress = emailadd;
                body = email.plainTextBody;
                contactMap = new Map<Id,Contact> ( [Select id,email,MobilePhone,RecordType.Name from Contact where email = :emailaddress ] );

                logger.log('\n Received contactMap : '+contactMap);

                logger.log('\n Getting Opportunities : ');

                for( Opportunity opportunity : [
                                                    SELECT Id,Name,GP_Contact__c,
                                                            Primary_Contact__c,
                                                            ( SELECT Id, Name
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
                    List<ContentWorkspace> contentWorkspaceLst = [SELECT Id, RootContentFolderId FROM ContentWorkspace WHERE Name LIKE 'Provider Onboarding%' ];
                    if(contentWorkspaceLst.size() > 0){
                        linkedEntityId = contentWorkspaceLst[0].Id;
                    }
                }

                // Attachments Store
                If (email.textAttachments != null) {
                    for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                        Attachment attachment = new Attachment();
                        attachment.Name = tAttachment.fileName;
                        attachment.Body = Blob.valueOf(tAttachment.body);
                        attachment.ParentId = conid;
                        attachments.add(attachment);

                        attachment = new Attachment();
                        attachment.Name = tAttachment.fileName;
                        attachment.Body = Blob.valueOf(tAttachment.body);
                        attachment.ParentId = opportunityId;
                        attachments.add(attachment);

                        ContentVersion conVer = new ContentVersion();
                        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                        conVer.PathOnClient = tAttachment.fileName; // The files name, extension is very important here which will help the file in preview.
                        conVer.Title = tAttachment.fileName; // Display name of the files
                        conVer.VersionData = EncodingUtil.base64Decode(tAttachment.body); // converting your binary string to Blog
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
                        Attachment attachment = new Attachment();

                        attachment.Name = bAttachment.fileName;
                        attachment.Body = bAttachment.body;
                        attachment.ParentId = conid;
                        attachments.add(attachment);

                        attachment = new Attachment();

                        attachment.Name = bAttachment.fileName;
                        attachment.Body = bAttachment.body;
                        attachment.ParentId = opportunityId;
                        attachments.add(attachment);

                        ContentVersion conVer = new ContentVersion();
                        conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                        conVer.PathOnClient = bAttachment.fileName; // The files name, extension is very important here which will help the file in preview.
                        conVer.Title = bAttachment.fileName; // Display name of the files
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
                if (attachments.size() > 0) {
                    insert attachments;
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
            }


        } Catch (Exception e) {
            System.debug(e);
            logger.setStatus('Error');
            logger.logException(e);
        }finally{
            ApexLogger.commitLogs();
        }
        Return result;
    }

    private static Boolean isPresent( String subject , List<String> wordLst ){
        for(String word : wordLst ){
            if(subject.containsIgnoreCase(word))
                return true;
        }
        return false;
    }
}