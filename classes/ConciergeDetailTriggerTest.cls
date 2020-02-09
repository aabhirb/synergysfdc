@isTest
public class ConciergeDetailTriggerTest {

    @testSetup
    private static void createTestData(){
        //Create opportunity object
        Contact contactObj = new Contact(firstname = 'John', lastname='Smith', email = 'abc@test.com', MobilePhone = '1234567890');
        insert contactObj;
        
        Opportunity opptObject = new Opportunity(Name='Test Opportunity',StageName='Closed Won', Probability = 100, CloseDate=system.today());
        opptObject.Primary_Contact__c = contactObj.Id;
        opptObject.GP_Contact__c = contactObj.id;
        insert opptObject;
        //Create Concierge Detail object and link it with the Invoice
        Concierge_Details__c conciergeDetail1 = new Concierge_Details__c(Driver_Name__c = 'John Smith',
                                                                       Driver_Needed__c	= true,
                                                                       Drop_Off_Time__c = DateTime.now(),
                                                                       POD_Needed__c = false);
        insert conciergeDetail1;
        Opportunity_Line_Item__c invoiceObj1 = new Opportunity_Line_Item__c(
                                                Opportunity__c = opptObject.Id,
                                                Treatment_Date__c = System.today(),
                                                Invoice_Due_Date__c = System.today(),
                                                Status__c = 'Invoice Approved',
        										Concierge_Details__c = conciergeDetail1.Id);
        insert invoiceObj1;
        
        //Create another Concierge Detail object and link it with Invoice
        Concierge_Details__c conciergeDetail2 = new Concierge_Details__c(Driver_Name__c = 'Harry Abel',
                                                                       Driver_Needed__c	= true,
                                                                       Drop_Off_Time__c = DateTime.now(),
                                                                       POD_Needed__c = false,
                                                                        is_Flight_Confirmed__c = true);
        insert conciergeDetail2;
        Opportunity_Line_Item__c invoiceObj2 = new Opportunity_Line_Item__c(
            Opportunity__c = opptObject.Id,
            Treatment_Date__c = System.today() + 1,
            Invoice_Due_Date__c = System.today(),
            Membrane_Cost__c = 50,
            Status__c = 'Invoice Sent for Payment',
            Concierge_Details__c = conciergeDetail2.Id
        );
        insert invoiceObj2;
        
        //Insert SMS templates
        String textTemplate = 'Dear Dr. {!opportunity_line_item__c.Opportunity__r.Primary_Contact__r.lastname}, Synergy Concierge has made reservation for you.';
        smagicinteract__SMS_Template__c template1 = new smagicinteract__SMS_Template__c(
            smagicinteract__Name__c = 'Concierge Car Reservation',
            smagicinteract__ObjectName__c = 'opportunity_line_item__c',
            smagicinteract__Text__c = textTemplate
        );
        smagicinteract__SMS_Template__c template2 = new smagicinteract__SMS_Template__c(
            smagicinteract__Name__c = 'Concierge Hotel Reservation',
            smagicinteract__ObjectName__c = 'opportunity_line_item__c',
            smagicinteract__Text__c = textTemplate
        );
        smagicinteract__SMS_Template__c template3 = new smagicinteract__SMS_Template__c(
            smagicinteract__Name__c = 'Concierge Flight Reservation',
            smagicinteract__ObjectName__c = 'opportunity_line_item__c',
            smagicinteract__Text__c = textTemplate
        );
        
        List<smagicinteract__SMS_Template__c> templates = new List<smagicinteract__SMS_Template__c>{
            template1,
                template2,
                template3
        };
            insert templates;
        //Insert smagicinteract__SMS_SenderId__c record
        smagicinteract__SMS_SenderId__c senderObject = new smagicinteract__SMS_SenderId__c(
            smagicinteract__senderId__c = '19543888730',
            smagicinteract__Email_Notification_Template__c = 'default',
            smagicinteract__Used_For__c = 'Both'
        );
        insert senderObject;
    }
    
    //This method will test if the Pod Tracker record is inserted successfully
    private testMethod static void insertConciergeDetail(){
        Concierge_Details__c conciergeDetail = new Concierge_Details__c(Driver_Name__c = 'John Smith',
                                                                       Driver_Needed__c	= true,
                                                                       Drop_Off_Time__c = DateTime.now(),
                                                                       POD_Needed__c = true);
        Test.startTest();
        insert conciergeDetail;
        Test.stopTest();
        List<POD_Tracker__c> podTrackers = [SELECT Id FROM POD_Tracker__c];
        //No Pod Tracker record will be inserted as this Concierge is not related to any invoice
        System.assertEquals(0, podTrackers.size());
    }
    
    private testMethod static void updateConciergeDetail(){
        //Query Concierge Detail object and update Pod Needed field
        Concierge_Details__c conciergeDetail = [SELECT Id, POD_Needed__c FROM Concierge_Details__c WHERE Driver_Name__c = 'John Smith' LIMIT 1];
        conciergeDetail.POD_Needed__c = true;
        Test.startTest();
        
        update conciergeDetail;
		List<POD_Tracker__c> podTrackers = [SELECT Id FROM POD_Tracker__c];
        //Pod Tracker record will be inserted as no pod trackers exist in the system with this treatment date
        System.assertEquals(1, podTrackers.size());
        
        //Update another concierge detail object with Pod needed as true
        Concierge_Details__c conciergeDetail2 = [SELECT Id, POD_Needed__c FROM Concierge_Details__c WHERE Driver_Name__c = 'Harry Abel' LIMIT 1];
        conciergeDetail2.POD_Needed__c = true;
        try{
            update conciergeDetail2;
        } catch(Exception e){
            podTrackers = [SELECT Id FROM POD_Tracker__c];
            //Only one pod tracker will exist in the system
            System.assertEquals(1, podTrackers.size());
        }
        Test.stopTest();
    }
    
    private testMethod static void testSMSFeature(){
        Concierge_Details__c conciergeDetail = new Concierge_Details__c(Driver_Name__c = 'John Smith',
                                                                       Driver_Needed__c	= true,
                                                                       Drop_Off_Time__c = DateTime.now(),
                                                                       is_Car_Confirmed__c = true,
                                                                       is_Hotel_Confirmed__c = true,
                                                                       is_Flight_Confirmed__c = true);
        Test.startTest();
        insert conciergeDetail;
        Test.stopTest();
        Integer count = [SELECT Count() FROM smagicinteract__smsMagic__c];
        //No SMS History record will be inserted as this Concierge is not related to any invoice
        System.assertEquals(0, count);
        Integer count2 = [SELECT Count() FROM Task];
        //No Task record will be inserted as this Concierge is not related to any invoice
        System.assertEquals(0, count2);
    }
    
    private testMethod static void updateAllSMSCheckboxes(){
        //Query Concierge Detail object and update Pod Needed field
        Concierge_Details__c conciergeDetail = [SELECT Id, is_Car_Confirmed__c, is_Hotel_Confirmed__c, is_Flight_Confirmed__c 
                                                FROM Concierge_Details__c WHERE Driver_Name__c = 'John Smith' LIMIT 1];
        conciergeDetail.is_Car_Confirmed__c = true;
		conciergeDetail.is_Hotel_Confirmed__c = true;
		conciergeDetail.is_Flight_Confirmed__c = true;
        Test.startTest();
        update conciergeDetail;
        Test.stopTest();
        Integer count = [SELECT Count() FROM smagicinteract__smsMagic__c];
        //SMS History record will be inserted as all the checkboxes are checked
        System.assertEquals(3, count);
        Integer count2 = [SELECT Count() FROM Task];
        //record will be inserted as all the checkboxes are checked
        System.assertEquals(3, count2);
    }
    
    private testMethod static void updateSMSCheckboxes(){
        //Query Concierge Detail object and update Pod Needed field
        Concierge_Details__c conciergeDetail = [SELECT Id, is_Car_Confirmed__c, is_Hotel_Confirmed__c, is_Flight_Confirmed__c 
                                                FROM Concierge_Details__c WHERE Driver_Name__c = 'Harry Abel' LIMIT 1];
        conciergeDetail.is_Car_Confirmed__c = true;
		conciergeDetail.is_Hotel_Confirmed__c = true;
		conciergeDetail.is_Flight_Confirmed__c = true;
        Test.startTest();
        update conciergeDetail;
        Test.stopTest();
        Integer count = [SELECT Count() FROM smagicinteract__smsMagic__c];
        //SMS History record will be inserted only for Car and Hotel rservation as Flight checkbox was checked during insert
        System.assertEquals(2, count);
        Integer count2 = [SELECT Count() FROM Task];
        //Task record will be inserted only for Car and Hotel rservation as Flight checkbox was checked during insert
        System.assertEquals(2, count2);
    }
    
    testMethod private static void testSMSException(){
        //Remove MobilePhone field from Contact to capture exception
        Contact contactObj = [SELECT Id, MobilePhone FROM Contact LIMIT 1];
        contactObj.MobilePhone = '';
        update contactObj;
        Concierge_Details__c conciergeDetail = [SELECT Id, is_Car_Confirmed__c, is_Hotel_Confirmed__c, is_Flight_Confirmed__c 
                                                FROM Concierge_Details__c WHERE Driver_Name__c = 'John Smith' LIMIT 1];
        conciergeDetail.is_Car_Confirmed__c = true;
		conciergeDetail.is_Hotel_Confirmed__c = true;
		conciergeDetail.is_Flight_Confirmed__c = true;
        Test.startTest();
        try{
            update conciergeDetail;
        } catch(Exception e){
            Integer count = [SELECT Count() FROM smagicinteract__smsMagic__c];
            //No SMS History record will be inserted as Mobilephone field is mandatory
            System.assertEquals(0, count);
            Integer count2 = [SELECT Count() FROM Task];
            //No record will be inserted as as Mobilephone field is mandatory
            System.assertEquals(0, count2);
        }
        Test.stopTest();
        
    }
}