public class TriggerHandlerFactory {
    public static final String EVENTFIELD='EventUuid';

    public static ITriggerHandler getInstance(final Schema.SObjectType value) {
        ITriggerHandler handler = null;
        DesignByContractUtil.assertNotEquals(null,value,'SObjectType is required!');
        if (isPlatformEventType(value)) {
           handler = new StandardPlatformEventTriggerHandler(value).getInstance(); 
        } else {
           handler = new StandardSObjectTriggerHandler(value).getInstance();
        }
        return handler; 
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