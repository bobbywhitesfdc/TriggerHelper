/**
 * Mock Helper class for testing the HappyPath for DML of the MockTriggerHandler
 **/ 
@isTest
public class MockHelperHappyDML extends MockITriggerHelper implements ITriggerHelper {
    
    /**
     * Insert a task for each Trigger_Framework_Mock__c to test the INSERT DML function.
     **/ 
    public override void processRecordBeforeInsert(final SObject record) {
        final Task testTask=new Task(Subject='HappyDML:'+record.Id);
        getDMLHandler().addForInsert(testTask);
    }

    /**
     * Insert a task for each Trigger_Framework_Mock__c to test the INSERT DML function.
     **/ 
    public override void processRecordAfterInsert(final SObject record) {
        final Task testTask=new Task(Subject='HappyDML:'+record.Id);
        getDMLHandler().addForInsert(testTask);
    }

     /**
     * Insert a task for each Trigger_Framework_Mock__c to test the INSERT DML function.
     **/ 
    public override void processRecordBeforeUpdate(final SObject record, final SObject original) {
        final Task testTask=new Task(Subject='HappyDML:'+record.Id);
        getDMLHandler().addForInsert(testTask);
    }
    
     /**
     * Insert a task for each case to test the INSERT DML function.
     **/ 
    public override void processRecordAfterUpdate(final SObject record, final SObject original) {
        final Task testTask=new Task(Subject='HappyDML:'+record.Id);
        getDMLHandler().addForInsert(testTask);
    }
    /**
     * Update a harmless field on some object to test UPDATE DML function
     **/ 
    public override void finalizeBeforeInsert() {
        doUpdateDML();
    }
    
    /**
     * Update a harmless field on some object to test UPDATE DML function
     **/ 
    public override void finalizeBeforeUpdate() {
        doUpdateDML();
    }
    
    /**
     * Update a harmless field on some object to test UPDATE DML function
     **/ 
    public override void finalizeAfterInsert() {
        doUpdateDML();
    }
    
    /**
     * Update a harmless field on some object to test UPDATE DML function
     **/ 
    public override void finalizeAfterUpdate() {
        doUpdateDML();
    }
    
    private void doUpdateDML() {
        final Integer BATCHSIZE=10;
        List<Trigger_Framework_Mock__c> dummyTriggerFrameworkMocks = new List<Trigger_Framework_Mock__c>();
        for(Integer i=0; i < BATCHSIZE; i++) {
            dummyTriggerFrameworkMocks.add(new Trigger_Framework_Mock__c(Name='Test',RequiredField__c='Populated'));
        }
        insert dummyTriggerFrameworkMocks;
        
        Integer n=0;
        for (Trigger_Framework_Mock__c current : [Select id, Name, RequiredField__c From Trigger_Framework_Mock__c LIMIT :BATCHSIZE]) {
            Trigger_Framework_Mock__c toUpdateRecord = (Trigger_Framework_Mock__c) getDMLHandler().getForUpdate(current);
            // Make some benign changes
            toUpdateRecord.Name='Happy'+ (n++);
            getDMLHandler().putForUpdate(toUpdateRecord);
        }
    }
        
}