/* Class Name - FinancialDisclosureAttachmentController
Created by - Sujata P Galinde
Description - Class For Generating Financial Disclosure Attachment For Synnergy Specialist
*/
public class FinancialDisclosureAttachmentController {
    public String PageContents{get;set;}
    Public Boolean isPrimaryCheck{get;set;}
    
    //Set OpportunityId From Visualforce Component 'FinancialDisclosureVF'
    public String opportunityObjectId{ get; set {
        if(PageContents==null)
            GenerateFinancialDisclosure(value);
    } }
    //Pass Opportunity ID to Visualforce Page Controller to Generate Details on AttachmentPDF
    public void GenerateFinancialDisclosure(String opportunityObjectID) 
    {
        try {
            System.debug('isPrimaryCheck'+isPrimaryCheck);
            PageReference pageRef = Page.FinancialDisclosurePDF;
            pageRef.getParameters().put('optyId', opportunityObjectID);
            pageRef.getParameters().put('isPrime',String.valueOf(isPrimaryCheck));
            if(Test.isRunningTest()) 
                PageContents = 'Test';
            else
                PageContents = pageRef.getContent().toString().replace('<html style="display:none !important;">', '<html>');
            System.debug(PageContents);
            
                 blob pdfBody;
            if(Test.isRunningTest()) { 
                pdfBody = blob.valueOf('Unit.Test');
            } else {
                pdfBody = pageRef.getContentAsPDF();
            }
            
            String b64 = EncodingUtil.base64Encode(pdfBody);
            System.debug('String b64: [' + b64 + ']');
            
            //Create ContentVersion
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // S specify this document is in SF
            conVer.PathOnClient = 'Financial_Disclosure.pdf'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'FinancialDisclosure '; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode(b64); // converting your binary string to Blog
            insert conVer;
            
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            System.debug('conDoc'+conDoc);
            //Create ContentDocumentLink
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = opportunityObjectID; 
            cDe.ShareType = 'I'; // Inferred permission
            cDe.Visibility = 'AllUsers';
            insert cDe;
            
            FinancialDisclosurePDFController c = new FinancialDisclosurePDFController();
            c.OpportunityID = opportunityObjectID;
            Opportunity opps = c.OpportunityDetails;
            System.debug('opps:'+opps);
            
            //Create EmailMessage
            EmailMessage emailMessage = new EmailMessage();
            emailMessage.status = '3'; // email was sent
            emailMessage.relatedToId = opportunityObjectID; // related to record e.g. an opportunity
            emailMessage.fromAddress = 'Support@SynergySpecialists.co'; // from address
            emailMessage.CcAddress = 'darius@synergyspecialists.com , hello@synergyspecialists.co ,Support@SynergySpecialists.co';
            emailMessage.subject = 'Financial Disclosure ! | Dr.' + opps.Primary_Contact__r.FirstName +' '+ opps.Primary_Contact__r.LastName +' '+'at'+' '+ opps.GP_Contact__r.Account.Name;//et.Subject;//'FinancialDisclosure !'; // email subject
            String contentBody;
            if(Test.isRunningTest()) 
               contentBody = 'Test<div class="footer"></div></div></div>';
            else
               contentBody = pageRef.getContent().toString();
            Integer startIndex = contentBody.indexOf('<div class="footer">');
            if(startIndex> -1){
                Integer endIndex = contentBody.indexOf('</div>', startIndex);
                endIndex = contentBody.indexOf('</div>', endIndex+1);
                endIndex = contentBody.indexOf('</div>', endIndex+1);
                String footerToRemove = contentBody.substring(startIndex, endIndex+6);
                
                System.debug(footerToRemove);
                contentBody = contentBody.replace(footerToRemove, '');
            }
            
            
            emailMessage.htmlBody ='<html>Dear Dr.'+''+ opps.GP_Contact__r.LastName+','+'<br/>'+'<br/>We want to reiterate the financial structure and compensation agreement with your'+' '+ opps.Primary_Contact__r.Specialty_Primary_Value__c +', '+
                'Dr.'+' '+opps.Primary_Contact__r.FirstName +' '+ opps.Primary_Contact__r.LastName +' '+'.'
                +'For your convenience we have also attached a copy in case you’d like to print it out.If there are any discrepancies from your understanding, please inform us immediately. </html>' 
                + contentBody; // email body
            
            String[] toAddress = new String[]{opps.GP_Contact__r.Email,opps.Primary_Contact__r.Email};
                emailMessage.toAddress = toAddress[0] +','+ toAddress[1];
            insert emailMessage; // insert
            
            //Create ContentDocumentLink
            ContentDocumentLink OptyCDL = new ContentDocumentLink();
            OptyCDL.ContentDocumentId = conDoc;
            System.debug('OptyCDL.ContentDocumentId: '+OptyCDL.ContentDocumentId);
            OptyCDL.LinkedEntityId = emailMessage.Id;
            System.debug('OptyCDL.LinkedEntityId: '+OptyCDL.LinkedEntityId);
            OptyCDL.ShareType = 'V'; // View permission
            OptyCDL.Visibility = 'AllUsers';
            insert OptyCDL;
            
        } catch(exception ex) { 
            PageContents = 'An error has occurred while trying to generate this invoice.  Please contact customer service.';
        }
        
    }
}