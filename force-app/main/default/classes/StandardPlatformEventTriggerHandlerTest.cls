/**
* Unit test for StandarPlatformEventTriggerHandler
**/
@isTest
public class StandardPlatformEventTriggerHandlerTest {
    public static final Schema.SObjectType referencePEType = TriggerMockPE__e.SObjectType;
    public static final Integer BATCHSIZE=2000;
    
    private static StandardPlatformEventTriggerHandler getHandler() {
        // Set the context so that our MockPEHelper is loaded
        TriggerHelperFactory.factoryContext='TestHappyPath';
        StandardPlatformEventTriggerHandler handler = new StandardPlatformEventTriggerHandler(TriggerMockPE__e.SObjectType);
        return handler;
    }

    public static testmethod void afterInsertOrchestrationTest() {
        StandardPlatformEventTriggerHandler handler = getHandler();
        
        // Create some test PE's
        Map<Id,TriggerMockPE__e> testData = new Map<Id,TriggerMockPE__e>();
        for (Integer i=0; i < BATCHSIZE; i++) {
            TriggerMockPE__e current = new TriggerMockPE__e();
            testData.put(current.ReplayId,current);
        }        
        
        Test.startTest();
        
        // Run AFTER INSERT ORCHESTRATION
        handler.afterInsert(testData);
        
        Test.stopTest();
        
        // Check to see if the appropriate methods were called as expected
    }
    
    public static testmethod void sobjectTypeTestHappy() {
        final Schema.SObjectType referencePEType = TriggerMockPE__e.SObjectType;
        Test.StartTest();
        
        StandardPlatformEventTriggerHandler handler = new StandardPlatformEventTriggerHandler(referencePEType);
        
        Test.StopTest();
        System.AssertEquals(referencePEType,handler.getSObjectType(),'SObjectType must be PEType');        
    }
    
    public static testmethod void sobjectTypeTestNull() {
        Test.StartTest();
        
        try {
           StandardPlatformEventTriggerHandler handler = new StandardPlatformEventTriggerHandler(null);
           System.Assert(false,'Expected an exception to be thrown on NULL SObjectType'); 
        } catch(DesignByContractUtil.DBCAssertionException dbcEx) {
           System.Assert(true,'Correct exception caught');
        }
        
        Test.StopTest();
    }
    
    public static testmethod void sobjectTypeTestBadType() {
        Test.StartTest();
        
        try {
           StandardPlatformEventTriggerHandler handler = new StandardPlatformEventTriggerHandler(Account.SObjectType);
           System.Assert(false,'Expected an exception to be thrown on BAD SObjectType'); 
        } catch(DesignByContractUtil.DBCAssertionException dbcEx) {
           System.Assert(true,'Correct exception caught');
        }
        
        Test.StopTest();
    }
    
    public static testmethod void bypassTest() {
        
        Trigger_Bypass_Setting__c triggerSetting = Trigger_Bypass_Setting__c.getOrgDefaults();
        triggerSetting.Bypass_All__c=false;
        upsert triggerSetting triggerSetting.Id;
        
        Test.StartTest();
        
        StandardPlatformEventTriggerHandler handler = new StandardPlatformEventTriggerHandler(referencePEType);
        
        Test.StopTest();
        System.AssertEquals(false,handler.getSObjectByPassValue(triggerSetting),'Expected false');        
    }

    
    public static testmethod void singletonTest() {
                
        Test.StartTest();
        
        final StandardPlatformEventTriggerHandler handler1 = new StandardPlatformEventTriggerHandler(referencePEType);
        final StandardPlatformEventTriggerHandler handler2 = new StandardPlatformEventTriggerHandler(referencePEType);
        
        Test.StopTest();
        System.AssertEquals(handler1.getInstance(),handler2.getInstance(),'Expected same instance');        
    }
    
    
}