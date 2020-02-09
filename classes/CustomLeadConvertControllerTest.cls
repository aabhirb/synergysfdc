/**
 * Created by abidap on 2/2/19.
 */
@isTest(seeAllData=false)
public with sharing class CustomLeadConvertControllerTest {

    static Id leadIdGP;
    static Id leadIdSP;
    static Id leadIdVC;


    public static void setUpData(){

        Lead leadGP = new Lead(FirstName = 'John Gp', LastName = 'Franklin gp', Email = 'test_gp'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-886-8899',
                                Company = 'GP ltd', RecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType,'Practice') , Lead_entered_by__c = 'Alex Molayem' , Lead_Credit_Assigned_To__c = 'Alex Molayem' ,
                                Street='2998 Milmont Drive' , City = 'Milpitas' , State = 'CA' , PostalCode = '95900' , Country = 'USA' , Latitude = 37.454320 , Longitude = -121.956920 ,
                                Type_of_Specialists_they_want__c = 'Perio' );
        insert leadGP;
        leadIdGP    = leadGP.Id;

        Lead leadSP = new Lead(FirstName = 'Tom Sp', LastName = 'lincoln sp', Email = 'test_sp'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-556-8899',
                                Company = 'SP ltd', RecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType,'Provider') , SPSPECIALTY__c = 'Perio' , Lead_entered_by__c = 'Alex Molayem' , Lead_Credit_Assigned_To__c = 'Alex Molayem' ,
                                Street='2999 Milmont Drive' , City = 'Milpitas' , State = 'CA' , PostalCode = '95678' , Country = 'USA' , Latitude = 37.554320 , Longitude = -121.916920 , Distance_Ready_To_Travel__c = 'Over 60 miles' );
        insert leadSP;
        leadIdSP    = leadSP.Id;

        Lead leadVC = new Lead(FirstName = 'VC ltd', LastName = 'Broewn vc', Email = 'test_vc'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-996-8899', Company = 'VC ltd', RecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType,'Vendor/Consultant') ,
                                 Street='3000 Milmont Drive' , City = 'Milpitas' , State = 'CA' , PostalCode = '95778' , Country = 'USA' , Latitude = 37.654320 , Longitude = -129.996920 , Lead_entered_by__c = 'Alex Molayem' , Lead_Credit_Assigned_To__c = 'Alex Molayem'  );
        insert leadVC;
        leadIdVC    = leadVC.Id;
        
        
    }
    
    
    public static testMethod void convertLeadTest(){
        setUpData();
        CustomLeadConvertController.convertLead( leadIdGP );
        CustomLeadConvertController.convertLead( leadIdSP );
        CustomLeadConvertController.convertLead( leadIdVC );
        
        
        // leadIdGP Converted

        List<Lead> leadLst = [SELECT Id,Name,ConvertedContactId from Lead where Id =: leadIdGP OR Id =: leadIdSP OR Id =: leadIdVC];
        if(leadLst != null && !leadLst.isEmpty() ){
            for( Lead lead : leadLst){
                CustomLeadConvertController.calculateProspectMatches(lead.ConvertedContactId , null , 150 );
                ProspectMatchMapViewCtrlr.getProspectMatches(lead.ConvertedContactId );
                ProspectMatchMapViewCtrlr.recalculateProspectMatches( lead.Id , 50);
                ProspectMatchMapViewCtrlr.getContactDetails(  lead.ConvertedContactId );              
            }
        }
	
        //ProspectMatchMapViewCtrlr.fakeMethod();

        List<Id> matchIdLst = new List<Id> ();
        for( Prospect_Match__c match : [SELECT id,name from Prospect_Match__c ]){
            matchIdLst.add( match.id );
        }
        
        //ProspectMatchMapViewCtrlr.updateProspectMatchWithNextSteps(  matchIdLst );
        ProspectMatchMapViewCtrlr.startMatchProcess( matchIdLst ,'gp');
        
        CustomLeadConvertController.AddressWrapper wrapper = new CustomLeadConvertController.AddressWrapper();
        wrapper.street  = '2998 Milmont Drive';
        wrapper.city = 'Milpitas';
        wrapper.state = 'CA';
        wrapper.zip = '96870';
        wrapper.latVal  = '37.454320';
        wrapper.longVal  = '-121.916920';
        wrapper.addressType = 'Home Address';

        List <CustomLeadConvertController.AddressWrapper> wrapperLst = new List <CustomLeadConvertController.AddressWrapper>{ wrapper };

        CustomLeadConvertController.updateAddressOnLead(JSON.serialize(wrapperLst),leadIdGP);

        wrapperLst[0].addressType = 'Entity Address';
        CustomLeadConvertController.updateAddressOnLead(JSON.serialize(wrapperLst),leadIdSP);

        wrapperLst[0].addressType = 'Practice Address';
        CustomLeadConvertController.updateAddressOnLead(JSON.serialize(wrapperLst),leadIdSP);

        wrapperLst[0].addressType = 'Non Compete Address';
        CustomLeadConvertController.updateAddressOnLead(JSON.serialize(wrapperLst),leadIdSP);
        
        ShowProspectMatchesCtrlr ctrlr = new ShowProspectMatchesCtrlr();
        Prospect_Match__c match = [Select id from Prospect_Match__c limit 1];
        ctrlr.setMatchId(match.Id);
        ctrlr.setMatchIdSP(match.Id); 
        ctrlr.setMatchIdSPGP(match.Id);       
        //CustomLeadConvertController.bumpTest();

        for( Lead leadSObj : leadLst ){
            if( leadSObj.Id == leadIdSP ){
                leadSObj.Status = 'Initial';
                update leadSObj;
                break;
            }
        }
        
        Test.startTest();

        CustomLeadConvertController.initiateEmailInvocation( leadIdSP , 'Endo;Perio' );
        CustomLeadConvertController.loadLeadData( leadLst[0].Id );

        List<Prospect_Match__c> matchLstToApprove = new List<Prospect_Match__c>();


        for ( Prospect_Match__c matchToApprove : [Select id from Prospect_Match__c]){
                matchToApprove.Match_Stage__c = 'Match Email Sent to SP';
            matchLstToApprove.add( matchToApprove );
        }

        update matchLstToApprove;

        matchLstToApprove = new List<Prospect_Match__c>();
        for ( Prospect_Match__c matchToApprove : [Select id from Prospect_Match__c]){
            matchToApprove.Match_Stage__c = 'Match Email Sent to GP';
            matchLstToApprove.add( matchToApprove );
        }

        update matchLstToApprove;

        matchLstToApprove = new List<Prospect_Match__c>();
        for ( Prospect_Match__c matchToApprove : [Select id from Prospect_Match__c]){
            matchToApprove.Match_Stage__c = 'Match Email Sent to SP';
            matchToApprove.Is_SP_Contract_Signed__c = true;
            matchLstToApprove.add( matchToApprove );
        }

        update matchLstToApprove;

        matchLstToApprove = new List<Prospect_Match__c>();
        for ( Prospect_Match__c matchToApprove : [Select id from Prospect_Match__c]){
                matchToApprove.Match_Stage__c = 'Match Approved';
                matchLstToApprove.add( matchToApprove );
        }

        update matchLstToApprove;



        Test.stopTest();

    }
    
    /*public static testMethod void convertLeadTestSP(){
        
        setUpData();
        CustomLeadConvertController.convertLead( leadIdSP );
        
        
        // leadIdGP Converted

        List<Lead> leadLst = [SELECT Id,Name,ConvertedContactId from Lead where Id =: leadIdSP];
        if(leadLst != null && !leadLst.isEmpty() ){
            for( Lead lead : leadLst){
                CustomLeadConvertController.calculateProspectMatches(lead.ConvertedContactId , null , 150 );
                ProspectMatchMapViewCtrlr.getProspectMatches(lead.ConvertedContactId );
                ProspectMatchMapViewCtrlr.recalculateProspectMatches( lead.Id , 50);
                ProspectMatchMapViewCtrlr.getContactDetails(  lead.ConvertedContactId );              
            }
        }
	
        //ProspectMatchMapViewCtrlr.fakeMethod();

        List<Id> matchIdLst = new List<Id> ();
        for( Prospect_Match__c match : [SELECT id,name from Prospect_Match__c ]){
            matchIdLst.add( match.id );
        }
        
        
        CustomLeadConvertController.AddressWrapper wrapper = new CustomLeadConvertController.AddressWrapper();
        wrapper.street  = '2998 Milmont Drive';
        wrapper.city = 'Milpitas';
        wrapper.state = 'CA';
        wrapper.zip = '96870';
        wrapper.latVal  = '37.454320';
        wrapper.longVal  = '-121.916920';
        wrapper.addressType = 'Home Address';

        List <CustomLeadConvertController.AddressWrapper> wrapperLst = new List <CustomLeadConvertController.AddressWrapper>{ wrapper };


        wrapperLst[0].addressType = 'Entity Address';
        CustomLeadConvertController.updateAddressOnLead(JSON.serialize(wrapperLst),leadIdSP);

        wrapperLst[0].addressType = 'Practice Address';
        CustomLeadConvertController.updateAddressOnLead(JSON.serialize(wrapperLst),leadIdSP);

        wrapperLst[0].addressType = 'Non Compete Address';
        CustomLeadConvertController.updateAddressOnLead(JSON.serialize(wrapperLst),leadIdSP);
        
        ShowProspectMatchesCtrlr ctrlr = new ShowProspectMatchesCtrlr();
        Prospect_Match__c match = [Select id from Prospect_Match__c limit 1];
        ctrlr.setMatchId(match.Id);
        ctrlr.setMatchIdSP(match.Id); 
        //CustomLeadConvertController.bumpTest();

        for( Lead leadSObj : leadLst ){
            if( leadSObj.Id == leadIdSP ){
                leadSObj.Status = 'Initial';
                update leadSObj;
                break;
            }
        }
        
        Test.startTest();

        CustomLeadConvertController.initiateEmailInvocation( leadIdSP , 'Endo;Perio' );
        CustomLeadConvertController.loadLeadData( leadLst[0].Id );

        List<Prospect_Match__c> matchLstToApprove = new List<Prospect_Match__c>();

        for ( Prospect_Match__c matchToApprove : [Select id from Prospect_Match__c]){
                matchToApprove.Match_Stage__c = 'Match Email Sent to SP';
            matchLstToApprove.add( matchToApprove );
        }

        update matchLstToApprove;

        matchLstToApprove = new List<Prospect_Match__c>();
        for ( Prospect_Match__c matchToApprove : [Select id from Prospect_Match__c]){
                matchToApprove.Match_Stage__c = 'Match Approved';
                matchLstToApprove.add( matchToApprove );
        }

        update matchLstToApprove;



        Test.stopTest();
    } */
    
    public static testMethod void ProspectMatchTest(){
        Account acctGP1 = new Account(Name='Test',RecordTypeId = Utility.getsObjectRecordTypeId(Account.SObjectType,'Practice'));
        insert acctGP1;
        Id acctIdGP1    = acctGP1.Id;
        
        Lead leadGP1 = new Lead(FirstName = 'John Gp1', LastName = 'Franklin gp1', Email = 'test_gp2'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-896-8899',
                                Company = 'GP ltd', RecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType,'Practice') , Lead_entered_by__c = 'Alex Molayem' , Lead_Credit_Assigned_To__c = 'Alex Molayem' ,
                                Street='2998 Milmont Drive' , City = 'Milpitas' , State = 'CA' , PostalCode = '95900' , Country = 'USA' , Latitude = 37.454320 , Longitude = -121.956920 ,
                                Type_of_Specialists_they_want__c = 'Endo' );
        insert leadGP1;
        
        Id leadIdGP1    = leadGP1.Id;
        
        Lead leadSP1 = new Lead(FirstName = 'Tom Sp1', LastName = 'lincoln sp1', Email = 'test_sp1'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-576-8899',
                                Company = 'SP ltd', RecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType,'Provider') , SPSPECIALTY__c = 'Endo' , Lead_entered_by__c = 'Alex Molayem' , Lead_Credit_Assigned_To__c = 'Alex Molayem' ,
                                Street='2999 Milmont Drive' , City = 'Milpitas' , State = 'CA' , PostalCode = '95678' , Country = 'USA' , Latitude = 37.554320 , Longitude = -121.916920 , Distance_Ready_To_Travel__c = 'Over 60 miles' );
        insert leadSP1;
        Id leadIdSP1    = leadSP1.Id;
        
        Contact cntSP1 = new Contact(FirstName = 'Tom1', LastName = 'lincoln 1', Email = 'test_sp33'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-576-8899',
                                     RecordTypeId = Utility.getsObjectRecordTypeId(Contact.SObjectType,'Provider') , SPSPECIALTY__c = 'Endo'  ,Type_of_Specialists_GP_want__c ='Endo',
                                     MailingStreet='2999 Milmont Drive' , MailingCity = 'Milpitas' , MailingState = 'CA' , MailingPostalCode = '95678' , MailingCountry = 'USA' , Distance_Ready_To_Travel__c = 'Over 60 miles' );
        insert cntSP1;
        Id cntIdSP1    = cntSP1.Id;
        
        Contact cntGP1 = new Contact(FirstName = 'Tom12', LastName = 'lincoln 2', Email = 'test_sp331'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-576-8899',
                                     RecordTypeId = Utility.getsObjectRecordTypeId(Contact.SObjectType,'Practice') , SPSPECIALTY__c = 'Ortho'  ,Type_of_Specialists_GP_want__c ='Endo',
                                     MailingStreet='2999 Milmont Drive' , MailingCity = 'Milpitas' , MailingState = 'CA' , MailingPostalCode = '95678' , MailingCountry = 'USA' , Distance_Ready_To_Travel__c = 'Over 60 miles' );
        insert cntGP1;
        Id cntIdGP1    = cntGP1.Id;
        
        
        Prospect_Match__c PM = new Prospect_Match__c(Match_Type__c='Lead', GP_Account__c=acctIdGP1, GP_Contact__c=cntIdGP1, SP_Contact__c=cntIdSP1, SP_Lead__c=leadIdSP1,GP_Lead__c=leadIdGP1 );
        insert PM;
        
        Id prosMatch    = PM.Id;
        
        Test.startTest();
        ProspectMatchMapViewCtrlr.getProspectMatches(cntIdSP1);
        ProspectMatchMapViewCtrlr.enQueueMatch(prosMatch);
        
        ProspectMatchMapViewCtrlr.getContactDetails(  leadIdGP1 );
	  	ProspectMatchMapViewCtrlr.getProspectMatches(leadIdGP1 );
        Test.stopTest();
    }
}