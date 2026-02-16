/**
 * Test Harness for unit testing individual ITriggerHelper implementations
 * 
 * This harness extends StandardSObjectTriggerHandler to provide an isolated testing
 * environment for helper developers. It allows:
 * 
 * 1. Testing a single helper in isolation (bypassing TriggerHelperFactory)
 * 2. Mocking the DML executor to verify DML operations without database commits
 * 3. End-to-end execution of both before/after phases for each operation type
 * 4. Proper lifecycle management - helpers are instantiated fresh for each phase
 * 
 * IMPORTANT: This harness follows the same lifecycle as real triggers:
 * - Helper is instantiated fresh in the BEFORE phase
 * - Helper is instantiated fresh again in the AFTER phase
 * - No state is shared between phases (matching production behavior)
 *
 * @author Bobby White
 * @date 2026-02-15
 **/
@isTest
public class TestTriggerHelperHarness extends StandardSObjectTriggerHandler {
    
    // Configuration properties
    private String helperClassName;
    private DMLExecutor customDmlExecutor;
    private LookupDataHandler customLookupDataHandler;
    
    // Tracking for test verification - separate instances for before/after phases
    @TestVisible
    private ITriggerHelper beforePhaseHelper;
    
    @TestVisible
    private ITriggerHelper afterPhaseHelper;
    
    // Track which phase we're currently in
    private enum Phase { BEFORE, AFTER }
    private Phase currentPhase;

    public TestTriggerHelperHarness(final Schema.SObjectType soType) {
        super(soType);
    }    

    /**
     * Set the helper class to test
     * 
     * @param helperClassName The fully qualified name of the helper class implementing ITriggerHelper
     * @throws TriggerHelperTestHarnessException if helperClassName is null
     **/
    public void setHelperUnderTest(final String helperClassName) {
        if (helperClassName == null) {
            throw new TriggerHelperTestHarnessException('Helper class name cannot be null');
        }
        this.helperClassName = helperClassName;
    }
    
    /**
     * Set a custom DML executor for mocking DML operations
     * 
     * @param executor Custom DMLExecutor instance (typically a mock)
     * @throws TriggerHelperTestHarnessException if executor is null
     **/
    public void setDMLExecutor(DMLExecutor executor) {
        if (executor == null) {
            throw new TriggerHelperTestHarnessException('DML Executor cannot be null');
        }
        this.customDmlExecutor = executor;
        // Update the static field on AbstractBaseTriggerHandler
        AbstractBaseTriggerHandler.dmlExecutor = executor;
    }
    
    /**
     * Set a custom LookupDataHandler for mocking query results
     * 
     * @param dataHandler Custom LookupDataHandler instance (typically a mock)
     * @throws TriggerHelperTestHarnessException if dataHandler is null
     * 
     * Note: Full implementation of LookupDataHandler mocking is reserved for future enhancement.
     * This method is provided as a placeholder to support that future work.
     **/
    public void setLookupDataHandler(LookupDataHandler dataHandler) {
        if (dataHandler == null) {
            throw new TriggerHelperTestHarnessException('LookupDataHandler cannot be null');
        }
        this.customLookupDataHandler = dataHandler;
    }
    
    /**
     * Override to instantiate only the helper under test
     * This bypasses the TriggerHelperFactory and allows isolated testing
     * 
     * CRITICAL: This method creates a NEW instance each time it's called,
     * matching the real trigger behavior where helpers are instantiated 
     * separately for before and after phases.
     **/
    public override List<ITriggerHelper> instantiateHelpers() {
        if (this.helperClassName == null) {
            throw new TriggerHelperTestHarnessException(
                'No helper configured. Call setHelperUnderTest() before executing operations.'
            );
        }
        
        // ALWAYS create a fresh instance - never reuse
        ITriggerHelper newHelperInstance = (ITriggerHelper) TriggerHelperFactory.createHelperInstance(this.helperClassName);
        
        // Store in the appropriate tracking variable based on phase
        if (currentPhase == Phase.BEFORE) {
            beforePhaseHelper = newHelperInstance;
        } else if (currentPhase == Phase.AFTER) {
            afterPhaseHelper = newHelperInstance;
        }
        
        // Store reference for framework use
        activeHelpers = new List<ITriggerHelper>{ newHelperInstance };
        
        return activeHelpers;
    }
        
    // ========================================================================
    // Simplified Test Entry Points
    // ========================================================================
    
    /**
     * Execute INSERT operation (both before and after phases)
     * 
     * @param newRecords List of SObjects to insert (simulates Trigger.new)
     * @throws TriggerHelperTestHarnessException if newRecords is null or empty
     **/
    public void doInsert(List<SObject> newRecords) {
        validateRecordList(newRecords, 'doInsert');
        
        // Execute before insert (set phase first)
        currentPhase = Phase.BEFORE;
        beforeInsert(newRecords);
        
        // Assign Ids to simulate after insert context
        Map<Id, SObject> newRecordsWithIds = assignMockIds(newRecords);
        
        // Execute after insert (set phase first)
        currentPhase = Phase.AFTER;
        afterInsert(newRecordsWithIds);
    }
    
    /**
     * Execute UPDATE operation (both before and after phases)
     * 
     * @param newRecords List of updated SObjects (simulates Trigger.new)
     * @param oldRecords List of original SObjects (simulates Trigger.old)
     * @throws TriggerHelperTestHarnessException if records are null, empty, or size mismatch
     **/
    public void doUpdate(List<SObject> newRecords, List<SObject> oldRecords) {
        validateRecordList(newRecords, 'doUpdate - newRecords');
        validateRecordList(oldRecords, 'doUpdate - oldRecords');
        
        if (newRecords.size() != oldRecords.size()) {
            throw new TriggerHelperTestHarnessException(
                'newRecords and oldRecords must have the same size'
            );
        }
        
        // Ensure records have Ids
        Map<Id, SObject> newRecordsMap = ensureRecordsHaveIds(newRecords);
        Map<Id, SObject> oldRecordsMap = ensureRecordsHaveIds(oldRecords);
        
        // Verify Id alignment
        if (!newRecordsMap.keySet().equals(oldRecordsMap.keySet())) {
            throw new TriggerHelperTestHarnessException(
                'newRecords and oldRecords must have matching Ids'
            );
        }
        
        // Execute before update (set phase first)
        currentPhase = Phase.BEFORE;
        beforeUpdate(newRecordsMap, oldRecordsMap);
        
        // Execute after update (set phase first)
        currentPhase = Phase.AFTER;
        afterUpdate(newRecordsMap, oldRecordsMap);
    }
    
    /**
     * Execute DELETE operation (both before and after phases)
     * 
     * @param deletedRecords List of SObjects to delete (simulates Trigger.old)
     * @throws TriggerHelperTestHarnessException if deletedRecords is null or empty
     **/
    public void doDelete(List<SObject> deletedRecords) {
        validateRecordList(deletedRecords, 'doDelete');
        
        // Ensure records have Ids
        Map<Id, SObject> deletedRecordsMap = ensureRecordsHaveIds(deletedRecords);
        
        // Execute before delete (set phase first)
        currentPhase = Phase.BEFORE;
        beforeDelete(deletedRecordsMap);
        
        // Execute after delete (set phase first)
        currentPhase = Phase.AFTER;
        afterDelete(deletedRecordsMap);
    }
    
    /**
     * Execute UNDELETE operation (after phase only)
     * 
     * @param undeletedRecords List of SObjects to undelete (simulates Trigger.new)
     * @throws TriggerHelperTestHarnessException if undeletedRecords is null or empty
     **/
    public void doUndelete(List<SObject> undeletedRecords) {
        validateRecordList(undeletedRecords, 'doUndelete');
        
        // Ensure records have Ids
        Map<Id, SObject> undeletedRecordsMap = ensureRecordsHaveIds(undeletedRecords);
        
        // Execute after undelete (set phase first)
        // Note: There is no before undelete phase
        currentPhase = Phase.AFTER;
        afterUndelete(undeletedRecordsMap);
    }
    
    // ========================================================================
    // Accessor Methods for Test Verification
    // ========================================================================
    
    /**
     * Get the helper instance from the BEFORE phase
     * Useful for verifying internal state after before phase execution
     * 
     * @return The ITriggerHelper instance used in the before phase
     **/
    public ITriggerHelper getBeforePhaseHelper() {
        return this.beforePhaseHelper;
    }
    
    /**
     * Get the helper instance from the AFTER phase
     * Useful for verifying internal state after after phase execution
     * 
     * @return The ITriggerHelper instance used in the after phase
     **/
    public ITriggerHelper getAfterPhaseHelper() {
        return this.afterPhaseHelper;
    }
    
    /**
     * Get the DML handler used by the helper
     * Useful for verifying deferred DML operations
     * 
     * @return The TriggerDMLHandler instance
     **/
    public TriggerDMLHandler getDMLHandler() {
        return this.dmlHandler;
    }
    
    // ========================================================================
    // Private Helper Methods
    // ========================================================================
    
    /**
     * Validate that a record list is not null or empty
     **/
    private void validateRecordList(List<SObject> records, String context) {
        if (records == null) {
            throw new TriggerHelperTestHarnessException(
                context + ': records cannot be null'
            );
        }
        if (records.isEmpty()) {
            throw new TriggerHelperTestHarnessException(
                context + ': records cannot be empty'
            );
        }
    }
    
    /**
     * Assign mock Ids to records that don't have them
     * Used for simulating after insert context
     * 
     * @param records List of SObjects
     * @return Map of Id to SObject with assigned Ids
     **/
    private Map<Id, SObject> assignMockIds(List<SObject> records) {
        Map<Id, SObject> recordMap = new Map<Id, SObject>();
        
        for (SObject record : records) {
            // Generate mock Id if not present (e.g DML is Mocked)
            if (record.Id == null) {
                record.Id = TestUtility.generateFakeId(getSObjectType());
            }
            
            recordMap.put(record.Id, record);
        }
        
        return recordMap;
    }
    
    /**
     * Ensure all records have Ids, throw exception if any are missing
     * 
     * @param records List of SObjects
     * @return Map of Id to SObject
     **/
    private Map<Id, SObject> ensureRecordsHaveIds(List<SObject> records) {
        Map<Id, SObject> recordMap = new Map<Id, SObject>();
        
        for (SObject record : records) {
            if (record.Id == null) {
                throw new TriggerHelperTestHarnessException(
                    'All records must have Ids for update/delete/undelete operations. ' +
                    'Ensure test data includes Id field or use Database.insert in test setup.'
                );
            }
            recordMap.put(record.Id, record);
        }
        
        return recordMap;
    }
    
    // ========================================================================
    // Custom Exception
    // ========================================================================
    
    /**
     * Custom exception for test harness errors
     **/
    public class TriggerHelperTestHarnessException extends Exception {}
}