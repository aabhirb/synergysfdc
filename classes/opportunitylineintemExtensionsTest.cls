@IsTest
public class opportunitylineintemExtensionsTest {

 private static testMethod void doTest() {
    List<Opportunity> oppList = new List<Opportunity>();
    Opportunity opp = new Opportunity(Name='test opp',StageName='Closed Won', Probability = 100, CloseDate=system.today());
    insert opp;
     
    Opportunity opp1 = new Opportunity(Name='test opp1',StageName='Closed Won', Probability = 100, CloseDate=system.today());
    insert opp1; 
    oppList.add(opp);
    oppList.add(opp1);
     

//create your opportunity line item.  This assumes you already have an opportunity created, called opp
Opportunity_Line_Item__c oli = new Opportunity_Line_Item__c(
     Opportunity__c = opp.Id,
     Treatment_Date__c = system.today(),
     Invoice_Due_Date__c = system.today(),
     Membrane_Cost__c = 60
);
insert oli;     
     
     ApexPages.StandardController sc = new ApexPages.StandardController(oli);
     opportunitylineintemExtensionsController oc = new opportunitylineintemExtensionsController(sc);
     oc.oli = oli;
     oc.getopp();
     oc.getopp1();
     oc.getAdjustmetList();
     oc.getbLineAdjustmetList();
     try{
         Test.startTest();
     	oc.saveAttachement();
         Test.stopTest();
     }catch(Exception e){
         
     }
 }
    
}