/**
 * SObject agnostic implementation of a TriggerHandler
 * Leverages the ITriggerHelper interface to organize the execution 
 * into small Helpers that operate on individual records
 **/ 
public abstract with sharing class AbstractBaseTriggerHandler implements ITriggerHandler {
    
    /**
     * Standard implementation of isDisabled using the custom setting
     **/ 
    public Boolean isDisabled(){
        //Fetching user level, profile level and org level trigger bypass
        Trigger_Bypass_Setting__c userBypass = Trigger_Bypass_Setting__c.getInstance(UserInfo.getUserId());
        Trigger_Bypass_Setting__c profileBypass = Trigger_Bypass_Setting__c.getInstance(UserInfo.getProfileId());
        Trigger_Bypass_Setting__c orgBypass= Trigger_Bypass_Setting__c.getOrgDefaults();
       
        //Checking Custom Setting for Trigger Bypass
        return ( orgBypass.Bypass_All__c || getSObjectByPassValue(orgBypass) 
           || profileBypass.Bypass_All__c || getSObjectByPassValue(profileBypass) 
           || userBypass.Bypass_All__c || getSObjectByPassValue(userBypass));
    }
    
    /**
     * The implementing Trigger must examine this setting and return the value that controls Bypass for their SObject.  Implementers should add their own flag if a separate bypass
     control is desired for their object.
     **/ 
    abstract Boolean getSObjectByPassValue(final Trigger_Bypass_Setting__c disabledSetting);
    
    /** 
     * The implementing Trigger Must return their SObjectType
     * It's used by the TriggerHelper factory and other methods to scope operations
     **/
    abstract Schema.SObjectType getSObjectType();
    
    /**
     * Abstract helper method to support the singleton behavior
     * Implementors must implement a singleton pattern to return
     * the same instance
     **/ 
    abstract ITriggerHandler getInstance();
    
    @TestVisible
    List<ITriggerHelper> activeHelpers = null;
    
    public List<ITriggerHelper> instantiateHelpers(){
        // Use the factory to modularize and separate the concerns
        final List<ITriggerHelper> helpers = TriggerHelperFactory.getHelpers(getSObjectType().getDescribe().getName());
        
        // Stash a reference to the activeHelpers for test classes to check
        activeHelpers = helpers;
        return helpers;
    }

    @TestVisible
    private void initialiseHelpers(final List<ITriggerHelper> helpers, final LookupDataHandler dataHandler, final TriggerDMLHandler dmlHandler){
        for(ITriggerHelper helper : helpers){
            helper.setDataHandler(dataHandler);
            helper.setDMLHandler(dmlHandler);
        }
    }

    // Allow tests to override the standard executor for Mocking purposes
    @TestVisible    
    private static DMLExecutor dmlExecutor = new DMLExecutor();
    @TestVisible 
    TriggerDMLHandler dmlHandler=new TriggerDMLHandler(dmlExecutor);
    
    private TriggerDMLHandler createDMLHandler() {
        dmlHandler = new TriggerDMLHandler(dmlExecutor); // for debugging
        return dmlHandler; 
    }

    public void beforeInsert(List<sObject> newItems){
        
        final LookupDataHandler dataHandler = new LookupDataHandler();
        try{
            final List<ITriggerHelper> helpers = instantiateHelpers();
            initialiseHelpers(helpers,dataHandler,createDMLHandler());

            for(SObject current : newItems){
                for(ITriggerHelper helper : helpers){
                    try {
                        helper.previewBeforeInsert(current);                      
                    } catch(Exception ex) {
                        LoggingUtility.logError(ex,true);
                        current.addError(ex.getMessage());                        
                    }
                }
            }

            for(SObject current : newItems){
                for(ITriggerHelper helper : helpers){
                    try {
                        if(helper.meetsEntryCriteriaBeforeInsert(current))
                            helper.processRecordBeforeInsert(current);
                        
                    } catch(Exception ex) {
                        /** 
                         * For proper bulk behavior, we don't rethrow the error when we have row-level context
                         * we fail this single row and continue on
                        **/ 
                        LoggingUtility.logError(ex,true);
                        current.addError(ex.getMessage());
                    }
                }
            }
            
            for(ITriggerHelper helper : helpers){
                helper.finalizeBeforeInsert();
            }
            
            dmlHandler.applyDML();
                    
        } catch(Exception ex){
            /**
             * Here we don't have row level context, so we log and rethrow
             **/  
            LoggingUtility.logError(ex, true);
            throw ex; 
        }
    }
    
    /**
     * Allow after insert to be overriden as needed by Platform Event TriggerHandler or other specializations.
     **/ 
    public virtual void afterInsert(Map<id,sObject> newItems){
       
        final TriggerDMLHandler dmlHandler= createDMLHandler();
        final LookupDataHandler dataHandler = new LookupDataHandler();
        try{
            final List<ITriggerHelper> helpers = instantiateHelpers();
            initialiseHelpers(helpers,dataHandler,dmlHandler);
            
            for(SObject current : newItems.values()){
                for(ITriggerHelper helper : helpers){
                    try {
                        helper.previewAfterInsert(current);                        
                    } catch(Exception ex) {
                        LoggingUtility.logError(ex,true);
                        current.addError(ex.getMessage());
                    }
                }
            }
            
            for(SObject current: newItems.values()){
                for(ITriggerHelper helper : helpers){
                    try {
                        if(helper.meetsEntryCriteriaAfterInsert(current))
                            helper.processRecordAfterInsert(current);
                        
                    } catch(Exception ex) {
                        /** 
                         * For proper bulk behavior, we don't rethrow the error when we have row-level context
                         * we fail this single row and continue on
                        **/ 
                        LoggingUtility.logError(ex,true);
                        current.addError(ex.getMessage());
                    }
                }
            }
            
            for(ITriggerHelper helper : helpers){
                helper.finalizeAfterInsert();
            }
            
            dmlHandler.applyDML();
            
        } catch(Exception ex){
            /**
            * Here we don't have row level context, so we log and rethrow
            **/  
            LoggingUtility.logError(ex, true);
            throw ex; 
        }
    }

    public void beforeUpdate(Map<id,sObject> newItems,Map<id,sObject> oldItems){
        
        final LookupDataHandler dataHandler = new LookupDataHandler();
        try{
            final List<ITriggerHelper> helpers = instantiateHelpers();
            initialiseHelpers(helpers,dataHandler,createDMLHandler());

            for(SObject current : newItems.values()){
                for(ITriggerHelper helper : helpers){
                    try {
                        helper.previewBeforeUpdate(current, oldItems.get(current.id));                       
                    } catch(Exception ex) {
                        LoggingUtility.logError(ex,true);
                        current.addError(ex.getMessage());                        
                    }
                }
            }

            for(SObject current: newItems.values()){
                for(ITriggerHelper helper : helpers){
                    try {
                        if(helper.meetsEntryCriteriaBeforeUpdate(current, oldItems.get(current.id)))
                            helper.processRecordBeforeUpdate(current, oldItems.get(current.id));
                        
                    } catch(Exception ex) {
                        /** 
                         * For proper bulk behavior, we don't rethrow the error when we have row-level context
                         * we fail this single row and continue on
                        **/ 
                        LoggingUtility.logError(ex,true);
                        current.addError(ex.getMessage());
                    }
                }
            }
            
            for(ITriggerHelper helper : helpers){
                helper.finalizeBeforeUpdate();
            }
            
            dmlHandler.applyDML();
                    
        } catch(Exception ex){
            /**
             * Here we don't have row level context, so we log and rethrow
             **/  
            LoggingUtility.logError(ex, true);
            throw ex; 
        }
    }
    
    public void afterUpdate(Map<id,sObject> newItems, Map<id,sObject> oldItems) {
                
        final LookupDataHandler dataHandler = new LookupDataHandler();
        final TriggerDMLHandler dmlHandler= createDMLHandler();
        
        try{
            List<ITriggerHelper> helpers = instantiateHelpers();
            initialiseHelpers(helpers,dataHandler,dmlHandler);

            for(SObject current : newItems.values()){
                for(ITriggerHelper helper : helpers){
                    try {
                       helper.previewAfterUpdate(current, oldItems.get(current.id));                      
                    } catch(Exception ex) {
                        /** 
                         * For proper bulk behavior, we don't rethrow the error when we have row-level context
                         * we fail this single row and continue on
                        **/ 
                        LoggingUtility.logError(ex,true);
                        current.addError(ex.getMessage());                        
                    }
                }
            }

            for(SObject current: newItems.values()){
                for(ITriggerHelper helper : helpers){
                    try{
                        if(helper.meetsEntryCriteriaAfterUpdate(current, oldItems.get(current.id)))
                            helper.processRecordAfterUpdate(current, oldItems.get(current.id));
                    } catch(Exception ex) {
                        /** 
                         * For proper bulk behavior, we don't rethrow the error when we have row-level context
                         * we fail this single row and continue on
                        **/ 
                        LoggingUtility.logError(ex,true);
                        current.addError(ex.getMessage());
                    }
                }
            }
            
            for(ITriggerHelper helper : helpers){
                helper.finalizeAfterUpdate();
            }
            
            dmlHandler.applyDML();
                    
        }catch(Exception ex){
            LoggingUtility.logError(ex, true);
            throw ex;
        }        
    }

    public void beforeDelete(Map<id,sObject> oldItems){
        final LookupDataHandler dataHandler = new LookupDataHandler();
        try{
            final List<ITriggerHelper> helpers = instantiateHelpers();
            initialiseHelpers(helpers,dataHandler,createDMLHandler());

            for(SObject deleted : oldItems.values()){
                for(ITriggerHelper helper : helpers){
                    try {
                        helper.previewBeforeDelete(deleted);                      
                    } catch(Exception ex) {
                        LoggingUtility.logError(ex,true);
                        deleted.addError(ex.getMessage());                        
                    }
                }
            }

            for(SObject deleted : oldItems.values()){
                for(ITriggerHelper helper : helpers){
                    try {
                        if(helper.meetsEntryCriteriaBeforeDelete(deleted))
                            helper.processRecordBeforeDelete(deleted);
                        
                    } catch(Exception ex) {
                        /** 
                         * For proper bulk behavior, we don't rethrow the error when we have row-level context
                         * we fail this single row and continue on
                        **/ 
                        LoggingUtility.logError(ex,true);
                        deleted.addError(ex.getMessage());
                    }
                }
            }
            
            for(ITriggerHelper helper : helpers){
                helper.finalizeBeforeDelete();
            }
            
            dmlHandler.applyDML();
                    
        } catch(Exception ex){
            /**
             * Here we don't have row level context, so we log and rethrow
             **/  
            LoggingUtility.logError(ex, true);
            throw ex; 
        }        
    }

    public void afterDelete(Map<id,sObject> oldItems){
       
        final TriggerDMLHandler dmlHandler= createDMLHandler();
        final LookupDataHandler dataHandler = new LookupDataHandler();
        try{
            final List<ITriggerHelper> helpers = instantiateHelpers();
            initialiseHelpers(helpers,dataHandler,dmlHandler);
            
            for(SObject deleted : oldItems.values()){
                for(ITriggerHelper helper : helpers){
                    try {
                        helper.previewAfterDelete(deleted);                        
                    } catch(Exception ex) {
                        LoggingUtility.logError(ex,true);
                        deleted.addError(ex.getMessage());
                    }
                }
            }
            
            for(SObject deleted: oldItems.values()){
                for(ITriggerHelper helper : helpers){
                    try {
                        if(helper.meetsEntryCriteriaAfterDelete(deleted))
                            helper.processRecordAfterDelete(deleted);
                        
                    } catch(Exception ex) {
                        /** 
                         * For proper bulk behavior, we don't rethrow the error when we have row-level context
                         * we fail this single row and continue on
                        **/ 
                        LoggingUtility.logError(ex,true);
                        deleted.addError(ex.getMessage());
                    }
                }
            }
            
            for(ITriggerHelper helper : helpers){
                helper.finalizeAfterDelete();
            }
            
            dmlHandler.applyDML();
            
        } catch(Exception ex){
            /**
            * Here we don't have row level context, so we log and rethrow
            **/  
            LoggingUtility.logError(ex, true);
            throw ex; 
        }           
    }

    
    public void afterUndelete(Map<id,sObject> newItems){
       
        final TriggerDMLHandler dmlHandler= createDMLHandler();
        final LookupDataHandler dataHandler = new LookupDataHandler();
        try{
            final List<ITriggerHelper> helpers = instantiateHelpers();
            initialiseHelpers(helpers,dataHandler,dmlHandler);
            
            for(SObject current : newItems.values()){
                for(ITriggerHelper helper : helpers){
                    try {
                        helper.previewAfterUndelete(current);                        
                    } catch(Exception ex) {
                        LoggingUtility.logError(ex,true);
                        current.addError(ex.getMessage());
                    }
                }
            }
            
            for(SObject current: newItems.values()){
                for(ITriggerHelper helper : helpers){
                    try {
                        if(helper.meetsEntryCriteriaAfterUndelete(current))
                            helper.processRecordAfterUndelete(current);
                        
                    } catch(Exception ex) {
                        /** 
                         * For proper bulk behavior, we don't rethrow the error when we have row-level context
                         * we fail this single row and continue on
                        **/ 
                        LoggingUtility.logError(ex,true);
                        current.addError(ex.getMessage());
                    }
                }
            }
            
            for(ITriggerHelper helper : helpers){
                helper.finalizeAfterUndelete();
            }
            
            dmlHandler.applyDML();
            
        } catch(Exception ex){
            /**
            * Here we don't have row level context, so we log and rethrow
            **/  
            LoggingUtility.logError(ex, true);
            throw ex; 
        }           
    }
}