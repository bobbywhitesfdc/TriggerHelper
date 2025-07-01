/**
 * Test the AbstractTriggerHandlerBase orchestration
 * and error handling. 
 **/  
@isTest(isParallel=false)
public class AbstractBaseTriggerHandlerTest {
    public static final Integer CHUNKMAX=200;
    
    // Defined constants tied to the correct MockITriggerHelper configurations
    public static final String CTX_GENERALERRORS='TestGeneralErrors';
    public static final String CTX_PREVIEWERRORS='TestPreviewErrors';
    public static final String CTX_ROWERRORS='TestRowErrors';
    public static final String CTX_DMLTEST='TestDMLHappy';
    public static final String CTX_HAPPYPATH='TestHappyPath';
    
    /**
     * An error thrown in Preview must be caught and must not interrupt the overall processing of a batch of records
     * at worst, a single record should fail and an error should be added to that record.
     **/ 
    public static testMethod void beforeInsertPreviewUnhappy() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_PREVIEWERRORS);
        final List<Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForInsert();
        handler.beforeInsert(inputDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        System.AssertEquals(false,handler.activeHelpers.isEmpty(),'No mock handlers returned!');
        final MockHelperPreviewErrors helper = (MockHelperPreviewErrors)handler.activeHelpers[0];
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
        
        for (Integer i=0; i < inputDataSet.size(); i++) {
            final Trigger_Framework_Mock__c current = inputDataSet[i];
            List<Database.Error> errors = current.getErrors();
            if (Math.mod(i,2)==0) { // Every 2nd row should have an error
                System.assertEquals(1,errors.size(),'Expected row errors for every 2nd row');
            } else {
                System.assertEquals(0,errors.size(),'Expected no row errors this row');                
            }
        }
    }
    
    /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void afterInsertPreviewError() {
        Test.StartTest();
            final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_PREVIEWERRORS);
            final Map<Id,Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForUpdate();
            handler.afterInsert(inputDataSet);
            Test.StopTest();
            
            // Get the MockHandler to check the counts of records processed
            final MockHelperPreviewErrors helper = (MockHelperPreviewErrors)handler.activeHelpers[0];
            System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
            Integer i = 0;
            for (Trigger_Framework_Mock__c current: inputDataSet.values()) {
                List<Database.Error> errors = current.getErrors();
                if (Math.mod(i,2)==0) { // Every 2nd row should have an error
                    System.assertEquals(1,errors.size(),'Expected row errors for every 2nd row');
                } else {
                    System.assertEquals(0,errors.size(),'Expected no row errors this row');                
                }
                i++;
            }
    }
    /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void afterUpdateRowPreviewError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_PREVIEWERRORS);
        final Map<Id,Trigger_Framework_Mock__c> updateDataSet = loadTestRecordsForUpdate();
        handler.afterUpdate(updateDataSet,updateDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperPreviewErrors helper = (MockHelperPreviewErrors)handler.activeHelpers[0];
        System.AssertEquals(false,updateDataSet.isEmpty(),'Cannot have an empty data set');
        
        Integer i= 0;
        for (Trigger_Framework_Mock__c current:updateDataSet.values()) {
            List<Database.Error> errors = current.getErrors();
            if (Math.mod(i,2)==0) { // Every 2nd row should have an error
                System.assertEquals(1,errors.size(),'Expected row errors for every 2nd row');
            } else {
                System.assertEquals(0,errors.size(),'Expected no row errors this row');                
            }
            i++;
        }
    }

    /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void beforeUpdatePreviewError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_PREVIEWERRORS);
        final Map<Id,Trigger_Framework_Mock__c> updateDataSet = loadTestRecordsForUpdate();
        handler.beforeUpdate(updateDataSet,updateDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperPreviewErrors helper = (MockHelperPreviewErrors)handler.activeHelpers[0];
        System.AssertEquals(false,updateDataSet.isEmpty(),'Cannot have an empty data set');
        
        Integer i= 0;
        for (Trigger_Framework_Mock__c current:updateDataSet.values()) {
            List<Database.Error> errors = current.getErrors();
            if (Math.mod(i,2)==0) { // Every 2nd row should have an error
                System.assertEquals(1,errors.size(),'Expected row errors for every 2nd row');
            } else {
                System.assertEquals(0,errors.size(),'Expected no row errors this row');                
            }
            i++;
        }
    }
    
    /**
     * Ensure that the helpers are being called and processing normally
     **/ 
    public static testmethod void beforeInsertHappy() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig();
        final List<Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForInsert();
        System.debug('Dataset size='+inputDataSet.size());
        handler.beforeInsert(inputDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperHappyPath helper = (MockHelperHappyPath)handler.activeHelpers[0];
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
        System.AssertEquals(inputDataset.size(),helper.previewBeforeInsertCounter,'All input records must be previewed');
        System.AssertEquals(inputDataset.size(),helper.meetsEntryCriteriaBeforeInsertCounter,'All input records must be evaluated by meetsEntryCriteria');
        System.AssertEquals(oddCounter(inputDataset.size()),helper.processRecordBeforeInsertCounter,'Every ODD input record must be processed');
    }
    
    // Calculate the number of ODD records based on the total count
    private static Integer oddCounter(final Integer inputCount) {
        // 1 --> 1, 2 --> 1, 3-->2, 4-->2, 5-->3...
        return (inputCount+1)/2;
    }
    
    private static Boolean isOdd(final Integer input) {
        return Math.mod(input,2) == 1;
    }
    
    // Helper to generate Test Trigger_Framework_Mock__c Records
    private static List<Trigger_Framework_Mock__c> loadTestRecordsForInsert() {
        final List<Trigger_Framework_Mock__c> testdata = new List<Trigger_Framework_Mock__c>();
        for (Integer i=0; i < CHUNKMAX; i++) {
            testdata.add(new Trigger_Framework_Mock__c(Name='TestRecord'+i, RequiredField__c='Populated'));
        }
        return testdata;
    }
    // Helper to generate Test Trigger_Framework_Mock__c records that appear to have been inserted into the database
    private static Map<Id,Trigger_Framework_Mock__c> loadTestRecordsForUpdate() {
        final Map<Id,Trigger_Framework_Mock__c> testdataMap = new Map<Id,Trigger_Framework_Mock__c>();
        for (Trigger_Framework_Mock__c current : loadTestRecordsForInsert()) {
            current.id = TestUtility.generateFakeId(Trigger_Framework_Mock__c.SobjectType);
            testdataMap.put(current.Id,current);
        }
        return testdataMap;
    }
    
    /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void beforeInsertRowLevelError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_ROWERRORS);
        final List<Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForInsert();
        handler.beforeInsert(inputDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        System.AssertEquals(false,handler.activeHelpers.isEmpty(),'No mock handlers returned!');
        final MockHelperRowErrors helper = (MockHelperRowErrors)handler.activeHelpers[0];
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
        
        for (Integer i=0; i < inputDataSet.size(); i++) {
            final Trigger_Framework_Mock__c current = inputDataSet[i];
            List<Database.Error> errors = current.getErrors();
            if (Math.mod(i,4)==0) { // Every 4th row should have an error
                System.assertEquals(1,errors.size(),'Expected row errors for every 4th row');
            } else {
                System.assertEquals(0,errors.size(),'Expected no row errors this row');                
            }
        }
    }
    
    /**
     * Ensure that an general error is logged and rethrown
     **/ 
    public static testmethod void beforeInsertGeneralError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_GENERALERRORS);       
        final List<Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForInsert();
        try {
            handler.beforeInsert(inputDataSet);
            System.Assert(false,'Expected an exception to be rethrown');
        } catch (IllegalArgumentException ex) {
            System.AssertEquals('finalizeBeforeInsert',ex.getMessage(),'finalizeBeforeInsert message wrong');
        }
        Test.StopTest();
    }

    
        /**
     * Ensure that the helpers are being called and processing normally
     **/ 
    public static testmethod void beforeUpdateHappy() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig();
        final Map<Id,Trigger_Framework_Mock__c> oldDataSet = loadTestRecordsForUpdate();
        final Map<Id,Trigger_Framework_Mock__c> inputDataSet = oldDataSet.clone();
        
        handler.beforeUpdate(inputDataSet,oldDataSet);
        
        Test.StopTest();     
        // Get the MockHandler to check the counts of records processed
        final MockHelperHappyPath helper = (MockHelperHappyPath)handler.activeHelpers[0];
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
        System.AssertEquals(inputDataset.size(),helper.previewBeforeUpdateCounter,'All input records must be previewed');
        System.AssertEquals(inputDataset.size(),helper.meetsEntryCriteriaBeforeUpdateCounter,'Every input record must be evaluated by meetsEntryCriteria');
        System.AssertEquals(oddCounter(inputDataset.size()),helper.processRecordBeforeUpdateCounter,'Every ODD input record must be processed');

    }
    /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void beforeUpdateRowLevelError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_ROWERRORS);
        final Map<Id,Trigger_Framework_Mock__c> updateDataSet = loadTestRecordsForUpdate();
        handler.beforeUpdate(updateDataSet,updateDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperRowErrors helper = (MockHelperRowErrors)handler.activeHelpers[0];
        System.AssertEquals(false,updateDataSet.isEmpty(),'Cannot have an empty data set');
        
        Integer i= 0;
        for (Trigger_Framework_Mock__c current:updateDataSet.values()) {
            List<Database.Error> errors = current.getErrors();
            if (Math.mod(i,4)==0) { // Every 4th row should have an error
                System.assertEquals(1,errors.size(),'Expected row errors for every 4th row');
            } else {
                System.assertEquals(0,errors.size(),'Expected no row errors this row');                
            }
            i++;
        }
    }
    /**
     * Ensure that an general error is logged and rethrown
     **/ 
    public static testmethod void beforeUpdateGeneralError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_GENERALERRORS);
        final Map<Id,Trigger_Framework_Mock__c> updateDataSet = loadTestRecordsForUpdate();
        try {
            handler.beforeUpdate(updateDataSet,updateDataSet);
            System.Assert(false,'Expected an exception to be rethrown');
        } catch (IllegalArgumentException ex) {
            System.AssertEquals('finalizeBeforeUpdate',ex.getMessage(),'finalizeBeforeUpdate message wrong');
        }

        Test.StopTest();        
    }
 
    
     /**
     * Ensure that the helpers are being called and processing normally
     **/ 
    public static testmethod void afterInsertHappy() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig();
        final Map<Id,Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForUpdate(); // This flavor create the map with Ids

        handler.afterInsert(inputDataSet);
        Test.StopTest();
    
        // Get the MockHandler to check the counts of records processed
        final MockHelperHappyPath helper = (MockHelperHappyPath)handler.activeHelpers[0];
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
        System.AssertEquals(inputDataset.size(),helper.previewAfterInsertCounter,'All input records must be previewed');
        System.AssertEquals(inputDataset.size(),helper.meetsEntryCriteriaAfterInsertCounter,'Every input record must evaluated by meetsEntryCriteria');
        System.AssertEquals(oddCounter(inputDataset.size()),helper.processRecordAfterInsertCounter,'Every ODD input record must be processed');
    }
    /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void afterInsertRowLevelError() {
        Test.StartTest();
            final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_ROWERRORS);
            final Map<Id,Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForUpdate();
            handler.afterInsert(inputDataSet);
            Test.StopTest();
            
            // Get the MockHandler to check the counts of records processed
            final MockHelperRowErrors helper = (MockHelperRowErrors)handler.activeHelpers[0];
            System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
            Integer i = 0;
            for (Trigger_Framework_Mock__c current: inputDataSet.values()) {
                List<Database.Error> errors = current.getErrors();
                if (Math.mod(i,4)==0) { // Every 4th row should have an error
                    System.assertEquals(1,errors.size(),'Expected row errors for every 4th row');
                } else {
                    System.assertEquals(0,errors.size(),'Expected no row errors this row');                
                }
                i++;
            }
    }

    
     /**
     * Ensure that the helpers are being called and processing normally
     **/ 
    public static testmethod void afterUpdateHappy() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig();
        final Map<Id,Trigger_Framework_Mock__c> oldDataSet = loadTestRecordsForUpdate();
        final Map<Id,Trigger_Framework_Mock__c> inputDataSet = oldDataSet.clone();
        
        handler.afterUpdate(inputDataSet,oldDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperHappyPath helper = (MockHelperHappyPath)handler.activeHelpers[0];
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
        System.AssertEquals(inputDataset.size(),helper.previewAfterUpdateCounter,'All input records must be previewed');
        System.AssertEquals(inputDataset.size(),helper.meetsEntryCriteriaAfterUpdateCounter,'Every input record must be evaluated by meetsEntryCriteria');
        System.AssertEquals(oddCounter(inputDataset.size()),helper.processRecordAfterUpdateCounter,'Every ODD input record must be processed');
    }
    /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void afterUpdateRowLevelError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_ROWERRORS);
        final Map<Id,Trigger_Framework_Mock__c> updateDataSet = loadTestRecordsForUpdate();
        handler.afterUpdate(updateDataSet,updateDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperRowErrors helper = (MockHelperRowErrors)handler.activeHelpers[0];
        System.AssertEquals(false,updateDataSet.isEmpty(),'Cannot have an empty data set');
        
        Integer i= 0;
        for (Trigger_Framework_Mock__c current:updateDataSet.values()) {
            List<Database.Error> errors = current.getErrors();
            if (Math.mod(i,4)==0) { // Every 4th row should have an error
                System.assertEquals(1,errors.size(),'Expected row errors for every 4th row');
            } else {
                System.assertEquals(0,errors.size(),'Expected no row errors this row');                
            }
            i++;
        }
    }
    /**
     * Ensure that an general error is logged and rethrown
     **/ 
    public static testmethod void afterInsertGeneralError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_GENERALERRORS);
        final Map<Id,Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForUpdate();

        try {
            handler.afterInsert(inputDataSet);
            System.Assert(false,'Expected an exception to be rethrown');
        } catch (IllegalArgumentException ex) {
            System.AssertEquals('finalizeAfterInsert',ex.getMessage(),'finalizeAfterInsert message wrong');
        }
        Test.StopTest();
    }
    /**
     * Ensure that an general error is logged and rethrown
     **/ 
    public static testmethod void afterUpdateGeneralError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_GENERALERRORS);
        final Map<Id,Trigger_Framework_Mock__c> updateDataSet = loadTestRecordsForUpdate();
        try {
            handler.afterUpdate(updateDataSet,updateDataSet);
            System.Assert(false,'Expected an exception to be rethrown');
        } catch (IllegalArgumentException ex) {
            System.AssertEquals('finalizeAfterUpdate',ex.getMessage(),'finalizeAfterUpdate message wrong');
        }
        Test.StopTest();
    }
    
     /**
     * Ensure that the After INSERT phase DML handles both Inserts and Updates
     **/
    public static testmethod void testAfterInsertDMLHappy() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_DMLTEST, new DMLExecutor());
        final Map<Id,Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForUpdate(); // This flavor creates the map with Ids

        handler.afterInsert(inputDataSet);
        Test.StopTest();
    
        // Get the MockHandler to check the counts of records processed
        System.AssertNotEquals(true,handler.activeHelpers.isEmpty(),'Active helpers cannot be empty -- TriggerHelperConfig__mdt config issue');
        final MockHelperHappyDML helper = (MockHelperHappyDML)handler.activeHelpers[0];
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
       
        // Inspect the TriggerDMLHandler
        TriggerDMLHandler dmlHandler=helper.getDMLHandler();
        System.AssertEquals(new DMLExecutor().toString(),dmlHandler.executor.toString(),'Expected Standard DMLExecutor');
        
        System.AssertEquals(inputDataSet.size()/2,dmlHandler.toInsert.size(),'Expected records to insert incorrect');
        // Validate Successful Inserts
        System.AssertEquals(dmlHandler.toInsert.size(),dmlHandler.toInsertResults.size(),'INSERT Results match input');
        for (Database.saveResult sr : dmlHandler.toInsertResults) {
            System.Assert(sr.isSuccess(),'Expected no DML failures:' + sr.toString());
        }
        // Validate Successful Updates - A single update is done in Finalize()
        System.AssertEquals(10,dmlHandler.toUpdateResults.size(),'UPDATE Results match input');
        for (Database.saveResult sr : dmlHandler.toUpdateResults) {
            System.Assert(sr.isSuccess(),'Expected no DML failures:' + sr.toString());
        }
    }
     /**
     * Ensure that the After UPDATE phase DML handles both Inserts and Updates
     **/
    public static testmethod void testAfterUpdateDMLHappy() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_DMLTEST,new DMLExecutor());
        final Map<Id,Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForUpdate(); // This flavor create the map with Ids
        final Map<Id,Trigger_Framework_Mock__c> originalInputDataSet = inputDataSet.clone();

        handler.afterUpdate(inputDataSet,originalInputDataSet);
        Test.StopTest();
    
        // Get the MockHandler to check the counts of records processed
        System.AssertNotEquals(true,handler.activeHelpers.isEmpty(),'Active helpers cannot be empty -- TriggerHelperConfig__mdt config issue');
        final MockHelperHappyDML helper = (MockHelperHappyDML)handler.activeHelpers[0];
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
       
        // Inspect the TriggerDMLHandler
        TriggerDMLHandler dmlHandler=helper.getDMLHandler();
        System.AssertEquals(new DMLExecutor().toString(),dmlHandler.executor.toString(),'Expected Standard DMLExecutor');
        
        System.AssertEquals(inputDataSet.size()/2,dmlHandler.toInsert.size(),'Expected records to insert incorrect');
        // Validate Successful Inserts
        System.AssertEquals(dmlHandler.toInsert.size(),dmlHandler.toInsertResults.size(),'INSERT Results match input');
        for (Database.saveResult sr : dmlHandler.toInsertResults) {
            System.Assert(sr.isSuccess(),'Expected no DML failures:' + sr.toString());
        }
        // Validate Successful Updates - A single update is done in Finalize()
        System.AssertEquals(10,dmlHandler.toUpdateResults.size(),'UPDATE Results match input');
        for (Database.saveResult sr : dmlHandler.toUpdateResults) {
            System.Assert(sr.isSuccess(),'Expected no DML failures:' + sr.toString());
        }
     }
    
         /**
     * Ensure that the After INSERT phase DML handles both Inserts and Updates
     **/
    public static testmethod void testBeforeInsertDMLHappy() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_DMLTEST, new DMLExecutor());
        final List<Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForInsert(); // This flavor creates the map with Ids
        System.debug(inputDataSet.size() + ' Test records for BeforeInsert');

        handler.beforeInsert(inputDataSet);
        Test.StopTest();
    
        // Get the MockHandler to check the counts of records processed
        System.AssertNotEquals(true,handler.activeHelpers.isEmpty(),'Active helpers cannot be empty -- TriggerHelperConfig__mdt config issue');
        final MockHelperHappyDML helper = (MockHelperHappyDML)handler.activeHelpers[0];
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
       
        // Inspect the TriggerDMLHandler
        TriggerDMLHandler dmlHandler=helper.getDMLHandler();
        System.AssertEquals(new DMLExecutor().toString(),dmlHandler.executor.toString(),'Expected Standard DMLExecutor');
        
        System.Debug('TriggerDMLHandler toInsert size: ' + dmlHandler.toInsert.size());
        System.AssertEquals(inputDataSet.size()/2,dmlHandler.toInsert.size(),'Expected records to insert incorrect');
        // Validate Successful Inserts
        System.AssertEquals(dmlHandler.toInsert.size(),dmlHandler.toInsertResults.size(),'INSERT Results match input');
        for (Database.saveResult sr : dmlHandler.toInsertResults) {
            System.Assert(sr.isSuccess(),'Expected no DML failures:' + sr.toString());
        }
        
        // Validate Successful Updates - A single update is done in Finalize()
        System.AssertEquals(10,dmlHandler.toUpdateResults.size(),'UPDATE Results match input');
        for (Database.saveResult sr : dmlHandler.toUpdateResults) {
            System.Assert(sr.isSuccess(),'Expected no DML failures:' + sr.toString());
        }
        
    }
     /**
     * Ensure that the After UPDATE phase DML handles both Inserts and Updates
     **/
    public static testmethod void testBeforeUpdateDMLHappy() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_DMLTEST,new DMLExecutor());
        final Map<Id,Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForUpdate(); // This flavor create the map with Ids
        final Map<Id,Trigger_Framework_Mock__c> originalInputDataSet = inputDataSet.clone();
        
        System.Debug('inputDataset.size()='+ inputDataSet.size());
        
        handler.beforeUpdate(inputDataSet,originalInputDataSet);
        Test.StopTest();
    
        // Get the MockHandler to check the counts of records processed
        System.AssertNotEquals(true,handler.activeHelpers.isEmpty(),'Active helpers cannot be empty -- TriggerHelperConfig__mdt config issue');
        final MockHelperHappyDML helper = (MockHelperHappyDML)handler.activeHelpers[0];
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
       
        // Inspect the TriggerDMLHandler
        TriggerDMLHandler dmlHandler=helper.getDMLHandler();
        System.AssertEquals(new DMLExecutor().toString(),dmlHandler.executor.toString(),'Expected Standard DMLExecutor');

        System.Debug('TriggerDMLHandler toInsert size: ' + dmlHandler.toInsert.size());        
        System.AssertEquals(inputDataSet.size()/2,dmlHandler.toInsert.size(),'Expected records to insert incorrect');
        // Validate Successful Inserts
        System.AssertEquals(dmlHandler.toInsert.size(),dmlHandler.toInsertResults.size(),'INSERT Results match input');
        for (Database.saveResult sr : dmlHandler.toInsertResults) {
            System.Assert(sr.isSuccess(),'Expected no DML failures:' + sr.toString());
        }
        // Validate Successful Updates - A single update is done in Finalize()
        System.AssertEquals(10,dmlHandler.toUpdateResults.size(),'UPDATE Results match input');
        for (Database.saveResult sr : dmlHandler.toUpdateResults) {
            System.Assert(sr.isSuccess(),'Expected no DML failures:' + sr.toString());
        }
     }
     /**
     * Ensure that the After INSERT phase DML handles both Inserts and Updates
     **/
    public static testmethod void testBeforeInsertHandleDMLExceptions() {
        Test.StartTest();
        // Install MockDMLExecutor that will throw mock exceptions
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_DMLTEST, new MockDMLExecutor());
        System.Debug(handler.dmlHandler.toString());
        
        final List<Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForInsert(); // This flavor creates the List without Ids

        handler.beforeInsert(inputDataSet);
        Test.StopTest();
    
        // Get the MockHandler to check the counts of records processed
        System.AssertNotEquals(true,handler.activeHelpers.isEmpty(),'Active helpers cannot be empty -- TriggerHelperConfig__mdt config issue');
        final MockHelperHappyDML helper = (MockHelperHappyDML)handler.activeHelpers[0];
        System.Debug(helper.getDMLHandler().toString());
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
       
        // Inspect the TriggerDMLHandler
        TriggerDMLHandler dmlHandler=helper.getDMLHandler();
        System.AssertEquals(new MockDMLExecutor().toString(),dmlHandler.executor.toString(),'Expected MockDMLExecutor');
        
        System.AssertEquals(inputDataSet.size()/2,dmlHandler.toInsert.size(),'Expected records to insert incorrect');
        // Validate Successful Inserts
        System.AssertEquals(dmlHandler.toInsert.size(),dmlHandler.toInsertResults.size(),'INSERT Results match input');
        Integer i=0;
        for (Database.saveResult sr : dmlHandler.toInsertResults) {
            Boolean expectedOutcome = (Math.mod(i,2)==1); // Success on ODD numbered rows
            System.AssertEquals(expectedOutcome,sr.isSuccess(),'Incorrect INSERT DML result:' + sr.toString());
            i++;
        }
        // Validate Successful Updates - A single update is done in Finalize()
        System.AssertEquals(10,dmlHandler.toUpdateResults.size(),'UPDATE Results match input');
        Integer u=0;
        for (Database.saveResult sr : dmlHandler.toUpdateResults) {
            Boolean expectedOutcome = (Math.mod(u,2)==1); // Success on ODD numbered rows
            System.AssertEquals(expectedOutcome,sr.isSuccess(),'Incorrect UPDATE DML result:' + sr.toString());
            u++;
        }
    }
     /**
     * Ensure that the After UPDATE phase DML handles both Inserts and Updates
     **/
    public static testmethod void testBeforeUpdateHandleDMLExceptions() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_DMLTEST, new MockDMLExecutor());
        final Map<Id,Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForUpdate(); // This flavor create the map with Ids
        final Map<Id,Trigger_Framework_Mock__c> originalInputDataSet = inputDataSet.clone();

        handler.beforeUpdate(inputDataSet,originalInputDataSet);
        Test.StopTest();
    
        // Get the MockHandler to check the counts of records processed
        System.AssertNotEquals(true,handler.activeHelpers.isEmpty(),'Active helpers cannot be empty -- TriggerHelperConfig__mdt config issue');
        final MockHelperHappyDML helper = (MockHelperHappyDML)handler.activeHelpers[0];
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
       
        // Inspect the TriggerDMLHandler
        TriggerDMLHandler dmlHandler=helper.getDMLHandler();
        System.AssertEquals(new MockDMLExecutor().toString(),dmlHandler.executor.toString(),'Expected MockDMLExecutor');
        
        System.AssertEquals(inputDataSet.size()/2,dmlHandler.toInsert.size(),'Expected records to insert incorrect');
        
        // Validate Successful Inserts
        System.AssertEquals(dmlHandler.toInsert.size(),dmlHandler.toInsertResults.size(),'INSERT Results match input');
        Integer i=0;
        for (Database.saveResult sr : dmlHandler.toInsertResults) {
            Boolean expectedOutcome = (Math.mod(i,2)==1); // Success on ODD numbered rows
            System.AssertEquals(expectedOutcome,sr.isSuccess(),'Incorrect INSERT DML result:' + sr.toString());
            i++;
        }
        // Validate Successful Updates - A 10 updates are done in Finalize()
        System.AssertEquals(10,dmlHandler.toUpdateResults.size(),'UPDATE Results match input');
        Integer u=0;
        for (Database.saveResult sr : dmlHandler.toUpdateResults) {
            Boolean expectedOutcome = (Math.mod(u,2)==1); // Success on ODD numbered rows
            System.AssertEquals(expectedOutcome,sr.isSuccess(),'Incorrect UPDATE DML result:' + sr.toString());
            u++;
        }
    }

    
     /**
     * Ensure that the After INSERT phase DML handles both Inserts and Updates
     **/
    public static testmethod void testAfterInsertHandleDMLExceptions() {
        Test.StartTest();
        // Install MockDMLExecutor that will throw mock exceptions
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_DMLTEST, new MockDMLExecutor());
        System.Debug(handler.dmlHandler.toString());
        
        final Map<Id,Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForUpdate(); // This flavor creates the map with Ids

        handler.afterInsert(inputDataSet);
        Test.StopTest();
    
        // Get the MockHandler to check the counts of records processed
        System.AssertNotEquals(true,handler.activeHelpers.isEmpty(),'Active helpers cannot be empty -- TriggerHelperConfig__mdt config issue');
        final MockHelperHappyDML helper = (MockHelperHappyDML)handler.activeHelpers[0];
        System.Debug(helper.getDMLHandler().toString());
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
       
        // Inspect the TriggerDMLHandler
        TriggerDMLHandler dmlHandler=helper.getDMLHandler();
        System.AssertEquals(new MockDMLExecutor().toString(),dmlHandler.executor.toString(),'Expected MockDMLExecutor');
        
        System.AssertEquals(inputDataSet.size()/2,dmlHandler.toInsert.size(),'Expected records to insert incorrect');
        // Validate Successful Inserts
        System.AssertEquals(dmlHandler.toInsert.size(),dmlHandler.toInsertResults.size(),'INSERT Results match input');
        Integer i=0;
        for (Database.saveResult sr : dmlHandler.toInsertResults) {
            Boolean expectedOutcome = (Math.mod(i,2)==1); // Success on ODD numbered rows
            System.AssertEquals(expectedOutcome,sr.isSuccess(),'Incorrect INSERT DML result:' + sr.toString());
            i++;
        }
        // Validate Successful Updates - A single update is done in Finalize()
        System.AssertEquals(10,dmlHandler.toUpdateResults.size(),'UPDATE Results match input');
        Integer u=0;
        for (Database.saveResult sr : dmlHandler.toUpdateResults) {
            Boolean expectedOutcome = (Math.mod(u,2)==1); // Success on ODD numbered rows
            System.AssertEquals(expectedOutcome,sr.isSuccess(),'Incorrect UPDATE DML result:' + sr.toString());
            u++;
        }
    }
     /**
     * Ensure that the After UPDATE phase DML handles both Inserts and Updates
     **/
    public static testmethod void testAfterUpdateHandleDMLExceptions() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_DMLTEST, new MockDMLExecutor());
        final Map<Id,Trigger_Framework_Mock__c> inputDataSet = loadTestRecordsForUpdate(); // This flavor create the map with Ids
        final Map<Id,Trigger_Framework_Mock__c> originalInputDataSet = inputDataSet.clone();

        handler.afterUpdate(inputDataSet,originalInputDataSet);
        Test.StopTest();
    
        // Get the MockHandler to check the counts of records processed
        System.AssertNotEquals(true,handler.activeHelpers.isEmpty(),'Active helpers cannot be empty -- TriggerHelperConfig__mdt config issue');
        final MockHelperHappyDML helper = (MockHelperHappyDML)handler.activeHelpers[0];
        System.AssertEquals(false,inputDataset.isEmpty(),'Cannot have an empty data set');
       
        // Inspect the TriggerDMLHandler
        TriggerDMLHandler dmlHandler=helper.getDMLHandler();
        System.AssertEquals(new MockDMLExecutor().toString(),dmlHandler.executor.toString(),'Expected MockDMLExecutor');
        
        System.AssertEquals(inputDataSet.size()/2,dmlHandler.toInsert.size(),'Expected records to insert incorrect');
        
        // Validate Successful Inserts
        System.AssertEquals(dmlHandler.toInsert.size(),dmlHandler.toInsertResults.size(),'INSERT Results match input');
        Integer i=0;
        for (Database.saveResult sr : dmlHandler.toInsertResults) {
            Boolean expectedOutcome = (Math.mod(i,2)==1); // Success on ODD numbered rows
            System.AssertEquals(expectedOutcome,sr.isSuccess(),'Incorrect INSERT DML result:' + sr.toString());
            i++;
        }
        // Validate Successful Updates - A 10 updates are done in Finalize()
        System.AssertEquals(10,dmlHandler.toUpdateResults.size(),'UPDATE Results match input');
        Integer u=0;
        for (Database.saveResult sr : dmlHandler.toUpdateResults) {
            Boolean expectedOutcome = (Math.mod(u,2)==1); // Success on ODD numbered rows
            System.AssertEquals(expectedOutcome,sr.isSuccess(),'Incorrect UPDATE DML result:' + sr.toString());
            u++;
        }
    }

    /** 
     * Test Helper management methods
     * */
    
    /**
     * Test the Instantiation of the Helpers
     **/ 
    public static testmethod void instantiateHelpers() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig();
        final List<ITriggerHelper> helpers = handler.instantiateHelpers();
        Test.StopTest();
        System.AssertNotEquals(0,helpers.size(),'Must return 1 or more helpers');
    }
    /**
     * Test the Initialization of the Helpers
     **/ 
    public static testmethod void initializeHelpers() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig();
        final List<ITriggerHelper> helpers = handler.instantiateHelpers();
        LookupDataHandler dataHandler = new LookupDataHandler();
        TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        handler.initialiseHelpers(helpers, dataHandler,dmlHandler);
        
        Test.StopTest();
        System.AssertNotEquals(0,helpers.size(),'Helpers must not be empty');
        for(ITriggerHelper helper : helpers) {
           System.AssertEquals(dataHandler,helper.getDataHandler(),'Expected getDataHandler to be set');
           System.AssertEquals((IHelperDMLHandler)dmlHandler,helper.getDMLHandler(),'Expected getDMLHandler to be set');
        }

    }
    
    /** Test the generic methods **/
    public static testmethod void getInstance() {
        final ITriggerHandler inst1 = new MockTriggerHandler().getInstance();
        final ITriggerHandler inst2 = new MockTriggerHandler().getInstance();

        System.AssertNotEquals(null,inst1,'Cannot return null');
        System.AssertEquals(inst1,inst2,'Must return the same instance');
    }
    public static testmethod void isDisabledTrue() {
        Test.StartTest();
        
        // Initialize the Custom Setting to disable it
        Trigger_Bypass_Setting__c triggerSetting = Trigger_Bypass_Setting__c.getOrgDefaults();
        triggerSetting.Bypass_Mock_Trigger__c=true;
        upsert triggerSetting triggerSetting.Id;
        
        Test.StopTest();
        System.AssertEquals(true,getTriggerHandlerTestConfig().isDisabled(),'Must be disabled');
    }
    public static testmethod void isDisabledFalse() {
        Test.StartTest();
        
        // Initialize the Custom Setting to disable it
        Trigger_Bypass_Setting__c triggerSetting = Trigger_Bypass_Setting__c.getOrgDefaults();
        triggerSetting.Bypass_Mock_Trigger__c=false;
        upsert triggerSetting triggerSetting.Id;
        
        Test.StopTest();
        System.AssertEquals(false,getTriggerHandlerTestConfig().isDisabled(),'Must not be disabled');
    }
     /**
     * Helper to Instantiate the TriggerHandler with our Debug MockHelper Classes initialized
     **/ 
    public static AbstractBaseTriggerHandler getTriggerHandlerTestConfig(final String contextOverride, final DMLExecutor dmlExecutor) {
        // Set the static context to ensure we get the Mock Helpers only
        TriggerHelperFactory.factoryContext=contextOverride; 
        // Set the static context to ensure we get the CORRECT DML executor (good or mock)
        AbstractBaseTriggerHandler.dmlExecutor=dmlExecutor;
        return (AbstractBaseTriggerHandler)  (new MockTriggerHandler()).getInstance();
    }
    
     /**
     * Helper to Instantiate the TriggerHandler with our Debug MockHelper Classes initialized
     **/ 
    public static AbstractBaseTriggerHandler getTriggerHandlerTestConfig(final String contextOverride) {
        // Default to the "normal" DMLExecutor that will not throw mock errors
        return getTriggerHandlerTestConfig(contextOverride,new DMLExecutor());
    }

    /**
     * Convenience override for happy path
     **/ 
    public static AbstractBaseTriggerHandler getTriggerHandlerTestConfig() {
        return getTriggerHandlerTestConfig(CTX_HAPPYPATH,new DMLExecutor());
    }
    

    
    public static testmethod void beforeInsertDMLAllowed() {
        AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig();
        
        List<SObject> newObjects = new List<SObject>();
        List<SObject> oldObjects = new List<SObject>();
        
        
        Test.StartTest();
        handler.beforeInsert(newObjects);
        ITriggerHelper helper = handler.activeHelpers[0]; // Get the Mock helper       
        IHelperDMLHandler dmlHandler = helper.getDMLHandler();
        
        Test.StopTest();
        System.AssertNotEquals(null,dmlHandler,'DML Handler must be initialized on Helper');
    }
    public static testmethod void beforeUpdateDMLAllowed() {
        AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig();
        
        Map<Id,SObject> newObjects = new Map<Id,SObject>();
        Map<Id,SObject> oldObjects = new Map<Id,SObject>();
        
        
        Test.StartTest();
        handler.beforeUpdate(newObjects,oldObjects);
        ITriggerHelper helper = handler.activeHelpers[0]; // Get the Mock helper       
        IHelperDMLHandler dmlHandler = helper.getDMLHandler();
        
        Test.StopTest();
        System.AssertNotEquals(null,dmlHandler,'DML Handler must be initialized on Helper');
   }

  
     /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void beforeDeletePreviewError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_PREVIEWERRORS);
        final Map<Id,Trigger_Framework_Mock__c> updateDataSet = loadTestRecordsForUpdate();
        handler.beforeDelete(updateDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperPreviewErrors helper = (MockHelperPreviewErrors)handler.activeHelpers[0];
        System.AssertEquals(false,updateDataSet.isEmpty(),'Cannot have an empty data set');
        
        Integer i= 0;
        for (Trigger_Framework_Mock__c current:updateDataSet.values()) {
            List<Database.Error> errors = current.getErrors();
            if (Math.mod(i,2)==0) { // Every 2nd row should have an error
                System.assertEquals(1,errors.size(),'Expected row errors for every 2nd row');
            } else {
                System.assertEquals(0,errors.size(),'Expected no row errors this row');                
            }
            i++;
        }
    }
     
    /**
     * Ensure that the helpers are being called and processing normally
     **/ 
    public static testmethod void beforeDeleteHappy() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig();
        final Map<Id,Trigger_Framework_Mock__c> oldDataSet = loadTestRecordsForUpdate();
        
        handler.beforeDelete(oldDataSet);
        
        Test.StopTest();     
        // Get the MockHandler to check the counts of records processed
        final MockHelperHappyPath helper = (MockHelperHappyPath)handler.activeHelpers[0];
        System.AssertEquals(false,oldDataSet.isEmpty(),'Cannot have an empty data set');
        System.AssertEquals(oldDataSet.size(),helper.previewBeforeDeleteCounter,'All input records must be previewed');
        System.AssertEquals(oldDataSet.size(),helper.meetsEntryCriteriaBeforeDeleteCounter,'Every input record must be evaluated by meetsEntryCriteria');
        System.AssertEquals(oddCounter(oldDataSet.size()),helper.processRecordBeforeDeleteCounter,'Every ODD input record must be processed');
    }

    /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void beforeDeleteRowLevelError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_ROWERRORS);
        final Map<Id,Trigger_Framework_Mock__c> updateDataSet = loadTestRecordsForUpdate();
        handler.beforeDelete(updateDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperRowErrors helper = (MockHelperRowErrors)handler.activeHelpers[0];
        System.AssertEquals(false,updateDataSet.isEmpty(),'Cannot have an empty data set');
        
        Integer i= 0;
        for (Trigger_Framework_Mock__c current:updateDataSet.values()) {
            List<Database.Error> errors = current.getErrors();
            if (Math.mod(i,4)==0) { // Every 4th row should have an error
                System.assertEquals(1,errors.size(),'Expected row errors for every 4th row');
            } else {
                System.assertEquals(0,errors.size(),'Expected no row errors this row');                
            }
            i++;
        }
    }

    /**
     * Ensure that an general error is logged and rethrown
     **/ 
    public static testmethod void beforeDeleteGeneralError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_GENERALERRORS);
        final Map<Id,Trigger_Framework_Mock__c> updateDataSet = loadTestRecordsForUpdate();
        try {
            handler.beforeDelete(updateDataSet);
            System.Assert(false,'Expected an exception to be rethrown');
        } catch (IllegalArgumentException ex) {
            System.AssertEquals('finalizeBeforeDelete',ex.getMessage(),'finalizeBeforeDelete message wrong');
        }

        Test.StopTest();        
    }

    public static testmethod void beforeDeleteDMLAllowed() {
        AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig();
        
        Map<Id,SObject> oldObjects = new Map<Id,SObject>();
                
        Test.StartTest();
        handler.beforeDelete(oldObjects);
        ITriggerHelper helper = handler.activeHelpers[0]; // Get the Mock helper       
        IHelperDMLHandler dmlHandler = helper.getDMLHandler();
        
        Test.StopTest();
        System.AssertNotEquals(null,dmlHandler,'DML Handler must be initialized on Helper');
   }

     /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void afterDeleteRowPreviewError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_PREVIEWERRORS);
        final Map<Id,Trigger_Framework_Mock__c> deleteDataSet = loadTestRecordsForUpdate();
        handler.afterDelete(deleteDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperPreviewErrors helper = (MockHelperPreviewErrors)handler.activeHelpers[0];
        System.AssertEquals(false,deleteDataSet.isEmpty(),'Cannot have an empty data set');
        
        Integer i= 0;
        for (Trigger_Framework_Mock__c current:deleteDataSet.values()) {
            List<Database.Error> errors = current.getErrors();
            if (Math.mod(i,2)==0) { // Every 2nd row should have an error
                System.assertEquals(1,errors.size(),'Expected row errors for every 2nd row');
            } else {
                System.assertEquals(0,errors.size(),'Expected no row errors this row');                
            }
            i++;
        }
    }

    /**
     * Ensure that the helpers are being called and processing normally
     **/ 
    public static testmethod void afterDeleteHappy() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig();
        final Map<Id,Trigger_Framework_Mock__c> oldDataSet = loadTestRecordsForUpdate();
        
        handler.afterDelete(oldDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperHappyPath helper = (MockHelperHappyPath)handler.activeHelpers[0];
        System.AssertEquals(false,oldDataSet.isEmpty(),'Cannot have an empty data set');
        System.AssertEquals(oldDataSet.size(),helper.previewAfterDeleteCounter,'All input records must be previewed');
        System.AssertEquals(oldDataSet.size(),helper.meetsEntryCriteriaAfterDeleteCounter,'Every input record must be evaluated by meetsEntryCriteria');
        System.AssertEquals(oddCounter(oldDataSet.size()),helper.processRecordAfterDeleteCounter,'Every ODD input record must be processed');
    } 
    
    /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void afterDeleteRowLevelError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_ROWERRORS);
        final Map<Id,Trigger_Framework_Mock__c> deleteDataSet = loadTestRecordsForUpdate();
        handler.afterDelete(deleteDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperRowErrors helper = (MockHelperRowErrors)handler.activeHelpers[0];
        System.AssertEquals(false,deleteDataSet.isEmpty(),'Cannot have an empty data set');
        
        Integer i= 0;
        for (Trigger_Framework_Mock__c current:deleteDataSet.values()) {
            List<Database.Error> errors = current.getErrors();
            if (Math.mod(i,4)==0) { // Every 4th row should have an error
                System.assertEquals(1,errors.size(),'Expected row errors for every 4th row');
            } else {
                System.assertEquals(0,errors.size(),'Expected no row errors this row');                
            }
            i++;
        }
    }

     /**
     * Ensure that an general error is logged and rethrown
     **/ 
    public static testmethod void afterDeleteGeneralError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_GENERALERRORS);
        final Map<Id,Trigger_Framework_Mock__c> deleteDataSet = loadTestRecordsForUpdate();
        try {
            handler.afterDelete(deleteDataSet);
            System.Assert(false,'Expected an exception to be rethrown');
        } catch (IllegalArgumentException ex) {
            System.AssertEquals('finalizeAfterDelete',ex.getMessage(),'finalizeAfterDelete message wrong');
        }
        Test.StopTest();
    }
    
     /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void afterUndeleteRowPreviewError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_PREVIEWERRORS);
        final Map<Id,Trigger_Framework_Mock__c> undeleteDataSet = loadTestRecordsForUpdate();
        handler.afterUndelete(undeleteDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperPreviewErrors helper = (MockHelperPreviewErrors)handler.activeHelpers[0];
        System.AssertEquals(false,undeleteDataSet.isEmpty(),'Cannot have an empty data set');
        
        Integer i= 0;
        for (Trigger_Framework_Mock__c current:undeleteDataSet.values()) {
            List<Database.Error> errors = current.getErrors();
            if (Math.mod(i,2)==0) { // Every 2nd row should have an error
                System.assertEquals(1,errors.size(),'Expected row errors for every 2nd row');
            } else {
                System.assertEquals(0,errors.size(),'Expected no row errors this row');                
            }
            i++;
        }
    }

    /**
     * Ensure that the helpers are being called and processing normally
     **/ 
    public static testmethod void afterUndeleteHappy() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig();
        final Map<Id,Trigger_Framework_Mock__c> oldDataSet = loadTestRecordsForUpdate();
        
        handler.afterUndelete(oldDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperHappyPath helper = (MockHelperHappyPath)handler.activeHelpers[0];
        System.Debug('helper mock:'+helper);
        System.AssertEquals(false,oldDataSet.isEmpty(),'Cannot have an empty data set');
        System.AssertEquals(oldDataSet.size(),helper.previewAfterUndeleteCounter,'All input records must be previewed');
        System.AssertEquals(oldDataSet.size(),helper.meetsEntryCriteriaAfterUndeleteCounter,'Every input record must be evaluated by meetsEntryCriteria');
        System.AssertEquals(oddCounter(oldDataSet.size()),helper.processRecordAfterUndeleteCounter,'Every ODD input record must be processed');
    } 
    
    /**
     * Ensure that a row level error is logged and returned via addError()
     **/ 
    public static testmethod void afterUndeleteRowLevelError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_ROWERRORS);
        final Map<Id,Trigger_Framework_Mock__c> undeleteDataSet = loadTestRecordsForUpdate();
        handler.afterUndelete(undeleteDataSet);
        Test.StopTest();
        
        // Get the MockHandler to check the counts of records processed
        final MockHelperRowErrors helper = (MockHelperRowErrors)handler.activeHelpers[0];
        System.AssertEquals(false,undeleteDataSet.isEmpty(),'Cannot have an empty data set');
        
        Integer i= 0;
        for (Trigger_Framework_Mock__c current:undeleteDataSet.values()) {
            List<Database.Error> errors = current.getErrors();
            if (Math.mod(i,4)==0) { // Every 4th row should have an error
                System.assertEquals(1,errors.size(),'Expected row errors for every 4th row');
            } else {
                System.assertEquals(0,errors.size(),'Expected no row errors this row');                
            }
            i++;
        }
    }

  /**
     * Ensure that an general error is logged and rethrown
     **/ 
    public static testmethod void afterUndeleteGeneralError() {
        Test.StartTest();
        final AbstractBaseTriggerHandler handler = getTriggerHandlerTestConfig(CTX_GENERALERRORS);
        final Map<Id,Trigger_Framework_Mock__c> undeleteDataSet = loadTestRecordsForUpdate();
        try {
            handler.afterUndelete(undeleteDataSet);
            System.Assert(false,'Expected an exception to be rethrown');
        } catch (IllegalArgumentException ex) {
            System.AssertEquals('finalizeAfterUndelete',ex.getMessage(),'finalizeAfterUndelete message wrong');
        }
        Test.StopTest();
    }

}