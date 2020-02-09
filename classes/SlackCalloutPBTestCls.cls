@IsTest
public class SlackCalloutPBTestCls {
    private static testMethod void doTest() {

        Test.startTest();
       	List<SlackCalloutProcessBuilder.Oppty> oppList = new List<SlackCalloutProcessBuilder.Oppty>();
        SlackCalloutProcessBuilder.Oppty o = new SlackCalloutProcessBuilder.Oppty();
        o.leadName = 'Test';
        o.url = 'google';
        o.type= 'test';
        oppList.add(o);
        try{
        SlackCalloutProcessBuilder.postToSlack(oppList);
        }catch(Exception e){}
        Test.stopTest();
	}
}