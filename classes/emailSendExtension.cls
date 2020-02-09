public class emailSendExtension {
        Public List<Id> ids;
        public List<Lead> posId;
        Public List<LeadWrapper> selectedList {get;set;}
        public String templateId {get;set;}
        public String templateBody {get;set;}

               
            
        public emailSendExtension(ApexPages.StandardSetController controller) {
            List<Lead> selectedLead = controller.getSelected();
            List<Lead> leadLst = [SELECT Id,Name,HasOptedOutOfEmail,EMail from Lead where Id IN: selectedLead ];
            selectedList = new List<LeadWrapper>();
            for(Lead leadObj : leadLst){
                selectedList.add(new LeadWrapper(leadObj.Name, leadObj.Email, leadObj.HasOptedOutOfEmail , leadObj.Id ));
            }

            system.debug('selectedList =>'+selectedList);

        }

        public void providerAboutUsWOIntake(){
            templateId = Utility.getEMailTemplateId('SP_Intake_Follow_up');
            populateTemplateString(templateId);
        }

        public void providerRTM()
        {
            templateId = Utility.getEMailTemplateId('SP_Intake_RTM');
            populateTemplateString(templateId);
        }

        public void providerAvail()
        {
            templateId = Utility.getEMailTemplateId('SP_Intake_Avail_Follow_Up');
            populateTemplateString(templateId);
        }

        public void practiceAboutUsWOIntake()
        {
            templateId = Utility.getEMailTemplateId('GP_Intake_Follow_up');
            populateTemplateString(templateId);
        }

        public void practiceRTM()
        {
            templateId = Utility.getEMailTemplateId('GP_Intake_RTM');
            populateTemplateString(templateId);
        }

        public void practiceAvail()
        {
            templateId = Utility.getEMailTemplateId('GP_Intake_Avail_Follow_Up');
            populateTemplateString(templateId);
        }

        private  void populateTemplateString( String templateId ){
            if(selectedList != null && !selectedList.isEmpty() ){
                Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate( templateId ,selectedList[0].leadId, selectedList[0].leadId);
                templateBody = message.getHtmlBody();
            }

        }


        public void sendEmailAction( ){
            List<Messaging.SingleEmailMessage> emailLst;
            emailLst = new List<Messaging.SingleEmailMessage>();
            for( LeadWrapper wrapper : selectedList ){

                if( wrapper.isSelected ){
                    system.debug('wrapper =>'+wrapper);
                    if( !String.isBlank(templateBody) ){


                        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate( templateId ,wrapper.leadId, wrapper.leadId);
                        emailToSend.setHTMLBody(message.getHTMLBody());
                        emailToSend.setSubject(message.getSubject());
                        emailToSend.setTargetObjectId(wrapper.leadId);
                        emailToSend.setCcAddresses(System.Label.Email_Cust_CC_Address.split(','));
                        OrgWideEmailAddress  owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='hello@synergyspecialists.co'];
                        emailToSend.setOrgWideEmailAddressId(owea.Id);

                        emailLst.add(emailToSend);

                    }
                }
            }

            system.debug('emailLst =>'+emailLst);
            if( !emailLst.isEmpty() ){
                Messaging.sendEmail( emailLst );
            }
            system.debug('emailLst =>'+emailLst);
        }

        // Send Email Button Call
        /*public Object  makeGetCallout() {
            Map<Integer, List<Lead>> leadMap= new Map<Integer, List<Lead>>();
            for(Lead leadObj:selectedList){
                if(Math.Mod(i, 40) == 0){
                    count++;
                    List<Lead> leadList= new List<Lead>();
                    leadList.add(leadObj);
                    leadMap.put(count, leadList);  
                    System.debug('leadMap if'+leadMap);
                } 
                Else{
                    List<Lead> leadList = leadMap.get(count);
                    leadList.add(leadObj);
                    leadMap.put(count, leadList);
                    System.debug('leadMap else'+leadMap);
                }
                i++;
            }       
            
        for (Integer key : leadMap.keySet()) {
            String orders = '';
            List<Lead> leadList = leadMap.get(key);
            for(Lead leadObj : leadList){
            if(leadObj.HasOptedOutOfEmail != True){
            orders = orders + '<Order Type="ET">' +
            '<EmailTo>' + leadObj.Email +'</EmailTo>' +
            '<EmailFrom>hello@synergyspecialist.co</EmailFrom>' +
            '<DisplayName>Synergy Support</DisplayName>' +
            '<EmailReplyTo>hello@synergyspecialist.co</EmailReplyTo>' +
            '<EmailSubject>Welcome to Synergy Specialists</EmailSubject>' +
            '<ReplaceLink>Yes</ReplaceLink>' +
            '<IsForward>Yes</IsForward>' +
            '<IsUnsubscribe>Yes</IsUnsubscribe>' +
            '<HtmlID>242594</HtmlID>' +
            '<HtmlFile />' +
            '<HTMLBinary />' +
            '<TextID />' +
            '<TextFile />' +
            '<TextBinary />' +
            '<Attachments>' +
            '<Attachment>' +
                '<AttachmentID />' +
               ' <AttachmentName />' +
               ' <AttachmentBinary />' +
            ' </Attachment>' +
            '</Attachments>' +
            '<RtfID />' +
            '<RtfFile />' +
            '<EnrichedID />' +
            '<EnrichedFile />' +
            '<XmlID />' +
            '<XmlFile />' +
            '</Order>';   
                System.debug('leadObj.HasOptedOutOfEmail' +leadObj.HasOptedOutOfEmail);
                System.debug('orders' +orders);
                System.debug('leadObj.Email' +leadObj.Email);
            }
           } //for end
           callHttp(orders);
           System.debug('Order'+orders);
            
            // Apex Message
            if(orders != null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Email Send successfully!'));
            }Else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Can Not Send Email!'));
            } 
            
         //Task Create   
         for(Lead leadObject : leadList){
             Task t = new Task();
             t.WhoId = leadObject.Id;
             t.Subject = 'Email Notification Send';
             t.Email__c = leadObject.Email;
             t.Status = 'Completed';
             taskList.add(t);
            }
            Upsert taskList;
       }    
        return null;    
    }
        
        public void callHttp(String orders){
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            String emailbody = //'<?xml version="1.0" encoding="UTF-8"?>' +
            '<Orders>' +
            orders +
            '</Orders>';
            req.setEndpoint('http://weblaunch.blifax.com/postAPI/xml/ETnew.aspx?UserName='+System.Label.weblaunch_UserName+'&UserPassword='+System.Label.weblaunch_UserPassword);
            req.setMethod('POST');
            System.debug('emailbody '+emailbody);
            System.debug('req.setEndpoint '+req);
            req.setBody(emailbody);
            if(!Test.isRunningTest()){
            try {
                res = http.send(req);
            } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
            }
            }
        }*/
        //Back To Lead List View Button Call
        public PageReference doAction(){
         PageReference pg = new PageReference(System.Label.Lead_Open_List_View);
         System.debug('Page Ref Url: '+ pg);
         pg.setRedirect(true);
         return pg;
    }

    public class LeadWrapper{
        public string nameStr {get;set;}
        public string emailStr {get;set;}
        public Boolean optedOutOfEmail {get;set;}
        public Boolean isSelected {get;set;}
        public String leadId {get;set;}

        public LeadWrapper( String leadIdParam ){
            List<Lead> leadLst = [SELECT Id,Name,HasOptedOutOfEmail,EMail from Lead where Id =: leadIdParam ];
            nameStr            = leadLst[0].Name;
            emailStr           = leadLst[0].EMail;
            optedOutOfEmail    = leadLst[0].HasOptedOutOfEmail;
            leadId             = leadLst[0].Id;
            isSelected         = true;
        }

        public LeadWrapper( String name, String email , Boolean hasOptedOut , String leadIdParam ){
            nameStr            = name;
            emailStr           = email;
            optedOutOfEmail    = hasOptedOut;
            leadId             = leadIdParam;
            isSelected         = true;
        }
    }
 }