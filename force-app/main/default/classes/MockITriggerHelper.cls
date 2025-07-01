/**
 * MockITriggerHelper -- used to Test ITriggerHandler orchestration.
 * Public methods simply count the number of times they were called to test orchestration
 **/ 
public abstract class MockITriggerHelper extends AbstractBaseTriggerHelper Implements ITriggerHelper{
        
    public Boolean isOdd(final Integer input) {
        return Math.mod(input,2) == 1;
    }
    
    /**
     * Dummy implementations of the required ITriggerHelper interface.
     * These implementations simply increment counters, except where noted
     **/
    public Integer previewBeforeInsertCounter=0;
    
    public virtual override void previewBeforeInsert(final SObject record){
        System.AssertNotEquals(null,record,'previewBeforeInsert expects a non-null input');
        previewBeforeInsertCounter++;
    }
    
    public Integer meetsEntryCriteriaBeforeInsertCounter=0;
    
    /**
     * odd numbered calls return true
     **/ 
    public override Boolean meetsEntryCriteriaBeforeInsert(final SObject record){
        System.AssertNotEquals(null,record,'meetsEntryCriteriaBeforeInsert expects a non-null input');
        meetsEntryCriteriaBeforeInsertCounter++;
        return isOdd(meetsEntryCriteriaBeforeInsertCounter);
    }

    public Integer processRecordBeforeInsertCounter=0;
    
    public virtual override void processRecordBeforeInsert(final SObject record) {
        System.AssertNotEquals(null,record,'processRecordBeforeInsert expects a non-null input');
        processRecordBeforeInsertCounter++;   
    }

    public Integer finalizeBeforeInsertCounter=0;

    public virtual override void finalizeBeforeInsert(){
        finalizeBeforeInsertCounter++;
    }
    
    public Integer previewAfterInsertCounter=0;
    
    public virtual override void previewAfterInsert(final SObject record){
        System.AssertNotEquals(null,record,'previewAfterInsert expects a non-null input');
        previewAfterInsertCounter++;       
    }

    public Integer meetsEntryCriteriaAfterInsertCounter=0;
    
    public override Boolean meetsEntryCriteriaAfterInsert(SObject record){
        System.AssertNotEquals(null,record,'meetsEntryCriteriaAfterInsert expects a non-null input');
        meetsEntryCriteriaAfterInsertCounter++;
        return isOdd(meetsEntryCriteriaAfterInsertCounter);
    }

    public Integer processRecordAfterInsertCounter=0;
    
    public virtual override void processRecordAfterInsert(final SObject record) {
        System.AssertNotEquals(null,record,'processRecordAfterInsert expects a non-null input');
        processRecordAfterInsertCounter++;        
    }

    public Integer finalizeAfterInsertCounter=0;
    
    public virtual override void finalizeAfterInsert(){
        finalizeAfterInsertCounter++;
    }
    
    public Integer previewBeforeUpdateCounter=0;
    
    public virtual override void previewBeforeUpdate(final SObject newRecord, final SObject oldRecord) {
        System.AssertNotEquals(null,newRecord,'previewBeforeUpdate expects a non-null newRecord');
        System.AssertNotEquals(null,oldRecord,'previewBeforeUpdate expects a non-null oldRecord');
        previewBeforeUpdateCounter++;
    }
    
    public Integer meetsEntryCriteriaBeforeUpdateCounter=0;
    
    public override Boolean meetsEntryCriteriaBeforeUpdate(final SObject newRecord, final SObject oldRecord) { 
        System.AssertNotEquals(null,newRecord,'meetsEntryCriteriaBeforeUpdate expects a non-null newRecord');
        System.AssertNotEquals(null,oldRecord,'meetsEntryCriteriaBeforeUpdate expects a non-null oldRecord');
        meetsEntryCriteriaBeforeUpdateCounter++;
        return isOdd(meetsEntryCriteriaBeforeUpdateCounter);
    }
    
    public Integer processRecordBeforeUpdateCounter=0;
    public virtual override void processRecordBeforeUpdate(final SObject current, final SObject original) {
        System.AssertNotEquals(null,current,'processRecordBeforeUpdate expects a non-null current');
        System.AssertNotEquals(null,original,'processRecordBeforeUpdate expects a non-null original');
        processRecordBeforeUpdateCounter++;     
    }
    
    public Integer finalizeBeforeUpdateCounter=0;
    
    public virtual override void finalizeBeforeUpdate(){
        finalizeBeforeUpdateCounter++;
    }
    
    public Integer previewAfterUpdateCounter=0;
    public virtual override void previewAfterUpdate(final SObject newRecord, final SObject oldRecord){
        System.AssertNotEquals(null,newRecord,'previewAfterUpdate expects a non-null newRecord');
        System.AssertNotEquals(null,oldRecord,'previewAfterUpdate expects a non-null oldRecord');
        previewAfterUpdateCounter++;
    }
    
    public Integer meetsEntryCriteriaAfterUpdateCounter=0;
    
    public override Boolean meetsEntryCriteriaAfterUpdate(SObject record,final SObject oldRecord){
        System.AssertNotEquals(null,record,'meetsEntryCriteriaBeforeUpdate expects a non-null record');
        System.AssertNotEquals(null,oldRecord,'meetsEntryCriteriaBeforeUpdate expects a non-null oldRecord');
        meetsEntryCriteriaAfterUpdateCounter++;
        return isOdd(meetsEntryCriteriaAfterUpdateCounter);    
    }

    public Integer processRecordAfterUpdateCounter=0;
    public virtual override void processRecordAfterUpdate(final SObject record,final SObject oldRecord) {
        System.AssertNotEquals(null,record,'processRecordAfterUpdate expects a non-null record');
        System.AssertNotEquals(null,oldRecord,'processRecordAfterUpdate expects a non-null oldRecord');
        processRecordAfterUpdateCounter++;        
    }

    public Integer finalizeAfterUpdateCounter=0;
    public virtual override void finalizeAfterUpdate(){
        finalizeAfterUpdateCounter++;
    }

    //New methods for Mock for Delete and undelete

    /**
     * Dummy implementations of the required ITriggerHelper interface.
     * These implementations simply increment counters, except where noted
     **/
    public Integer previewBeforeDeleteCounter=0;
    
    public virtual override void previewBeforeDelete(final SObject newRecord){
        System.AssertNotEquals(null,newRecord,'previewBeforeDelete expects a non-null input');
        previewBeforeDeleteCounter++;
    }
    
    public Integer meetsEntryCriteriaBeforeDeleteCounter=0;
    
    /**
     * odd numbered calls return true
     **/ 
    public override Boolean meetsEntryCriteriaBeforeDelete(final SObject record){
        System.AssertNotEquals(null,record,'meetsEntryCriteriaBeforeDelete expects a non-null input');
        meetsEntryCriteriaBeforeDeleteCounter++;
        return isOdd(meetsEntryCriteriaBeforeDeleteCounter);
    }

    public Integer processRecordBeforeDeleteCounter=0;
    
    public virtual override void processRecordBeforeDelete(final SObject record) {
        System.AssertNotEquals(null,record,'processRecordBeforeDelete expects a non-null input');
        processRecordBeforeDeleteCounter++;   
    }

    public Integer finalizeBeforeDeleteCounter=0;

    public virtual override void finalizeBeforeDelete(){
        finalizeBeforeDeleteCounter++;
    }
    
    public Integer previewAfterDeleteCounter=0;
    
    public virtual override void previewAfterDelete(final SObject newRecord){
        System.AssertNotEquals(null,newRecord,'previewAfterDelete expects a non-null input');
        previewAfterDeleteCounter++;       
    }

    public Integer meetsEntryCriteriaAfterDeleteCounter=0;
    
    public override Boolean meetsEntryCriteriaAfterDelete(SObject record){
        System.AssertNotEquals(null,record,'meetsEntryCriteriaAfterDelete expects a non-null input');
        meetsEntryCriteriaAfterDeleteCounter++;
        return isOdd(meetsEntryCriteriaAfterDeleteCounter);
    }

    public Integer processRecordAfterDeleteCounter=0;
    
    public virtual override void processRecordAfterDelete(final SObject record) {
        System.AssertNotEquals(null,record,'processRecordAfterDelete expects a non-null input');
        processRecordAfterDeleteCounter++;        
    }

    public Integer finalizeAfterDeleteCounter=0;
    
    public virtual override void finalizeAfterDelete(){
        finalizeAfterDeleteCounter++;
    }

    public Integer previewAfterUndeleteCounter=0;
    
    public virtual override void previewAfterUndelete(final SObject newRecord){
        System.AssertNotEquals(null,newRecord,'previewAfterUndelete expects a non-null input');
        previewAfterUndeleteCounter++;       
    }

    public Integer meetsEntryCriteriaAfterUndeleteCounter=0;
    
    public override Boolean meetsEntryCriteriaAfterUndelete(SObject record){
        System.AssertNotEquals(null,record,'meetsEntryCriteriaAfterUndelete expects a non-null input');
        meetsEntryCriteriaAfterUndeleteCounter++;
        return isOdd(meetsEntryCriteriaAfterUndeleteCounter);
    }

    public Integer processRecordAfterUndeleteCounter=0;
    
    public virtual override void processRecordAfterUndelete(final SObject record) {
        System.AssertNotEquals(null,record,'processRecordAfterUndelete expects a non-null input');
        processRecordAfterUndeleteCounter++;        
    }

    public Integer finalizeAfterUndeleteCounter=0;
    
    public virtual override void finalizeAfterUndelete(){
        finalizeAfterUndeleteCounter++;
    }

}