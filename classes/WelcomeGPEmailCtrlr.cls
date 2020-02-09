/**
 * Created by abidap on 1/9/19.
 */

public with sharing class WelcomeGPEmailCtrlr {
    public Id idToRetreive {get;}
    public void setIdToRetreive(Id idToRetreiveParam){
        if(idToRetreiveParam != null){

            leadSObj = [
                    Select id,name,LastName,Type_of_Specialists_they_want__c,Specialties_sent_for_intake__c
                    from
                            Lead
                    where
                            Id =: idToRetreiveParam
                    LIMIT 1
            ];

        }
    }
    public Lead leadSObj {get;set;}

    public WelcomeGPEmailCtrlr(){

        if(idToRetreive != null){

            leadSObj = [
                    Select id,name,LastName,Type_of_Specialists_they_want__c,Specialties_sent_for_intake__c
                    from
                            Lead
                    where
                            Id =: idToRetreive
                    LIMIT 1
            ];

        }

    }
}