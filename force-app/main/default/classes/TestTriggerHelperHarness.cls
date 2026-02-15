/**
 * Test Harness for unit testing individual ITriggerHelper implementations
 * 
 * This harness extends StandardSObjectTriggerHandler to provide an isolated testing
 * environment for helper developers. It allows:
 * 
 * 1. Testing a single helper in isolation (bypassing TriggerHelperFactory)
 * 2. Mocking the DML executor to verify DML operations without database commits
 * 3. End-to-end execution of both before/after phases for each operation type

 * @author Bobby White
 * @date 2026-02-15
 **/
@isTest
public class TestTriggerHelperHarness extends StandardSObjectTriggerHandler {
    
    // Configuration properties
    private String helperClassName;
    private DMLExecutor customDmlExecutor;
    private LookupDataHandler customLookupDataHandler;
    
    // Tracking for test verification
    @TestVisible
    private ITriggerHelper helperInstance;

    public TestTriggerHelperHarness(final Schema.SObjectType soType) {
        super(soType);
    }    

    /**
     * Set the helper class to test
     * 
     * @param helperType The Type of the helper class implementing ITriggerHelper
     * @throws TriggerHelperTestHarnessException if helperType is null
     **/
    public void setHelperUnderTest(final String helperClassName) {
        if (helperClassName == null) {
            throw new TriggerHelperTestHarnessException('Helper type cannot be null');
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
     **/
    public override List<ITriggerHelper> instantiateHelpers() {
        if (this.helperClassName == null) {
            throw new TriggerHelperTestHarnessException(
                'No helper configured. Call setHelperUnderTest() before executing operations.'
            );
        }
        
        if (this.helperInstance==null) {        
        	this.helperInstance = (ITriggerHelper) TriggerHelperFactory.createHelperInstance(this.helperClassName);
    	}
        
        // Store reference for test verification
        activeHelpers = new List<ITriggerHelper>{ this.helperInstance };
        
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
        
        // Assign Ids to simulate after insert context
        Map<Id, SObject> newRecordsWithIds = assignMockIds(newRecords);
        
        // Execute before insert
        beforeInsert(newRecords);
        
        // Execute after insert
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
        
        // Execute before update
        beforeUpdate(newRecordsMap, oldRecordsMap);
        
        // Execute after update
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
        
        // Execute before delete
        beforeDelete(deletedRecordsMap);
        
        // Execute after delete
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
        
        // Execute after undelete (there is no before undelete)
        afterUndelete(undeletedRecordsMap);
    }
    
    // ========================================================================
    // Accessor Methods for Test Verification
    // ========================================================================
    
    /**
     * Get the helper instance being tested
     * Useful for verifying internal state after execution
     * 
     * @return The ITriggerHelper instance under test
     **/
    public ITriggerHelper getHelperInstance() {
        return this.helperInstance;
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
        Integer counter = 1;
        
        for (SObject record : records) {
            
            // Generate mock Id if not present (e.g DML is Mocked)
            if (record.Id == null) {
                record.Id=TestUtility.generateFakeId(getSObjectType());
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
    
    /**
     * Generate a mock Salesforce Id
     * 
     * @param keyPrefix The 3-character key prefix for the SObjectType
     * @param counter Unique counter value
     * @return A valid-format Salesforce Id
     **/
    private Id generateMockId(String keyPrefix, Integer counter) {
        // Salesforce Ids are 15 or 18 characters
        // Format: [3-char prefix][12-char unique identifier]
        String uniquePart = String.valueOf(counter).leftPad(12, '0');
        return Id.valueOf(keyPrefix + uniquePart);
    }
    
    // ========================================================================
    // Custom Exception
    // ========================================================================
    
    /**
     * Custom exception for test harness errors
     **/
    public class TriggerHelperTestHarnessException extends Exception {}
}