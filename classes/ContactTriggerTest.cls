/**
 * Created by abidap on 3/28/19.
 */
@isTest
public with sharing class ContactTriggerTest {

    static testMethod void testContactTrigger(){


        Lead leadSP = new Lead(FirstName = 'Tom Sp', LastName = 'lincoln sp', Email = 'test_sp'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-556-8899',
                Company = 'SP ltd', RecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType,'Provider') , SPSPECIALTY__c = 'Perio' , Lead_entered_by__c = 'Alex Molayem' , Lead_Credit_Assigned_To__c = 'Alex Molayem' ,
                Street='2999 Milmont Drive' , City = 'Milpitas' , State = 'CA' , PostalCode = '95678' , Country = 'USA' );
        insert leadSP;
        List<Contact> contactLst = new List<Contact>();
        CustomLeadConvertController.convertLead( leadSP.Id );

        List<Lead> leadLst = [SELECT Id,Name,ConvertedContactId from Lead where Id =: leadSP.Id  ];
        Set<Id> contactIdSet = new Set<id>();
        if(leadLst != null && !leadLst.isEmpty() ){
            for( Lead lead : leadLst){

                contactIdSet.add( leadLst[0].ConvertedContactId );
            }
        }

        Test.startTest();

        GeoCodeAddressAsynch asynchInst = new GeoCodeAddressAsynch();
        asynchInst.sobjectLst = new List<SObject>{leadSP};
        asynchInst.sobjectType = 'Lead';

        System.enqueueJob( asynchInst );

         for( Contact contactObj : [SELECT Id,Name from Contact where Id IN: contactIdSet ] ){
             contactObj.Contact_Status__c = 'Contract Signed';
             contactLst.add( contactObj );
         }

         update contactLst;

        Test.stopTest();
    }
}