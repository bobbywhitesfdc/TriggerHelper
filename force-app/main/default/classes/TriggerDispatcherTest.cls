/**
 * Unit Test for TriggerDispatcher - mocks all of the Trigger phases
 **/ 
@Istest(isParallel=true)
public class TriggerDispatcherTest {
    public static testmethod void testExceptionHandling() {
        TriggerDispatcher.enableTOMocking=true;
        TriggerDispatcher.unitTestOperationType=System.TriggerOperation.BEFORE_INSERT;
        
        MockTriggerHandler mockHandler = new MockTriggerHandler();
        mockHandler.throwMockException=true;
        try {
            Test.StartTest();           
            TriggerDispatcher.run(mockHandler);
            Test.StopTest();
            
            System.Assert(false,'Must not reach this line');
        } catch(IllegalArgumentException iex) {
            System.AssertEquals(mockHandler.MSG,iex.getMessage(),'Message did not match');
        }
        
    }

    // Test the orchestration for each phase
    public static testmethod void testBeforeInsert() {
        TriggerDispatcher.enableTOMocking=true;
        TriggerDispatcher.unitTestOperationType=System.TriggerOperation.BEFORE_INSERT;
        
        Test.StartTest();
        MockTriggerHandler mockHandler = new MockTriggerHandler();
        TriggerDispatcher.run(mockHandler);
        Test.StopTest();
        
        System.Assert(mockHandler.beforeInsertWasCalled,'Expected Before Insert to be called');
    }
    public static testmethod void testBeforeUpdate() { 
        TriggerDispatcher.enableTOMocking=true;
        TriggerDispatcher.unitTestOperationType=System.TriggerOperation.BEFORE_UPDATE;
        
        Test.StartTest();
        MockTriggerHandler mockHandler = new MockTriggerHandler();
        TriggerDispatcher.run(mockHandler);
        Test.StopTest();
        
        System.Assert(mockHandler.beforeUpdateWasCalled,'Expected Before Update to be called');
    }
    public static testmethod void testBeforeDelete() { 
        TriggerDispatcher.enableTOMocking=true;
        TriggerDispatcher.unitTestOperationType=System.TriggerOperation.BEFORE_DELETE;
        
        Test.StartTest();
        MockTriggerHandler mockHandler = new MockTriggerHandler();
        TriggerDispatcher.run(mockHandler);
        Test.StopTest();
        
        System.Assert(mockHandler.beforeDeleteWasCalled,'Expected Before Delete to be called');
    }
    public static testmethod void testAfterInsert() { 
        TriggerDispatcher.enableTOMocking=true;
        TriggerDispatcher.unitTestOperationType=System.TriggerOperation.AFTER_INSERT;
        
        Test.StartTest();
        MockTriggerHandler mockHandler = new MockTriggerHandler();
        TriggerDispatcher.run(mockHandler);
        Test.StopTest();
        
        System.Assert(mockHandler.afterInsertWasCalled,'Expected After Insert to be called:' + TriggerDispatcher.unitTestOperationType );
    }
    public static testmethod void testAfterUpdate() { 
        TriggerDispatcher.enableTOMocking=true;
        TriggerDispatcher.unitTestOperationType=System.TriggerOperation.AFTER_UPDATE;
        
        Test.StartTest();
        MockTriggerHandler mockHandler = new MockTriggerHandler();
        TriggerDispatcher.run(mockHandler);
        Test.StopTest();
        
        System.Assert(mockHandler.afterUpdateWasCalled,'Expected After Update to be called:' + TriggerDispatcher.unitTestOperationType );
    }
    public static testmethod void testAfterDelete() { 
        TriggerDispatcher.enableTOMocking=true;
        TriggerDispatcher.unitTestOperationType=System.TriggerOperation.AFTER_DELETE;
        
        Test.StartTest();
        MockTriggerHandler mockHandler = new MockTriggerHandler();
        TriggerDispatcher.run(mockHandler);
        Test.StopTest();
        
        System.Assert(mockHandler.afterDeleteWasCalled,'Expected After Delete to be called:' + TriggerDispatcher.unitTestOperationType );
    }
    public static testmethod void testAfterUnDelete() {
        TriggerDispatcher.enableTOMocking=true;
        TriggerDispatcher.unitTestOperationType=System.TriggerOperation.AFTER_UNDELETE;
        
        Test.StartTest();
        MockTriggerHandler mockHandler = new MockTriggerHandler();
        TriggerDispatcher.run(mockHandler);
        Test.StopTest();
        
        System.Assert(mockHandler.afterUnDeleteWasCalled,'Expected After UnDelete to be called:' + TriggerDispatcher.unitTestOperationType );
    }
    
    
    public class MockTriggerHandler implements ITriggerHandler {
        public final string MSG='MockException message';
        public Boolean throwMockException=false;
        
        public Boolean beforeInsertWasCalled=false;
        public Boolean beforeUpdateWasCalled=false;
        public Boolean beforeDeleteWasCalled=false;
        public Boolean afterInsertWasCalled=false;
        public Boolean afterUpdateWasCalled=false;
        public Boolean afterDeleteWasCalled=false;
        public Boolean afterUnDeleteWasCalled=false;
        
        
        public void beforeInsert(List<sObject> newItems) {
            beforeInsertWasCalled=true;
            if (throwMockException) { throw new IllegalargumentException(MSG);}
        }
        public void beforeUpdate(Map<id,sObject> newItems,Map<id,sObject> oldItems) {
           beforeUpdateWasCalled=true; 
        }
        public void beforeDelete(Map<id,sObject> oldItems) {
           beforeDeleteWasCalled=true; 
        }
        public void afterInsert(Map<id,sObject> newItems) {
           afterInsertWasCalled=true; 
        }
        public void afterUpdate(Map<id,sObject> newItems,Map<id,sObject> oldItems) {
           afterUpdateWasCalled=true; 
        }
        public void afterDelete(Map<id,sObject> oldItems) {
           afterDeleteWasCalled=true; 
        }
        public void afterUndelete(Map<id,sObject> oldItems) {
           afterUnDeleteWasCalled=true; 
        }

        public Boolean isDisabled() { return false; }
    }
    
    public static testmethod void testRunSObjectTypeGood() {
        List<Trigger_Framework_Mock__c> testData = new List<Trigger_Framework_Mock__c>();
        testData.add(new Trigger_Framework_Mock__c(name='test'));
        Test.StartTest();
        TriggerDispatcher.validateSObjectTypeMatch(testData, Trigger_Framework_Mock__c.SObjectType);
        Test.StopTest();
        System.Assert(true,'Expected to reach this line');
    }
    public static testmethod void testRunSObjectTypeMismatch() {
        List<Trigger_Framework_Mock__c> testData = new List<Trigger_Framework_Mock__c>();
        testData.add(new Trigger_Framework_Mock__c(name='test'));
        Test.StartTest();
        try {
            TriggerDispatcher.validateSObjectTypeMatch(testData, Account.SObjectType); 
            System.Assert(false,'Must not reach this line');
        } catch (DesignByContractUtil.DBCAssertionException dbcex) {
            System.Assert(true,'Expected to reach this line');    
        }
        Test.StopTest();
    }
    
    public static testmethod void testRunMocked() {
        List<Trigger_Framework_Mock__c> testData = new List<Trigger_Framework_Mock__c>();
        testData.add(new Trigger_Framework_Mock__c(name='test'));
        
        TriggerDispatcher.enableRunMocking=true;
        TriggerDispatcher.mockNew = testData;
        
        Test.StartTest();
        TriggerDispatcher.run();
        
        Test.StopTest();
        System.Assert(true,'Expected to reach this line');
    }
    
    public static testmethod void testRunUnmocked() {
        List<Trigger_Framework_Mock__c> testData = new List<Trigger_Framework_Mock__c>();
        testData.add(new Trigger_Framework_Mock__c(name='test'));
        
        TriggerDispatcher.enableRunMocking=false;
        TriggerDispatcher.mockNew=testData;
        
        Test.StartTest();

        try {
            TriggerDispatcher.run(); 
            System.Assert(false,'Must not reach this line');
        } catch (DesignByContractUtil.DBCAssertionException dbcex) {
            System.Debug(dbcex.getMessage());
            System.Assert(true,'Expected to reach this line');    
        }
        
        Test.StopTest();
    }
    public static testmethod void testRunNonTriggerContextUnmocked() {
        List<Trigger_Framework_Mock__c> testData = new List<Trigger_Framework_Mock__c>();
        testData.add(new Trigger_Framework_Mock__c(name='test'));
        
        System.Assert(!Trigger.isExecuting,'Test is invalid if executing in a Trigger context');
        
        TriggerDispatcher.enableRunMocking=false;
        TriggerDispatcher.mockNew=testData;
        
        Test.StartTest();

        try {
            TriggerDispatcher.run(); 
            System.Assert(false,'Must not reach this line');
        } catch (DesignByContractUtil.DBCAssertionException dbcex) {
            System.Debug(dbcex.getMessage());
            System.Assert(true,'Expected to reach this line');    
        }
        
        Test.StopTest();
    }

}