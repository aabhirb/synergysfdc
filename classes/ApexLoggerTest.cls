/**
 * Created by kmachhewar on 10/4/18.
 */

@IsTest
private class ApexLoggerTest {

    static testMethod void testPositiveFlow() {
        ApexLogger.log('CustomerDeduplicationModule','Test Logger');
        Test.startTest();
        ApexLogger.commitLogs();
        Test.stopTest();
        System.assert([SELECT Id FROM Log__c].size() ==1, 'No logs or more than one logs are created.');
        System.assert([SELECT Id FROM Attachment].size() ==0, 'Attachment should not have been created.');

    }
    static testMethod void testIfBodyIsMoreThanCharacterLimit() {
        ApexLogger.Logger logger = ApexLogger.createLogger('MyLogger');
        logger.log('Log message 1');
        logger.logRequest('Request');
        logger.logResponse('Response');
        String sampleTextOf10CharacterLong = 'ABCDEFGHIJ';
        String longText = '';
        for(Integer index = 0 ;index < 13500; index++ ){
            logger.log(sampleTextOf10CharacterLong);
            longText+=sampleTextOf10CharacterLong;
        }
        logger.logRequest(longText);
        logger.logResponse(longText);
        logger.setStatus('Success');
        //For committing logger you need to use
        Test.startTest();
        ApexLogger.commitLogs();
        Test.stopTest();
        System.assert([SELECT Id FROM Log__c].size() ==1, 'No logs or more than one logs are created.');
        System.assert([SELECT Id FROM Attachment].size() ==3, 'Attachment should have been created');
    }


    static testMethod void testIfOnlyRequestOrResponseIsLogged() {
        ApexLogger.Logger logger = ApexLogger.createLogger('MyLogger');
        logger.logRequest('Test');
        Test.startTest();
        ApexLogger.commitLogs();
        Test.stopTest();
        System.assert([SELECT Id FROM Log__c].size() ==1, 'Log should have been created');
        System.assert([SELECT Id FROM Attachment].size() ==0, 'Attachment should not have been created.');
    }

    static testMethod void testIfNothingIsLogged() {
        ApexLogger.Logger logger = ApexLogger.createLogger('MyLogger');
        Test.startTest();
        ApexLogger.commitLogs();
        Test.stopTest();
        System.assert([SELECT Id FROM Log__c].size() == 0, 'No logs should have been created.');
        System.assert([SELECT Id FROM Attachment].size() == 0, 'Attachment should not have been created.');
    }

    static testMethod void testIfThereAreMultipleCommits() {
        ApexLogger.Logger logger = ApexLogger.createLogger('MyLogger');
        Test.startTest();
        logger.log('Test');
        ApexLogger.commitLogs();
        ApexLogger.commitLogs();
        ApexLogger.commitLogs();
        ApexLogger.commitLogs();
        System.assert(Limits.getDMLStatements() == 1,'DML is not exactly one.');
        Test.stopTest();
    }

}