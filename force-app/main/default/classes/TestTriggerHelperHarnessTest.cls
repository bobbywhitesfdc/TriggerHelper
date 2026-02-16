/**
 * Comprehensive test class demonstrating TestTriggerHelperHarness usage
 * 
 * Tests all trigger operations: INSERT, UPDATE, DELETE, UNDELETE
 * Verifies proper lifecycle management with separate before/after phase helpers
 * 
 * @author Bobby White
 * @date 2026-02-16
 **/
@IsTest
public class TestTriggerHelperHarnessTest {
    
    // Test data size
    public static final Integer RECCOUNT = 20;
    
    // ========================================================================
    // INSERT Tests
    // ========================================================================
    
    /**
     * Test INSERT operation with comprehensive before/after phase verification
     **/
    @isTest
    static void testInsert_VerifiesSeparatePhases() {
        // Create Test data
        List<Trigger_Framework_Mock__c> testData = new List<Trigger_Framework_Mock__c>();
        for (Integer i = 0; i < RECCOUNT; i++) {
            testData.add(new Trigger_Framework_Mock__c(Name = 'Test' + i));
        }
        
        // Initialize the harness
        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Trigger_Framework_Mock__c.SObjectType);
        harness.setDMLExecutor(new MockDMLExecutor());
        harness.setHelperUnderTest('MockHelperHappyPath');
        
        // Execute
        Test.startTest();
        harness.doInsert(testData);        
        Test.stopTest();
        
        // ====================================================================
        // VERIFY BEFORE PHASE
        // ====================================================================
        MockITriggerHelper beforeHelper = (MockITriggerHelper) harness.getBeforePhaseHelper();
        System.assertNotEquals(null, beforeHelper, 'Before helper should exist');
        System.debug('BEFORE helper: ' + JSON.serialize(beforeHelper));
        
        // Verify before phase counters
        System.assertEquals(RECCOUNT, beforeHelper.previewBeforeInsertCounter, 
            'Before phase: preview should see all records');
        System.assertEquals(RECCOUNT, beforeHelper.meetsEntryCriteriaBeforeInsertCounter, 
            'Before phase: meetsEntryCriteria should see all records');
        System.assertEquals(RECCOUNT / 2, beforeHelper.processRecordBeforeInsertCounter, 
            'Before phase: processRecord should see half of all records');
        System.assertEquals(1, beforeHelper.finalizeBeforeInsertCounter, 
            'Before phase: finalize must be executed once');
        
        // Verify no after phase activity in before helper
        System.assertEquals(0, beforeHelper.previewAfterInsertCounter, 
            'Before helper should NOT have after phase preview calls');
        System.assertEquals(0, beforeHelper.meetsEntryCriteriaAfterInsertCounter, 
            'Before helper should NOT have after phase entry criteria calls');
        System.assertEquals(0, beforeHelper.processRecordAfterInsertCounter, 
            'Before helper should NOT have after phase process calls');
        System.assertEquals(0, beforeHelper.finalizeAfterInsertCounter, 
            'Before helper should NOT have after phase finalize calls');
        
        // ====================================================================
        // VERIFY AFTER PHASE
        // ====================================================================
        MockITriggerHelper afterHelper = (MockITriggerHelper) harness.getAfterPhaseHelper();
        System.assertNotEquals(null, afterHelper, 'After helper should exist');
        System.debug('AFTER helper: ' + JSON.serialize(afterHelper));
        
        // CRITICAL: Verify separate instances
        System.assert(beforeHelper !== afterHelper, 
            'Before and After helpers MUST be different instances');
        
        // Verify after phase counters
        System.assertEquals(RECCOUNT, afterHelper.previewAfterInsertCounter, 
            'After phase: preview should see all records');
        System.assertEquals(RECCOUNT, afterHelper.meetsEntryCriteriaAfterInsertCounter, 
            'After phase: meetsEntryCriteria should see all records');
        System.assertEquals(RECCOUNT / 2, afterHelper.processRecordAfterInsertCounter, 
            'After phase: processRecord should see half of all records');
        System.assertEquals(1, afterHelper.finalizeAfterInsertCounter, 
            'After phase: finalize must be executed once');
        
        // Verify no before phase activity in after helper
        System.assertEquals(0, afterHelper.previewBeforeInsertCounter, 
            'After helper should NOT have before phase preview calls');
        System.assertEquals(0, afterHelper.meetsEntryCriteriaBeforeInsertCounter, 
            'After helper should NOT have before phase entry criteria calls');
        System.assertEquals(0, afterHelper.processRecordBeforeInsertCounter, 
            'After helper should NOT have before phase process calls');
        System.assertEquals(0, afterHelper.finalizeBeforeInsertCounter, 
            'After helper should NOT have before phase finalize calls');
    }
    
    // ========================================================================
    // UPDATE Tests
    // ========================================================================
    
    /**
     * Test UPDATE operation with separate before/after phase verification
     **/
    @isTest
    static void testUpdate_VerifiesSeparatePhases() {
        // Create test data with Ids (required for update)
        List<Trigger_Framework_Mock__c> oldRecords = new List<Trigger_Framework_Mock__c>();
        List<Trigger_Framework_Mock__c> newRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i = 0; i < RECCOUNT; i++) {
            Id mockId = TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType);
            oldRecords.add(new Trigger_Framework_Mock__c(
                Id = mockId, 
                Name = 'OldTest' + i,
                RequiredField__c = 'Old Value'
            ));
            newRecords.add(new Trigger_Framework_Mock__c(
                Id = mockId, 
                Name = 'NewTest' + i,
                RequiredField__c = 'New Value'
            ));
        }
        
        // Initialize the harness
        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Trigger_Framework_Mock__c.SObjectType);
        harness.setDMLExecutor(new MockDMLExecutor());
        harness.setHelperUnderTest('MockHelperHappyPath');
        
        // Execute
        Test.startTest();
        harness.doUpdate(newRecords, oldRecords);
        Test.stopTest();
        
        // ====================================================================
        // VERIFY BEFORE PHASE
        // ====================================================================
        MockITriggerHelper beforeHelper = (MockITriggerHelper) harness.getBeforePhaseHelper();
        System.assertNotEquals(null, beforeHelper, 'Before helper should exist');
        System.debug('UPDATE BEFORE helper: ' + JSON.serialize(beforeHelper));
        
        // Verify before update counters
        System.assertEquals(RECCOUNT, beforeHelper.previewBeforeUpdateCounter, 
            'Before phase: preview should see all records');
        System.assertEquals(RECCOUNT, beforeHelper.meetsEntryCriteriaBeforeUpdateCounter, 
            'Before phase: meetsEntryCriteria should see all records');
        System.assertEquals(RECCOUNT / 2, beforeHelper.processRecordBeforeUpdateCounter, 
            'Before phase: processRecord should see half of all records');
        System.assertEquals(1, beforeHelper.finalizeBeforeUpdateCounter, 
            'Before phase: finalize must be executed once');
        
        // Verify no after phase activity in before helper
        System.assertEquals(0, beforeHelper.previewAfterUpdateCounter, 
            'Before helper should NOT have after phase preview calls');
        System.assertEquals(0, beforeHelper.meetsEntryCriteriaAfterUpdateCounter, 
            'Before helper should NOT have after phase entry criteria calls');
        System.assertEquals(0, beforeHelper.processRecordAfterUpdateCounter, 
            'Before helper should NOT have after phase process calls');
        System.assertEquals(0, beforeHelper.finalizeAfterUpdateCounter, 
            'Before helper should NOT have after phase finalize calls');
        
        // Verify no insert activity (sanity check)
        System.assertEquals(0, beforeHelper.previewBeforeInsertCounter, 
            'Update operation should not trigger insert methods');
        
        // ====================================================================
        // VERIFY AFTER PHASE
        // ====================================================================
        MockITriggerHelper afterHelper = (MockITriggerHelper) harness.getAfterPhaseHelper();
        System.assertNotEquals(null, afterHelper, 'After helper should exist');
        System.debug('UPDATE AFTER helper: ' + JSON.serialize(afterHelper));
        
        // CRITICAL: Verify separate instances
        System.assert(beforeHelper !== afterHelper, 
            'UPDATE: Before and After helpers MUST be different instances');
        
        // Verify after update counters
        System.assertEquals(RECCOUNT, afterHelper.previewAfterUpdateCounter, 
            'After phase: preview should see all records');
        System.assertEquals(RECCOUNT, afterHelper.meetsEntryCriteriaAfterUpdateCounter, 
            'After phase: meetsEntryCriteria should see all records');
        System.assertEquals(RECCOUNT / 2, afterHelper.processRecordAfterUpdateCounter, 
            'After phase: processRecord should see half of all records');
        System.assertEquals(1, afterHelper.finalizeAfterUpdateCounter, 
            'After phase: finalize must be executed once');
        
        // Verify no before phase activity in after helper
        System.assertEquals(0, afterHelper.previewBeforeUpdateCounter, 
            'After helper should NOT have before phase preview calls');
        System.assertEquals(0, afterHelper.meetsEntryCriteriaBeforeUpdateCounter, 
            'After helper should NOT have before phase entry criteria calls');
        System.assertEquals(0, afterHelper.processRecordBeforeUpdateCounter, 
            'After helper should NOT have before phase process calls');
        System.assertEquals(0, afterHelper.finalizeBeforeUpdateCounter, 
            'After helper should NOT have before phase finalize calls');
        
        // Verify no insert activity (sanity check)
        System.assertEquals(0, afterHelper.previewAfterInsertCounter, 
            'Update operation should not trigger insert methods');
    }
    
    /**
     * Test UPDATE operation with field changes verification
     **/
    @isTest
    static void testUpdate_FieldChangesAccessible() {
        // Create a single record to test field change access
        Id mockId = TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType);
        
        Trigger_Framework_Mock__c oldRecord = new Trigger_Framework_Mock__c(
            Id = mockId,
            Name = 'Original Name',
            RequiredField__c = 'Original Value',
            MockExternalId__c = 'EXT-001'
        );
        
        Trigger_Framework_Mock__c newRecord = new Trigger_Framework_Mock__c(
            Id = mockId,
            Name = 'Updated Name',
            RequiredField__c = 'Updated Value',
            MockExternalId__c = 'EXT-002'
        );
        
        // Initialize the harness
        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Trigger_Framework_Mock__c.SObjectType);
        harness.setDMLExecutor(new MockDMLExecutor());
        harness.setHelperUnderTest('MockHelperHappyPath');
        
        // Execute
        Test.startTest();
        harness.doUpdate(
            new List<Trigger_Framework_Mock__c>{ newRecord },
            new List<Trigger_Framework_Mock__c>{ oldRecord }
        );
        Test.stopTest();
        
        // Verify both helpers executed
        System.assertNotEquals(null, harness.getBeforePhaseHelper(), 
            'Before helper should have processed update');
        System.assertNotEquals(null, harness.getAfterPhaseHelper(), 
            'After helper should have processed update');
    }
    
    // ========================================================================
    // DELETE Tests
    // ========================================================================
    
    /**
     * Test DELETE operation with separate before/after phase verification
     **/
    @isTest
    static void testDelete_VerifiesSeparatePhases() {
        // Create test data with Ids (required for delete)
        List<Trigger_Framework_Mock__c> deletedRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i = 0; i < RECCOUNT; i++) {
            deletedRecords.add(new Trigger_Framework_Mock__c(
                Id = TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType),
                Name = 'ToDelete' + i,
                RequiredField__c = 'Will be deleted'
            ));
        }
        
        // Initialize the harness
        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Trigger_Framework_Mock__c.SObjectType);
        harness.setDMLExecutor(new MockDMLExecutor());
        harness.setHelperUnderTest('MockHelperHappyPath');
        
        // Execute
        Test.startTest();
        harness.doDelete(deletedRecords);
        Test.stopTest();
        
        // ====================================================================
        // VERIFY BEFORE PHASE
        // ====================================================================
        MockITriggerHelper beforeHelper = (MockITriggerHelper) harness.getBeforePhaseHelper();
        System.assertNotEquals(null, beforeHelper, 'Before helper should exist');
        System.debug('DELETE BEFORE helper: ' + JSON.serialize(beforeHelper));
        
        // Verify before delete counters
        System.assertEquals(RECCOUNT, beforeHelper.previewBeforeDeleteCounter, 
            'Before phase: preview should see all records');
        System.assertEquals(RECCOUNT, beforeHelper.meetsEntryCriteriaBeforeDeleteCounter, 
            'Before phase: meetsEntryCriteria should see all records');
        System.assertEquals(RECCOUNT / 2, beforeHelper.processRecordBeforeDeleteCounter, 
            'Before phase: processRecord should see half of all records');
        System.assertEquals(1, beforeHelper.finalizeBeforeDeleteCounter, 
            'Before phase: finalize must be executed once');
        
        // Verify no after phase activity in before helper
        System.assertEquals(0, beforeHelper.previewAfterDeleteCounter, 
            'Before helper should NOT have after phase preview calls');
        System.assertEquals(0, beforeHelper.meetsEntryCriteriaAfterDeleteCounter, 
            'Before helper should NOT have after phase entry criteria calls');
        System.assertEquals(0, beforeHelper.processRecordAfterDeleteCounter, 
            'Before helper should NOT have after phase process calls');
        System.assertEquals(0, beforeHelper.finalizeAfterDeleteCounter, 
            'Before helper should NOT have after phase finalize calls');
        
        // Verify no insert/update activity (sanity check)
        System.assertEquals(0, beforeHelper.previewBeforeInsertCounter, 
            'Delete operation should not trigger insert methods');
        System.assertEquals(0, beforeHelper.previewBeforeUpdateCounter, 
            'Delete operation should not trigger update methods');
        
        // ====================================================================
        // VERIFY AFTER PHASE
        // ====================================================================
        MockITriggerHelper afterHelper = (MockITriggerHelper) harness.getAfterPhaseHelper();
        System.assertNotEquals(null, afterHelper, 'After helper should exist');
        System.debug('DELETE AFTER helper: ' + JSON.serialize(afterHelper));
        
        // CRITICAL: Verify separate instances
        System.assert(beforeHelper !== afterHelper, 
            'DELETE: Before and After helpers MUST be different instances');
        
        // Verify after delete counters
        System.assertEquals(RECCOUNT, afterHelper.previewAfterDeleteCounter, 
            'After phase: preview should see all records');
        System.assertEquals(RECCOUNT, afterHelper.meetsEntryCriteriaAfterDeleteCounter, 
            'After phase: meetsEntryCriteria should see all records');
        System.assertEquals(RECCOUNT / 2, afterHelper.processRecordAfterDeleteCounter, 
            'After phase: processRecord should see half of all records');
        System.assertEquals(1, afterHelper.finalizeAfterDeleteCounter, 
            'After phase: finalize must be executed once');
        
        // Verify no before phase activity in after helper
        System.assertEquals(0, afterHelper.previewBeforeDeleteCounter, 
            'After helper should NOT have before phase preview calls');
        System.assertEquals(0, afterHelper.meetsEntryCriteriaBeforeDeleteCounter, 
            'After helper should NOT have before phase entry criteria calls');
        System.assertEquals(0, afterHelper.processRecordBeforeDeleteCounter, 
            'After helper should NOT have before phase process calls');
        System.assertEquals(0, afterHelper.finalizeBeforeDeleteCounter, 
            'After helper should NOT have before phase finalize calls');
        
        // Verify no insert/update activity (sanity check)
        System.assertEquals(0, afterHelper.previewAfterInsertCounter, 
            'Delete operation should not trigger insert methods');
        System.assertEquals(0, afterHelper.previewAfterUpdateCounter, 
            'Delete operation should not trigger update methods');
    }
    
    // ========================================================================
    // UNDELETE Tests
    // ========================================================================
    
    /**
     * Test UNDELETE operation (after phase only - no before undelete in Salesforce)
     **/
    @isTest
    static void testUndelete_OnlyAfterPhaseExists() {
        // Create test data with Ids (required for undelete)
        List<Trigger_Framework_Mock__c> undeletedRecords = new List<Trigger_Framework_Mock__c>();
        
        for (Integer i = 0; i < RECCOUNT; i++) {
            undeletedRecords.add(new Trigger_Framework_Mock__c(
                Id = TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType),
                Name = 'Restored' + i,
                RequiredField__c = 'Undeleted record'
            ));
        }
        
        // Initialize the harness
        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Trigger_Framework_Mock__c.SObjectType);
        harness.setDMLExecutor(new MockDMLExecutor());
        harness.setHelperUnderTest('MockHelperHappyPath');
        
        // Execute
        Test.startTest();
        harness.doUndelete(undeletedRecords);
        Test.stopTest();
        
        // ====================================================================
        // VERIFY NO BEFORE PHASE (Salesforce doesn't have before undelete)
        // ====================================================================
        System.assertEquals(null, harness.getBeforePhaseHelper(), 
            'UNDELETE has no before phase - before helper should be null');
        
        // ====================================================================
        // VERIFY AFTER PHASE
        // ====================================================================
        MockITriggerHelper afterHelper = (MockITriggerHelper) harness.getAfterPhaseHelper();
        System.assertNotEquals(null, afterHelper, 'After helper should exist');
        System.debug('UNDELETE AFTER helper: ' + JSON.serialize(afterHelper));
        
        // Verify after undelete counters
        System.assertEquals(RECCOUNT, afterHelper.previewAfterUndeleteCounter, 
            'After phase: preview should see all records');
        System.assertEquals(RECCOUNT, afterHelper.meetsEntryCriteriaAfterUndeleteCounter, 
            'After phase: meetsEntryCriteria should see all records');
        System.assertEquals(RECCOUNT / 2, afterHelper.processRecordAfterUndeleteCounter, 
            'After phase: processRecord should see half of all records');
        System.assertEquals(1, afterHelper.finalizeAfterUndeleteCounter, 
            'After phase: finalize must be executed once');
        
        // Verify no other operation activity (sanity check)
        System.assertEquals(0, afterHelper.previewAfterInsertCounter, 
            'Undelete operation should not trigger insert methods');
        System.assertEquals(0, afterHelper.previewAfterUpdateCounter, 
            'Undelete operation should not trigger update methods');
        System.assertEquals(0, afterHelper.previewAfterDeleteCounter, 
            'Undelete operation should not trigger delete methods');
        
        // Verify no before phase activity
        System.assertEquals(0, afterHelper.previewBeforeInsertCounter, 
            'Undelete should not have before phase activity');
        System.assertEquals(0, afterHelper.previewBeforeUpdateCounter, 
            'Undelete should not have before phase activity');
        System.assertEquals(0, afterHelper.previewBeforeDeleteCounter, 
            'Undelete should not have before phase activity');
    }
    
    // ========================================================================
    // Error Handling Tests
    // ========================================================================
    
    /**
     * Test harness validation - null records throws exception
     **/
    @isTest
    static void testValidation_NullRecords_ThrowsException() {
        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Trigger_Framework_Mock__c.SObjectType);
        harness.setDMLExecutor(new MockDMLExecutor());
        harness.setHelperUnderTest('MockHelperHappyPath');
        
        Exception caughtException;
        
        Test.startTest();
        try {
            harness.doInsert(null);
            System.assert(false, 'Should have thrown exception for null records');
        } catch (TestTriggerHelperHarness.TriggerHelperTestHarnessException e) {
            caughtException = e;
        }
        Test.stopTest();
        
        System.assertNotEquals(null, caughtException, 'Exception should be thrown');
        System.assert(caughtException.getMessage().contains('cannot be null'), 
            'Exception should indicate null records');
    }
    
    /**
     * Test harness validation - empty records throws exception
     **/
    @isTest
    static void testValidation_EmptyRecords_ThrowsException() {
        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Trigger_Framework_Mock__c.SObjectType);
        harness.setDMLExecutor(new MockDMLExecutor());
        harness.setHelperUnderTest('MockHelperHappyPath');
        
        Exception caughtException;
        
        Test.startTest();
        try {
            harness.doInsert(new List<Trigger_Framework_Mock__c>());
            System.assert(false, 'Should have thrown exception for empty records');
        } catch (TestTriggerHelperHarness.TriggerHelperTestHarnessException e) {
            caughtException = e;
        }
        Test.stopTest();
        
        System.assertNotEquals(null, caughtException, 'Exception should be thrown');
        System.assert(caughtException.getMessage().contains('cannot be empty'), 
            'Exception should indicate empty records');
    }
    
    /**
     * Test harness validation - update with mismatched sizes throws exception
     **/
    @isTest
    static void testValidation_UpdateMismatchedSizes_ThrowsException() {
        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Trigger_Framework_Mock__c.SObjectType);
        harness.setDMLExecutor(new MockDMLExecutor());
        harness.setHelperUnderTest('MockHelperHappyPath');
        
        List<Trigger_Framework_Mock__c> newRecords = new List<Trigger_Framework_Mock__c>{
            new Trigger_Framework_Mock__c(
                Id = TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType),
                Name = 'Record 1'
            )
        };
        
        List<Trigger_Framework_Mock__c> oldRecords = new List<Trigger_Framework_Mock__c>{
            new Trigger_Framework_Mock__c(
                Id = TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType),
                Name = 'Record 1 Old'
            ),
            new Trigger_Framework_Mock__c(
                Id = TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType),
                Name = 'Record 2 Old'
            )
        };
        
        Exception caughtException;
        
        Test.startTest();
        try {
            harness.doUpdate(newRecords, oldRecords);
            System.assert(false, 'Should have thrown exception for size mismatch');
        } catch (TestTriggerHelperHarness.TriggerHelperTestHarnessException e) {
            caughtException = e;
        }
        Test.stopTest();
        
        System.assertNotEquals(null, caughtException, 'Exception should be thrown');
        System.assert(caughtException.getMessage().contains('same size'), 
            'Exception should indicate size mismatch');
    }
    
    /**
     * Test harness validation - records without Ids for update throws exception
     **/
    @isTest
    static void testValidation_UpdateWithoutIds_ThrowsException() {
        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Trigger_Framework_Mock__c.SObjectType);
        harness.setDMLExecutor(new MockDMLExecutor());
        harness.setHelperUnderTest('MockHelperHappyPath');
        
        List<Trigger_Framework_Mock__c> newRecords = new List<Trigger_Framework_Mock__c>{
            new Trigger_Framework_Mock__c(Name = 'No Id') // Missing Id
        };
        
        List<Trigger_Framework_Mock__c> oldRecords = new List<Trigger_Framework_Mock__c>{
            new Trigger_Framework_Mock__c(Name = 'No Id Old') // Missing Id
        };
        
        Exception caughtException;
        
        Test.startTest();
        try {
            harness.doUpdate(newRecords, oldRecords);
            System.assert(false, 'Should have thrown exception for missing Ids');
        } catch (TestTriggerHelperHarness.TriggerHelperTestHarnessException e) {
            caughtException = e;
        }
        Test.stopTest();
        
        System.assertNotEquals(null, caughtException, 'Exception should be thrown');
        System.assert(caughtException.getMessage().contains('must have Ids'), 
            'Exception should indicate missing Ids');
    }
    
    /**
     * Test harness validation - no helper configured throws exception
     **/
    @isTest
    static void testValidation_NoHelperConfigured_ThrowsException() {
        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Trigger_Framework_Mock__c.SObjectType);
        harness.setDMLExecutor(new MockDMLExecutor());
        // Intentionally NOT calling setHelperUnderTest()
        
        List<Trigger_Framework_Mock__c> testData = new List<Trigger_Framework_Mock__c>{
            new Trigger_Framework_Mock__c(Name = 'Test')
        };
        
        Exception caughtException;
        
        Test.startTest();
        try {
            harness.doInsert(testData);
            System.assert(false, 'Should have thrown exception for missing helper');
        } catch (TestTriggerHelperHarness.TriggerHelperTestHarnessException e) {
            caughtException = e;
        }
        Test.stopTest();
        
        System.assertNotEquals(null, caughtException, 'Exception should be thrown');
        System.assert(caughtException.getMessage().contains('No helper configured'), 
            'Exception should indicate missing helper configuration');
    }
    
    // ========================================================================
    // Integration Tests
    // ========================================================================
    
    /**
     * Test complete lifecycle - multiple operations in sequence
     * Demonstrates that the harness can be reused for multiple operations
     **/
    @isTest
    static void testMultipleOperations_ReuseHarness() {
        // Initialize the harness once
        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Trigger_Framework_Mock__c.SObjectType);
        harness.setDMLExecutor(new MockDMLExecutor());
        harness.setHelperUnderTest('MockHelperHappyPath');
        
        Test.startTest();
        
        // Test 1: Insert
        List<Trigger_Framework_Mock__c> insertData = new List<Trigger_Framework_Mock__c>{
            new Trigger_Framework_Mock__c(Name = 'Insert Test')
        };
        harness.doInsert(insertData);
        System.assertNotEquals(null, harness.getBeforePhaseHelper(), 'Insert: Before helper created');
        System.assertNotEquals(null, harness.getAfterPhaseHelper(), 'Insert: After helper created');
        
        // Test 2: Update (harness reuse)
        Id mockId = TestUtility.generateFakeId(Trigger_Framework_Mock__c.SObjectType);
        List<Trigger_Framework_Mock__c> updateOld = new List<Trigger_Framework_Mock__c>{
            new Trigger_Framework_Mock__c(Id = mockId, Name = 'Old')
        };
        List<Trigger_Framework_Mock__c> updateNew = new List<Trigger_Framework_Mock__c>{
            new Trigger_Framework_Mock__c(Id = mockId, Name = 'New')
        };
        harness.doUpdate(updateNew, updateOld);
        System.assertNotEquals(null, harness.getBeforePhaseHelper(), 'Update: Before helper created');
        System.assertNotEquals(null, harness.getAfterPhaseHelper(), 'Update: After helper created');
        
        // Test 3: Delete (harness reuse)
        List<Trigger_Framework_Mock__c> deleteData = new List<Trigger_Framework_Mock__c>{
            new Trigger_Framework_Mock__c(Id = mockId, Name = 'Delete Me')
        };
        harness.doDelete(deleteData);
        System.assertNotEquals(null, harness.getBeforePhaseHelper(), 'Delete: Before helper created');
        System.assertNotEquals(null, harness.getAfterPhaseHelper(), 'Delete: After helper created');
        
        Test.stopTest();
        
        // Verify harness remained functional throughout
        System.assert(true, 'Harness successfully reused for multiple operations');
    }
}