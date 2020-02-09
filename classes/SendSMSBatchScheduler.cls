global class SendSMSBatchScheduler implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        SendScheduleSMSBatch batchSMS = new SendScheduleSMSBatch();
		Database.executeBatch(batchSMS);
    }

}