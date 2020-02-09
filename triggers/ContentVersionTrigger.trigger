/**
* @author abhishek
* @date 2019-09-20
*
* @description : .
*/
trigger ContentVersionTrigger on ContentVersion (after insert, after update) {

   switch on Trigger.operationType{
    
         //Ankita A: 25 Nov: Provider Onboarding Email changes
        when AFTER_INSERT{
            //This method will create Public url for the files only for Opportunity object and if the file is of type 
            //Fee Schedule or Scheduling guidelines or Personality questionnaire
            ContentVersionTriggerHandler.createPublicUrl(Trigger.New);
        }

        when  AFTER_UPDATE{
            ContentVersionTriggerHandler.createPublicURLandPassword(Trigger.New,Trigger.oldMap);
        }
   }
    
}