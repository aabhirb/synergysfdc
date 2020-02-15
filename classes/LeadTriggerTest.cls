/**
 * Created by abidap on 3/28/19.
 */
@isTest
public with sharing class LeadTriggerTest {

    @TestSetup
    static void makeData(){
        //Create GP Lead
        Lead gpLead = new Lead(LastName = 'GPLead', Company = 'GPLeadCompany' , email = 'gpLead@company.com' ,
                                    Street = '1035 Atsre Ave' , City = 'Sunnyvale' , State = 'California' , PostalCode = '94086',
                                    RecordTypeId = Utility.getsObjectRecordTypeId(Lead.getSobjectType(), 'Practice'));
        insert gpLead;

        Contact spContact = new Contact(LastName = 'SPContact', email = 'spContact@company.com' ,
                            MailingStreet = '1035 Atsre Ave' , MailingCity = 'Sunnyvale' , MailingState = 'California' , MailingPostalCode = '94086',
                            RecordTypeId = Utility.getsObjectRecordTypeId(Contact.getSobjectType(), 'Provider'),
                            SPSPECIALTY__c = 'Perio');
        insert spContact;
        Contact spContact2 = new Contact(LastName = 'SPContact', email = 'spContact@company.com' ,
                            MailingStreet = '1035 Atsre Ave' , MailingCity = 'Sunnyvale' , MailingState = 'California' , MailingPostalCode = '94086',
                            RecordTypeId = Utility.getsObjectRecordTypeId(Contact.getSobjectType(), 'Provider'),
                            SPSPECIALTY2__c = 'Perio');
        insert spContact2;

        //Create SP Lead
        //Create GP Lead
        Lead spLead = new Lead(LastName = 'SPLead', Company = 'SPLeadCompany' , email = 'spLead@company.com' ,
                                    Street = '1035 Atsre Ave' , City = 'Sunnyvale' , State = 'California' , PostalCode = '94086',
                                    RecordTypeId = Utility.getsObjectRecordTypeId(Lead.getSobjectType(), 'Provider'));
        insert spLead;

        Contact gpContact = new Contact(LastName = 'SPContact', email = 'spContact@company.com' ,
                            MailingStreet = '1035 Atsre Ave' , MailingCity = 'Sunnyvale' , MailingState = 'California' , MailingPostalCode = '94086',
                            RecordTypeId = Utility.getsObjectRecordTypeId(Contact.getSobjectType(), 'Practice'),
                            Type_of_Specialists_GP_want__c = 'Periodontist (Perio)');
        insert gpContact;
        Contact gpContact2 = new Contact(LastName = 'SPContact', email = 'spContact@company.com' ,
                            MailingStreet = '1035 Atsre Ave' , MailingCity = 'Sunnyvale' , MailingState = 'California' , MailingPostalCode = '94086',
                            RecordTypeId = Utility.getsObjectRecordTypeId(Contact.getSobjectType(), 'Practice'),
                            Type_of_Specialists_GP_want__c = 'Orthodontist (Ortho)');
        insert gpContact2;
    }
    static testMethod void testUpdateFlow(){

        Lead leadObj = new Lead( LastName = 'TestLead' , Company = 'TEstCompany' , email = 'testLead@company.com' ,
                                    Street = '1035 Atsre Ave' , City = 'Sunnyvale' , State = 'California' , PostalCode = '94086' );
        insert leadObj;

        leadObj.Status = 'Intake Sent';
        update leadObj;


        leadObj.Status = 'Intake Sent';
        leadObj.Intake_Followup_Sent__c = true;
        update leadObj;

        leadObj.Status = 'Intake Complete';
        update leadObj;

    }

    @IsTest
    static void updateTypeofSpecialtyofGPLead(){
        Lead gpLead = [SELECT Id, Type_of_Specialists_they_want__c FROM Lead WHERE RecordType.Name = 'Practice' LIMIT 1];
        gpLead.Type_of_Specialists_they_want__c = 'Perio';
        Test.startTest();
            update gpLead;
        Test.stopTest();
        //Assert statements
        System.assertEquals(2, [SELECT Count() FROM Prospect_Match__c]);
        //Again update the Type of specialists
        gpLead = [SELECT Id, Type_of_Specialists_they_want__c FROM Lead WHERE RecordType.Name = 'Practice' LIMIT 1];
        gpLead.Type_of_Specialists_they_want__c = 'Perio;Ortho';
        update gpLead;
        System.assertEquals(2, [SELECT Count() FROM Prospect_Match__c]);
    }

    @IsTest
    static void updateSpecialtyofSpLead(){
        
        Lead spLead = [SELECT Id, SPSPECIALTY__c FROM Lead WHERE RecordType.Name = 'Provider' LIMIT 1];
        spLead.SPSPECIALTY__c = 'Perio';
        Test.startTest();
            update spLead;
        Test.stopTest();
        System.assertEquals(1, [SELECT Count() FROM Prospect_Match__c]);
        //Again update the specialty
        spLead = [SELECT Id, SPSPECIALTY__c FROM Lead WHERE RecordType.Name = 'Provider' LIMIT 1];
        spLead.SPSPECIALTY__c = 'Ortho';
        update spLead;
        System.assertEquals(2, [SELECT Count() FROM Prospect_Match__c]);
        
    }
}