@isTest
public class CreateOpptControllerTest {

    testMethod private static void testgetTraditionalRecordTypeId(){
        Id recordTypeId = CreateOpptController.getTraditionalRecordTypeId();
        Id traditionalRecId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Traditional' LIMIT 1].Id;
        System.assertEquals(traditionalRecId, recordTypeId);
    }
    
    testMethod private static void testGetOpptFields(){
        List<String> fields = CreateOpptController.getOpptFields();
        //Fields list is not empty
        System.assert(!fields.isEmpty());
    } 
}