/**
* @author abhishek
* @date 2019-09-19
*
* @description : .
*/
public with sharing class SendInvoiceEmailCtrlr {

    public class EmailContentWrapper{
        public String emailContent;
        public String subject;
        public String toAddress;
        public String status;
        
        public EmailContentWrapper(String emailContent, String subject, String toAddress, String status){
            this.emailContent = emailContent;
            this.subject = subject;
            this.toAddress = toAddress;
            this.status = status;

        }
    }
    
    //Ankita A: This method is no longer used
    //Instead of this, we are auto populating the contents in the email widget
    /*@AuraEnabled
    public static String sendInvoiceEmail(String invoiceId) {
        if(String.isNotBlank(invoiceId)) {

            if(validateDocuments(invoiceId)) {

                List<Opportunity_Line_Item__c> opptyLineItem = [
                                                                    SELECT Id,Name,Opportunity__r.Primary_Contact__c,Status__c
                                                                    from
                                                                    Opportunity_Line_Item__c
                                                                    where
                                                                    Id =: invoiceId
                                                                ];
    
                if(!opptyLineItem.isEmpty()){
                    if(opptyLineItem[0].Status__c == 'Invoice Sent') {
                        return 'Invoice already sent for payment';
                    }
                    
                    List<EmailTemplate> templateLst = [SELECT Id,Name from EmailTemplate where DeveloperName = 'Send_Invoice_CL'];
                    Messaging.SingleEmailMessage email = Utility.sendEmail(opptyLineItem[0].Id,templateLst[0].Id,opptyLineItem[0].Opportunity__r.Primary_Contact__c);
                    email.setCcAddresses(new List<String>{ 'support@synergyXdspecialists.co' });
    
                    try{
    
                        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                        //opptyLineItem[0].Status__c = 'Invoice Sent';
                        opptyLineItem[0].Invoice_Sent_for_Approval_Date__c = Date.today();
                        update opptyLineItem[0];
                        
                    }catch(Exception ex) {
                        throw new AuraHandledException('Error encountered while sending email, Please contact Admin.');
                    }
                }
                
                return 'SUCCESS';
                        
            } else {
               return 'Either one of the following is missing / not activated : Production Report, Expense Report or Invoice. Please set it up and retry.';
            }
        }
        
        return null;
    } */

    @AuraEnabled
    public static String generateEmailContent(String invoiceId){
        //Populate the content from Lightning email template
        if(String.isNotBlank(invoiceId)) {
            if(validateDocuments(invoiceId)) {
                List<Opportunity_Line_Item__c> opptyLineItem = [SELECT Id, Name, Opportunity__r.Primary_Contact__c, Status__c,
                                                                Production_Report_PDF_URL__c
                                                                FROM Opportunity_Line_Item__c
                                                                    WHERE Id =: invoiceId
                                                                ];
    
                if(!opptyLineItem.isEmpty()){
                    //Ankita A: 19 Jan 2020: Populate other email template if Prod report not present
                    List<EmailTemplate> templateLst = [SELECT Id, HtmlValue, Subject, DeveloperName FROM EmailTemplate
                                        WHERE DeveloperName IN ('Send_Invoice_CL_Lightning_w_o_Prod_Report', 'Send_Invoice_CL_Lightning')];
                    //Create a map of Developername and email template
                    Map<String, EmailTemplate> nameToTemplateMap = new Map<String, EmailTemplate>();
                    for(EmailTemplate templateObj : templateLst){
                        nameToTemplateMap.put(templateObj.DeveloperName, templateObj);
                    }
                    
                    try{
                        opptyLineItem[0].Status__c = 'Invoice Sent to Provider';
                        opptyLineItem[0].Invoice_Sent_for_Approval_Date__c = Date.today();
                        update opptyLineItem[0];
                        
                    }catch(Exception ex) {
                        System.debug('exception '+ex.getStackTraceString());
                        throw new AuraHandledException('Error encountered while updating the Invoice, Please contact Admin.');
                    }
                    //If Production report is not blank, then return Email with both Invoice and Production report 
                    if(String.isNotBlank(opptyLineItem[0].Production_Report_PDF_URL__c) && nameToTemplateMap.containsKey('Send_Invoice_CL_Lightning')){
                            return JSON.serialize(new EmailContentWrapper(nameToTemplateMap.get('Send_Invoice_CL_Lightning').HtmlValue, 
                                                        nameToTemplateMap.get('Send_Invoice_CL_Lightning').Subject, 
                                                        opptyLineItem[0].Opportunity__r.Primary_Contact__c,
                                                        'SUCCESS'));

                    } else if(nameToTemplateMap.containsKey('Send_Invoice_CL_Lightning_w_o_Prod_Report')){
                            return JSON.serialize(new EmailContentWrapper(nameToTemplateMap.get('Send_Invoice_CL_Lightning_w_o_Prod_Report').HtmlValue, 
                                                        nameToTemplateMap.get('Send_Invoice_CL_Lightning_w_o_Prod_Report').Subject, 
                                                        opptyLineItem[0].Opportunity__r.Primary_Contact__c,
                                                        'SUCCESS'));

                    } 
                }
                                        
            } else {
                String errorMsg = 'Invoice report is missing / not activated. Please set it up and retry.';
                //String errorMsg = 'Either one of the following is missing / not activated : Production Report, Expense Report or Invoice. Please set it up and retry.';
                return JSON.serialize(new EmailContentWrapper('', '', '', errorMsg));
            }
        }
        
        return null;
    }
    
    public static Boolean validateDocuments(String invoiceId) {

        Set<Id> documentIdSet = getRelatedContentDocumentLinks(invoiceId);
        //Boolean isProductionReport = false;
        //Boolean isExpenseReport = false;
        Boolean isInvoice = false;

        if(!documentIdSet.isEmpty()) {

            for( ContentDocument document : [
                                                SELECT Id,
                                                    (SELECT Id,Content_Type__c,Is_Approved__c from ContentVersions where Is_Approved__c = true Order By CreatedDate DESC),
                                                    (SELECT Id from ContentDistributions)
                                                    FROM
                                                    ContentDocument
                                                    WHERE Id IN: documentIdSet ]){

                for( ContentVersion version : document.ContentVersions) {
                    //Ankita A: Remove the check for production report and expense report
                    /*if(!isProductionReport && version.Content_Type__c == 'Production Report' ) {
                        isProductionReport = true;
                    }else if(!isExpenseReport && version.Content_Type__c == 'Expense Report') {
                        isExpenseReport = true;
                    }else */
                    if(!isInvoice && version.Content_Type__c == 'Invoice'){
                        isInvoice = true;
                    }
                }
            }
        }
        return isInvoice;
        /*if(!isProductionReport) {
            return false;
        } else if(!isExpenseReport) {
            return false;
        } else if(!isInvoice) {
            return false;
        } */
    }

    private static Set<Id> getRelatedContentDocumentLinks(String invoiceId) {

        Set<Id> documentIdSet = new Set<Id>();

        for(ContentDocumentLink documentLink :  [
                                                        SELECT
                                                                Id,LinkedEntityId,
                                                                ContentDocumentId
                                                        FROM
                                                                ContentDocumentLink
                                                        WHERE
                                                                LinkedEntityId =: invoiceId
                                                ]) {
            documentIdSet.add(documentLink.ContentDocumentId);
        }

        return documentIdSet;
    }
}