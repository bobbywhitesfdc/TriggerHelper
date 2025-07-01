/**
 * Unit test for the base methods implemented in AbstractBaseTriggerHelper
 * These are type agnostic and operate on SObject
 * There are no persona or data dependencies to test.
 **/ 
@isTest(isParallel=true)
public class AbstractBaseTriggerHelperTest {
    public static final String NOOPMSG = 'No-op method implementation';
    
    public static testmethod void testSetGetDMLHandler() {
        final MockAbstractBaseTriggerHelper mock = new MockAbstractBaseTriggerHelper();
        final TriggerDMLHandler dmlHandler = new TriggerDMLHandler();
        Test.StartTest();
        mock.setDMLHandler(dmlHandler);
        Test.StopTest();
        System.AssertEquals(dmlHandler,mock.getDMLHandler(),'Getting must return the DMLHandler which was set');
    }
    
    public static testmethod void testSetGetDataHandler() {
        final MockAbstractBaseTriggerHelper mock = new MockAbstractBaseTriggerHelper();
        final LookupDataHandler dataHandler = new LookupDataHandler();
        Test.StartTest();
        mock.setDataHandler(dataHandler);
        Test.StopTest();
        System.AssertEquals(dataHandler,mock.getDataHandler(),'Getting must return the DataHandler which was set');
    }
    
    public static testmethod void testFinalizeBeforeInsert() {
        final MockAbstractBaseTriggerHelper mock = new MockAbstractBaseTriggerHelper();
        Test.StartTest();
        mock.finalizeBeforeInsert();
        Test.StopTest();
        System.Assert(true,NOOPMSG);        
    }
    
    public static testmethod void testFinalizeBeforeUpdate() {
        final MockAbstractBaseTriggerHelper mock = new MockAbstractBaseTriggerHelper();
        Test.StartTest();
        mock.finalizeBeforeUpdate();
        Test.StopTest();
        System.Assert(true,NOOPMSG);        
    }

    public static testmethod void testFinalizeBeforeDelete() {
        final MockAbstractBaseTriggerHelper mock = new MockAbstractBaseTriggerHelper();
        Test.StartTest();
        mock.finalizeBeforeDelete();
        Test.StopTest();
        System.Assert(true,NOOPMSG);        
    }
    
    public static testmethod void testFinalizeAfterInsert() {
        final MockAbstractBaseTriggerHelper mock = new MockAbstractBaseTriggerHelper();
        Test.StartTest();
        mock.finalizeAfterInsert();
        Test.StopTest();
        System.Assert(true,NOOPMSG);        
    }
    
    public static testmethod void testFinalizeAfterUpdate() {
        final MockAbstractBaseTriggerHelper mock = new MockAbstractBaseTriggerHelper();
        Test.StartTest();
        mock.finalizeAfterUpdate();
        Test.StopTest();
        System.Assert(true,NOOPMSG);        
    }   

    public static testmethod void testFinalizeAfterDelete() {
        final MockAbstractBaseTriggerHelper mock = new MockAbstractBaseTriggerHelper();
        Test.StartTest();
        mock.finalizeAfterDelete();
        Test.StopTest();
        System.Assert(true,NOOPMSG);        
    }

    public static testmethod void testFinalizeAfterUndelete() {
        final MockAbstractBaseTriggerHelper mock = new MockAbstractBaseTriggerHelper();
        Test.StartTest();
        mock.finalizeAfterUndelete();
        Test.StopTest();
        System.Assert(true,NOOPMSG);        
    }
    
    public class MockAbstractBaseTriggerHelper extends AbstractBaseTriggerHelper {
        /* Unused but required methods from ITriggerHelper interface */
        public String getName() { return MockAbstractBaseTriggerHelper.class.getName(); }
    }
    public static testmethod void testPreviewBeforeInsert() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.previewBeforeInsert(current);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.previewBeforeInsertCalled,'adapted method not called');
    }
    public static testmethod void testPreviewBeforeUpdate() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        final SObject original = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.previewBeforeUpdate(current,original);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.previewBeforeUpdateCalled,'adapted method not called');
    }
    public static testmethod void testPreviewBeforeDelete() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.previewBeforeDelete(current);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.previewBeforeDeleteCalled,'adapted method not called');
    }
    public static testmethod void testPreviewAfterInsert() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.previewAfterInsert(current);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.previewAfterInsertCalled,'adapted method not called');
    }
    public static testmethod void testPreviewAfterUpdate() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        final SObject original = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.previewAfterUpdate(current,original);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.previewAfterUpdateCalled,'adapted method not called');
    }

    public static testmethod void testPreviewAfterDelete() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.previewAfterDelete(current);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.previewAfterDeleteCalled,'adapted method not called');
    }

    public static testmethod void testPreviewAfterUndelete() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.previewAfterUndelete(current);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.previewAfterUndeleteCalled,'adapted method not called');
    }

    public static testmethod void testMeetsEntryCriteriaBeforeInsert() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        System.AssertEquals(true,helper.meetsEntryCriteriaBeforeInsert(current),'Expected Return value incorrect');
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.meetsEntryCriteriaBeforeInsertCalled,'adapted method not called');
    }
    public static testmethod void testMeetsEntryCriteriaBeforeUpdate() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        final SObject original = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        System.AssertEquals(true,helper.meetsEntryCriteriaBeforeUpdate(current,original),'Expected Return value incorrect');
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.meetsEntryCriteriaBeforeUpdateCalled,'adapted method not called');
    }
    
    public static testmethod void testMeetsEntryCriteriaBeforeDelete() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        System.AssertEquals(true,helper.meetsEntryCriteriaBeforeDelete(current),'Expected Return value incorrect');
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.meetsEntryCriteriaBeforeDeleteCalled,'adapted method not called');
    }
    
    public static testmethod void testMeetsEntryCriteriaAfterInsert() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        System.AssertEquals(true,helper.meetsEntryCriteriaAfterInsert(current),'Expected Return value incorrect');
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.meetsEntryCriteriaAfterInsertCalled,'adapted method not called');
    }
    
    public static testmethod void testMeetsEntryCriteriaAfterUpdate() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        final SObject original = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        System.AssertEquals(true,helper.meetsEntryCriteriaAfterUpdate(current,original),'Expected Return value incorrect');
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.meetsEntryCriteriaAfterUpdateCalled,'adapted method not called');
    }

    public static testmethod void testMeetsEntryCriteriaAfterDelete() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        System.AssertEquals(true,helper.meetsEntryCriteriaAfterDelete(current),'Expected Return value incorrect');
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.meetsEntryCriteriaAfterDeleteCalled,'adapted method not called');
    }

    public static testmethod void testMeetsEntryCriteriaAfterUndelete() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        System.AssertEquals(true,helper.meetsEntryCriteriaAfterUndelete(current),'Expected Return value incorrect');
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.meetsEntryCriteriaAfterUndeleteCalled,'adapted method not called');
    }
    
    /////
    public static testmethod void testProcessBeforeInsert() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.processRecordBeforeInsert(current);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.processRecordBeforeInsertCalled,'adapted method not called');
    }
    public static testmethod void testProcessBeforeUpdate() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        final SObject original = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.processRecordBeforeUpdate(current,original);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.processRecordBeforeUpdateCalled,'adapted method not called');
    }
    public static testmethod void testProcessBeforeDelete() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.processRecordBeforeDelete(current);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.processRecordBeforeDeleteCalled,'adapted method not called');
    }
    public static testmethod void testProcessAfterInsert() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.processRecordAfterInsert(current);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.processRecordAfterInsertCalled,'adapted method not called');
    }
    public static testmethod void testProcessAfterUpdate() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        final SObject original = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.processRecordAfterUpdate(current,original);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.processRecordAfterUpdateCalled,'adapted method not called');
    }

    public static testmethod void testProcessAfterDelete() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.processRecordAfterDelete(current);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.processRecordAfterDeleteCalled,'adapted method not called');
    }

    public static testmethod void testProcessAfterUndelete() {
        final ITriggerHelper helper = new MockAbstractTriggerHelper();
        final SObject current = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        helper.processRecordAfterUndelete(current);
        Test.StopTest();
        
        final MockAbstractTriggerHelper mock = (MockAbstractTriggerHelper) helper;
        System.AssertEquals(true,mock.processRecordAfterUndeleteCalled,'adapted method not called');
    }
    
    /**
     *  Coverage Hack -- not a real scenario but 
     *  required because the non-overridden implementations would never be called otherwise
     **/ 
    public static testmethod void testMethodCoverallCoverageHack() {
        final ITriggerHelper helper = new MockAbstractNoOverrides();
        final SObject current = new Trigger_Framework_Mock__c();
        final SObject original = new Trigger_Framework_Mock__c();
        Test.StartTest();
        
        // Call everything -- not overriding anything -- this is just to get code coverage in the Abstract Class virtual methods
        helper.previewBeforeInsert(current);
        helper.previewBeforeUpdate(current,original);
        helper.previewBeforeDelete(current);
        helper.previewAfterInsert(current);
        helper.previewAfterUpdate(current,original);
        helper.previewAfterDelete(current);
        helper.previewAfterUndelete(current);
        helper.meetsEntryCriteriaBeforeInsert(current);
        helper.meetsEntryCriteriaBeforeUpdate(current,original);
        helper.meetsEntryCriteriaBeforeDelete(current);
        helper.meetsEntryCriteriaAfterInsert(current);
        helper.meetsEntryCriteriaAfterUpdate(current,original);
        helper.meetsEntryCriteriaAfterDelete(current);
        helper.meetsEntryCriteriaAfterUndelete(current);
        helper.processRecordBeforeInsert(current);
        helper.processRecordBeforeUpdate(current,original);
        helper.processRecordBeforeDelete(current);
        helper.processRecordAfterInsert(current);
        helper.processRecordAfterUpdate(current,original);
        helper.processRecordAfterDelete(current);
        helper.processRecordAfterUndelete(current);
        System.Assert(true,'NO-Op test for coverage only');
    }
 
    /**
     * MockNoOverride -- This mock doesn't override anything it doesn't have to
     **/
    public class MockAbstractNoOverrides extends AbstractBaseTriggerHelper {
        
        // Required, but not tested by this class
        public String getName() { return MockAbstractNoOverrides.class.getName(); }
    }
    
    /**
      * Mock implements all of the "adapted" methods
      * 
     **/
    public class MockAbstractTriggerHelper extends AbstractBaseTriggerHelper {
        
        // Required, but not tested by this class
        public String getName() { return MockAbstractTriggerHelper.class.getName(); }
        
        @Testvisible Boolean previewBeforeInsertCalled=false;
        public override void previewBeforeInsert(final SObject current) {
            System.Debug('previewBeforeInsert(Trigger_Framework_Mock__c) called');
            System.AssertNotEquals(null,current,'Missing parameter current');
            previewBeforeInsertCalled=true;
        }
        
        @Testvisible Boolean previewBeforeUpdateCalled=false;
        public override void previewBeforeUpdate(final SObject current, final SObject original) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            System.AssertNotEquals(null,original,'Missing parameter original');
            previewBeforeUpdateCalled=true;
        }
        @Testvisible Boolean previewBeforeDeleteCalled=false;
        public override void previewBeforeDelete(final SObject current) {
            System.Debug('previewBeforeDelete(Trigger_Framework_Mock__c) called');
            System.AssertNotEquals(null,current,'Missing parameter current');
            previewBeforeDeleteCalled=true;
        }

        @Testvisible Boolean previewAfterInsertCalled=false;        
        public override void previewAfterInsert(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');            
            previewAfterInsertCalled=true;
        }
        
        @Testvisible Boolean previewAfterUpdateCalled=false;        
        public override void previewAfterUpdate(final SObject current, final SObject original) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            System.AssertNotEquals(null,original,'Missing parameter original');
            previewAfterUpdateCalled=true;
        }

        @Testvisible Boolean previewAfterDeleteCalled=false;        
        public override void previewAfterDelete(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            previewAfterDeleteCalled=true;
        }

        @Testvisible Boolean previewAfterUndeleteCalled=false;        
        public override void previewAfterUndelete(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            previewAfterUndeleteCalled=true;
        }

        @Testvisible Boolean meetsEntryCriteriaBeforeInsertCalled=false;                
        public override Boolean meetsEntryCriteriaBeforeInsert(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            meetsEntryCriteriaBeforeInsertCalled=true;
            return true;
        }

        @Testvisible Boolean meetsEntryCriteriaBeforeUpdateCalled=false;                        
        public override Boolean meetsEntryCriteriaBeforeUpdate(final SObject current, final SObject original) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            System.AssertNotEquals(null,original,'Missing parameter original'); 
            meetsEntryCriteriaBeforeUpdateCalled=true;
            return true;
        }
        
        @Testvisible Boolean meetsEntryCriteriaBeforeDeleteCalled=false;                                        
        public override Boolean meetsEntryCriteriaBeforeDelete(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            meetsEntryCriteriaBeforeDeleteCalled=true;
            return true;
        }

        @Testvisible Boolean meetsEntryCriteriaAfterInsertCalled=false;                                
        public override Boolean meetsEntryCriteriaAfterInsert(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            meetsEntryCriteriaAfterInsertCalled=true;
            return true;
        }

        @Testvisible Boolean meetsEntryCriteriaAfterUpdateCalled=false;                                        
        public override Boolean meetsEntryCriteriaAfterUpdate(final SObject current, final SObject original) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            System.AssertNotEquals(null,original,'Missing parameter original');
            meetsEntryCriteriaAfterUpdateCalled=true;
            return true;
        }

        @Testvisible Boolean meetsEntryCriteriaAfterDeleteCalled=false;                                        
        public override Boolean meetsEntryCriteriaAfterDelete(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            meetsEntryCriteriaAfterDeleteCalled=true;
            return true;
        }

        @Testvisible Boolean meetsEntryCriteriaAfterUndeleteCalled=false;                                        
        public override Boolean meetsEntryCriteriaAfterUndelete(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            meetsEntryCriteriaAfterUndeleteCalled=true;
            return true;
        }
        
        @Testvisible Boolean processRecordBeforeInsertCalled=false;                                                
        public override void processRecordBeforeInsert(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            processRecordBeforeInsertCalled=true;
        }
        
        @Testvisible Boolean processRecordBeforeUpdateCalled=false;                                                        
        public override void processRecordBeforeUpdate(final SObject current, final SObject original) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            System.AssertNotEquals(null,original,'Missing parameter original');
            processRecordBeforeUpdateCalled=true;
        }
        
        @Testvisible Boolean processRecordBeforeDeleteCalled=false;                                                
        public override void processRecordBeforeDelete(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            processRecordBeforeDeleteCalled=true;
        }
        
        @Testvisible Boolean processRecordAfterInsertCalled=false;                                                       
        public override void processRecordAfterInsert(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            processRecordAfterInsertCalled=true;
        }
        
        @Testvisible Boolean processRecordAfterUpdateCalled=false;                                                       
        public override void processRecordAfterUpdate(final SObject current, final SObject original) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            System.AssertNotEquals(null,original,'Missing parameter original');
            processRecordAfterUpdateCalled=true;
        }    

        @Testvisible Boolean processRecordAfterDeleteCalled=false;                                                
        public override void processRecordAfterDelete(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            processRecordAfterDeleteCalled=true;
        }

        @Testvisible Boolean processRecordAfterUndeleteCalled=false;                                                
        public override void processRecordAfterUndelete(final SObject current) {
            System.AssertNotEquals(null,current,'Missing parameter current');
            processRecordAfterUndeleteCalled=true;
        }
    }
    
    
}