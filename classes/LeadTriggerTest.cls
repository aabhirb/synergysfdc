/**
 * Created by abidap on 3/28/19.
 */
@isTest
public with sharing class LeadTriggerTest {

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
}