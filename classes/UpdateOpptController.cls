public class UpdateOpptController {
    
    @AuraEnabled
    public static void updateOnboardingChecklist(String recordId, String picklistValue){
        System.debug('updating ----');
        if(String.isNotEmpty(recordId)){
            Opportunity opportunityObj = [SELECT Id, Onboarding_Checklist__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
            opportunityObj.Onboarding_Checklist__c = picklistValue;
            
            // Perform isAccessible() and isUpdateable() checks here 
            update opportunityObj;
        }
    }
}