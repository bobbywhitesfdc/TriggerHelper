/**
 * This abstract helper is specialized for Platform Event handling
 * It limits the scope to AFTER INSERT related methods to simplify and
 * ruggedize the PE helpers.
 *
 **/ 
public abstract class AbstractBasePETriggerHelper extends AbstractBaseTriggerHelper {

    /**
     * Overrideable Virtual methods to support AFTER INSERT phase for PE
     **/ 
    public override virtual void previewAfterInsert(final SObject current) {}  
    public override virtual Boolean meetsEntryCriteriaAfterInsert(final SObject current) { return true; } 
    public override virtual void processRecordAfterInsert(final SObject current)  {}
    public override virtual void finalizeAfterInsert() {}

    
    /**
     * NO-OP implementations that are not overridable
     * to satisfy the Interface Requirements
     **/  
    public override void previewBeforeInsert(final SObject current) {}
    public override  void previewBeforeUpdate(final SObject current, final SObject original) {}
    public override void previewBeforeDelete(final SObject current) {}
    public override void previewAfterUpdate(final SObject current, final SObject original) {}
    public override void previewAfterDelete(final SObject current) {}
    public override void previewAfterUndelete(final SObject current) {}
    public override Boolean meetsEntryCriteriaBeforeInsert(final SObject current) { return true; }
    public override Boolean meetsEntryCriteriaBeforeUpdate(final SObject current, final SObject original) { return true; }
    public override Boolean meetsEntryCriteriaBeforeDelete(final SObject current) { return true; } 
    public override Boolean meetsEntryCriteriaAfterUpdate(final SObject current, final SObject original) { return true; }
    public override Boolean meetsEntryCriteriaAfterDelete(final SObject current) { return true; } 
    public override Boolean meetsEntryCriteriaAfterUndelete(final SObject current) { return true; }
    public override void processRecordBeforeInsert(final SObject current){}
    public override void processRecordBeforeUpdate(final SObject current, final SObject original){}
    public override void processRecordBeforeDelete(final SObject current){}
    public override void processRecordAfterUpdate(final SObject current, final SObject original){}
    public override void processRecordAfterDelete(final SObject current){}
    public override void processRecordAfterUndelete(final SObject current){}
    public override void finalizeBeforeInsert(){}
    public override void finalizeBeforeUpdate(){}
    public override void finalizeBeforeDelete(){}
    public override void finalizeAfterUpdate(){}
    public override void finalizeAfterDelete(){}
    public override void finalizeAfterUndelete(){}
}