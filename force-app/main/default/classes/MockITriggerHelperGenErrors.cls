/**
 * MockITriggerHelperGenErrors
 * test class to test the ITriggerHandler2 orchestration of non-rowlevel error handling
 * Throws exceptions in the various finalizeXXX methods that must be caught and logged.
 **/
@IsTest
public class MockITriggerHelperGenErrors extends MockITriggerHelper implements ITriggerHelper {
    
    public String getName() {
        return MockITriggerHelperGenErrors.class.getName();
    }
     /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    public override void finalizeBeforeInsert() {
       throw new IllegalArgumentException('finalizeBeforeInsert'); 
    }
   
    public override void finalizeBeforeUpdate() {
       throw new IllegalArgumentException('finalizeBeforeUpdate');         
    }
    public override void finalizeBeforeDelete() {
       throw new IllegalArgumentException('finalizeBeforeDelete');         
    }
    
    public override void finalizeAfterInsert() {
       throw new IllegalArgumentException('finalizeAfterInsert');                 
    }
    
    public override void finalizeAfterUpdate() {
       throw new IllegalArgumentException('finalizeAfterUpdate');                 
    }
    public override void finalizeAfterDelete() {
       throw new IllegalArgumentException('finalizeAfterDelete');                 
    }
    public override void finalizeAfterUndelete() {
       throw new IllegalArgumentException('finalizeAfterUndelete');                 
    }

}