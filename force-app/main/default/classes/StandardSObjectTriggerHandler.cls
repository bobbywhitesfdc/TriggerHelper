public virtual class StandardSObjectTriggerHandler extends AbstractBaseTriggerHandler {
    static Schema.SObjectType myType;
    static StandardSObjectTriggerHandler theSingleton;
    
    /**
     *  Default Constructor required, but should never be used
     **/     
    public StandardSObjectTriggerHandler() {
        throw new IllegalArgumentException('StandardSObjectTriggerHandler default constructor must never be used!');
    }

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