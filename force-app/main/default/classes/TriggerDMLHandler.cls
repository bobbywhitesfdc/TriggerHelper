/**
 * TriggerDMLHandler is responsible for applying
 * DML's that have been deferred by Helpers
 * The primary objective is to avoid multiple DML operations on the same object
 * across individual helpers
 * 
 **/ 
public class TriggerDMLHandler implements IHelperDMLHandler {
    // Input Collections
    @TestVisible List<SObject> toInsert = new List<SObject>();
    @TestVisible Map<Id,SObject> toUpdate = new Map<Id,SObject>();
    @TestVisible Map<String,SObject> toUpsert = new Map<String,SObject>();
    @TestVisible Map<Id,SObject> toDelete = new Map<Id,SObject>(); 
    @TestVisible Map<Id,SObject> toUndelete = new Map<Id,SObject>();
    @TestVisible List<SObject> toPublish = new List<SObject>();

    
    @TestVisible
    final DMLExecutor executor;
    
    /**
     * Default constructor
     **/ 
    public TriggerDMLHandler() {
        executor = new DMLExecutor();
    }
    public TriggerDMLHandler(DMLExecutor specialExecutor) {
        executor = specialExecutor;
    }
    
    public override String toString() {
        return 'TriggerDMLHandler w/' + executor.toString();
    }
    
    private void assertEquals(final Object expected, final Object actual,final String msg) {
        if (expected!=actual) {
            throw new IllegalArgumentException(msg+' Expected:' + expected + ' Actual:' + actual);
        }
    }
    private void assertNotEquals(final Object expected, final Object actual,final String msg) {
        if (expected==actual) {
            throw new IllegalArgumentException(msg+' NOT Expected:' + expected + ' Actual:' + actual);
        }
    }
    
    /**
     * For error logging, return this value for context
     **/ 
    public String getContext() {
        return TriggerDMLHandler.class.getName();
    }
    
    /**
     * Add a candidate Platform Event for future PUBLISH
     * 
     **/ 
    public void addForPublish(final SObject candidatePE) {
        assertNotEquals(null,candidatePE,'Proposed Platform Event must not be null');
        try {
            // This will throw an exception if the standard Platform Event field isn't defined
            candidatePE.isSet('EventUuid');
        } catch (System.SObjectException ex) {
            throw new IllegalArgumentException('Published item must be a platform event',ex);
        }
        toPublish.add(candidatePE);
    }

    
    /**
     * Add a candidate record for future INSERT
     * 
     * Nothing prevents duplicate inserts
     **/ 
    public void addForInsert(final SObject candidateRecord) {
       assertNotEquals(null,candidateRecord,'Proposed record must not be null');
       assertEquals(null,candidateRecord.Id,'Proposed record must NOT have an Id'); 
       toInsert.add(candidateRecord);
    }

    private Schema.SObjectField upsertField = null;

    /**
     * Get a candidate record for future UPSERT
     * Prevent duplicate upserts by checking for the existing proposed record by ExternalId
     **/ 
    public SObject getForUpsert(final SObject candidateRecord, final Schema.SObjectField externalIdField) {
       assertNotEquals(null,candidateRecord,'Proposed record must not be null');
       assertEquals(null,candidateRecord.Id,'Proposed record must NOT have an Id'); 
       assertNotEquals(null,externalIdField,'ExternalIdField name is required');
       assertNotEquals(null,candidateRecord.get(externalIdField),'Proposed record must have value for ExternalId field');
        
        if (upsertField==null) {
            upsertField=externalIdField;
        }
       // Must not allow different externalId fields
       assertEquals(upsertField,externalIdField,'Only 1 externalId field allowed per Upsert'); 
        
       // Return the existing record if it's already been inserted into the map, otherwise, return the candidate record
       final SObject result = toUpsert.get((String) candidateRecord.get(externalIdField));
       return result == null ? candidateRecord : result;
    }
    
    /**
     * Put a candidate record for future UPSERT
     * Prevent duplicate upserts by checking for the existing proposed record by ExternalId
     **/ 
    public void putForUpsert(final SObject candidateRecord, final Schema.SObjectField externalIdField) {
       assertNotEquals(null,candidateRecord,'Proposed record must not be null');
       assertEquals(null,candidateRecord.Id,'Proposed record must NOT have an Id'); 
       assertNotEquals(null,externalIdField,'ExternalIdField name is required');
       assertNotEquals(null,candidateRecord.get(externalIdField),'Proposed record must have value for ExternalId field');
        
        if (upsertField==null) {
            upsertField=externalIdField;
        }
       // Must not allow different externalId fields
       assertEquals(upsertField,externalIdField,'Only 1 externalId field allowed per Upsert'); 
        
       // Add the candidate record to the map replacing the existing record if it's already been inserted into the map 
       toUpsert.put((String) candidateRecord.get(externalIdField),candidateRecord);
    }
    
    
    /**
     * Add a candidate record for future DELETE
     * 
     * Prevents duplicate DELETES
     **/ 
    public void addForDelete(final SObject candidateRecord) {
       assertNotEquals(null,candidateRecord,'Proposed record must not be null');
       assertNotEquals(null,candidateRecord.Id,'Proposed record must have an Id'); 
       toDelete.put(candidateRecord.id,candidateRecord);
    }
     /**
     * Add a candidate record for future UNDELETE
     * 
     * Prevents duplicate UNDELETES
     **/ 
    public void addForUnDelete(final SObject candidateRecord) {
       assertNotEquals(null,candidateRecord,'Proposed record must not be null');
       assertNotEquals(null,candidateRecord.Id,'Proposed record must have an Id'); 
       toUnDelete.put(candidateRecord.id,candidateRecord);
    }
    
     /**
     * Update is an operation that requires special handling
     * We want to ensure that a 2nd update will not obliterate state
     * from another helper.  This method returns the record from the Map if it's previously
     * been queued for an update.  If not, it returns the candidateRecord without placing it in the map.
     * Caller is guaranteed to have a non-null result;
     **/ 
    public SObject getForUpdate(final SObject candidateRecord){
        System.debug('inside DML handler'+candidateRecord);
       assertNotEquals(null,candidateRecord,'Proposed record must not be null');
       assertNotEquals(null,candidateRecord.Id,'Proposed record must have an Id');
        System.debug('inside DML handler'+toUpdate.containsKey(candidateRecord.Id));
       return toUpdate.containsKey(candidateRecord.Id) ? toUpdate.get(candidateRecord.Id) : candidateRecord; 
    }
    
    public void putForUpdate(final SObject candidateRecord) {
        assertNotEquals(null,candidateRecord,'Proposed record must not be null');
        assertNotEquals(null,candidateRecord.Id,'Proposed record must have an Id');
        toUpdate.put(candidateRecord.Id,candidateRecord);
    }

    /**
     * Method to have collective Inserts in a trigger transaction
     **/ 
    public List<Database.SaveResult> insertObjects(){
        System.debug('### TriggerDMLHandler.insertObjects');
        List<Database.SaveResult> saveResults= new List<Database.SaveResult>();
        if(!toInsert.isEmpty()){
            // Allow for incremental success and row-level failure
            toInsert.sort(); // Sort by SObjectType to avoid error with mixed batch
            saveResults =  executor.insertData(toInsert,false);
            System.debug('### TriggerDMLHandler.insertObjects - saveResults: ' + saveResults); 
            LoggingUtility.logError(saveResults,toInsert,getContext());
            Integer n = 0;
            for (Database.saveResult result : saveResults ) {
                if (!result.isSuccess()) {
                    for (Database.error err : result.getErrors()) {                        
                        // Because Inserted records don't have an Id, we have to match by the relative position in the list
                       toInsert[n].addError(err.getMessage());                      
                    }
                }
                n++;
            }
        }
        return saveResults;
    }

    /**
     * Method to have collective Platform Event Publications in a trigger transaction
     **/ 
    public List<Database.SaveResult> publish(){
        System.debug('### TriggerDMLHandler.publish');
        List<Database.SaveResult> saveResults= new List<Database.SaveResult>();
        if(!toPublish.isEmpty()){
            // Allow for incremental success and row-level failure
            toPublish.sort(); // Sort by SObjectType to avoid error with mixed batch
            saveResults =  executor.publish(toPublish);
            System.debug('### TriggerDMLHandler.publish - saveResults: ' + saveResults); 
            LoggingUtility.logError(saveResults,toPublish,getContext());

            for (Integer n=0; n < saveResults.size(); n++) {
                final Database.saveResult result = saveResults[n];
                if (!result.isSuccess()) {
                    for (Database.error err : result.getErrors()) {                        
                        // Because Inserted records don't have an Id, we have to match by the relative position in the list
                       System.Debug('Adding error to row: '+ n);
                       toPublish[n].addError(err.getMessage());                      
                    }
                }
            }
        }
        return saveResults;
    }
    
    
    /**
     *  Method to have collective Updates in a trigger transaction
     **/ 
    public List<Database.SaveResult> updateObjects(){
        System.debug('### TriggerDMLHandler.updateObjects');
        List<Database.SaveResult> saveResults= new List<Database.SaveResult>();
        if(!toUpdate.isEmpty()){
            //Actual DML Operation and Logging
            List<SObject> toUpdateValues = toUpdate.values();
            toUpdateValues.sort();
            saveResults =  executor.updateData(toUpdateValues,false);
            System.debug('### TriggerDMLHandler.updateObjects - saveResults: ' + saveResults); 
            LoggingUtility.logError(saveResults,toUpdateValues,getContext());
            
            // Tag any failed records with their errors
            Integer n = 0; 
            for (Database.saveResult result : saveResults ) {
                if (!result.isSuccess()) {
                    // Find the original record by Position
                    final SObject failedRecord = toUpdateValues[n];
                    DesignByContractUtil.assertNotEquals(null, failedRecord, 'failedRecord must not be null');
                    for (Database.error err : result.getErrors()) {
                       failedRecord.addError(err.getMessage());                      
                    }
                }
                n++;
            }
        }
        return saveResults;
    }

    /**
     *  Method to have collective UPSERTS in a trigger transaction
     **/ 
    public List<Database.UpsertResult> upsertObjects(){
        System.debug('### TriggerDMLHandler.upsertObjects');
        List<Database.UpsertResult> upsertResults= new List<Database.UpsertResult>();
        if(!toUpsert.isEmpty()){
            upsertResults =  executor.upsertData(toUpsert.values(),this.upsertField,false);
            System.debug('### TriggerDMLHandler.upsertObjects - upsertResults: ' + upsertResults); 
            
            LoggingUtility.logError(upsertResults,toUpsert.values(),getContext());
            
            // Tag any failed records with their errors
            Integer n = 0; 
            for (Database.UpsertResult result : upsertResults ) {
                if (!result.isSuccess()) {
                    // Find the original record by Position
                    final SObject failedRecord = toUpsert.values()[n];
                    DesignByContractUtil.assertNotEquals(null, failedRecord, 'failedRecord must not be null');
                    for (Database.error err : result.getErrors()) {
                       failedRecord.addError(err.getMessage());                      
                    }
                }
                n++;
            }
        }
        return upsertResults;
    }
 
    /**
     * Method to have collective Delete in a trigger transaction
     **/ 
    public List<Database.DeleteResult>  deleteObjects(){
        List<Database.DeleteResult>  deleteResults= new List<Database.DeleteResult>();
        
        if(!toDelete.isEmpty()){        
            //Actual DML Operation and Logging
            List<SObject> toDeleteValues = toDelete.values();
            toDeleteValues.sort();
            deleteResults =  executor.deleteData(toDeleteValues,false);
            LoggingUtility.logError(deleteResults,toDeleteValues,getContext());
            
            // Tag any failed records with their errors
            Integer n=0;
            for (Database.DeleteResult result : deleteResults ) {
                if (!result.isSuccess()) {
                    // Find the original record by Id
                    final SObject failedRecord = toDeleteValues[n];
                    DesignByContractUtil.assertNotEquals(null, failedRecord, 'failedRecord must not be null');
                    for (Database.error err : result.getErrors()) {
                       failedRecord.addError(err.getMessage());                      
                    }
                }
                n++;
            }
        }
        return deleteResults;
    }
    
    /**
     * Method to have collective Undelete in a trigger transaction
     **/ 
    public List<Database.UndeleteResult> undeleteObjects(){
        List<Database.UndeleteResult> undeleteResults= new List<Database.UndeleteResult>();
        
        if(!toUndelete.isEmpty()){
            //Actual DML Operation and Logging
            final List<SObject> toUndeleteValues = toUndelete.values();
            toUndeleteValues.sort();
            undeleteResults =  executor.undeleteData(toUndeleteValues,false);
            LoggingUtility.logError(undeleteResults,toUndeleteValues,getContext());
            
            // Tag any failed records with their errors
            Integer n=0;
            for (Database.UndeleteResult result : undeleteResults ) {
                if (!result.isSuccess()) {
                    // Find the original record by Id
                    final SObject failedRecord = toUndeleteValues[n];
                    DesignByContractUtil.assertNotEquals(null, failedRecord, 'failedRecord must not be null');
                    for (Database.error err : result.getErrors()) {
                       failedRecord.addError(err.getMessage());                      
                    }
                }
                n++;
            }
        }
        return undeleteResults;
    }
    
    // Result Collections
    @TestVisible List<Database.SaveResult> toInsertResults = new List<Database.SaveResult>();
    @TestVisible List<Database.SaveResult> toUpdateResults = new List<Database.SaveResult>();
    @TestVisible List<Database.UpsertResult> toUpsertResults = new List<Database.UpsertResult>();
    @TestVisible List<Database.DeleteResult> toDeleteResults = new List<Database.DeleteResult>();
    @TestVisible List<Database.UndeleteResult> toUndeleteResults = new List<Database.UndeleteResult>();
    
    /**
     * Convenience method to execute all of the possible DMLs
     * Results are saved in test visible collections for validation
     **/ 
    public void applyDML() {
        toInsertResults = insertObjects();
        toUpsertResults = upsertObjects();
        toUpdateResults = updateObjects();
        toDeleteResults = deleteObjects();
        toUndeleteResults = undeleteObjects();
    }
}