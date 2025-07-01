/**
* Define the common methods all TriggerHandler helpers must implement.
* Implements a ROW based paradigm to simplify processing.
* See: LookupDataHandler for supporting Queries
* See: TriggerDMLHandler for supporting DML queries (deferred)
**/  
public Interface ITriggerHelper {
    /**
     * For debugging, give the name of the class implementing the ITriggerHelper interface
     **/ 
    String getName();
    /**
     * Set the data handler for bulk operations
     **/  
    void setDatahandler(final LookupDataHandler dataHandler);
    
    /**
     * Set the DML handler for deferred DML operations
     **/ 
    void setDMLHandler(final TriggerDMLHandler dmlHandler);
    
     /**
     * Get the data handler for bulk operations
     **/  
    LookupDataHandler getDatahandler();
    
    /**
     * Get the DML Handler for deferred DML
     * Limit the public methods to the subset we want Helpers using
     **/ 
    IHelperDMLHandler getDMLHandler();
    
    /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    void previewBeforeInsert(final SObject current);
    
    /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    void previewBeforeUpdate(final SObject current, final SObject original);

    /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    void previewBeforeDelete(final SObject current);
    
     /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    void previewAfterInsert(final SObject current);
    
     /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    void previewAfterUpdate(final SObject current, final SObject original);
 
    /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    void previewAfterDelete(final SObject current);
 
    /**
     * For helpers that need extra information to evaluate EntryCriteria, this entry point allows 
     * them to preview the record and request extra info
     * Implementors should minimize the number of records they request here if possible by prescreening
     * based on supplied fields
     **/ 
    void previewAfterUndelete(final SObject current);
     
    /**
    * Test to see if this record meets the entry criteria to be processed - Before Insert phase
    **/  
    Boolean meetsEntryCriteriaBeforeInsert(final SObject current);
    
    /**
    * Test to see if this record meets the entry criteria to be processed - Before Update phase
    **/  
    Boolean meetsEntryCriteriaBeforeUpdate(final SObject current, final SObject original);
    
    /**
    * Test to see if this record meets the entry criteria to be processed - Before Delete phase
    **/  
    Boolean meetsEntryCriteriaBeforeDelete(final SObject current);
    
    /**
    * Test to see if this record meets the entry criteria to be processed - After Insert phase
    **/  
    Boolean meetsEntryCriteriaAfterInsert(final SObject current);
    
    /**
    * Test to see if this record meets the entry criteria to be processed - After Update phase
    **/  
    Boolean meetsEntryCriteriaAfterUpdate(final SObject current, final SObject original);
   
    /**
    * Test to see if this record meets the entry criteria to be processed - After Delete phase
    **/
    Boolean meetsEntryCriteriaAfterDelete(final SObject current);

    /**
    * Test to see if this record meets the entry criteria to be processed - After Undelete phase
    **/  
    Boolean meetsEntryCriteriaAfterUndelete(final SObject current);
    
    /**
    * process the record -- Before Insert phase
    **/ 
    void processRecordBeforeInsert(final SObject current);
    
    /**
    * process the record -- Before Update phase
    **/ 
    void processRecordBeforeUpdate(final SObject current, final SObject original);

    /**
    * process the record -- Before Delete phase
    **/ 
    void processRecordBeforeDelete(final SObject current);

    /**
    * process the record -- After Insert phase
    **/ 
    void processRecordAfterInsert(final SObject current);
    
    /**
    * process the record -- After Update phase
    **/ 
    void processRecordAfterUpdate(final SObject current, final SObject original);
    
    /**
    * process the record -- After Delete phase
    **/ 
    void processRecordAfterDelete(final SObject current);

    /**
    * process the record -- After Undelete phase
    **/ 
    void processRecordAfterUndelete(final SObject current);

    /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    void finalizeBeforeInsert();
    
    /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    void finalizeBeforeUpdate();
    
    /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    void finalizeBeforeDelete();
    
    /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    void finalizeAfterInsert();
    
        /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    void finalizeAfterUpdate();

    /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    void finalizeAfterDelete();

    /**
     * called after all of the records have been processed in Pass 1
     * Helpers can perform full collection tasks here like publishing Platform events
     **/ 
    void finalizeAfterUndelete();
}