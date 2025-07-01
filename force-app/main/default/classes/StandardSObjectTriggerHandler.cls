public class StandardSObjectTriggerHandler extends AbstractBaseTriggerHandler {
    static Schema.SObjectType myType;
    static StandardSObjectTriggerHandler theSingleton;
    

    /**
     *  Constructor takes the SObjectType
     **/     
    public StandardSObjectTriggerHandler(final Schema.SObjectType typeValue) {
        myType=typeValue;
        theSingleton=this;
    }
    
    /**
     * Default implementation is no specific bypass for this SObjectType
     **/ 
    public Boolean getSObjectByPassValue(final Trigger_Bypass_Setting__c disabledSetting) {
        return false;
    }
    
    /** 
     * Return the constructed value
     **/
    public Schema.SObjectType getSObjectType() {
        return myType;
    }
    
    /**
     * Return the singleton instance
     **/ 
    public ITriggerHandler getInstance() {
        return theSingleton;
    }
    
}