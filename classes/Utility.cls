/**
 * Created by abidap on 12/26/18.
 */

public with sharing class Utility {

    public Enum TaskStatus { COMPLETE , OPEN }

    public static Map<String,Id> productMap;

    public static Map<String,String> mSoPrefixByNameMap = new Map<String,String>
                                            {
                                                     Contact.sObjectType.getDescribe().getKeyPrefix()  => 'Contact' ,
                                                     Opportunity.sObjectType.getDescribe().getKeyPrefix() => 'Opportunity',
                                                     Lead.sObjectType.getDescribe().getKeyPrefix() => 'Lead',
                                                     Account.sObjectType.getDescribe().getKeyPrefix() => 'Account',
                                                     Event.sObjectType.getDescribe().getKeyPrefix() => 'Event',
                                                     Task.sObjectType.getDescribe().getKeyPrefix() => 'Task'
                                            };

    public static Map<String,String> stateCodeMap = new Map <String,String>{
                                                                                'AL'=>'Alabama',
                                                                                'AK'=>'Alaska',
                                                                                'AZ'=>'Arizona',
                                                                                'AR'=>'Arkansas',
                                                                                'CA'=>'California',
                                                                                'CO'=>'Colorado',
                                                                                'CT'=>'Connecticut',
                                                                                'DE'=>'Delaware',
                                                                                'DC'=>'District of Columbia',
                                                                                'FL'=>'Florida',
                                                                                'GA'=>'Georgia',
                                                                                'HI'=>'Hawaii',
                                                                                'ID'=>'Idaho',
                                                                                'IL'=>'Illinois',
                                                                                'IN'=>'Indiana',
                                                                                'IA'=>'Iowa',
                                                                                'KS'=>'Kansas',
                                                                                'KY'=>'Kentucky',
                                                                                'LA'=>'Louisiana',
                                                                                'ME'=>'Maine',
                                                                                'MD'=>'Maryland',
                                                                                'MA'=>'Massachusetts',
                                                                                'MI'=>'Michigan',
                                                                                'MN'=>'Minnesota',
                                                                                'MS'=>'Mississippi',
                                                                                'MO'=>'Missouri',
                                                                                'MT'=>'Montana',
                                                                                'NE'=>'Nebraska',
                                                                                'NV'=>'Nevada',
                                                                                'NH'=>'New Hampshire',
                                                                                'NJ'=>'New Jersey',
                                                                                'NM'=>'New Mexico',
                                                                                'NY'=>'New York',
                                                                                'NC'=>'North Carolina',
                                                                                'ND'=>'North Dakota',
                                                                                'OH'=>'Ohio',
                                                                                'OK'=>'Oklahoma',
                                                                                'OR'=>'Oregon',
                                                                                'PA'=>'Pennsylvania',
                                                                                'RI'=>'Rhode Island',
                                                                                'SC'=>'South Carolina',
                                                                                'SD'=>'South Dakota',
                                                                                'TN'=>'Tennessee',
                                                                                'TX'=>'Texas',
                                                                                'UT'=>'Utah',
                                                                                'VT'=>'Vermont',
                                                                                'VA'=>'Virginia',
                                                                                'WA'=>'Washington',
                                                                                'WV'=>'West Virginia',
                                                                                'WI'=>'Wisconsin',
                                                                                'WY'=>'Wyoming'
                                                                            };

    public static String orgWideEmailTemplateId ;

    public static String getsObjectRecordTypeId(SObjectType sObjectType, String recordTypeName){
        //Generate a map of tokens for all the Record Types for the desired object
        Map<String, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName();

        if(recordTypeInfo.containsKey(recordTypeName)){
            return recordTypeInfo.get(recordTypeName).getRecordTypeId();
        } else {
            return 'Could not find the record type name';
        }
    }

    public static String getsObjectRecordTypeName(SObjectType sObjectType, Id recordTypeId){
        //Generate a map of tokens for all the Record Types for the desired object
        Map<Id, Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosById();

        if(recordTypeInfo.containsKey(recordTypeId)){
            return recordTypeInfo.get(recordTypeId).getName();
        } else {
            return 'Could not find the record type name';
        }
    }

    public static List<SelectOption> getPickListValues(String objName, String fieldName){

        list<SelectOption> options = new list<SelectOption>();
        Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objName).getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get(fieldName).getDescribe().getPickListValues();

        for (Schema.PicklistEntry a : values){
            options.add(new SelectOption(a.getLabel(), a.getValue()));
        }

        return options;
    }

    public static Task createActivity( Id objectIdToAssociate , Id userIdToAssociate , Utility.TaskStatus statusEnum ,
                                        String subjectString , String descriptionString , String typeString , Date duedate ){

        Task taskObj = new Task();
        taskObj.Type = ( typeString == null ) ? 'System Generated Synergy Activity' : typeString ;
        taskObj.ActivityDate = (duedate == null) ? Date.Today() : duedate ;
        taskObj.WhatId = objectIdToAssociate ;
        taskObj.whoId = userIdToAssociate;
        taskObj.Status = statusEnum.Name();
        taskObj.Subject = subjectString; 
        taskObj.Description = descriptionString;
        taskObj.OwnerId = UserInfo.getUserId();
        return taskObj;
    }

    public static Messaging.SingleEmailMessage sendEmail( Id whatId , Id templateId , Id targetObjectId ){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Step 2: Set list of people who should get the email
       // mail.setToAddresses(sendTo);
        mail.setTemplateId(templateId);
        mail.setTargetObjectId(targetObjectId);
        if(whatId != null){
            mail.setWhatId(whatId);
        }
        if( orgWideEmailTemplateId == null ){
            OrgWideEmailAddress  owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address ='hello@synergyspecialists.co'];
            orgWideEmailTemplateId = owea.Id;
        }

        mail.setOrgWideEmailAddressId( orgWideEmailTemplateId );
        mail.setOptOutPolicy('FILTER');
        return mail;
    }

    public static Messaging.SingleEmailMessage sendEmail( Id whatId , Id templateId , Id targetObjectId , String sendAsSupportUserString ){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Step 2: Set list of people who should get the email
       // mail.setToAddresses(sendTo);
        mail.setTemplateId(templateId);
        mail.setTargetObjectId(targetObjectId);
        if(whatId != null){
            mail.setWhatId(whatId);
        }
        
        if( orgWideEmailTemplateId == null && 'SUPPORT'.equalsIgnoreCase(sendAsSupportUserString) ){
            OrgWideEmailAddress  owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address ='support@synergyspecialists.com'];
            orgWideEmailTemplateId = owea.Id;
        } else if( orgWideEmailTemplateId == null && !'SUPPORT'.equalsIgnoreCase(sendAsSupportUserString) ){
            OrgWideEmailAddress  owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address ='hello@synergyspecialists.co'];
            orgWideEmailTemplateId = owea.Id;
        }

        mail.setOrgWideEmailAddressId( orgWideEmailTemplateId );
        mail.setOptOutPolicy('FILTER');
        return mail;
    }
    
    //Ankita A: 11 Nov 2019: Changes made for Concierge feature
    //This method will ensure that the email is not sent to the recipient
    public static Messaging.SingleEmailMessage sendEmail( Id whatId , Id templateId , Id targetObjectId, Boolean treatTargetObjectAsRecipient ){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(templateId);
        mail.setTargetObjectId(targetObjectId);
        mail.setWhatId(whatId);
        mail.setTreatTargetObjectAsRecipient(treatTargetObjectAsRecipient);
        if( orgWideEmailTemplateId == null ){
            OrgWideEmailAddress  owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address ='hello@synergyspecialists.co'];
            orgWideEmailTemplateId = owea.Id;
        }

        mail.setOrgWideEmailAddressId( orgWideEmailTemplateId );
        mail.setOptOutPolicy('FILTER');
        return mail;
    }
    
    //Ankita A: 11 Nov 2019: Changes made for Concierge feature
    //This method will ensure that the email is not sent to the recipient
    public static Messaging.SingleEmailMessage sendEmail( Id whatId , Id templateId , Id targetObjectId, Boolean treatTargetObjectAsRecipient , String sendAsSupportUserString  ){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(templateId);
        mail.setTargetObjectId(targetObjectId);
        mail.setWhatId(whatId);
        mail.setTreatTargetObjectAsRecipient(treatTargetObjectAsRecipient);
        
        if( orgWideEmailTemplateId == null && 'SUPPORT'.equalsIgnoreCase(sendAsSupportUserString) ){
            OrgWideEmailAddress  owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address ='support@synergyspecialists.com'];
            orgWideEmailTemplateId = owea.Id;
        } else if( orgWideEmailTemplateId == null && !'SUPPORT'.equalsIgnoreCase(sendAsSupportUserString) ){
            OrgWideEmailAddress  owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address ='hello@synergyspecialists.co'];
            orgWideEmailTemplateId = owea.Id;
        }

        mail.setOrgWideEmailAddressId( orgWideEmailTemplateId );
        mail.setOptOutPolicy('FILTER');
        return mail;
    }

    public static void updateLatLongForAddress( String sobjectType , Id sobjectId , String addressString ){
        
    }

    public static State_ASA_Mapping__c getASAMappingRecord( String stateName ){

        if(!String.isBlank( stateName )){

            String nameToSearch = ( stateName.length() == 2 ) ? ('$'+stateName+'$') : stateName ;

            for( State_ASA_Mapping__c asaMappingVar : State_ASA_Mapping__c.getAll().values()){
                if((asaMappingVar.Name).containsIgnoreCase(nameToSearch)){
                    return asaMappingVar;
                }
            }
        }
        return null;
    }

    public static void synchActivity( Id sourceRelatedToId ,  Id targetRelatedToId ){

        List<EmailMessage> emailMessageLst = [SELECT BccAddress,CcAddress,FirstOpenedDate,FromAddress,FromName,HasAttachment,Headers,
                                                    HtmlBody,Id,Incoming,IsBounced,IsClientManaged,IsDeleted,IsExternallyVisible,IsOpened,IsTracked,MessageDate,
                                                    MessageIdentifier,ParentId,RelatedToId,ReplyToEmailMessageId,Status,Subject,TextBody,ThreadIdentifier,ToAddress,
                                                    ValidatedFromAddress
                                                    from
                                                    EmailMessage
                                                    where RelatedToId =: sourceRelatedToId  Order By CreatedDate DESC ];

        if( emailMessageLst != null && emailMessageLst.size() != 0 ){
            EmailMessage newEmailMessageObj = emailMessageLst[0].clone();
            newEmailMessageObj.RelatedToId = targetRelatedToId;
            insert newEmailMessageObj;
        }

    }


    public static Map<String,Id> getProductMap( Set<String> productCodeSet ){

        if( productMap == null ){
            productMap = new Map<String,Id>();
            for(Product2  productVar : [SELECT Id,Name,ProductCode from Product2 where ProductCode IN: productCodeSet ]){
                productMap.put(productVar.ProductCode,productVar.id);
            }
        }
        return productMap;
    }

    public static String getSobjectType( String sobjectId ){
        return (!String.isBlank(sobjectId)) ? Utility.mSoPrefixByNameMap.get(sobjectId.substring(0,3)) : null ;
    }

    public static Set<String> getTeslaConfigurationsMatchingWithPrefix(String prefix){

        List<Constant__c> configurations = Constant__c.getall().values();
        Set<String> matchingValues = new Set<String>();
        for(Constant__c configurationVar : configurations){
            if(configurationVar.Name !=null && configurationVar.Name.startsWith(prefix) && configurationVar.Value__c != null){
                matchingValues.add(configurationVar.Value__c);
            }
        }
        return matchingValues;
    }

    /**
    * This method does the exception handling of aura errors.
    */
    public static void handleAuraException(Exception ex){
        AuraHandledException auraException = new AuraHandledException(ex.getMessage());
        auraException.setMessage(ex.getMessage());
        if(ex instanceof DmlException ){
            DmlException theDmlException = (DmlException)ex;
            auraException = new AuraHandledException(theDmlException.getDMLMessage(0));
            auraException.setMessage(theDmlException.getDMLMessage(0));
        }

        throw auraException;
    }
 
    public static String getEMailTemplateId( String templateName ){
        List<EmailTemplate> templateLst = [SELECT Id,Name,DeveloperName from EmailTemplate where DeveloperName =: templateName ];
        return ((templateLst != null && templateLst.size() != 0) ? templateLst[0].Id : null );
    }
}