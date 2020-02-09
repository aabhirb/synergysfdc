/**
 * Created by abidap on 2/3/19.
 */
@isTest
public with sharing class GPNoMatchNotificationBannerCtrlrTest {

    public static testMethod void GPNoMatchNotificationBannerControllerTest(){

        Lead leadGP = new Lead(FirstName = 'John Gp', LastName = 'Franklin gp', Email = 'test_gp'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-886-8899',
                Company = 'GP ltd', RecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType,'Practice') ,
                Street='2998 Milmont Drive' , City = 'Milpitas' , State = 'CA' , PostalCode = '95900' , Country = 'USA' , Latitude = 37.454320 , Longitude = -121.956920 ,
                Type_of_Specialists_they_want__c = 'Perio' );

        insert leadGP;

        Lead leadSP = new Lead(FirstName = 'John Gp', LastName = 'Franklin gp', Email = 'test_gp'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-886-8899',
                Company = 'GP ltd', RecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType,'Provider') ,
                Street='2998 Milmont Drive' , City = 'Milpitas' , State = 'CA' , PostalCode = '95900' , Country = 'USA' , Latitude = 37.454320 , Longitude = -121.956920 ,
                Type_of_Specialists_they_want__c = 'Perio' );

        insert leadSP;

        CustomLeadConvertController.LeadConvertWrapper wrapperGP =  CustomLeadConvertController.convertLead( leadGP.Id );
        CustomLeadConvertController.LeadConvertWrapper wrapperSP =  CustomLeadConvertController.convertLead( leadSP.Id );

        List<Lead> leadLst = [ SELECT id,convertedContactId from Lead where Id =: leadGP.Id ];
        List<COntact> contactLst = [ SELECT id ,name from COntact where id =: wrapperGP.contactObject.id ];

        if( contactLst != null && !contactLst.isEmpty()){

            PageReference pageRef = Page.GPNoMatchNotificationBanner;
            pageRef.getParameters().put('id', String.valueOf(contactLst[0].Id));
            Test.setCurrentPage(pageRef);

            ApexPages.StandardController sc = new ApexPages.StandardController(contactLst[0]);
            GPNoMatchNotificationBannerController ctrlr = new GPNoMatchNotificationBannerController(sc);

            GPNoMatchNotificationBannerController.sendEmail( contactLst[0].Id, false  );
            GPNoMatchNotificationBannerController.sendEmail( contactLst[0].Id, true  );
            GPNoMatchNotificationBannerController.sendEmail( null, false  );
        }


        /*leadLst = [ SELECT id,convertedContactId from Lead where Id =: leadSP.Id ];*/
      /*  contactLst = [ SELECT id ,name from COntact where id =: wrapperSP.contactObject.Id ];

        if( contactLst != null && !contactLst.isEmpty()){

            PageReference pageRef = Page.GPNoMatchNotificationBanner;
            pageRef.getParameters().put('id', String.valueOf(contactLst[0].Id));
            Test.setCurrentPage(pageRef);

            ApexPages.StandardController sc = new ApexPages.StandardController(contactLst[0]);
            GPNoMatchNotificationBannerController ctrlr = new GPNoMatchNotificationBannerController(sc);

            GPNoMatchNotificationBannerController.sendEmail( contactLst[0].Id, false  );
            GPNoMatchNotificationBannerController.sendEmail( contactLst[0].Id, true  );
            GPNoMatchNotificationBannerController.sendEmail( null, false  );
        }*/




    }

    public static testMethod void ProspectMatchViewExtensionTest(){

        Lead leadGP = new Lead(FirstName = 'John Gp', LastName = 'Franklin gp', Email = 'test_gp'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-886-8899',
                Company = 'GP ltd', RecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType,'Practice') ,
                Street='2998 Milmont Drive' , City = 'Milpitas' , State = 'CA' , PostalCode = '95900' , Country = 'USA' , Latitude = 37.454320 , Longitude = -121.956920 ,
                Type_of_Specialists_they_want__c = 'Perio' );

        insert leadGP;

        CustomLeadConvertController.convertLead( leadGP.Id );

        List<Lead> leadLst = [ SELECT id,convertedContactId from Lead where Id =: leadGP.Id ];
        List<COntact> contactLst = [ SELECT id ,name from COntact where id =: leadLst[0].ConvertedContactId ];
        ApexPages.StandardController sc = new ApexPages.StandardController(contactLst[0]);
        ProspectMatchViewExtension ctrlr = new ProspectMatchViewExtension(sc);

        PageReference pageRef = Page.ProspectMatchView;
        pageRef.getParameters().put('id', String.valueOf(contactLst[0].Id));
        Test.setCurrentPage(pageRef);


    }


}