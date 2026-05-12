# TriggerHelper Implementation Authoring Skill

Generates a production-ready TriggerHelper implementation class from a natural-language
description of the business logic. The output is framework-conformant and review-ready:
dispatcher-only trigger body, correct lifecycle method selection, bulk-safe
LookupDataHandler usage, and narrow exception throwing.

## Invocation Forms

```
/triggerhelper-write-helper <description of business logic>
/triggerhelper-write-helper          (prompts for description)
```

## Step 1 — Gather Requirements

If no description is provided, ask:
> "Describe the business logic this helper should implement. Include: the SObject, the
> trigger phase (before/after insert/update/delete), the entry criteria, the field
> mutations or DML actions, and any lookup dependencies (e.g. a queue, related record)."

Confirm before writing:
- SObject API name
- Trigger phase(s) — before insert / after insert / before update / etc.
- Entry criteria (what makes a record eligible)
- Core logic per record
- Any lookups required (and their key type — Salesforce Id or string external key)
- Error behavior when a required lookup is missing

## Step 2 — Read Framework Reference

Read (relative to this repo root):
- `force-app/main/default/classes/AbstractBaseTriggerHelper.cls` — base class and virtual methods
- `force-app/main/default/classes/LookupDataHandler.cls` — query API
- `force-app/main/default/classes/TriggerDMLHandler.cls` — deferred DML API
- `force-app/main/default/classes/ITriggerHelper.cls` — interface contract

## Step 3 — Select Lifecycle Methods

Only override the methods the logic actually requires. Default no-op implementations
in `AbstractBaseTriggerHelper` cover everything not overridden.

| Need | Override |
|------|----------|
| Bulk lookup registration | `preview<Phase>` |
| Record admission gating | `meetsEntryCriteria<Phase>` |
| Per-record mutation / DML enqueue | `processRecord<Phase>` |
| Cross-record aggregation or one-time transaction work | `finalize<Phase>` |

Do not override `finalize` unless cross-record aggregation is genuinely required.
Per-record DML must be delegated to `getDMLHandler().addForInsert/Update/Delete(record)`
inside `processRecord`, not buffered in an instance field.

## Step 4 — Apply LookupDataHandler Correctly

Match the API to the key type:
- **Salesforce Id** → `getDataHandler().requestItemDetail(id)` in `preview`, `getDataHandler().getItemDetail(id)` in `processRecord`
- **String external key** (e.g. `Group.DeveloperName`) → `getDataHandler().requestExternalId(topic, key)` in `preview`, `getDataHandler().getExternalId(topic, key)` in `processRecord`

In `preview`, pre-screen with available fields before registering a lookup to avoid
unnecessary queries across a bulk batch. Request only what the record needs.

## Step 5 — Apply Exception and Logging Rules

- Helpers **must not** call `Logger.error`, `Logger.debug`, or any logging framework directly.
- Throw narrow, typed exceptions with meaningful messages when a required condition is unmet.
- The dispatcher (`AbstractBaseTriggerHandler`) catches all exceptions, calls
  `LoggingUtility.logError(ex, true)`, and calls `current.addError(ex.getMessage())`.
- Define inner exception classes for each distinct fault condition.
- Do not call `Logger.debug(msg, record)` in before-insert context — records have no Id.

## Step 6 — Write the Helper Class

### Structure

```apex
/**
 * @description <Business-intent description.>
 *
 * @author <author>
 * @date <YYYY-MM-DD>
 */
public with sharing class <HelperClassName> extends AbstractBaseTriggerHelper {

    // Constants
    private static final String STATUS_<X> = '<value>';
    private static final String TOPIC_<X>  = '<TopicName>';

    // preview — register lookups needed by processRecord
    public override void preview<Phase>(final SObject current) {
        final <SObject__c> record = (<SObject__c>) current;
        if (<pre-screen condition>) {
            getDataHandler().requestExternalId(TOPIC_X, record.<Field__c>);
        }
    }

    // entry gate — return true for records processRecord should act on
    public override Boolean meetsEntryCriteria<Phase>(final SObject current) {
        final <SObject__c> record = (<SObject__c>) current;
        return <condition>;
    }

    // per-record action
    public override void processRecord<Phase>(final SObject current) {
        final <SObject__c> record = (<SObject__c>) current;
        // ... mutations or getDMLHandler().addFor<X>(relatedRecord)
    }

    // Inner exceptions — one per distinct fault condition
    public class <Name>Exception extends Exception {}
}
```

### Naming

- Class name must be ≤ 40 characters and describe business intent, not implementation mechanism.
  Prefer `<Domain><Action>Helper` (e.g. `CaseOwnerAssignmentHelper`, `ISAdvisorTaskHelper`).
- Constants: `SCREAMING_SNAKE_CASE`.
- No `Helper` suffix on exception classes: `NotFoundException`, `MissingQueueException`.

## Step 7 — Write the Trigger and CMT Stub

Also produce:
1. A thin trigger file:
```apex
trigger <SObject>Trigger on <SObject__c> (before insert, ...) {
    TriggerDispatcher.run();
}
```

2. A `TriggerHelperConfig__mdt` custom metadata record stub:
```xml
<!-- force-app/main/default/customMetadata/TriggerHelperConfig.<RecordName>.md-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata">
    <label><RecordName></label>
    <values><field>HelperClassName__c</field><value xsi:type="xsi:string"><HelperClassName></value></values>
    <values><field>SObjectType__c</field><value xsi:type="xsi:string"><SObjectApiName></value></values>
    <values><field>Enabled__c</field><value xsi:type="xsi:boolean">true</value></values>
    <values><field>ExecutionSequence__c</field><value xsi:type="xsi:double">10</value></values>
    <values><field>Context__c</field><value xsi:type="xsi:string">Production</value></values>
    <values><field>IsPilotMode__c</field><value xsi:type="xsi:boolean">false</value></values>
</CustomMetadata>
```

Remind the user: the `TriggerLookupTopic__mdt` record for any new lookup topic must also
be created (Production context and UnitTest context both required if tests use live queries).

## Step 8 — Self-Review Checklist

- [ ] Class name ≤ 40 characters, business-intent named
- [ ] Only required lifecycle methods overridden
- [ ] `preview` pre-screens before registering lookups
- [ ] LookupDataHandler API matches key type (Id → detail; string → externalId)
- [ ] Per-record DML via `getDMLHandler()`, not buffered in instance field
- [ ] `finalize` used only when cross-record aggregation genuinely required
- [ ] No logging calls in helper — narrow typed exceptions only
- [ ] No `Logger.debug(msg, record)` in before-insert context
- [ ] Inner exception class(es) defined for each fault condition
- [ ] Trigger file is dispatcher-only
- [ ] CMT stub produced with correct field values
