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
        
        MockITriggerHelper helper = (MockITriggerHelper) harness.getHelperInstance();
        System.debug(JSON.serialize(helper));
        // Before Phase of Insert
        System.AssertEquals(RECCOUNT,helper.previewBeforeInsertCounter,'before Preview should see all records');
        System.AssertEquals(RECCOUNT,helper.meetsEntryCriteriaBeforeInsertCounter,'before Meets should see all records');
        System.AssertEquals(RECCOUNT/2,helper.processRecordBeforeInsertCounter,'before Process should half of all records');
        System.AssertEquals(1,helper.finalizeBeforeInsertCounter,'finalize before must be executed once');
        // After Phase of Insert
        System.AssertEquals(RECCOUNT,helper.previewAfterInsertCounter,'after Preview should see all records');
        System.AssertEquals(RECCOUNT,helper.meetsEntryCriteriaAfterInsertCounter,'after Meets should see all records');
        System.AssertEquals(RECCOUNT/2,helper.processRecordAfterInsertCounter,'after Process should half of all records');
        System.AssertEquals(1,helper.finalizeAfterInsertCounter,'finalize after must be executed once');

    }
}