public with sharing class SynergyInvoiceScheduler implements Schedulable {

    

    public void execute(SchedulableContext SC) {

        ApexLogger.Logger logger = ApexLogger.createLogger('SynergyInvoiceScheduler :'+Date.Today());

        List<Opportunity_Line_Item__c> invoiceListToUpdate = new List<Opportunity_Line_Item__c> () ;

        logger.log('First criteria: Sending email to Invoices whose status is Scheduled and 3 days before the Tx Day \n');
        for( Opportunity_Line_Item__c invoiceVar : SynergyInvoiceSchedulerHelper.getInvoicesDueForScheduleReminder() ) {

            if ( !invoiceVar.Schedule_Confirmation_Mail_Sent__c && invoiceVar.Treatment_Date__c == Date.Today().addDays(3) && !invoiceVar.Disable_Auto_Emails__c) {
                // Send Schedule Tx Date Confirmation
                logger.log('Sending Email for : '+invoiceVar.Name );
                //invoiceVar.Schedule_Confirmation_Mail_Sent__c = true;
                //invoiceListToUpdate.add(invoiceVar);
                
            }else if ( !invoiceVar.Schedule_Confirmation_Mail_Sent_Prelim__c && invoiceVar.Treatment_Date__c == Date.Today().addDays(10) && !invoiceVar.Disable_Auto_Emails__c) {
                // Send Schedule Tx Date Confirmation Prelim
                logger.log('Sending Email for : '+invoiceVar.Name );


                    //invoiceVar.Schedule_Confirmation_Mail_Sent_Prelim__c = true;
                    //invoiceListToUpdate.add(invoiceVar);
                
            }else if ( invoiceVar.Treatment_Date__c == Date.Today() ) {
                // Update Invoice Status as Completed
                logger.log('Updating Status to Complete for : '+invoiceVar.Name );
                invoiceVar.Status__c = 'Completed';
                invoiceListToUpdate.add(invoiceVar);
            }
        }

        logger.log('\n Second criteria: Sending email to Invoices with Status as Completed and 1 day after Tx day. Requesting'
                    + 'for Production report \n');
        for( Opportunity_Line_Item__c invoiceVar : SynergyInvoiceSchedulerHelper.getInvoicesWithTxDateComplete() ) {

            if ( invoiceVar.Treatment_Date__c == Date.Today().addDays(-1) ) {
                // Update Invoice Status as Completed
                logger.log('Updating Status to Production Report Requested for : '+invoiceVar.Name );

                    //invoiceVar.Status__c = 'Production Report Requested';
                    //invoiceListToUpdate.add(invoiceVar);

            }
        }

        logger.log('\n Third criteria: Sending email to Invoices with status as Sent for Approval and and 2 days after approval date.\n');
        for( Opportunity_Line_Item__c invoiceVar : SynergyInvoiceSchedulerHelper.getInvoicesWithInvoiceSentForApproval() ) {

            if ( invoiceVar.Invoice_Sent_for_Approval_Date__c == Date.Today().addDays(-2) && !invoiceVar.Disable_Auto_Emails__c ) {
                // Update Invoice Status as Completed
                logger.log('Sending Invoice Approval Follow Up : '+invoiceVar.Name );

                    //invoiceVar.Invoice_Approval_Follow_Up_Sent__c = true;
                    //invoiceListToUpdate.add(invoiceVar);

            }
        }

        logger.log(' Fourth criteria: Payment follow up emails \n');
        for( Opportunity_Line_Item__c invoiceVar : SynergyInvoiceSchedulerHelper.getInvoicesDueToday() ) {

            if ( invoiceVar.Invoice_Due_Date__c == Date.Today() && !invoiceVar.Disable_Auto_Emails__c) {
                logger.log('Sending Invoice Payment Follow Up : '+invoiceVar.Name );

                    //invoiceVar.Invoice_Payment_Follow_Up_Sent__c = true;
                    //invoiceListToUpdate.add(invoiceVar);

            }else if(invoiceVar.Invoice_Due_Date__c == Date.Today().addDays(-3) && !invoiceVar.Disable_Auto_Emails__c) {
                logger.log('Sending Invoice Payment Follow Up 2 : '+invoiceVar.Name );

                    //invoiceVar.Invoice_Payment_Follow_Up_2_Sent__c = true;
                   // invoiceListToUpdate.add(invoiceVar);

            }
        }

        //Ankita A: 11 Nov 2019: Changes made for Concierge feature
        
        for( Opportunity_Line_Item__c invoiceVar : SynergyInvoiceSchedulerHelper.sendConciergeReminder() ) {
            //If Concierge Details not sent already and Two days before the treatment date 
            if (!invoiceVar.Concierge_Details_Sent__c && (invoiceVar.Treatment_Date__c.addDays(-2) == Date.Today())) {
                  // Send Concierge Details Email confirmation
                  logger.log('Sending Concierge Details Email for : '+invoiceVar.Name );
                    invoiceVar.Concierge_Details_Sent__c = true;
                    invoiceListToUpdate.add(invoiceVar);
                }
        }

        //Ankita A: 30 Dec 2019: Changes made for sending reminder email to SC
        logger.log(' Fifth criteria: Email to Support coordinator \n');
        for( Opportunity_Line_Item__c invoiceVar : SynergyInvoiceSchedulerHelper.getInvoicesWithPRRequested()) {
            //If Support coordinator is not notified and 5 days before treatment date 
            if (!invoiceVar.Notify_to_SC__c && (invoiceVar.Treatment_Date__c.addDays(-5) == Date.Today())) {
                  //Send email and post to slack for reminder
                  logger.log('Send email and post to slack for Production request reminder : '+invoiceVar.Name + '\n');
                    invoiceVar.Notify_to_SC__c = true;
                    invoiceListToUpdate.add(invoiceVar);
                }
        }

        //Ankita A: 4 Jan 2020: Changes made for sending follow up email to Practice for Production report request
        logger.log(' Sixth criteria: Send follow up email to Practice for Production report \n');
        for(Opportunity_Line_Item__c invoiceVar : SynergyInvoiceSchedulerHelper.getInvoicesWithPRRequested()){
            //If Practice is not yet notified and 5 days after treatment date
            if(!invoiceVar.Practice_Post_Prod_FU_Sent__c && (invoiceVar.Treatment_Date__c.addDays(5) == Date.Today() && !invoiceVar.Disable_Auto_Emails__c)){
                //Send follow up email to Practice for Production report
                logger.log('Sending email to ' +invoiceVar.Name);
                //invoiceVar.Practice_Post_Prod_FU_Sent__c = true;
                //invoiceListToUpdate.add(invoiceVar);
            }
        }

        if( !invoiceListToUpdate.isEmpty() ) {

            Database.SaveResult[] results = Database.update(invoiceListToUpdate,false);

            if( !results.isEmpty() ) {
                Boolean isError = false;
                for( Database.SaveResult saveResult : results ) {
                    if( !saveResult.isSuccess() ){
                        for( Database.Error error :  saveResult.getErrors() ){
                            logger.log('Error : '+error.getMessage());
                            isError = true;
                        }
                    }
                }

                logger.setStatus(isError ? 'Error' : 'Success');
               //logger.log(isError ? 'Error In Execution ' : 'Successfull Execution')
            }
        }

        ApexLogger.commitLogs();
    }
}