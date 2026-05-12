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

2. A `TriggerHelperConfig__mdt` custom metadata record stub.

**Before generating the XML, determine which SObject field to populate.**

Salesforce does not allow certain standard objects to be selected via the Entity Reference
picker in CMT records. The framework handles this with two separate fields and two separate
SOQL queries (CMT does not support OR across a relationship field and a text field).

**Step 1 — Check known exceptions first.**

The following standard objects are known to require `AlternateSObject__c` regardless of
what `EntityDefinition.IsCustomizable` returns — the CMT Entity Reference picker maintains
its own internal restricted list that does not match `IsCustomizable`:

- `User`
- `Task`
- `Event`

If the SObject is on this list, use `AlternateSObject__c` and skip the query.

**Step 2 — For all other objects, run the EntityDefinition query as a hint:**

```bash
sf data query --target-org <alias> --query "SELECT QualifiedApiName, IsCustomizable FROM EntityDefinition WHERE QualifiedApiName = '<SObjectApiName>'"
```

| `IsCustomizable` result | Field to populate |
|------------------------|-------------------|
| `true` | `SObjectType__c` — likely safe, but see note below |
| `false` or no rows returned | `AlternateSObject__c` |

**Important:** `IsCustomizable = true` is a necessary but not sufficient condition for
`SObjectType__c`. Other standard objects may also be restricted by the CMT picker but not
yet confirmed. If deployment fails with a "bad value for restricted picklist field" error
on `SObjectType__c`, switch to `AlternateSObject__c` and add the object to the known
exceptions list above.

Using the wrong field causes silent failure at runtime — no helpers run and no error is raised.

**Read one of the existing CMT records as the canonical template.**

Check the local project first, then fall back to the framework repo:

```bash
# Preferred — adopter's own records (already validated against their org)
ls force-app/main/default/customMetadata/TriggerHelperConfig.*.md-meta.xml 2>/dev/null | head -1

# Fallback — framework repo (always present, symlinked peer directory)
ls ../TriggerHelper/force-app/main/default/customMetadata/TriggerHelperConfig.*.md-meta.xml 2>/dev/null | head -1
```

Read whichever file is found first. Use it as the exact template — namespaces, field order, value types,
and any fields added in future package versions are all authoritative there. Substitute only the fields
that change:
- `<label>`, `HelperClassName__c`, `Context__c`, `ExecutionSequence__c`, `IsPilotMode__c`, `RelatedFlows__c`
- The SObject field pair (`SObjectType__c` / `AlternateSObject__c`) per the `IsCustomizable` determination above

The only critical difference from a test record: `Context__c = Production`.

The templates below are a last-resort fallback only if neither location yields a file.

For most objects — use `SObjectType__c`:
```xml
<!-- force-app/main/default/customMetadata/TriggerHelperConfig.<RecordName>.md-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label><RecordName></label>
    <protected>false</protected>
    <values>
        <field>AlternateSObject__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Context__c</field>
        <value xsi:type="xsd:string">Production</value>
    </values>
    <values>
        <field>Enabled__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>ExecutionSequence__c</field>
        <value xsi:type="xsd:double">10.0</value>
    </values>
    <values>
        <field>HelperClassName__c</field>
        <value xsi:type="xsd:string"><HelperClassName></value>
    </values>
    <values>
        <field>IsPilotMode__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>RelatedFlows__c</field>
        <value xsi:type="xsd:string">Not Applicable</value>
    </values>
    <values>
        <field>SObjectType__c</field>
        <value xsi:type="xsd:string"><SObjectApiName></value>
    </values>
</CustomMetadata>
```

For restricted objects (`User`, `Event`, `Task`, etc.) — use `AlternateSObject__c` instead:
```xml
<!-- force-app/main/default/customMetadata/TriggerHelperConfig.<RecordName>.md-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label><RecordName></label>
    <protected>false</protected>
    <values>
        <field>AlternateSObject__c</field>
        <value xsi:type="xsd:string"><SObjectApiName></value>
    </values>
    <values>
        <field>Context__c</field>
        <value xsi:type="xsd:string">Production</value>
    </values>
    <values>
        <field>Enabled__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>ExecutionSequence__c</field>
        <value xsi:type="xsd:double">10.0</value>
    </values>
    <values>
        <field>HelperClassName__c</field>
        <value xsi:type="xsd:string"><HelperClassName></value>
    </values>
    <values>
        <field>IsPilotMode__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>RelatedFlows__c</field>
        <value xsi:type="xsd:string">Not Applicable</value>
    </values>
    <values>
        <field>SObjectType__c</field>
        <value xsi:nil="true"/>
    </values>
</CustomMetadata>
```

Remind the user: a `TriggerLookupTopic__mdt` record is required for any new lookup topic.
Use `/triggerhelper-write-lookup-topic` to generate it.

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
- [ ] `EntityDefinition` query was run to determine `IsCustomizable` for the target SObject
- [ ] CMT stub uses `SObjectType__c` if `IsCustomizable = true`, `AlternateSObject__c` otherwise — never both
