/* Class Name - FinancialDisclosurePDFController
Created by - Sujata P Galinde
Description - Class For Getting Opportunity Details For Financial Disclosure Status
*/
public class FinancialDisclosurePDFController {
//To get OpportunityId of the Opportunity whose Financial Disclosure Status Field is Marked True.
    public String OpportunityID {
        get{
            if(OpportunityID == null && 
               ApexPages.currentPage().getParameters().get('optyId') != null){
                   OpportunityID = ApexPages.currentPage().getParameters().get('optyId');
               }
            
            return OpportunityID;
        }
        set;
    }
    
    //Get Opportunity Details From Above OpportunityId
    Public Opportunity OpportunityDetails{
        get{
            
            return [SELECT GP_Contact__c,GP_Contact__r.Email,Primary_Contact__r.Email,Primary_Contact__r.FirstName,Primary_Contact__r.LastName,Primary_Contact__r.Account.Name,GP_Contact__r.Account.Name,GP_Contact__r.LastName,Primary_Contact__r.Specialty_Primary_Value__c,GP_Contact__r.MailingStreet,GP_Contact__r.MailingCity,
                    GP_Contact__r.MailingState,GP_Contact__r.MailingPostalCode,GP_Contact__r.Account.Website,Compensation__c,Provider_Per_Diem__c,Practice_Earning_Retention__c,Primary_Contact__r.Net_Terms__c,GP_Contact__r.Formulated_MailingAddress__c,Payable_To__c,Payment_Address__c FROM OPPORTUNITY WHERE ID = :OpportunityID];
            
            
        }
        set;
    }
    //Get value to check if contact is Primary or Not
    public Boolean isPrimaryContact {
    get{
        if(ApexPages.currentPage().getParameters().get('isPrime') != null){
        String isPrimaryCnt = ApexPages.currentPage().getParameters().get('isPrime');
           isPrimaryContact = Boolean.valueOf(isPrimaryCnt);
            System.debug('isPrimaryContact :'+isPrimaryContact);
        }
        System.debug('isPrimaryContact :'+isPrimaryContact);
        return isPrimaryContact;
    }
        set;
    }
}