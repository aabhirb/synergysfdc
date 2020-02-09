//Utility class to send sms using SMS magic
public class SendSMSUtility {
    
    public static String senderId;
    public static void sendConciergeReservationSMS(List<Concierge_Details__c> conciergeDetailLst, smagicinteract__SMS_Template__c template){
        List <smagicinteract__smsmagic__c> smsObjectList = new List <smagicinteract__smsmagic__c>();
        List<Task> tasksToInsert = new List<Task>();
        Map<Id,Task> invoiceToTaskMap = new Map<Id,Task>();
        //Query the Phone and name information from invoice object
        List<Opportunity_Line_Item__c> invoiceLst = [SELECT Id, Opportunity__r.Primary_Contact__r.MobilePhone,
                                                     Opportunity__r.Primary_Contact__r.Name,
                                                     Opportunity__r.Primary_Contact__c
                                                     FROM Opportunity_Line_Item__c 
                                                     WHERE Concierge_Details__c IN: conciergeDetailLst];
        List<Id> recordIds = new List<Id>();
        
        for(Opportunity_Line_Item__c invoice : invoiceLst) {
            recordIds.add(invoice.Id);
        }
        System.debug('recordIds  '+recordIds);
        
        //Call the method to resolve the merge fields of template only if record Ids is not null and template is not null
        if(!recordIds.isEmpty() && template != null){
            Map<SObject,String> objectTextMap = new smagicinteract.TemplateResolver().resolveTemplate(template.smagicinteract__Text__c, 
                                                                                            invoiceLst.getSObjectType(),
                                                                                            recordIds, 
                                                                                            new Set<String>());
            System.debug('objectTextMap  '+objectTextMap);
            Map<Id, String> mapInvoiceToText = new Map<Id, String>();
            for(SObject sObjectRec : objectTextMap.keySet()){
                mapInvoiceToText.put(sObjectRec.Id, objectTextMap.get(sObjectRec));
            }
            
            //Get the senderId value from smagicinteract__senderId__c object if senderId is not set
            if(String.isBlank(senderId)){
                smagicinteract__SMS_SenderId__c senderObject = [SELECT Id, smagicinteract__senderId__c FROM smagicinteract__SMS_SenderId__c LIMIT 1];
                senderId = senderObject != null ? senderObject.smagicinteract__senderId__c : '';
            }
            
            for(Opportunity_Line_Item__c invoice : invoiceLst) {
                smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
                smsObject.smagicinteract__SenderId__c = senderId; //Getting the value using a query
                smsObject.smagicinteract__PhoneNumber__c = invoice.Opportunity__r.Primary_Contact__r.MobilePhone;
                smsObject.smagicinteract__Name__c = invoice.Opportunity__r.Primary_Contact__r.Name; // records name        
                smsObject.smagicinteract__SMSText__c = mapInvoiceToText.get(invoice.Id);
                smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you 
                                                                    //specify the value as 1 then sms will not get send but 
                                                                    //entry of sms will get create under SMS History object
                
                smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
                smsObject.smagicinteract__Direction__c = 'OUT';
                smsObject.opportunity_line_item__c = invoice.Id;
                smsObjectList.add(smsObject);
                
                System.debug('sms object '+smsObject);
                
                //Create task object in similar way on Invoice
                Task taskObject = new Task();
                taskObject.Subject = template.smagicinteract__Name__c + ' SMS';
                taskObject.Status = 'Completed';
                taskObject.Description = mapInvoiceToText.get(invoice.Id);
                taskObject.WhoId = invoice.Opportunity__r.Primary_Contact__c;
                taskObject.WhatId = invoice.Id;
                invoiceToTaskMap.put(invoice.Id, taskObject);
            }
            //Handle error while insertion
            List<String> errorLst = new List<String>();
            List<Id> smsHistoryIds = new List<Id>(); 
            Database.SaveResult[] srList = Database.insert(smsObjectList, false);
            
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){
                    //Store the Id of the SMS history object which was inserted successfully
                    smsHistoryIds.add(sr.getId());
                } else {
                    for(Database.Error err : sr.getErrors()){
                        errorLst.add(err.getMessage());
                    }
                }
            }
            System.debug('smsHistoryIds  '+smsHistoryIds);
            //Query the Invoice Id from the SMS History object which was inserted successfully
            for(smagicinteract__smsmagic__c smsHistoryObj : [SELECT opportunity_line_item__c FROM smagicinteract__smsmagic__c
                                                                WHERE Id IN: smsHistoryIds]){
                //Insert the tasks related to the invoice id
                System.debug('smsHistoryObj  '+smsHistoryObj.opportunity_line_item__c);
                tasksToInsert.add(invoiceToTaskMap.get(smsHistoryObj.opportunity_line_item__c));
            }
            insert tasksToInsert;
            
            //Check if any sms history object was not inserted
            if(errorLst.size() > 0){
                throw new ConciergeDetailTriggerHandler.TriggerException('Error '+errorLst);
            }
        }
        
    }
    
}