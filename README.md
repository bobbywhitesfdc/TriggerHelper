# TriggerHelper Framework

TriggerHelper Framework

# Quick Start
1) Create an Apex trigger on your object (e.g Account)
TriggerDispatcher.run(Account.SObjectType);

2) Create your first helper Apex Class by Subclassing  AbstractBaseTriggerHelper
(Override methods only as needed for your use case)
```
/**
 * Mock Helper class for testing the HappyPath for DML of the MockTriggerHandler
 **/ 
public class MyFirstAccountHelper extends AbstractBaseTriggerHelper implements ITriggerHelper {
    
    public String getName() {
        return MyFirstAccountHelper.class.getName();
    }
    
    /**
     * Insert a task for each Account to test the INSERT DML function.
     **/ 
    public override void processRecordAfterInsert(final SObject record, final SObject original ) {
        final Task testTask=new Task(Subject='HappyDML:'+record.Id);
        getDMLHandler().addForInsert(testTask);
    }
        
}
```
3) Create a Custom Metadata Type record configuration (TriggerHelperConfig_mdt)
  a) Configure the object (Account)
  b) Set the HelperClass name to your helper (MyFirstAccountHelper)
  c) Set the Execution Order to 1
  d) Enable it
