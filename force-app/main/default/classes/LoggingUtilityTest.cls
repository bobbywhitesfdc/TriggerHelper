/**
 * This is a test class for testing the functionality of the LogginUtility class.
 * 
**/
@isTest
private class LoggingUtilityTest {
    
    /**
     * MockLogger class simulates logging functionality for testing purposes.
     */
    private class MockLogger {
        public List<LogEntry__c> logEntries = new List<LogEntry__c>();
        /**
         * Saves the log entry to the logEntries list.
         */
        public void saveLog() {
            LogEntry__c logEntry = new LogEntry__c();
            logEntry.Message__c = 'Mock Log Entry';
            logEntries.add(logEntry);
        }
    }
    
    
    /**
     * Tests logging an error message with saveFlag set to true.
     */
    @isTest
    static void testLogErrorWithSaveFlagTrue() {
        // Test setup
        Test.startTest();
        
        // Perform action
        LoggingUtility.logError('Test error message', true);
        MockLogger mockLogger = new MockLogger();
        mockLogger.saveLog();
        
        // Test validation
        Test.stopTest();
        System.assert(!mockLogger.logEntries.isEmpty(), 'Log entry should be created when saveFlag is true');
    }
    
    /**
     * Tests logging an error message with saveFlag set to false.
     */
    @isTest
    static void testLogErrorWithSaveFlagFalse() {
        // Test setup
        Test.startTest();
        
        // Perform action
        LoggingUtility.logError('Test error message', false);
        
        // Test validation
        Test.stopTest();
    }
    
    /**
     * Tests logging an error message with an exception and saveFlag set to true.
     */
    @isTest
    static void testLogErrorWithExceptionAndSaveFlagTrue() {
        // Test setup
        Test.startTest();
        
        // Perform action
        try {
            Integer a = 1/0;
        } catch (Exception e) {
            LoggingUtility.logError(e, true);
        }
        MockLogger mockLogger = new MockLogger();
        mockLogger.saveLog();
        
        // Test validation
        Test.stopTest();
        System.assert(!mockLogger.logEntries.isEmpty(), 'Log entry should be created when saveFlag is true');
    }
    
    /**
     * Tests logging an error message with an exception and saveFlag set to false.
     */
    @isTest
    static void testLogErrorWithExceptionAndSaveFlagFalse() {
        // Test setup
        Test.startTest();
        
        // Perform action
        try {
            Integer a = 1/0;
        } catch (Exception e) {
            LoggingUtility.logError(e, false);
        }
        
        // Test validation
        Test.stopTest();
    }
    
    /**
     * Tests logging an error message from a Lightning Web Component (LWC).
     */
    @isTest
    static void testLogLwcError() {
        // Test setup
        String error = 'Test error message';
        String lwcName = 'TestLwcComponent';
        
        // Perform action
        Test.startTest();
        LoggingUtility.logLwcError(error, lwcName);
        MockLogger mockLogger = new MockLogger();
        mockLogger.saveLog();
        
        // Test validation
        Test.stopTest();
        System.assert(!mockLogger.logEntries.isEmpty(), 'Log entry for LWC error should be created');
    }
    
    /**
     * Tests logging errors from a Flow.
     */
    @isTest
    static void testLogFlowError() {
        // Test setup
        List<LoggingUtility.LogFaultDetail> faults = new List<LoggingUtility.LogFaultDetail>();
        LoggingUtility.LogFaultDetail fault1 = new LoggingUtility.LogFaultDetail();
        fault1.flowName = 'TestFlow';
        fault1.flowElement = 'TestElement';
        fault1.message = 'Test message';
        faults.add(fault1);
        
        // Perform action
        Test.startTest();
        LoggingUtility.logFlowError(faults);
        MockLogger mockLogger = new MockLogger();
        mockLogger.saveLog();
        
        // Test validation
        Test.stopTest();
        System.assert(!mockLogger.logEntries.isEmpty(), 'Log entry for Flow error should be created');
    }
    
    /**
     * Tests logging errors from a DML operation.
     */
    @IsTest
    static void testLogErrorWithSaveResults() {
        // Test setup        
        // Perform action
        Test.startTest();
        list<Account> accts = new list<Account>();
        Account acc1 = new Account();
        accts.add(acc1);
        Account acc2 = new Account();
        accts.add(acc2);
        Account acc3 = new Account();
        accts.add(acc3 );
        
        List<Database.SaveResult> saveResults = new MockDMLExecutor().insertData(accts,false);
        LoggingUtility.logError(saveResults,accts,'enterpriseLoggerTest');
                    
        // Test validation
        Test.stopTest();
    }
    
    /**
     * Tests logging errors from a DML operation.
     */
    @IsTest
    static void testLogErrorWithPEPublish() {
        // Test setup        
        List<TriggerMockPE__e> peList = new List<TriggerMockPE__e >();
        for (Integer i=0; i < 100; i++) {
            peList.add(new TriggerMockPE__e(RequiredField__c ='Foo'+i));
        }
        Test.startTest();
        
        List<Database.SaveResult> saveResults = new MockDMLExecutor().publish(peList);
        LoggingUtility.logError(saveResults,peList,'enterpriseLoggerTest');
                    
        // Test validation
        Test.stopTest();
    }
    
    
    /**
     * Tests logging errors from an Delete operation.
     */
    @IsTest
    static void testLogErrorWithDeleteResults() {

        // Test setup        
        // Perform action
        Test.startTest();
        list<Account> accts = new list<Account>();
        Account acc1 = new Account();
        acc1.name = 'test 1';
        accts.add(acc1);
        insert accts;
        
        //undelete Results cannot be rerieved from recyclebin in test class
        List<Database.DeleteResult> deleteResults = new MockDMLExecutor().deleteData(accts,false);
        LoggingUtility.logError(deleteResults, accts, 'enterpriseLoggerTest');
                    
        // Test validation
        Test.stopTest();
    }
    
    /**
     * Tests logging errors from an Delete operation.
     */
    @IsTest
    static void testLogErrorWithDeleteResultErrors() {

        // Test setup        
        // Perform action
        Test.startTest();
        list<Account> accts = new list<Account>();
        Account acc1 = new Account();
        acc1.name = 'test 1';
        accts.add(acc1);
        insert accts;
        delete accts;
        
        //delete when already deleted will test the error path
        List<Database.DeleteResult> deleteResults = new MockDMLExecutor().deleteData(accts,false);
        LoggingUtility.logError(deleteResults, accts, 'LoggingUtilityTest');
                    
        // Test validation
        Test.stopTest();
    }
    
    /**
 * Tests logging errors from an Undelete operation.
 */
    @IsTest
    static void testLogErrorWithUndeleteResults() {

        // Test setup        
        // Perform action
        Test.startTest();
        list<Account> accts = new list<Account>();
        Account acc1 = new Account();
        acc1.name = 'test 1';
        accts.add(acc1);
        insert accts;
        
        Delete accts;
        //undelete Results cannot be rerieved from recyclebin in test class
        List<Database.UndeleteResult> undeleteResults = new MockDMLExecutor().undeleteData(accts,false);
        LoggingUtility.logError(undeleteResults, accts, 'LoggingUtilityTest');
                    
        // Test validation
        Test.stopTest();
    }
    
    /**
     * Tests logging errors from an Upsert operation.
     */
    @IsTest
    static void testLogErrorWithUpsertResults() {

        // Test setup        
        // Perform action
        Test.startTest();
        list<Account> accts = new list<Account>();
        Account acc1 = new Account();
        acc1.name = 'test 1';
        accts.add(acc1);         
        insert accts;
        
        //Upsert Results  
        List<Database.UpsertResult> upsertResults = new MockDMLExecutor().upsertData(accts,Account.Fields.Id,false);
        LoggingUtility.logError(upsertResults, accts, 'LoggingUtilityTest');
                    
        // Test validation
        Test.stopTest();
    }
    
    /**
     * Tests logging errors from an Upsert operation.
     */
    @IsTest
    static void testLogErrorWithUpsertResultsFailure() {

        // Test setup        
        // Perform action
        Test.startTest();
        list<Account> accts = new list<Account>();
        Account acc1 = new Account();
        acc1.name = 'test 1';
        accts.add(acc1);         
        insert accts;
        delete accts;
        
        //Upsert Results  
        List<Database.UpsertResult> upsertResults = new MockDMLExecutor().upsertData(accts,Account.Fields.Id,false);
        LoggingUtility.logError(upsertResults, accts, 'LoggingUtilityTest');
                    
        // Test validation
        Test.stopTest();
    }
}