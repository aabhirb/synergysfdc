/* Class Name - FinancialDisclosureHandler
Created by - Sujata P Galinde
Description - class for FinancialDisclosure to update Financial_Discloser_Sent__c field
*/
public class FinancialDisclosureHandler {
    //Get the Current Value of Financial_Discloser_Sent__c field and Update it
    @AuraEnabled
    public static String MarkFinancialDisclosure (Id OpptyId) {
        Opportunity opp = [Select Id, Financial_Discloser_Sent__c from Opportunity where Id =:OpptyId];
        if(opp.Financial_Discloser_Sent__c != null && opp.Financial_Discloser_Sent__c){
           /* opp.Financial_Discloser_Sent__c = false;
            update opp;*/
            return 'DONE';
        }
        opp = new Opportunity(Id = OpptyId, Financial_Discloser_Sent__c = true );
        update opp;
        return 'SUCCESS';    
    }
}