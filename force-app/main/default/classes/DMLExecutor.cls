/**
 * Lightweight wrapper to allow System.Database methods to be executed
 * at runtime and mocked for tests
 * All public methods are intended to be overridden by a mock.
 **/ 
public virtual class DMLExecutor {
    public virtual List<Database.Saveresult> insertData(List<SObject> records, Boolean dmlAllOrNone) {
        return Database.insert(records,dmlAllOrNone);
    }
    public virtual List<Database.Saveresult> updateData(List<SObject> records, Boolean dmlAllOrNone) {
        return Database.update(records,dmlAllOrNone);
    }
    public virtual List<Database.UpsertResult> upsertData(List<SObject> records, Schema.SObjectField externalIdField, Boolean dmlAllOrNone) {
        return Database.upsert(records,externalIdField,dmlAllOrNone);
    }
    public virtual List<Database.DeleteResult> deleteData(List<SObject> records, Boolean dmlAllOrNone) {
        return Database.delete(records,dmlAllOrNone);
    }
    public virtual List<Database.UndeleteResult> undeleteData(List<SObject> records, Boolean dmlAllOrNone) {
        return Database.undelete(records,dmlAllOrNone);
    }
    public virtual List<Database.Saveresult> publish(List<SObject> records) {
        return  EventBus.publish(records); 
    }
}