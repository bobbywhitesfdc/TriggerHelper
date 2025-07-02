/**
 * Base implementation of the ITriggerHelper interface methods
 * 
 **/ 
public abstract class AbstractBaseTriggerHelper implements ITriggerHelper {
    
    private LookupDataHandler dataHandler=null;
    private TriggerDMLHandler dmlHandler=null;
    private String helperClassName=null;
    
    /**
     * Default constructor
     **/  
    public AbstractBaseTriggerHelper() {
        dataHandler=null;
        dmlHandler=null;
    }
    
    /**
     * For debugging, give the name of the class implementing the ITriggerHelper interface
     * By declaring this public and non-virtual, we prevent helpers from overriding this implementation
     **/ 
    public String getName() {
        return helperClassName;
    }
    
    /** 
     * For debugging, allow the TriggerHelper factory to set the helper name from configuration
     **/
    public void setName(final String helperClassName) {
        this.helperClassName=helperClassName;
    }

    
    /**
     * Get the data handler
     **/  
    public LookupDataHandler getDataHandler() {
        return dataHandler;
    }
    
    /**
     * Set the data handler for bulk operations
     **/  
    public void setDatahandler(final LookupDataHandler dataHandler) {
        this.dataHandler=dataHandler;
    }
    
    /**
     * Set the DML handler for deferred DML operations
     **/ 
    public void setDMLHandler(final TriggerDMLHandler dmlHandler) {
        this.dmlHandler=dmlHandler;
    }
    
    /**
     * Get the DML Handler for deferred DML 
     **/ 
    public TriggerDMLHandler getDMLHandler() {
        return dmlHandler;
    }    
    
    /**
     *  NO-OP implementation of these Optional Methods that may be overriden
     *  and are SObjectType agnostic (e.g. no SObject parameters passed)
     **/ 
    
    /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    public virtual void finalizeBeforeInsert() {
        
    }
    
     /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    public virtual void finalizeBeforeUpdate() {
        
    }  
    
    /**
    * called after all of the records have been processed in Pass 1
    * Helpers can perform full collection tasks here like publishing Platform events
    **/ 
    public virtual void finalizeBeforeDelete() {
       
    }
    
    /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    public virtual void finalizeAfterInsert() {
        
    }
    
     /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    public virtual void finalizeAfterUpdate() {
        
    }

     /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    public virtual void finalizeAfterDelete() {
        
    }

     /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    public virtual void finalizeAfterUndelete() {
        
    }

     /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows  
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    public virtual void previewBeforeInsert(final SObject current) {
    }
    
    /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    public virtual void previewBeforeUpdate(final SObject current, final SObject original) {
    }
    
     /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    public virtual void previewAfterInsert(final SObject current) {
    }
    
     /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    public virtual void previewAfterUpdate(final SObject current, final SObject original) {
    } 
    
    /**
    * Test to see if this record meets the entry criteria to be processed - Before Insert phase
    **/  
    public virtual Boolean meetsEntryCriteriaBeforeInsert(final SObject current) {
        return true;
    }
    
    /**
    * Test to see if this record meets the entry criteria to be processed - Before Update phase
    **/  
    public virtual Boolean meetsEntryCriteriaBeforeUpdate(final SObject current, final SObject original) {
       return true;
    }

    /**
    * Test to see if this record meets the entry criteria to be processed - After Insert phase
    **/  
    public virtual Boolean meetsEntryCriteriaAfterInsert(final SObject current) {
       return true; 
    }
    
    /**
    * Test to see if this record meets the entry criteria to be processed - After Update phase
    **/  
    public virtual Boolean meetsEntryCriteriaAfterUpdate(final SObject current, final SObject original) {
        return true;
    }
    
    /**
    * process the record -- Before Insert phase
    **/ 
    public virtual void processRecordBeforeInsert(final SObject current) {
    }
    
    /**
    * process the record -- Before Update phase
    **/ 
    public virtual void processRecordBeforeUpdate(final SObject current, final SObject original) {
    }

    /**
    * process the record -- After Insert phase
    **/ 
    public virtual void processRecordAfterInsert(final SObject current) {
    }
    
    /**
    * process the record -- After Update phase
    **/ 
    public virtual void processRecordAfterUpdate(final SObject current, final SObject original) {
    }

    /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    public virtual void previewBeforeDelete(final SObject current) {
    }

     /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    public virtual void previewAfterDelete(final SObject current) {
    }

     /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    public virtual void previewAfterUndelete(final SObject current) {
    }

    /**
    * Test to see if this record meets the entry criteria to be processed - Before Update phase
    **/  
    public virtual Boolean meetsEntryCriteriaBeforeDelete(final SObject current) {
        return true;
    }    

    /**
    * Test to see if this record meets the entry criteria to be processed - After Update phase
    **/  
    public virtual Boolean meetsEntryCriteriaAfterDelete(final SObject current) {
        return true;
    }
    
    /**
    * Test to see if this record meets the entry criteria to be processed - After Update phase
    **/  
    public virtual Boolean meetsEntryCriteriaAfterUndelete(final SObject current) {
        return true;
    }   

    /**
    * process the record -- Before Delete phase
    **/ 
    public virtual void processRecordBeforeDelete(final SObject current) {
    }

    /**
    * process the record -- After Delete phase
    **/ 
    public virtual void processRecordAfterDelete(final SObject current) {
    }

    /**
    * process the record -- After Undelete phase
    **/ 
    public virtual void processRecordAfterUndelete(final SObject current) {
    }
}