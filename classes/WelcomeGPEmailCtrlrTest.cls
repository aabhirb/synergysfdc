/**
 * Created by abidap on 2/3/19.
 */
@isTest
public with sharing class WelcomeGPEmailCtrlrTest {

    public static testMethod void WelcomeGPEmailCtrlrTest(){
        Lead leadGP = new Lead(FirstName = 'John Gp', LastName = 'Franklin gp', Email = 'test_gp'+Integer.valueOf(Math.random()*1000)+'@gmail.com', MobilePhone = '650-886-8899',
                Company = 'GP ltd', RecordTypeId = Utility.getsObjectRecordTypeId(Lead.SObjectType,'Practice') ,
                Street='2998 Milmont Drive' , City = 'Milpitas' , State = 'CA' , PostalCode = '95900' , Country = 'USA' , Latitude = 37.454320 , Longitude = -121.956920 ,
                Type_of_Specialists_they_want__c = 'Perio' );
        insert leadGP;

        WelcomeGPEmailCtrlr ctrlr = new WelcomeGPEmailCtrlr();
        ctrlr.setIdToRetreive(leadGP.Id);
    }
}