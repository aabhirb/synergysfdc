@IsTest
public class ProposedDateTriggerHandlerTest {
 private static testMethod void doTest() {
     List<Proposed_Date__c> pdList = new List<Proposed_Date__c>();
Date closeDt = Date.Today();

 date myDate = date.today();
    Account acctObj = new Account(Name = 'Test-Name');
     insert acctObj;
     
     Contact contactGP = new Contact(FirstName = 'GP_Fname', LastName = 'GP_LName', Email = 'gp_Contact@ss.co',
                                    OM_Email__c = 'gp_contact_om@ss.co', Practice_Email__c = 'gp_contact_pr@ss.co');
     insert  contactGP;  
     //Create Opportunity
     opportunity oppr = new opportunity(Name='testing DIE 4/6/2015' ,  AccountId= acctObj.Id, StageName = 'Prospecting', 
                                   CloseDate = closeDt,GP_Contact__c = contactGP.Id , Primary_Contact__c = contactGP.Id );
     insert oppr;
     String rcdid = Schema.SObjectType.Proposed_Date__c.getRecordTypeInfosByName().get('Meeting').getRecordTypeId();
     Proposed_Date__c pd = new Proposed_Date__c();
     pd.Name = 'Test';
     pd.RecordTypeId = rcdid;
     pd.Start_Time__c = system.now() - 10;
     pd.End_Time__c = system.today();
     pd.Type__c = 'Meeting';
     pd.Status__c = 'Approved';
     pd.Related_Opportunity__c = oppr.Id;
     //pd.GP_Contact__c = '';
     
     insert pd;
    // pdList.add(pd);
    
     pd.End_Time__c = system.today() + 2;
      pd.Type__c = 'Treatment';
     pd.Status__c = 'Proposed By GP';
     update pd;
     
     pd.Type__c = 'Meeting';
     pd.Status__c = 'Request Meeting Outcome';
     update pd;
     
     
 }
}