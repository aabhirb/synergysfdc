/**
 * Created by abidap on 3/30/19.
 */
@isTest
public with sharing class ConfirmMatchCtrlrTest {
    static CustomLeadConvertController.LeadConvertWrapper covertedWrapperGP;
    static CustomLeadConvertController.LeadConvertWrapper covertedWrapperSP;
    static Id matchId;
    static void setUpdata(){

        Lead leadGP = new Lead(FirstName = 'John Gp', LastName = 'Franklin gp', Email = 'test_gp'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-886-8899',
                Company = 'GP ltd', RecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType,'Practice') , Lead_entered_by__c = 'Alex Molayem' , Lead_Credit_Assigned_To__c = 'Alex Molayem' ,
                Street='2998 Milmont Drive' , City = 'Milpitas' , State = 'CA' , PostalCode = '95900' , Country = 'USA' , Latitude = 37.454320 , Longitude = -121.956920 ,
                Type_of_Specialists_they_want__c = 'Perio' );
        insert leadGP;


        Lead leadSP = new Lead(FirstName = 'Tom Sp', LastName = 'lincoln sp', Email = 'test_sp'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-556-8899',
                Company = 'SP ltd', RecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType,'Provider') , SPSPECIALTY__c = 'Perio' , Lead_entered_by__c = 'Alex Molayem' , Lead_Credit_Assigned_To__c = 'Alex Molayem' ,
                Street='2999 Milmont Drive' , City = 'Milpitas' , State = 'CA' , PostalCode = '95678' , Country = 'USA' , Latitude = 37.554320 , Longitude = -121.916920 , Distance_Ready_To_Travel__c = 'Over 60 miles' );
        insert leadSP;

        covertedWrapperGP = CustomLeadConvertController.convertLead( leadGP.Id );
        covertedWrapperSP = CustomLeadConvertController.convertLead( leadSP.Id );

        Prospect_Match__c match = new Prospect_Match__c ( Match_Type__c = 'Contact', GP_Account__c = covertedWrapperGP.accountObject.Id,
                                                            GP_Contact__c = covertedWrapperGP.contactObject.Id, SP_Account__c = covertedWrapperSP.accountObject.Id,
                                                            SP_Contact__c = covertedWrapperSP.contactObject.Id , Approximate_Distance__c = 30 );

        insert match;

        matchId = match.Id;

    }

    static testMethod void ConfirmMatchCtrlrGPTest(){

        setUpdata();

        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.ConfirmMatchPage'));
        System.currentPageReference().getParameters().put('type', 'gp');
        System.currentPageReference().getParameters().put('email', covertedWrapperGP.contactObject.Email);
        System.currentPageReference().getParameters().put('matchId', matchId);

        ConfirmMatchCtrlr ctrl = new ConfirmMatchCtrlr();

        ConfirmMatchCtrlr.onclickOfAction('approve', matchId, 'gp' );
        ConfirmMatchCtrlr.onclickOfAction('approve', matchId, 'sp' );

        ConfirmMatchCtrlr.onclickOfAction('approve', matchId, 'gp' );
        ConfirmMatchCtrlr.onclickOfAction('decline', matchId, 'sp' );

        Test.stopTest();
    }

    static testMethod void ConfirmMatchCtrlrSPTest(){

        setUpdata();

        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.ConfirmMatchPage'));
        System.currentPageReference().getParameters().put('type', 'sp');
        System.currentPageReference().getParameters().put('email', covertedWrapperSP.contactObject.Email);
        System.currentPageReference().getParameters().put('matchId', matchId);

        ConfirmMatchCtrlr ctrl = new ConfirmMatchCtrlr();

        ConfirmMatchCtrlr.onclickOfAction('approve', matchId, 'gp' );
        ConfirmMatchCtrlr.onclickOfAction('approve', matchId, 'sp' );

        ConfirmMatchCtrlr.onclickOfAction('approve', matchId, 'gp' );
        ConfirmMatchCtrlr.onclickOfAction('decline', matchId, 'sp' );

        Test.stopTest();
    }
}