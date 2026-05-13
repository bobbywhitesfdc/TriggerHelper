# TriggerHelper Framework

TriggerHelper Framework is designed to simplify the creation and maintenance of Apex Triggers in complex salesforce orgs.   It fully supports modular development especially in projects with multiple concurrent workstreams.  It optimizes and simplifies SOQL query lookups and batches DML for great scalability.   Nebula Logging is integrated into the framework.

# Quick Start — Claude Code

This repo ships Claude Code skills that accelerate helper authoring for framework adopters (creating a trigger, creating a helper, generating unit tests, query topic creation)


Setup instructions, permissions snippets, and symlink steps: [`.claude/README.md`](.claude/README.md)

# Quick Start Manual
1) Install the Unlocked Package
Latest Stable Subscriber Package Version Id: 04tDn000000vFYqIAM

Package Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04tDn000000vFYqIAM


Alternatively, use the CLI
```
 sf package install \
    --package 04tDn000000vFYqIAM \
    --target-org <YourScratchOrgAlias> \
    --wait 10 \
    --publish-wait 10 \
    --no-prompt
```

2) Create an Apex trigger on your object (e.g Account)
```
trigger AccountTrigger on Account (before insert, before update, before delete
                                                                  , after insert, after update
                                                                  , after delete, after undelete ) {
   TriggerDispatcher.run();
}
```

3) Create your first helper Apex Class by extending  AbstractBaseTriggerHelper
(Override methods only as needed for your use case — or use `/triggerhelper-write-helper` in Claude Code)
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
4) Write unit tests for your helper (or use `/triggerhelper-unit-tests` in Claude Code)

5) Create a Custom Metadata Type record configuration (TriggerHelperConfig__mdt)
 - Configure the object (Account)
 - Set the HelperClass name to your helper (MyFirstAccountHelper)
 - Set the Execution Order to 1
 - Enable it

> **Note — User, Event, Task, and other restricted objects:**
> Salesforce does not allow certain standard objects (including `User`, `Event`, and `Task`) to be
> selected via the Entity Reference picker in Custom Metadata Type records. For these objects,
> leave `SObjectType__c` blank and populate `AlternateSObject__c` with the plain API name
> (e.g. `User`) instead. The framework queries both fields, so behavior is identical at runtime —
> only the way the CMT record is populated differs.

# TriggerHelperFramework Scratch Org Automation

If you'd like to build your own version of this Unlocked package, I've included some useful scripts and utilities.
This repository includes a Bash script to automate your Salesforce 2GP development cycle with dependencies.

## Files

- `dev_scratch_cycle.sh` — Automates scratch org creation, dependency installation, source deployment, test running, and cleanup.  
- `project.properties` — Configuration file for environment-specific variables used by the script.

## Setup Instructions

1. **Edit `project.properties`:**  
   Open `project.properties` and update the values to match your Salesforce environment:  
   - Set your Dev Hub alias (`DEV_HUB_ALIAS`).  
   - Choose a scratch org alias (`SCRATCH_ALIAS`).  
   - Verify the path to your scratch org definition file (`SCRATCH_DEF_FILE`).  
   - Confirm the package alias for Nebula Logger (`NEBULA_ALIAS`).  
   - Adjust scratch org duration (`SCRATCH_DURATION`) if needed.

2. **Make the script executable:**  
   ```bash
   chmod +x dev_scratch_cycle.sh

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.