/**
 * Standard TriggerHandler that does not need to be customized or overridden 
 * for specific Platform Event types.
 **/ 
public class StandardPlatformEventTriggerHandler extends AbstractBaseTriggerHandler {
    public static final String EVENTFIELD='EventUuid';
    
    final Schema.SObjectType peType;
    private static StandardPlatformEventTriggerHandler singleton=null;
    
    public StandardPlatformEventTriggerHandler(final Schema.SObjectType peType) {
        DesignByContractUtil.AssertEquals(true,isPlatformEventType(peType),'SObjectType must be a PlatformEvent which defines: '+EVENTFIELD);
        
        this.peType = peType;
        singleton = this;
    }
    
    /**
     * No bypass implementation that is PE Objecttype specific
     **/ 
    public Boolean getSObjectByPassValue(final Trigger_Bypass_Setting__c disabledSetting) {
        return false;
    }
    
    /** 
     * The implementing Trigger Must return their SObjectType
     * It's used by the TriggerHelper factory and other methods to scope operations
     **/
    public  Schema.SObjectType getSObjectType() {
        return this.peType;
    }
    
    /**
     * Implement the singleton pattern
     **/ 
    public ITriggerHandler getInstance() {
        return singleton;
    }
    
    public static boolean isPlatformEventType(final Schema.SObjectType value) {
        DesignByContractUtil.AssertNotEquals(null,value,'Must not be null');
        try {
            value.newSObject().isSet(EVENTFIELD);
            return true;
        } catch (System.SObjectException soex) {
            return false;
        }
    }

}