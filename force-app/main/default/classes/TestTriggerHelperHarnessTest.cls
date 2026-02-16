/**
 * Illustrates the usage of TestTriggerHelperHarness
**/
@IsTest
public class TestTriggerHelperHarnessTest {
    public static Integer RECCOUNT=20;
    public static testmethod void testInsert() {
        // Create Test data
        List<Trigger_Framework_Mock__c> testData = new List<Trigger_Framework_Mock__c>();
        for (integer i=0; i < RECCOUNT; i++) {
            testData.add(new Trigger_Framework_Mock__c(name='Test'+i));
        }
        
        // Initialize the harness
        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Trigger_Framework_Mock__c.SObjectType);
		harness.setDMLExecutor(new MockDMLExecutor());
		harness.setHelperUnderTest('MockHelperHappyPath');
        
        Test.StartTest();
 		harness.doInsert(testData);        
        Test.StopTest();
        
        MockITriggerHelper beforeHelper = (MockITriggerHelper) harness.getBeforePhaseHelper();
        System.debug('BEFORE helper: '+JSON.serialize(beforeHelper));
        // Before Phase of Insert
        System.AssertEquals(RECCOUNT,beforeHelper.previewBeforeInsertCounter,'before Preview should see all records');
        System.AssertEquals(RECCOUNT,beforeHelper.meetsEntryCriteriaBeforeInsertCounter,'before Meets should see all records');
        System.AssertEquals(RECCOUNT/2,beforeHelper.processRecordBeforeInsertCounter,'before Process should half of all records');
        System.AssertEquals(1,beforeHelper.finalizeBeforeInsertCounter,'finalize before must be executed once');

        MockITriggerHelper afterHelper = (MockITriggerHelper) harness.getAfterPhaseHelper();
        System.debug('AFTER helper: '+JSON.serialize(beforeHelper));
        
        // After Phase of Insert
        System.AssertEquals(RECCOUNT,afterHelper.previewAfterInsertCounter,'after Preview should see all records');
        System.AssertEquals(RECCOUNT,afterHelper.meetsEntryCriteriaAfterInsertCounter,'after Meets should see all records');
        System.AssertEquals(RECCOUNT/2,afterHelper.processRecordAfterInsertCounter,'after Process should half of all records');
        System.AssertEquals(1,afterHelper.finalizeAfterInsertCounter,'finalize after must be executed once');

    }
}