@IsTest
global class emailSendExtensionTest {

      global static testMethod void testemailSendExtensionUpdate(){
        List<Lead> leadList= new List<Lead>();
        List<Lead> leadUpList= new List<Lead>();
        List<Task> taskList = new List<Task>();
        List<Task> taskListUp = new List<Task>();
        //leadList = [Select id from Lead];
        //for(Lead l : leadList){
            Lead leadobj1 = new Lead();
            leadobj1.Email = 'test@gmail.com';
            leadobj1.lastname = 'last1';
            leadobj1.company = 'Test';
            leadobj1.MobilePhone = '65788287';
            leadobj1.Status = 'New';
            leadobj1.Practise_Name__c = 'Test';
            leadobj1.Lead_Credit_Assigned_To__c = 'Mark Anthony';
            leadobj1.Lead_entered_by__c = 'Faye Ganaban';
            leadobj1.HasOptedOutOfEmail = False;
            leadUpList.add(leadobj1);
            
            Lead leadobj2 = new Lead();
            leadobj2.Email = 'test1@gmail.com';
            leadobj2.MobilePhone = '657882870';
            leadobj2.Status = 'New';
            leadobj2.lastname = 'last1';
            leadobj2.company = 'Test';            
            leadobj2.Practise_Name__c = 'Test0';
            leadobj2.Lead_Credit_Assigned_To__c = 'Mark Anthony';
            leadobj2.Lead_entered_by__c = 'Faye Ganaban';
            leadobj2.HasOptedOutOfEmail = False;
            leadUpList.add(leadobj2);
          
           
      //  }
        Insert leadUpList;
       
        for(Lead leadobb : leadUpList){
           Task t = new Task();
            t.WhoId = leadobb.Id;
           t.Subject = 'Email Notification Send';
          // t.Email__c = leadobb.Email;
           t.Status = 'Completed';
           taskListUp.add(t);
          }
          Upsert taskListUp;
        
        
        Test.StartTest(); 
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(leadUpList);
            emailSendExtension  testObj = new emailSendExtension(sc);
           // testObj.selectedList= leadUpList;
           // testObj.taskList=taskListUp;
          testObj.providerAboutUsWOIntake();
          testObj.providerRTM();
          testObj.providerAvail();
          testObj.practiceAboutUsWOIntake();
          testObj.practiceRTM();
          testObj.practiceAvail();
          testObj.doAction();

            PageReference pageRef = Page.EmailSendVF;
            Test.setCurrentPageReference(pageRef);
        
        Test.StopTest();
        
      }
      
    }