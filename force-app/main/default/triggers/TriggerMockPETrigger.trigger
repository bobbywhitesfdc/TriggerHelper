trigger TriggerMockPETrigger on TriggerMockPE__e (after insert) {
   TriggerDispatcher.run(TriggerMockPE__e.SObjectType);
}