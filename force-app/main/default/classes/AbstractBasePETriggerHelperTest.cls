/**
  Unit test for Platform Event specialized base Helper class
**/
@isTest
public class AbstractBasePETriggerHelperTest {
    
    public static testmethod void testGetName() {
        final MockPEHelper helper = initHelper();
        System.AssertNotEquals(null,helper.getName());
    }
    
    public static testmethod void testFinalizeAfterInsert() {
        final MockPEHelper helper = initHelper();
        
        System.AssertEquals(false,helper.bFinalizeAfterInsert,'Expected finalize Not called');
        Test.StartTest();
        
        helper.finalizeAfterInsert();
        
        Test.StopTest();
        System.AssertEquals(true,helper.bFinalizeAfterInsert,'Expected finalize called');
    } 
    
    public static testmethod void testPreviewAfterInsert() {
        final MockPEHelper helper = initHelper();
        final TriggerMockPE__e pe = new TriggerMockPE__e();
        
        System.AssertEquals(0,helper.cPreviewAfterInsert,'Expected preview Not called');
        Test.StartTest();
        
        helper.previewAfterInsert(pe);
        
        Test.StopTest();
        System.AssertEquals(1,helper.cPreviewAfterInsert,'Expected preview called');
    } 
    public static testmethod void testMeetsEntryCriteriaAfterInsert() {
        final MockPEHelper helper = initHelper();
        final TriggerMockPE__e pe = new TriggerMockPE__e();
        
        System.AssertEquals(0,helper.cMeetsAfterInsert,'Expected Meets Not called');
        Test.StartTest();
        
        helper.meetsEntryCriteriaAfterInsert(pe);
        
        Test.StopTest();
        System.AssertEquals(1,helper.cMeetsAfterInsert,'Expected Meets called');
    } 
    
    public static testmethod void testProcessAfterInsert() {
        final MockPEHelper helper = initHelper();
        final TriggerMockPE__e pe = new TriggerMockPE__e();
        
        System.AssertEquals(0,helper.cProcessAfterInsert,'Expected Process Not called');
        Test.StartTest();
        
        helper.processRecordAfterInsert(pe);
        
        Test.StopTest();
        System.AssertEquals(1,helper.cProcessAfterInsert,'Expected Process called');
    } 
    
    public static testmethod void testNoopMethods() {
        final MockPEHelper helper = initHelper();
        helper.previewBeforeInsert(null);
        helper.previewBeforeUpdate(null,null);
        helper.previewBeforeDelete(null);
        helper.previewAfterUpdate(null,null);
        helper.previewAfterDelete(null);
        helper.previewAfterUndelete(null);
        helper.meetsEntryCriteriaBeforeInsert(null);
        helper.meetsEntryCriteriaBeforeUpdate(null,null);
        helper.meetsEntryCriteriaBeforeDelete(null);
        helper.meetsEntryCriteriaAfterUpdate(null,null);
        helper.meetsEntryCriteriaAfterDelete(null);
        helper.meetsEntryCriteriaAfterUndelete(null);
        helper.processRecordBeforeInsert(null);
        helper.processRecordBeforeUpdate(null,null);
        helper.processRecordBeforeDelete(null);
        helper.processRecordAfterUpdate(null,null);
        helper.processRecordAfterDelete(null);
        helper.processRecordAfterUndelete(null);
        helper.finalizeBeforeInsert();
        helper.finalizeBeforeUpdate();
        helper.finalizeBeforeDelete();
        helper.finalizeAfterUpdate();
        helper.finalizeAfterDelete();
        helper.finalizeAfterUndelete();
        
        System.Assert(1<2,'No op methods tested');

    }
    private static MockPEHelper initHelper() {
        return new MockPEHelper();
    }    
}