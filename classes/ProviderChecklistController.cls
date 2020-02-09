public class ProviderChecklistController {
    
    public class CheckboxWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String fieldApiName;
        @AuraEnabled public Boolean value;
        
        public CheckboxWrapper(String label, String fieldApiName, Boolean value){
            this.label = label;
            this.fieldApiName = fieldApiName;
            this.value = value;
        }
        
    }
    
    @AuraEnabled
    public static List<CheckboxWrapper> getCheckboxWrapper(String recId){
        //Create CheckboxWrapper
        List<CheckboxWrapper> wrapper = new List<CheckboxWrapper>();
        List<String> fields = new List<String>{
            'Contract_Completed__c',
                'Credentialing_Completed__c',
                'W9_Completed__c',
                'Specialists_Package_Sent__c',
                'Stripe_Account_Created__c'
                };
                    
                    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
        Map<String, CheckboxWrapper> mapFieldToWrapper = new Map<String, CheckboxWrapper>();
        for(String field : fields){
            CheckboxWrapper wrapperObj = new CheckboxWrapper(
                fieldMap.get(field).getDescribe().getLabel(),
                field,
                false
            );
            wrapper.add(wrapperObj);
            mapFieldToWrapper.put(field, wrapperObj);
        }
        
        if(String.isNotBlank(recId)){
            List<Contact> contactLst = Database.query('SELECT Id, ' +String.join(fields, ', ') 
                                                      +' FROM Contact WHERE Id =\'' +recId +'\'LIMIT 1');
            //Contact record exists
            if(contactLst.size() > 0){
                for(String field: fields){
                    mapFieldToWrapper.get(field).value = Boolean.valueOf(contactLst[0].get(field));
                }
            }
        }
        System.debug('mapFieldToWrapper '+mapFieldToWrapper.values());
        return mapFieldToWrapper.values();
    }
    
    @AuraEnabled
    public static void updateCheckbox(String recordId, String fieldApiName, Boolean checkboxValue){
        //Update the Boolean field as value
        if(String.isNotBlank(recordId)){
            List<Contact> contactLst = Database.query('SELECT Id, ' +fieldApiName
                                                      +' FROM Contact WHERE Id =\'' +recordId +'\'LIMIT 1');
            //Contact record exists
            if(contactLst.size() > 0){
                contactLst[0].put(fieldApiName, checkboxValue);
                update contactLst[0];
            }
        }
    }
    
}