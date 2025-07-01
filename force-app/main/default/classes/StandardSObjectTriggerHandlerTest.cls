@isTest(isParallel=true)
public class StandardSObjectTriggerHandlerTest {
    public static final Schema.SObjectType REFSOBJTYPE = Account.SObjectType;
    
    public static testmethod void testGetSObjectType() {
        final StandardSObjectTriggerHandler handler = new StandardSObjectTriggerHandler(REFSOBJTYPE);
        Test.StartTest();
        final Schema.SObjectType result = handler.getSObjectType();
        Test.StopTest();
        System.AssertEquals(REFSOBJTYPE,result,'Types must match');        
    }
    
    public static testmethod void testGetInstance() {
        final StandardSObjectTriggerHandler handler = new StandardSObjectTriggerHandler(REFSOBJTYPE);
        Test.StartTest();
        final ITriggerHandler result = handler.getInstance();
        Test.StopTest();
        System.AssertEquals(handler,result,'Must be a singleton');        
    }
    
    public static testmethod void testBypassSetting() {
        final StandardSObjectTriggerHandler handler = new StandardSObjectTriggerHandler(REFSOBJTYPE);
        Trigger_Bypass_Setting__c setting = Trigger_Bypass_Setting__c.getInstance();
        setting.Bypass_All__c=true;
        
        Test.StartTest();
        final Boolean result = handler.getSObjectByPassValue(setting);
        Test.StopTest();
        System.AssertEquals(false,result,'Always bypass=false for this handler');        
    }

}