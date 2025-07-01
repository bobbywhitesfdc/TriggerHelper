/**
 * Defines subset of the DML methods that we want helpers to use.  Intentionally excludes methods we only only want the framework to use.
 **/ 
public interface IHelperDMLHandler {
    /**
     * Add a candidate record for future INSERT
     * 
     * Nothing prevents duplicate inserts
     **/ 
    void addForInsert(final SObject candidateRecord);

    /**
     * Add a candidate record for future DELETE
     * 
     * Prevents duplicate DELETES
     **/ 
    void addForDelete(final SObject candidateRecord);
    
     /**
     * Add a candidate record for future UNDELETE
     * 
     * Prevents duplicate UNDELETES
     **/ 
    void addForUnDelete(final SObject candidateRecord);
    
     /**
     * Update is an operation that requires special handling
     * We want to ensure that a 2nd update will not obliterate state
     * from another helper.  This method returns the record if it's previously
     * been queued for an update
     **/ 
    SObject getForUpdate(final SObject candidateRecord);
    
    /**
     * Add a record for Update.   #getForUpdate should be used first to ensure
     * that you do not overwrite changes made by another helper
     **/ 
    void putForUpdate(final SObject candidateRecord);
}