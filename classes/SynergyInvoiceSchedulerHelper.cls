/**
* @author abhishek
* @date 2019-09-15
*
* @description : .
*/
public with sharing class SynergyInvoiceSchedulerHelper
{
    public static final String INV_STATUS_SCHEDULED = 'Scheduled';
    public static final String INV_STATUS_COMPLETE  = 'Completed';
    public static final String INV_STATUS_PR_REQUESTED  = 'Production Report Requested';
    public static final String INV_STATUS_SENT_FOR_APPOVAL  = 'Invoice Sent for Approval';
    public static final String INV_STATUS_SENT_FOR_PAYMENT  = 'Invoice Sent for Payment';

    public static List<Opportunity_Line_Item__c> getInvoicesDueForScheduleReminder() {
       return [
                SELECT Id,Name,Schedule_Confirmation_Mail_Sent__c,Status__c,Treatment_Date__c,Schedule_Confirmation_Mail_Sent_Prelim__c,Disable_Auto_Emails__c,Notify_To_SC__c,Practice_Post_Prod_FU_Sent__c,Disable_Follow_up__c
                        from
                        Opportunity_Line_Item__c
                        where
                        Status__c =: INV_STATUS_SCHEDULED
              ];
    }

    public static List<Opportunity_Line_Item__c> getInvoicesWithTxDateComplete() {
        return [
                    SELECT Id,Name,Schedule_Confirmation_Mail_Sent__c,Status__c,Treatment_Date__c,Disable_Auto_Emails__c,Notify_To_SC__c,Practice_Post_Prod_FU_Sent__c,Disable_Follow_up__c
                        from
                        Opportunity_Line_Item__c
                        where
                        Status__c =: INV_STATUS_COMPLETE
                ];
    }

    public static List<Opportunity_Line_Item__c> getInvoicesWithPRRequested() {
        return [
                SELECT Id,Name,Schedule_Confirmation_Mail_Sent__c,Status__c,Treatment_Date__c,
                        Opportunity__r.GP_Contact__r.Name,Invoice_Due_Date__c,
                        Opportunity__r.GP_Contact__r.Account.Name
                        ,Opportunity__r.Primary_Contact__r.Name,Disable_Auto_Emails__c,Notify_To_SC__c,Practice_Post_Prod_FU_Sent__c,Disable_Follow_up__c
                        from
                        Opportunity_Line_Item__c
                        where
                        Status__c =: INV_STATUS_PR_REQUESTED
                 ];
    }

    public static List<Opportunity_Line_Item__c> getInvoicesWithInvoiceSentForApproval() {
        return [
                SELECT Id,Name,Schedule_Confirmation_Mail_Sent__c,Status__c,Treatment_Date__c,
                        Opportunity__r.GP_Contact__r.Name,Invoice_Due_Date__c,Disable_Auto_Emails__c,
                        Opportunity__r.GP_Contact__r.Account.Name,Invoice_Sent_for_Approval_Date__c
                        ,Opportunity__r.Primary_Contact__r.Name,Notify_To_SC__c,Practice_Post_Prod_FU_Sent__c,Disable_Follow_up__c
                from
                        Opportunity_Line_Item__c
                where
                        Status__c =: INV_STATUS_SENT_FOR_APPOVAL
        ];
    }

    public static List<Opportunity_Line_Item__c> getInvoicesDueToday() {
        return [
                SELECT Id,Name,Schedule_Confirmation_Mail_Sent__c,Status__c,Treatment_Date__c,
                        Opportunity__r.GP_Contact__r.Name,Invoice_Due_Date__c,
                        Opportunity__r.GP_Contact__r.Account.Name
                        ,Opportunity__r.Primary_Contact__r.Name,Disable_Auto_Emails__c,Notify_To_SC__c,Practice_Post_Prod_FU_Sent__c,Disable_Follow_up__c
                        FROM
                        Opportunity_Line_Item__c
                        WHERE
                        Status__c =: INV_STATUS_SENT_FOR_PAYMENT
                        AND
                        Invoice_Due_Date__c =: Date.Today()
        ];
    } 

     //Ankita A: 11 Nov 2019: Changes made for Concierge feature
    //This method will send Concierge Details email to the admin
    public static List<Opportunity_Line_Item__c> sendConciergeReminder(){
        return [SELECT Id, Name, Status__c, Treatment_Date__c,
                    Concierge_Details_Sent__c,
                        Opportunity__r.GP_Contact__r.Name,
                  Opportunity__r.GP_Contact__r.Account.Name,
                  Opportunity__r.Primary_Contact__r.Name,Disable_Auto_Emails__c,Notify_To_SC__c,Practice_Post_Prod_FU_Sent__c,Disable_Follow_up__c
                        FROM Opportunity_Line_Item__c
                        WHERE Concierge_Details__c != null AND Concierge_Needed__c = true];
    }

}