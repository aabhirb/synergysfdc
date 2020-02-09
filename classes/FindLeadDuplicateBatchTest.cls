@isTest
public class FindLeadDuplicateBatchTest {
    
    @testSetup
    private static void createTestData(){
        //Create duplicate leads
        Lead leadObj1 = new Lead(FirstName = 'John', LastName = 'Smith', Email = 'john@smithtest.com', Company = 'ABC');
        Lead leadObj2 = new Lead(FirstName = 'John', LastName = 'Smith', Email = 'john@smithtest.com', Company = 'ABC');
        Lead leadObj3 = new Lead(FirstName = 'John', LastName = 'Smith', Email = 'john@smithtest.com', Company = 'ABC');
        Lead leadObj4 = new Lead(FirstName = 'Harry', LastName = 'Smith', Email = 'harry@smithtest.com', Company = 'ABC');
        List<Lead> leadLst = new List<Lead>{leadObj1, leadObj2, leadObj3, leadObj4};
        insert leadLst;
    }
    
    testMethod private static void testBatch(){
        Test.startTest();
        FindLeadDuplicateBatch duplicateBatch = new FindLeadDuplicateBatch();
        Id batchId = Database.executeBatch(duplicateBatch);
        Test.stopTest();
        
        //Assert
        //Only one duplicate record set will be inserted as we have three leads which are duplicate
        System.assertEquals(1, [SELECT Count() FROM DuplicateRecordSet]);
        System.assertEquals(3, [SELECT Count() FROM DuplicateRecordItem]);
    }

}