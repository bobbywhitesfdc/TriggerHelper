/**
 * Mock Case implementing ITriggerHelper interface
 * It's designed to throw Exceptions for row level operations in order to test the error handling 
 * and logging of the TriggerHandler. 
 **/ 
@isTest
public class MockHelperPreviewErrors extends MockITriggerHelper implements ITriggerHelper {
    
    public override void previewBeforeInsert(final SObject record) {
        System.AssertNotEquals(null,record,'previewBeforeInsert expects a non-null input');
        previewBeforeInsertCounter++;
        if  (isOdd(previewBeforeInsertCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ previewBeforeInsertCounter);
        }
    }
    public override void previewAfterInsert(final SObject record) {
        System.AssertNotEquals(null,record,'previewAfterInsert expects a non-null input');
        previewAfterInsertCounter++;        
        if  (isOdd(previewAfterInsertCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ previewAfterInsertCounter);
        }
    }
    public override void previewBeforeUpdate(final SObject record, final SObject original) {
        System.AssertNotEquals(null,record,'previewBeforeInsert expects a non-null input');
        previewBeforeUpdateCounter++;
        if  (isOdd(previewBeforeUpdateCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ previewBeforeUpdateCounter);
        }
    }
    public override void previewAfterUpdate(final SObject record, final SObject original) {
        System.AssertNotEquals(null,record,'previewAfterInsert expects a non-null input');
        previewAfterUpdateCounter++;        
        if  (isOdd(previewAfterUpdateCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ previewAfterUpdateCounter);
        }
    }
    public override void previewBeforeDelete(final SObject record) {
        System.AssertNotEquals(null,record,'previewBeforeDelete expects a non-null input');
        previewBeforeDeleteCounter++;
        if  (isOdd(previewBeforeDeleteCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ previewBeforeDeleteCounter);
        }
    }
    public override void previewAfterDelete(final SObject record) {
        System.AssertNotEquals(null,record,'previewAfterDelete expects a non-null input');
        previewAfterDeleteCounter++;        
        if  (isOdd(previewAfterDeleteCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ previewAfterDeleteCounter);
        }
    }
    public override void previewAfterUndelete(final SObject record) {
        System.AssertNotEquals(null,record,'previewAfterUndelete expects a non-null input');
        previewAfterUndeleteCounter++;        
        if  (isOdd(previewAfterUndeleteCounter)) {
            throw new IllegalArgumentException('Mock exception for record: '+ previewAfterUndeleteCounter);
        }
    }   
}