//Utility class to send sms using SMS magic
public class SendSMSUtility {
    
    public static final String SENDER_ID = '12133194239';
    public static final String  INVOICE_SENDER_ID = '13108072208'; 
    public static String senderId;
    //Ankita A: 10 Feb 2020: Sender Id for sms related to Invoice
    public static String invoiceSMSSenderId; 
    //Static error list
    public static List<String> errorLst = new List<String>();
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
                //Ankita A: 10 Feb 2020: Using senderId for Invoice sms
                smagicinteract__SMS_SenderId__c senderObject = [SELECT Id, smagicinteract__senderId__c FROM smagicinteract__SMS_SenderId__c 
                                                            WHERE smagicinteract__senderId__c =: INVOICE_SENDER_ID LIMIT 1];
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
            List<String> conciergeErrorLst = new List<String>();
            List<Id> smsHistoryIds = new List<Id>(); 
            Database.SaveResult[] srList = Database.insert(smsObjectList, false);
            
            for(Database.SaveResult sr : srList){
                if(sr.isSuccess()){
                    //Store the Id of the SMS history object which was inserted successfully
                    smsHistoryIds.add(sr.getId());
                } else {
                    for(Database.Error err : sr.getErrors()){
                        conciergeErrorLst.add(err.getMessage());
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
            if(conciergeErrorLst.size() > 0){
                throw new ConciergeDetailTriggerHandler.TriggerException('Error '+conciergeErrorLst);
            }
        }
        
    }
    
    public static void sendIntakeSMS(Map<Id, SObject> mapSObject, smagicinteract__SMS_Template__c template, Boolean isSP){
        List<Id> recordIds = new List<Id>(mapSObject.keySet());
                
        //Call the method to resolve the merge fields of template only if record Ids is not null and template is not null
        if(!recordIds.isEmpty() && template != null){
            Map<Id, String> mapSObjectToText = resolveTemplate(recordIds, template);
            
            //Get the senderId value from smagicinteract__senderId__c object if senderId is not set
            if(String.isBlank(senderId)){
                //Ankita A: 10 Feb 2020: Below senderId will be used for intake SMS
                smagicinteract__SMS_SenderId__c senderObject = [SELECT Id, smagicinteract__senderId__c FROM smagicinteract__SMS_SenderId__c WHERE 
                                                            smagicinteract__senderId__c = :SENDER_ID];
                senderId = senderObject != null ? senderObject.smagicinteract__senderId__c : '';
            }
            
            //Create sms object 
            List <smagicinteract__smsmagic__c> smsObjectList = createSMSObject(mapSObject.values(), mapSObjectToText, 'Lead', isSP);
        	Map<Id,Task> idToTaskMap = createTasks(mapSObject.values(), template, mapSObjectToText, 'Lead', isSP); 
            
            //Handle error while insertion
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
            
            List<Task> tasksToInsert = new List<Task>();

            //Query the Invoice Id from the SMS History object which was inserted successfully
            for(smagicinteract__smsmagic__c smsHistoryObj : [SELECT smagicinteract__Lead__c FROM smagicinteract__smsmagic__c WHERE Id IN: smsHistoryIds]){
                //Insert the tasks
                tasksToInsert.add(idToTaskMap.get(smsHistoryObj.smagicinteract__Lead__c));
            }
            insert tasksToInsert;
        }
    }
    
    public static void sendOptInSMS(Map<Id, SObject> mapSObject, smagicinteract__SMS_Template__c template, Boolean isSP){
        List<Id> recordIds = new List<Id>(mapSObject.keySet());
                
        //Call the method to resolve the merge fields of template only if record Ids is not null and template is not null
        if(!recordIds.isEmpty() && template != null){
            Map<Id, String> mapSObjectToText = resolveTemplate(recordIds, template);
            
            //Get the senderId value from smagicinteract__senderId__c object if senderId is not set
            if(String.isBlank(senderId)){
                //Ankita A: Below senderid will be used for opt in sms
                smagicinteract__SMS_SenderId__c senderObject = [SELECT Id, smagicinteract__senderId__c FROM smagicinteract__SMS_SenderId__c WHERE 
                                                                    smagicinteract__senderId__c = :SENDER_ID];
                senderId = senderObject != null ? senderObject.smagicinteract__senderId__c : '';
            }
            
            //Create sms object 
            List <smagicinteract__smsmagic__c> smsObjectList = createSMSObject(mapSObject.values(), mapSObjectToText, 'Prospect_Match__c', isSP);
        	Map<Id,Task> idToTaskMap = createTasks(mapSObject.values(), template, mapSObjectToText, 'Prospect_Match__c', isSP); 
            
            //Handle error while insertion
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
            System.debug('smsHistoryIds ' +smsHistoryIds);
            
            List<Task> tasksToInsert = new List<Task>();
            //Query the Invoice Id from the SMS History object which was inserted successfully
            for(smagicinteract__smsmagic__c smsHistoryObj : [SELECT prospect_match__c FROM smagicinteract__smsmagic__c WHERE Id IN: smsHistoryIds]){
                //Insert the tasks
                tasksToInsert.add(idToTaskMap.get(smsHistoryObj.prospect_match__c));
            }
            insert tasksToInsert;
            
        }
    }
    
    public static void sendFollowupSMS(Map<Id, SObject> mapSObject, smagicinteract__SMS_Template__c template, Boolean isSP){
        List<Id> recordIds = new List<Id>(mapSObject.keySet());
                
        //Call the method to resolve the merge fields of template only if record Ids is not null and template is not null
        if(!recordIds.isEmpty() && template != null){
            Map<Id, String> mapSObjectToText = resolveTemplate(recordIds, template);
            
            //Get the senderId value from smagicinteract__senderId__c object if senderId is not set
            if(String.isBlank(senderId)){
                //Ankita A: 10 Feb 2020: Below senderid will be used for followup sms 
                smagicinteract__SMS_SenderId__c senderObject = [SELECT Id, smagicinteract__senderId__c FROM smagicinteract__SMS_SenderId__c WHERE 
                                                                    smagicinteract__senderId__c = :SENDER_ID];
                senderId = senderObject != null ? senderObject.smagicinteract__senderId__c : '';
            }
            
            //Create sms object 
            List <smagicinteract__smsmagic__c> smsObjectList = createSMSObject(mapSObject.values(), mapSObjectToText, 'Opportunity', isSP);
        	Map<Id,Task> idToTaskMap = createTasks(mapSObject.values(), template, mapSObjectToText, 'Opportunity', isSP); 
            
            //Handle error while insertion
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
            
            List<Task> tasksToInsert = new List<Task>();
            //Query the Invoice Id from the SMS History object which was inserted successfully
            for(smagicinteract__smsmagic__c smsHistoryObj : [SELECT smagicinteract__Opportunity__c FROM smagicinteract__smsmagic__c WHERE Id IN: smsHistoryIds]){
                //Insert the tasks
                tasksToInsert.add(idToTaskMap.get(smsHistoryObj.smagicinteract__Opportunity__c));
            }
            insert tasksToInsert;
            
        }
    }
    
    public static void sendInvoiceSMS(Map<Id, SObject> mapSObject, smagicinteract__SMS_Template__c template, Boolean isSP){
        List<Id> recordIds = new List<Id>(mapSObject.keySet());
                
        //Call the method to resolve the merge fields of template only if record Ids is not null and template is not null
        if(!recordIds.isEmpty() && template != null){
            Map<Id, String> mapSObjectToText = resolveTemplate(recordIds, template);
            
            //Get the senderId value from smagicinteract__senderId__c object if senderId is not set
            if(String.isBlank(invoiceSMSSenderId)){
                //Ankita A: 10 Feb 2020: Different senderId will be used for Invoice sms
                smagicinteract__SMS_SenderId__c senderObject = [SELECT Id, smagicinteract__senderId__c FROM smagicinteract__SMS_SenderId__c WHERE 
                                                               smagicinteract__senderId__c =: INVOICE_SENDER_ID ];
                invoiceSMSSenderId = senderObject != null ? senderObject.smagicinteract__senderId__c : '';
            }
            
            //Create sms object 
            List <smagicinteract__smsmagic__c> smsObjectList = createSMSObject(mapSObject.values(), mapSObjectToText, 'Invoice', isSP);
        	Map<Id,Task> idToTaskMap = createTasks(mapSObject.values(), template, mapSObjectToText, 'Invoice', isSP); 
            
            //Handle error while insertion
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
            
            List<Task> tasksToInsert = new List<Task>();
            //Query the Invoice Id from the SMS History object which was inserted successfully
            for(smagicinteract__smsmagic__c smsHistoryObj : [SELECT opportunity_line_item__c FROM smagicinteract__smsmagic__c WHERE Id IN: smsHistoryIds]){
                //Insert the tasks
                tasksToInsert.add(idToTaskMap.get(smsHistoryObj.opportunity_line_item__c));
            }
            insert tasksToInsert;
        }
    }
    
    private static Map<Id, String> resolveTemplate(List<Id> recordIds, smagicinteract__SMS_Template__c template){
        Map<Id, String> mapSObjectToText = new Map<Id, String>();
        //Call the SMS Magic method to resolve the merge fields of template only if record Ids is not null and template is not null
        if(!recordIds.isEmpty() && template != null){
            Map<SObject,String> objectTextMap = new smagicinteract.TemplateResolver().resolveTemplate(template.smagicinteract__Text__c, 
                                                                                                      recordIds[0].getSObjectType(),
                                                                                                      recordIds, 
                                                                                                      new Set<String>());
            System.debug('objectTextMap  '+objectTextMap);
            for(SObject sObjectRec : objectTextMap.keySet()){
                mapSObjectToText.put(sObjectRec.Id, objectTextMap.get(sObjectRec));
            }
        }
        return mapSObjectToText;
    }
    
    private static List<smagicinteract__smsmagic__c> createSMSObject(List<SObject> sObjects, Map<Id, String> mapSObjectToText, String objectName, Boolean isSP){
        List <smagicinteract__smsmagic__c> smsObjectList = new List <smagicinteract__smsmagic__c>();
        for(SObject sObjectRec : sObjects) {
            smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c();
            smsObject.smagicinteract__SenderId__c = senderId; //Getting the value using a query
            smsObject.smagicinteract__SMSText__c = mapSObjectToText.get(sObjectRec.Id);
            smsObject.smagicinteract__disableSMSOnTrigger__c = 0; // this field either be 0 or 1, if you 
            //specify the value as 1 then sms will not get send but 
            //entry of sms will get create under SMS History object
            
            smsObject.smagicinteract__external_field__c = smagicinteract.ApexAPI.generateUniqueKey();
            smsObject.smagicinteract__Direction__c = 'OUT';
            smsObject = setObjectSpecificInfo(smsObject, sObjectRec, objectName, isSP); 
            smsObjectList.add(smsObject);
            
            System.debug('sms object '+smsObject);
            
        }
        return smsObjectList;
    }
    
    private static smagicinteract__smsMagic__c setObjectSpecificInfo(smagicinteract__smsMagic__c smsObject, SObject sObjectRec, String sObjectName, Boolean isSP){
    //Get the object name from the sObjectRec
        if(sObjectName.equalsIgnoreCase('Lead')){
            smsObject.smagicinteract__PhoneNumber__c = toString(sObjectRec.get('MobilePhone'));
            smsObject.smagicinteract__Name__c = toString(sObjectRec.get('Name'));    
            smsObject.smagicinteract__Lead__c = sObjectRec.Id;
            
        } else if(sObjectName.equalsIgnoreCase('Contact')){
            smsObject.smagicinteract__PhoneNumber__c = toString(sObjectRec.get('MobilePhone'));
            smsObject.smagicinteract__Name__c = toString(sObjectRec.get('Name'));    
            smsObject.smagicinteract__Contact__c = sObjectRec.Id;
            
        }else if(sObjectName.equalsIgnoreCase('Opportunity')){
            smsObject.smagicinteract__PhoneNumber__c = isSP ? toString(sObjectRec.getSObject('Primary_Contact__r').get('MobilePhone')) :
                                                            toString(sObjectRec.getSObject('GP_Contact__r').get('MobilePhone'));
            
            smsObject.smagicinteract__Name__c = isSP ? toString(sObjectRec.getSObject('Primary_Contact__r').get('Name')) :
                                                    toString(sObjectRec.getSObject('GP_Contact__r').get('Name'));
            smsObject.smagicinteract__Opportunity__c = sObjectRec.Id;
            
        } else if(sObjectName.equalsIgnoreCase('Prospect_Match__c')){
            smsObject.smagicinteract__PhoneNumber__c = isSP ? toString(sObjectRec.getSObject('SP_Contact__r').get('MobilePhone')) :
                                                            toString(sObjectRec.getSObject('GP_Contact__r').get('MobilePhone'));
            
            smsObject.smagicinteract__Name__c = isSP ? toString(sObjectRec.getSObject('SP_Contact__r').get('Name')) :
                                                    toString(sObjectRec.getSObject('GP_Contact__r').get('Name'));
            smsObject.prospect_match__c = sObjectRec.Id;
            
        } else if(sObjectName.equalsIgnoreCase('opportunity_line_item__c') && isSP){
            smsObject.smagicinteract__PhoneNumber__c = isSP ? toString(sObjectRec.getSObject('Opportunity__r').getSObject('Primary_Contact__r').get('MobilePhone')) :
                                                            toString(sObjectRec.getSObject('Opportunity__r').getSObject('GP_Contact__r').get('MobilePhone'));
            
            smsObject.smagicinteract__Name__c = isSP ? toString(sObjectRec.getSObject('Opportunity__r').getSObject('Primary_Contact__r').get('Name')) :
                                                    toString(sObjectRec.getSObject('Opportunity__r').getSObject('GP_Contact__r').get('Name'));
            
            smsObject.opportunity_line_item__c = sObjectRec.Id;

        } 
        return smsObject;
    }

    private static Map<Id, Task> createTasks(List<SObject> sObjects, smagicinteract__SMS_Template__c template, Map<Id, String> mapSObjectToText,
                                            String sObjectName, Boolean isSP){
        Map<Id,Task> idToTaskMap = new Map<Id,Task>();
        for(SObject sObjectRec : sObjects){
            Task taskObject = new Task();
            taskObject.Subject = template.smagicinteract__Name__c + ' SMS';
            taskObject.Status = 'Completed';
            taskObject.Description = mapSObjectToText.get(sObjectRec.Id);
            //If object is Lead or Contact
            if(sObjectName.equalsIgnoreCase('Lead') || sObjectName.equalsIgnoreCase('Contact')){
                taskObject.WhoId = sObjectRec.Id;
            }
            //If object is Opportunity
            if(sObjectName.equalsIgnoreCase('Opportunity')){
                taskObject.WhatId = sObjectRec.Id;
                taskObject.WhoId = isSP ? (Id)sObjectRec.get('Primary_Contact__c') : (Id)sObjectRec.get('GP_Contact__c');
            } 
            //If object is Prospect Match
            if(sObjectName.equalsIgnoreCase('Prospect_Match__c')){
                taskObject.WhatId = sObjectRec.Id;
                taskObject.WhoId = isSP ? (Id)sObjectRec.get('SP_Contact__c') : (Id)sObjectRec.get('GP_Contact__c');
            }
            //If object is Invoice
            if(sObjectName.equalsIgnoreCase('Invoice')){
                taskObject.WhatId = sObjectRec.Id;
                taskObject.WhoId = isSP ? (Id)sObjectRec.getSObject('Opportunity__r').get('Primary_Contact__c') :
                			(Id)sObjectRec.getSObject('Opportunity__r').get('GP_Contact__c');
            }
            
            idToTaskMap.put(sObjectRec.Id, taskObject);
        }
        return idToTaskMap;
    }

    private static String toString(Object value){
        return value != null ? value.toString() : '';
    }
    
}