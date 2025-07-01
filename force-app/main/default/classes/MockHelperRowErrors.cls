/**
 * Mock Trigger_Framework_Mock__c implementing ITriggerHelper interface
 * It's designed to throw Exceptions for row level operations in order to test the error handling 
 * and logging of the TriggerHandler. 
 **/
@isTest
public class MockHelperRowErrors extends MockITriggerHelper implements ITriggerHelper {
    public String getName() {
        return MockHelperRowErrors.class.getName();
    }
    
    public override void processRecordBeforeInsert(final SObject record) {
        System.AssertNotEquals(null,record,'processRecordBeforeInsert expects a non-null input');
        processRecordBeforeInsertCounter++;
        if  (isOdd(processRecordBeforeInsertCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ processRecordBeforeInsertCounter);
        }
    }
    public override void processRecordAfterInsert(final SObject record) {
        System.AssertNotEquals(null,record,'processRecordAfterInsert expects a non-null input');
        processRecordAfterInsertCounter++;        
        if  (isOdd(processRecordAfterInsertCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ processRecordAfterInsertCounter);
        }
    }
    public override void processRecordBeforeUpdate(final SObject record, final SObject original) {
        System.AssertNotEquals(null,record,'processRecordBeforeInsert expects a non-null input');
        processRecordBeforeUpdateCounter++;
        if  (isOdd(processRecordBeforeUpdateCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ processRecordBeforeUpdateCounter);
        }
    }
    public override void processRecordAfterUpdate(final SObject record, final SObject original) {
        System.AssertNotEquals(null,record,'processRecordAfterInsert expects a non-null input');
        processRecordAfterUpdateCounter++;        
        if  (isOdd(processRecordAfterUpdateCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ processRecordAfterUpdateCounter);
        }
    }
    public override void processRecordBeforeDelete(final SObject record) {
        System.AssertNotEquals(null,record,'processRecordBeforeDelete expects a non-null input');
        processRecordBeforeDeleteCounter++;
        if  (isOdd(processRecordBeforeDeleteCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ processRecordBeforeDeleteCounter);
        }
    }
    public override void processRecordAfterDelete(final SObject record) {
        System.AssertNotEquals(null,record,'processRecordAfterDelete expects a non-null input');
        processRecordAfterDeleteCounter++;        
        if  (isOdd(processRecordAfterDeleteCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ processRecordAfterDeleteCounter);
        }
    }
    public override void processRecordAfterUndelete(final SObject record) {
        System.AssertNotEquals(null,record,'processRecordAfterUndelete expects a non-null input');
        processRecordAfterUndeleteCounter++;        
        if  (isOdd(processRecordAfterUndeleteCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ processRecordAfterUndeleteCounter);
        }
    }    
}