/**
 * Created by abidap on 1/12/19.
 */

public with sharing class GPNoMatchNotificationBannerController {

    public Id accountId {get;set;}
    public Boolean isEmailSent {get;set;}
    public Boolean isSPContact {get;set;}
    public Boolean isGPFromNonServiceAbleStates {get;set;}
    public List<Prospect_Match__c> futureMatchLst {get;set;}

    public GPNoMatchNotificationBannerController(ApexPages.StandardController controller){
        accountId = ApexPages.currentPage().getParameters().get('id');
        isEmailSent = false;
        isGPFromNonServiceAbleStates = false;
        futureMatchLst = [Select id,name,GP_Contact__r.MailingState from Prospect_Match__c where GP_Contact__c =: accountId or SP_Contact__c =: accountId ];
        List<Contact> acctLst = [SELECT id,name,MailingState,Notified_about_No_Eligible_Specialist__c,RecordType.Name  from Contact where Id =: accountId ];
        if(acctLst != null && !acctLst.isEmpty()){
            isEmailSent = acctLst[0].Notified_about_No_Eligible_Specialist__c;
            isSPContact = ( 'Provider'.equalsIgnoreCase( acctLst[0].RecordType.Name ) ) ? true : false ;

            if( !isSPContact && ( acctLst[0].MailingState == 'FL' || acctLst[0].MailingState == 'NY' || acctLst[0].MailingState == 'NC' ) ){
                isGPFromNonServiceAbleStates = true; // Notified_about_non_serviceability
            }
        }
    }

    @RemoteAction
    public static Boolean sendEmail(String accountId, Boolean isNonServiceAble){
        try{
            List<Task> taskLst = new List <Task>();
           // List<Account> acctLst = [SELECT id,name,Notified_about_No_Eligible_Specialist__c,(Select id,Name,LastName,MailingState,Email from Contacts) from Account where Id =: accountId ];
            List<Contact> contactLst = [SELECT id,name,RecordType.DeveloperName,LastName,Email,MailingState,Notified_about_No_Eligible_Specialist__c from Contact where Id =: accountId ];
            if(contactLst != null && !contactLst.isEmpty()){
                String emailTemplateToFetch = '';
                if(!isNonServiceAble){

                    contactLst[0].Notified_about_No_Eligible_Specialist__c = true;
                    if( contactLst[0].RecordType.DeveloperName == 'Dental_Host_Office_HO_GP' )
                        emailTemplateToFetch = 'GP_No_Match_HTML';
                    else if( contactLst[0].RecordType.DeveloperName == 'SP_Specialists' )
                        emailTemplateToFetch = 'SP_No_Match_HTML';

                }else{
                    contactLst[0].Notified_about_non_serviceability__c = true;
                    emailTemplateToFetch = 'GP_Non_Serviceable_HTML';

                }

                update contactLst;

                List<EmailTemplate> etLst = [ SELECT id FROM EmailTemplate WHERE developerName =: emailTemplateToFetch ];
                List<Messaging.SingleEmailMessage> emailLst = new List<Messaging.SingleEmailMessage>();

                emailLst.add( Utility.sendEmail( null  , etLst[0].Id , contactLst[0].Id ));


                if( !emailLst.isEmpty() ){
                    Messaging.sendEmail( emailLst );
                }

                //sendEmailToContact(contactLst[0]);
                //( Id objectIdToAssociate , Id userIdToAssociate , Utility.TaskStatus statusEnum ,
                //String subjectString , String descriptionString , String typeString , Date duedate )
                /*taskLst.add( Utility.createActivity( null , contactLst[0].Id , Utility.TaskStatus.COMPLETE , 'No Match Found email sent ' , 'No Match Found email sent ' , null , Date.today()  ) );

                if(taskLst != null && !taskLst.isEmpty())
                    insert taskLst;*/

                return true;
            }
        }catch (Exception ex){
            throw ex;
        }

        return false;

    }

    /*private static void sendEmailToContact(Contact contact){

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String ccMail = 'Support@synergyspecialists.com';
        string[] to = new string[] {contact.Email};
        string[] cc = new string[] {'Support@synergyspecialists.com'};

        email.setToAddresses(to);
        if(ccMail!=null && ccMail != '')
            email.setCcAddresses(cc);


        email.setSubject('Synergy Specialists | Dr '+contact.Name);
        String htmlBody = 'Dear Dr '+contact.LastName+', <br/>';
        htmlBody        += 'Unfortunately, we don’t have a specialist that fits your practice profile at this time, but our team is working on recruitment efforts in '+contact.MailingState+' and nearby to fill your specific need.<br/>';
        htmlBody        += 'As soon as a specialist comes online that fits your practice needs, the Synergy Specialists will automatically message you. Our network of specialists is over 250 nationally and growing quickly.<br/>';
        htmlBody        += 'As a reminder, there is no cost to you for recruiting and matching you with a specialist. Consider us a free and useful resource in helping grow your practice, as opposed to the traditional headhunter model that charges tens of thousands. In the meantime, if you know of any local specialists you’d recommend we reach out to, please respond directly to this message with the provider’s information.<br/>';

        htmlBody        += 'Best regards <br/>';


        htmlBody        += 'Your Synergy Team,<br/>';
        htmlBody        += 'Darius Somekhian | CEO | (310) 400-2531 | Darius@SynergySpecialists.com / Toll Free : 18006847479<br/>';
        htmlBody        += 'Julia Akhmerova | Operations & Credentialing | (805) 990-3509 | Julia@SynergySpecialists.com<br/>';
        htmlBody        += 'Faye Ganaban | Host Office Coordinator & Executive Assistant | Support@SynergySpecialists.com<br/>';

        email.setHtmlBody(htmlBody);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }

    }*/
}