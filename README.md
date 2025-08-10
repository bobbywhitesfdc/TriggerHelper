# TriggerHelper Framework

TriggerHelper Framework

# Quick Start
1) Install the Unlocked Package
Latest Stable Subscriber Package Version Id: 04tDn000000fHnVIAU

Package Installation URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=04tDn000000fHnVIAU

Alternatively, use the CLI
```
 sf package install \
    --package 04tDn000000fHnVIAU \
    --target-org <YourScratchOrgAlias> \
    --wait 10 \
    --publish-wait 10 \
    --no-prompt
```

2) Create an Apex trigger on your object (e.g Account)
```
trigger AccountTrigger on Acccount (before insert, before update, before delete
                                                                  , after insert, after update
                                                                  , after delete, after undelete ) {
   TriggerDispatcher.run();
}
```

3) Create your first helper Apex Class by extending  AbstractBaseTriggerHelper
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
4) Create a Custom Metadata Type record configuration (TriggerHelperConfig_mdt)
 - Configure the object (Account)
 - Set the HelperClass name to your helper (MyFirstAccountHelper)
 - Set the Execution Order to 1
 - Enable it

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
