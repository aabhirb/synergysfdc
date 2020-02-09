/**
* @author abhishekbidap
* @date 9/1/19
*
* @description : .
*/
public with sharing class BannerComponentController
{
    @AuraEnabled
    public static BannerWrapper getBannerFields(Id sobjectId){
        BannerWrapper wrapper ;
        String sobjectType = Utility.getSobjectType(sobjectId);
        system.debug('sobjectType=>'+sobjectType);
        system.debug('sobjectId=>'+sobjectId);
        if('Contact'.equalsIgnoreCase(sobjectType)){
            for( Contact contactObj : [SELECT Id,DoNotCall,HasOptedOutOfEmail from Contact where Id =: sobjectId ] ){
                wrapper = new BannerWrapper(contactObj.DoNotCall,contactObj.HasOptedOutOfEmail);
            }
        }else if('Lead'.equalsIgnoreCase(sobjectType)){
            for( Lead leadObj : [SELECT Id,DoNotCall,HasOptedOutOfEmail from Lead where Id =: sobjectId ] ){
                wrapper = new BannerWrapper(leadObj.DoNotCall,leadObj.HasOptedOutOfEmail);
            }
        }
        system.debug('wrapper=>'+wrapper);
        return wrapper;
    }

    @AuraEnabled
    public static void setBannerFields( Id sobjectId, String fieldTypeStr ){
        String sobjectType = Utility.getSobjectType(sobjectId);
        if('Contact'.equalsIgnoreCase(sobjectType)){
            Contact contactObj = [SELECT Id,DoNotCall,HasOptedOutOfEmail from Contact where Id =: sobjectId ];
            contactObj.put(fieldTypeStr,!Boolean.valueOf(contactObj.get(fieldTypeStr)) );
            update contactObj;

        }else if('Lead'.equalsIgnoreCase(sobjectType)){
            Lead leadObj = [SELECT Id,DoNotCall,HasOptedOutOfEmail from Lead where Id =: sobjectId ];
            leadObj.put(fieldTypeStr,!Boolean.valueOf(leadObj.get(fieldTypeStr)) );
            update leadObj;
        }
    }

    public class BannerWrapper {
        @AuraEnabled public Boolean doNotCallVal;
        @AuraEnabled public Boolean doNotEmailVal;

        public BannerWrapper (Boolean doNotCallParam , Boolean doNotEmailParam ){
            doNotCallVal = doNotCallParam;
            doNotEmailVal = doNotEmailParam;
        }
    }
}