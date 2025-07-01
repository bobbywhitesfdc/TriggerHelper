trigger TriggerFrameworkMockTrigger on Trigger_Framework_Mock__c (before insert, before update, before delete
                                                                  , after insert, after update
                                                                  , after delete, after undelete ) {
   TriggerDispatcher.run();
}