/**
* @ApexClass    : ApexLogger
* @Description  : This class contains utility methods which will be required for attachment based logger.
* @Features     :
*               1. Large log could be maintained as compared to storing information as field value in text area.
*               2. Attachment based logger gets associated with the sobjects, it becomes easy to search and get required logs.
*               3. Single commit statement makes sure that only one DML is made for all logging.
*               4. Same logger could be used in multiple places where instance is not even passed by referencing to name.
*               5. Module wise logging could be performed.
*/
public class ApexLogger {

    //cache of log
    public static Map<String,Log> logs = new Map<String,Log>();
    public enum APIType {INBOUND,OUTBOUND}

    //Wrapper class to hold attachment
    public class Log{
        Log__c log;
        String body='';
        Boolean isLogChanged = false;
        public Log(Log__c log, String body){
            this.log = log;
            this.body = body;
        }
    }

    //Creation of logger instance
    public static ApexLogger.Logger createLogger(String logName){
        if(logs.get(logName)==null){
            logs.put(logName,new Log(new Log__c(Name=logName, Request__c = '', Response__c = '' ),''));
        }
        return new ApexLogger.Logger(logName);
    }

    //method to log
    public static void log(String loggerName,String logMessage){
        if(loggerName == null || loggerName == '' ) return;
        if(logs.get(loggerName) == null){
            createLogger(loggerName);
        }
        logs.get(loggerName).isLogChanged = true;
        logs.get(loggerName).body = logs.get(loggerName).body + '\n'+ logMessage;
    }



    public static void logRequest(String loggerName,String logMessage){
        if(loggerName == null || loggerName == '' ) return;
        if(logs.get(loggerName) == null){
            createLogger(loggerName);
        }
        logs.get(loggerName).isLogChanged = true;
        logs.get(loggerName).log.Request__c += logMessage;
    }

    public static void logResponse(String loggerName,String logMessage){
        if(loggerName == null || loggerName == '' ) return;
        if(logs.get(loggerName) == null){
            createLogger(loggerName);
        }
        logs.get(loggerName).isLogChanged = true;
        logs.get(loggerName).log.Response__c += logMessage;
    }

    public static void setStatus(String loggerName,String status){
        if(loggerName == null || loggerName == '' ) return;
        if(logs.get(loggerName) == null){
            createLogger(loggerName);
        }
        logs.get(loggerName).isLogChanged = true;
        logs.get(loggerName).log.Status__c = status;
    }

    public static void setAPIType(String loggerName,APIType theApiType){
        if(loggerName == null || loggerName == '' ) return;
        if(logs.get(loggerName) == null){
            createLogger(loggerName);
        }
        if(theApiType == APIType.INBOUND ){
            logs.get(loggerName).log.API_Type__c = 'Inbound';
        }
        if(theApiType == APIType.OUTBOUND ){
            logs.get(loggerName).log.API_Type__c = 'Outbound';
        }
    }
    public static void setOperationType(String loggerName,String operationType){
        if(loggerName == null || loggerName == '' ) return;
        if(logs.get(loggerName) == null){
            createLogger(loggerName);
        }
        logs.get(loggerName).isLogChanged = true;
        logs.get(loggerName).log.Operation_Type__c = operationType;
    }

    public static void logException(String loggerName,Exception ex){
        if(loggerName == null || loggerName == '' ) return;
        if(logs.get(loggerName) == null){
            createLogger(loggerName);
        }
        logs.get(loggerName).isLogChanged = true;
        logs.get(loggerName).log.Status__c = 'Error';
        logs.get(loggerName).body = logs.get(loggerName).body + '\n'+ ex.getMessage() + ex.getStackTraceString();
    }



    //wrapper class to hold logs
    public class Logger{
        String loggerName;
        public Logger(String loggerName){
            this.loggerName = loggerName;
        }
        public void log(String log){
            ApexLogger.log(loggerName,log);
        }

        public void logRequest(String logMessage){
            ApexLogger.logRequest(loggerName,logMessage);
        }
        public void logResponse(String logMessage){
            ApexLogger.logResponse(loggerName,logMessage);
        }

        public void setStatus(String status){
            ApexLogger.setStatus(loggerName,status);
        }
        public  void setAPIType(APIType theApiType){
            ApexLogger.setAPIType(loggerName,theApiType);
        }

        public  void setOperationType(String  operationType){
            ApexLogger.setOperationType(loggerName,operationType);
        }

        

        public  void logException(Exception ex){
            ApexLogger.logException(loggerName,ex);
        }

    }

    public class AttachmentWrapper{
        Log__c log       {get;set;}
        Attachment att   {get;set;}
        Attachment requestAtt {get;set;}
        Attachment responseAtt {get;set;}
    }
    //Commit method to commit all logs at once
    public static void commitLogs(){
        try{
            List<Log__c> allLogs = new List<Log__c>();
            List<Attachment> attachmentsToBeCreated = new List<Attachment>();
            List<AttachmentWrapper> attachmentWrappers = new List<AttachmentWrapper>();
            for(Log lg : logs.values()){
                if(!lg.isLogChanged){
                    continue; //nothing changed so don't add to the list and do dml
                }
                lg.log.Body__c = lg.Body;
                allLogs.add(lg.log);
                AttachmentWrapper theAttachmentWrapper = new AttachmentWrapper();
                theAttachmentWrapper.log = lg.log;
                attachmentWrappers.add(theAttachmentWrapper);
                Integer TEXT_LIMIT_ON_LONG_TEXT_FIELD = 131000;
                if(lg.Body != null && lg.Body.length() > TEXT_LIMIT_ON_LONG_TEXT_FIELD){
                    Attachment theAttachment = new Attachment(Name='Log.txt',Body = Blob.valueOf(lg.Body));
                    theAttachmentWrapper.att = theAttachment;
                    attachmentsToBeCreated.add(theAttachment);
                }
                if(lg.log.Request__c != null && lg.log.Request__c.length() > TEXT_LIMIT_ON_LONG_TEXT_FIELD ){
                    Attachment theAttachment = new Attachment(Name='Request.txt',Body = Blob.valueOf(lg.log.Request__c));
                    theAttachmentWrapper.requestAtt = theAttachment;
                    attachmentsToBeCreated.add(theAttachment);
                }
                if(lg.log.Response__c != null && lg.log.Response__c.length() > TEXT_LIMIT_ON_LONG_TEXT_FIELD ){
                    Attachment theAttachment = new Attachment(Name='Response.txt',Body = Blob.valueOf(lg.log.Response__c));
                    theAttachmentWrapper.responseAtt = theAttachment;
                    attachmentsToBeCreated.add(theAttachment);
                }
                lg.isLogChanged = false;
            }
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.optAllOrNone = false;
            dml.allowFieldTruncation = true;
            for(Log__c tempLog : allLogs){
                tempLog.setOptions(dml);
            }
            upsert allLogs;
            for(AttachmentWrapper theAttachmentWrapper : attachmentWrappers){
                if(theAttachmentWrapper.att != null){
                    theAttachmentWrapper.att.ParentId = theAttachmentWrapper.log.Id;
                }

                if(theAttachmentWrapper.requestAtt != null){
                    theAttachmentWrapper.requestAtt.ParentId = theAttachmentWrapper.log.Id;
                }

                if(theAttachmentWrapper.responseAtt != null){
                    theAttachmentWrapper.responseAtt.ParentId = theAttachmentWrapper.log.Id;
                }
            }
            System.debug('attachmentsToBeCreated-->'+JSON.serializePretty(attachmentsToBeCreated));
            insert attachmentsToBeCreated;
        }catch(Exception ex){
            System.debug('Error in logging-->'+ex.getMessage());
            System.debug('StackTrace-->'+ex.getStackTraceString());
        }
    }

    /*
         ********************************
         //USAGE 1

         //If logger instance is not accesible and want to have log in the same file then you can use below method to log in the same file
         ApexLogger.log('CustomerDeduplicationModule','<Your log message goes here>');

         //For committing logger you need to use
         ApexLogger.commitLogs();

         ********************************
         //USAGE 2

         ApexLogger.Logger logger = ApexLogger.createLogger('MyLogger');
         logger.log('Log message 1');
         logger.log('Log message 2');
         logger.log('Log message 3');
         //For committing logger you need to use
         ApexLogger.commitLogs();
         ********************************

    */

}