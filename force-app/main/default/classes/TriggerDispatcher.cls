/*
   All Object triggers need to call the run method from the Dispatcher class to route to respective Trigger Handlers
*/
public with sharing class TriggerDispatcher {
    
    @TestVisible 
    private static Boolean enableRunMocking=false;
    @TestVisible 
    private static List<SObject> mockNew=null;
    @TestVisible
    private static List<SObject> mockOld=null;
    
    /**
     * General entrypoint for Apex Triggers.  Simply pass in the SObjectType for 
     * Standard Objects, Custom Objects, or Platform Events
     * This entrypoint will instantiate the correct Handler
     **/ 
    public static void run(final Schema.SObjectType sobjectType) {
        try {
            DesignByContractUtil.assertNotEquals(null,sobjectType,'SObjectType is required!');
            
            // Avoid cut & paste errors in the calling trigger
            if (Trigger.isExecuting || enableRunMocking) { 
                validateSObjectTypeMatch(Trigger.isExecuting ? Trigger.new : mockNew,sobjectType); 
            }            
            
            // Instantiate the correct standard handler based on SObjectType
            final ITriggerHandler handler =  TriggerHandlerFactory.getInstance(sobjectType);

            run(handler);
            
        } catch (Exception ex) { LoggingUtility.logError(ex,true); throw(ex); } // Log and rethrow unhandled exceptions
   }
    
    public static void validateSObjectTypeMatch(final List<SObject> triggerNewCollection, final Schema.SObjectType passedType) {
        DesignByContractUtil.assertEquals(triggerNewCollection[0].getSObjectType(),passedType, 'Configuration error, trigger SObjectType incorrect!');
    }
    
    /**
     * Explicit entrypoint if a specialized handler is required
     **/ 
    public static void run(ITriggerHandler handler){
       try {
            /**
             * Short circuit if the handler is disabled
             **/ 
            if(handler.isDisabled()){ return; }

            /**
             * Orchestrate the correct Trigger Phase based on the Trigger Operation type
             **/ 
            switch on (getTriggerOperationType()) {
                when BEFORE_INSERT{
                    handler.beforeInsert(Trigger.new);
                }
                when BEFORE_UPDATE{
                    handler.beforeUpdate(Trigger.newMap,Trigger.oldMap);
                }

                when BEFORE_DELETE{
                    handler.beforeDelete(Trigger.oldMap);
                }
                when AFTER_INSERT{
                    handler.afterInsert(Trigger.newMap);
                } 
                when AFTER_UPDATE{
                    handler.afterUpdate(Trigger.newMap,Trigger.oldMap);
                } 
                when AFTER_DELETE{
                    handler.afterDelete(Trigger.oldMap);
                }
                when AFTER_UNDELETE{
                    handler.afterUndelete(Trigger.oldMap);
                }
            }           
        } catch (Exception ex) { LoggingUtility.logError(ex,true); throw(ex); } // Log and rethrow unhandled exceptions
    }
    
@TestVisible
Static System.TriggerOperation unitTestOperationType=null;
@TestVisible
Static Boolean enableTOMocking=false;
    
    /**
     * Allow a Unit Test to explicitly test the trigger Context
     * by setting the static variable "unitTestOperationType"
     **/ 
    public static System.TriggerOperation getTriggerOperationType() {
        //NOTE: for testing.  Stacked to trick code coverage
        if (enableTOMocking && Test.isRunningTest()) { return unitTestOperationType; } else {return Trigger.operationType; }
    }
}