/**
 * Interface for the SObject and Platform Event Trigger handler(s)
 * Defines the core operations that the handlers orchestrate
**/
public interface ITriggerHandler {
    void beforeInsert(List<sObject> newItems);
    void beforeUpdate(Map<id,sObject> newItems,Map<id,sObject> oldItems);
    void beforeDelete(Map<id,sObject> oldItems);

    void afterInsert(Map<id,sObject> newItems);
    void afterUpdate(Map<id,sObject> newItems,Map<id,sObject> oldItems);
    void afterDelete(Map<id,sObject> oldItems);
    void afterUndelete(Map<id,sObject> oldItems);

    Boolean isDisabled();
    
}