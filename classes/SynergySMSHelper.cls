public class SynergySMSHelper {

    public static final String INTAKE_SENT = 'Intake Sent';
    public static final String PRACTICE_LEAD_RECORDTYPE = 'Practice';
    public static final String PROVIDER_LEAD_RECORDTYPE = 'Provider';
    public static final String MATCH_SENT_TO_SP = 'Match Email Sent to SP';
    public static final String MATCH_SENT_TO_GP = 'Match Email Sent to GP';
    public static final String STAGENAME_INTRODUCED = 'Introduced';
    public static final String MEETING_SCHEDULED = 'Meeting Scheduled'; 
    public static final String INV_STATUS_PR_REQUESTED  = 'Production Report Requested';
    public static final String INV_STATUS_SENT_FOR_APPOVAL  = 'Invoice Sent to Provider';


    public static List<Lead> getPracticeIntakeSentLeads(){
        return ([SELECT Id, Status, Days_Since_Intake_Sent__c, MobilePhone, Name FROM Lead 
                WHERE Recordtype.Name =: PRACTICE_LEAD_RECORDTYPE AND Status =:INTAKE_SENT
                AND MobilePhone != null AND smagicinteract__SMSOptOut__c = false
               ]);
    } 
    
    public static List<Lead> getProviderIntakeSentLeads(){
        return ([SELECT Id, Status, Days_Since_Intake_Sent__c, MobilePhone, Name FROM Lead 
                WHERE Recordtype.Name =: PROVIDER_LEAD_RECORDTYPE AND Status =:INTAKE_SENT
                AND MobilePhone != null AND smagicinteract__SMSOptOut__c = false
               ]);
    } 
    
    public static List<Prospect_Match__c> getMatchOptInSentGP(){
        return ([SELECT Id, Name, GP_Contact__c, GP_Contact__r.Name, GP_Contact__r.MobilePhone, Days_Since_Match_Opt_in__c
                FROM Prospect_Match__c WHERE Match_Stage__c =:MATCH_SENT_TO_GP AND
                 GP_Contact__r.MobilePhone != null AND GP_Contact__r.smagicinteract__SMSOptOut__c = false
                ]);
    }
    
    public static List<Prospect_Match__c> getMatchOptInSentSP(){
        return ([SELECT Id, Name, SP_Contact__c, SP_Contact__r.Name, SP_Contact__r.MobilePhone, Days_Since_Match_Opt_in__c
                FROM Prospect_Match__c WHERE Match_Stage__c =:MATCH_SENT_TO_SP AND
                 SP_Contact__r.MobilePhone != null AND SP_Contact__r.smagicinteract__SMSOptOut__c = false
                ]);
    }
    
    //Get list of GPs to whom Introduction email is sent
    public static List<Opportunity> getIntroducedGPs(){
        return ([SELECT Id, GP_Contact__c, GP_Contact__r.Name, GP_Contact__r.MobilePhone, Days_Since_Intro_Sent__c
                FROM Opportunity WHERE StageName =:STAGENAME_INTRODUCED AND
                 GP_Contact__r.MobilePhone != null AND GP_Contact__r.smagicinteract__SMSOptOut__c = false
                ]);
    }
    
	public static List<Opportunity> getIntroducedSPs(){
        return ([SELECT Id, Primary_Contact__c, Primary_Contact__r.Name, Primary_Contact__r.MobilePhone, Days_Since_Intro_Sent__c
                FROM Opportunity WHERE StageName =:STAGENAME_INTRODUCED AND
                 Primary_Contact__r.MobilePhone != null AND Primary_Contact__r.smagicinteract__SMSOptOut__c = false
                ]);
    }
    
	public static List<Opportunity> getGPsWithMeetingScheduled(){
        return ([SELECT Id, GP_Contact__c, GP_Contact__r.Name, GP_Contact__r.MobilePhone, Days_Since_Intro_Sent__c,
                 Meeting_Date__c
                FROM Opportunity WHERE StageName =: MEETING_SCHEDULED AND Meeting_Date_Set__c = true AND
                 GP_Contact__r.MobilePhone != null AND GP_Contact__r.smagicinteract__SMSOptOut__c = false
                ]);
    }
    
	public static List<Opportunity> getSPsWithMeetingScheduled(){
        return ([SELECT Id, Primary_Contact__c, Primary_Contact__r.Name, Primary_Contact__r.MobilePhone, Days_Since_Intro_Sent__c,
                 Meeting_Date__c
                FROM Opportunity WHERE StageName =: MEETING_SCHEDULED AND Meeting_Date_Set__c = true AND
                 Primary_Contact__r.MobilePhone != null AND Primary_Contact__r.smagicinteract__SMSOptOut__c = false
                ]);
    }
    
    public static List<Opportunity> getGpWithNoTxScheduled(){
        return ([SELECT Id, GP_Contact__c, GP_Contact__r.Name, GP_Contact__r.MobilePhone, Prep_Completion_Date__c
                FROM Opportunity WHERE Specialist_Package__c = true AND Invoices_Created__c = 0 AND
                 GP_Contact__r.MobilePhone != null AND GP_Contact__r.smagicinteract__SMSOptOut__c = false
                ]);
    } 
    
    public static List<Opportunity_Line_Item__c> getInvoiceWithNoProdReport(){
        return ([SELECT Id, Opportunity__r.GP_Contact__c, Opportunity__r.GP_Contact__r.Name, 
                 Opportunity__r.GP_Contact__r.MobilePhone, Treatment_Date__c
                 FROM Opportunity_Line_Item__c WHERE Status__c =: INV_STATUS_PR_REQUESTED AND
                 Opportunity__r.GP_Contact__r.MobilePhone != null AND Opportunity__r.GP_Contact__r.smagicinteract__SMSOptOut__c = false
                ]);
    }

    public static List<Opportunity_Line_Item__c> getInvoicesWithInvoiceSentForApproval() {
        return ([SELECT Id, Opportunity__r.Primary_Contact__c, Opportunity__r.Primary_Contact__r.Name, 
            Opportunity__r.Primary_Contact__r.MobilePhone, Invoice_Sent_for_Approval_Date__c
            FROM Opportunity_Line_Item__c WHERE Status__c =: INV_STATUS_SENT_FOR_APPOVAL AND
            Opportunity__r.Primary_Contact__r.MobilePhone != null AND Opportunity__r.Primary_Contact__r.smagicinteract__SMSOptOut__c = false
           ]);
    }
    
}