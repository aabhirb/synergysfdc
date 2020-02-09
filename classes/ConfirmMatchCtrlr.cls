/**
 * Created by abidap on 2/10/19.
 */

global without sharing class ConfirmMatchCtrlr {

    public String contextType {get;set;}
    public String email {get;set;}
    public String prospectMatchId {get;set;}
    public Prospect_Match__c matchToUpdate {get;set;}
    public String addressString {get;set;}
    public String specialtyString {get;set;}

    public ConfirmMatchCtrlr(){

        parseURLParameters();
        addressString = '';
        specialtyString = '';

        System.debug('contextType ==>'+contextType);

        if('GP'.equalsIgnoreCase(contextType)){
            List <Prospect_Match__c> matchLst = [ Select Id,name,SP_Contact__r.Name, GP_Account__r.Name, SP_Contact__r.Email , SP_Contact__r.Phone , SP_Contact__r.SPSPECIALTY__c , SP_Contact__r.SPSPECIALTY2__c,Match_Stage__c,
                                                                SP_Contact__r.MailingStreet , SP_Contact__r.MailingCity , SP_Contact__r.MailingState, SP_Contact__r.MailingCountry,SP_Contact__r.MailingPostalCode
                                                        from
                                                                Prospect_Match__c
                                                        where
                                                                Id =: prospectMatchId 
                                                ];
            //and GP_Contact__r.Email =: email
            system.debug('matchLst =>'+matchLst);
            matchToUpdate = ( matchLst != null && !matchLst.isEmpty()) ? matchLst [0] : null;
            
            if( matchToUpdate != null ){
                
               /* if( String.isNotBlank(matchToUpdate.SP_Contact__r.MailingStreet) )
                    addressString   += matchToUpdate.SP_Contact__r.MailingStreet;*/

                if( String.isNotBlank(matchToUpdate.SP_Contact__r.MailingCity) ){
                    //addressString   += ', ';
                    addressString   += matchToUpdate.SP_Contact__r.MailingCity;
    
                }
    
    
                if( String.isNotBlank(matchToUpdate.SP_Contact__r.MailingState) ){
                    addressString   += ', ';
                    addressString   += matchToUpdate.SP_Contact__r.MailingState;
    
                }
    
               /* if( String.isNotBlank(matchToUpdate.SP_Contact__r.MailingCountry) ){
                    addressString   += ', ';
                    addressString   += matchToUpdate.SP_Contact__r.MailingCountry;
                }else{
                    addressString   += ', ';
                    addressString   += 'USA';
                }*/
    
    
                if( String.isNotBlank(matchToUpdate.SP_Contact__r.MailingPostalCode) ){
                    addressString   += ', ';
                    addressString   += matchToUpdate.SP_Contact__r.MailingPostalCode;
    
                }
    
                if( String.isNotBlank(matchToUpdate.SP_Contact__r.SPSPecialty__c) ){
    
                    specialtyString   += matchToUpdate.SP_Contact__r.SPSPecialty__c;
                }
    
                if( String.isNotBlank(matchToUpdate.SP_Contact__r.SPSPecialty2__c) ){
                    specialtyString   += ', ';
                    specialtyString   += matchToUpdate.SP_Contact__r.SPSPecialty2__c;
    
                }
    
            }
            
            
        }else if('sp'.equalsIgnoreCase(contextType)){

            List <Prospect_Match__c> matchLst = [ Select Id,name,GP_Contact__r.Name, GP_Account__r.Name, GP_Contact__r.Email , GP_Contact__r.Phone , GP_Contact__r.Account.Type_of_Specialist_Needed__c,Match_Stage__c,
                                                                    GP_Contact__r.MailingStreet , GP_Contact__r.MailingCity , GP_Contact__r.MailingState, GP_Contact__r.MailingCountry,GP_Contact__r.MailingPostalCode
                                                            from
                                                                    Prospect_Match__c
                                                            where
                                                                    Id =: prospectMatchId
                                                            ];
            //and GP_Contact__r.Email =: email
            system.debug('matchLst =>'+matchLst);
            matchToUpdate = ( matchLst != null && !matchLst.isEmpty()) ? matchLst [0] : null;

            if( matchToUpdate != null ){

               /* if( String.isNotBlank(matchToUpdate.GP_Contact__r.MailingStreet) )
                    addressString   += matchToUpdate.GP_Contact__r.MailingStreet;*/

                if( String.isNotBlank(matchToUpdate.GP_Contact__r.MailingCity) ){
                    //addressString   += ', ';
                    addressString   += matchToUpdate.GP_Contact__r.MailingCity;

                }


                if( String.isNotBlank(matchToUpdate.GP_Contact__r.MailingState) ){
                    addressString   += ', ';
                    addressString   += matchToUpdate.GP_Contact__r.MailingState;

                }

               /* if( String.isNotBlank(matchToUpdate.GP_Contact__r.MailingCountry) ){
                    addressString   += ', ';
                    addressString   += matchToUpdate.GP_Contact__r.MailingCountry;
                }else{
                    addressString   += ', ';
                    addressString   += 'USA';
                }*/


                if( String.isNotBlank(matchToUpdate.GP_Contact__r.MailingPostalCode) ){
                    addressString   += ', ';
                    addressString   += matchToUpdate.GP_Contact__r.MailingPostalCode;

                }



                if( String.isNotBlank(matchToUpdate.GP_Contact__r.Account.Type_of_Specialist_Needed__c) ){
                    specialtyString   += matchToUpdate.GP_Contact__r.Account.Type_of_Specialist_Needed__c;
                }

            }
        }

    }

    private void parseURLParameters(){

        if(ApexPages.currentPage().getParameters() != null ){
            contextType      = ApexPages.currentPage().getParameters().get('type');
            email            = ApexPages.currentPage().getParameters().get('email');
            prospectMatchId  = ApexPages.currentPage().getParameters().get('matchId');
        }

    }
    
    @RemoteAction
    global static Boolean onclickOfAction(String actionType, String prospectId , String contextType ) {
        try{
            List<Task> taskLst = new List<Task>();
            if(String.isNotBlank(prospectId)){
                List<Prospect_Match__c> matchLst = [Select id,name,Match_Stage__c,SP_Contact__c,
                                                            GP_Contact__c,First_Response__c
                                                            from
                                                            Prospect_Match__c
                                                            where Id =: prospectId ] ;
                
                if( matchLst != null && !matchLst.isEmpty()){
                    if('approve'.equalsIgnoreCase(actionType)){
                        Boolean isRespondedOnce = matchLst[0].First_Response__c;
                        String msgStatus = 'Match Email Sent to SP';
                        if( 'SP'.equalsIgnoreCase(contextType) ){
                            msgStatus = 'Match Email Sent to GP';
                        }

                        matchLst[0].Match_Stage__c = ( !isRespondedOnce ) ? msgStatus : 'Match Approved';

                        if(!isRespondedOnce)
                            matchLst[0].First_Response__c = (!isRespondedOnce);

                    }else if('decline'.equalsIgnoreCase(actionType)){
                        matchLst[0].Match_Stage__c = ('GP'.equalsIgnoreCase(contextType)) ? 'Match Denied By GP' : 'Match Denied By SP' ;
                    }

                        
                    update matchLst;
                    
                     Id sobjectId = actionType.containsIgnoreCase('gp') ? matchLst[0].GP_Contact__c : matchLst[0].SP_Contact__c;
                    String subjectString = 'Update on Match : Match Status :'+matchLst[0].Match_Stage__c;
                    Task taskObj = Utility.createActivity( matchLst[0].Id ,
                                                                sobjectId , Utility.TaskStatus.COMPLETE ,  subjectString  ,
                                                                matchLst[0].Match_Stage__c  ,null , Date.today() );
                    taskObj.Description = subjectString;
                    taskLst.add( taskObj );

                    if( taskLst != null && !taskLst.isEmpty() ){
                        insert taskLst;
                    }
                    
                    return true;
                }
                
            }
        
        }catch( Exception ex){
            return false;
        }
        
        return false;
    }
}