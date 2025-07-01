/** 
 * Standardized implementation for the Trigger_Framework_Mock__c Object.
 **/ 
public class MockTriggerHandler extends AbstractBaseTriggerHandler {       
    /** 
    * The implementing Trigger Must return their SObjectType
    * It's used by the TriggerHelper factory and other methods to scope operations
    **/
   public Schema.SObjectType getSObjectType() {
       return Trigger_Framework_Mock__c.SObjectType;
   }    

   Static ITriggerHandler instance=null;
   
    /**
    * Abstract helper method to support the singleton behavior
    * Implementors must implement a singleton pattern to return
    * the same instance
    **/ 
   public ITriggerHandler getInstance() {
       if (instance==null) {
           instance= new MockTriggerHandler();
       }
       return  instance;
   }
   
   /**
    * The implementing Trigger must examine this setting and return the value that controls Bypass for their SObject
    **/ 
   public Boolean getSObjectByPassValue(final Trigger_Bypass_Setting__c disabledSetting) {
       return disabledSetting.Bypass_Mock_Trigger__c;
   }
   
}