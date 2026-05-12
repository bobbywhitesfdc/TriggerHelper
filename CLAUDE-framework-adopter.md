# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

TriggerHelper is an installed unlocked package (`TriggerHelperFramework`). You write helpers in **your** project; the framework classes (`AbstractBaseTriggerHelper`, `TriggerDispatcher`, etc.) live in the package namespace and are not editable.

---

## Writing a trigger

Every trigger is one line:

```apex
trigger AccountTrigger on Account (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    TriggerDispatcher.run();
}
```

---

## Writing a helper

Extend `AbstractBaseTriggerHelper` and override only the phase methods you need. All others are no-ops by default.

```apex
public class AccountStatusHelper extends AbstractBaseTriggerHelper {

    // Optional: register bulk queries before records are evaluated
    public override void previewAfterUpdate(SObject current, SObject original) {
        Account acct = (Account) current;
        if (acct.OwnerId != ((Account) original).OwnerId) {
            getDataHandler().requestItemDetail(acct.OwnerId);  // User lookup
        }
    }

    public override Boolean meetsEntryCriteriaAfterUpdate(SObject current, SObject original) {
        return ((Account) current).OwnerId != ((Account) original).OwnerId;
    }

    public override void processRecordAfterUpdate(SObject current, SObject original) {
        Account acct = (Account) current;
        User newOwner = (User) getDataHandler().getItemDetail(acct.OwnerId);
        Account toUpdate = (Account) getDMLHandler().getForUpdate(acct);
        toUpdate.Description = 'Owner changed to ' + newOwner.Name;
        getDMLHandler().putForUpdate(toUpdate);
    }
}
```

**Rules:**
- Never write SOQL inside `meetsEntryCriteria*` or `processRecord*` — register keys in `preview*`, retrieve in `processRecord*`
- Never call DML directly — queue everything through `getDMLHandler()`
- No logging in helpers — handled by the framework layer

---

## Helper lifecycle (per trigger phase)

```
For each record → preview*(record)          register query keys
                                            [framework executes batch queries]
               → meetsEntryCriteria*(record) return false to skip
               → processRecord*(record)      business logic; queue DML
After all records → finalize*()             cross-record aggregation
                  [framework executes deferred DML]
```

---

## Bulk queries — LookupDataHandler

Three patterns, all accessed via `getDataHandler()`:

**Detail lookup** (foreign key → primary key of target):
```apex
// preview: register
getDataHandler().requestItemDetail(acct.OwnerId);            // topic = SObjectType of the Id

// processRecord: retrieve
User owner = (User) getDataHandler().getItemDetail(acct.OwnerId);
```

**Related list** (primary key → child records):
```apex
// preview: register
getDataHandler().requestRelatedList('CaseMilestones', caseRecord.Id);

// processRecord: retrieve (always returns a list, never null)
List<SObject> milestones = getDataHandler().getRelatedList('CaseMilestones', caseRecord.Id);
```

**External ID lookup** (string key → record):
```apex
// preview: register
getDataHandler().requestExternalId('MyTopic', record.External_Id__c);

// processRecord: retrieve
SObject related = getDataHandler().getExternalId('MyTopic', record.External_Id__c);
```

Topic names for related list and external ID queries must match a `TriggerLookupTopic__mdt` record (see below).

---

## Deferred DML — TriggerDMLHandler

Accessed via `getDMLHandler()`:

| Operation | Methods |
|-----------|---------|
| Insert | `addForInsert(record)` — record must have no Id |
| Update | `getForUpdate(record)` then `putForUpdate(record)` — merges edits from multiple helpers |
| Upsert | `getForUpsert(record, externalIdField)` then `putForUpsert(record, externalIdField)` |
| Delete | `addForDelete(record)` — record must have Id |
| Undelete | `addForUnDelete(record)` |
| Platform Event | `addForPublish(event)` |

Always `getFor*` before `putFor*` on update/upsert — this prevents one helper from overwriting another helper's field changes on the same record.

---

## Configuration — TriggerHelperConfig__mdt

One record per helper. Fields:

| Field | Purpose |
|-------|---------|
| `SObjectType__c` | Entity Reference to the SObject — use when `IsCustomizable = true` (see below) |
| `AlternateSObject__c` | Plain-text API name fallback — use when `IsCustomizable = false`. Leave `SObjectType__c` blank. |
| `HelperClassName__c` | Apex class name (e.g. `AccountStatusHelper`) |
| `ExecutionSequence__c` | Integer — ascending order of execution |
| `Enabled__c` | Boolean on/off without code change |
| `Context__c` | `Production` for live helpers; use a separate value for test-only records |
| `IsPilotMode__c` | Gates on `FF_TriggerHelperPilot` custom permission |
| `RelatedFlows__c` | Required text field. Document any Flows that must be deactivated when this helper is active (they are mutually exclusive). If no flows are related, set to `Not Applicable`. |

A record must populate **either** `SObjectType__c` **or** `AlternateSObject__c`, never both. The factory runs two separate SOQL queries because CMT does not support OR across a relationship field and a text field. Using the wrong field causes silent failure — no helpers run and no error is raised.

Some standard objects are known to require `AlternateSObject__c` regardless of other signals —
the CMT Entity Reference picker has its own internal restricted list. Known cases: `User`, `Task`, `Event`.
For these, use `AlternateSObject__c` directly.

For all other objects, query `EntityDefinition` as a guide:

```bash
sf data query --target-org <alias> --query "SELECT QualifiedApiName, IsCustomizable FROM EntityDefinition WHERE QualifiedApiName = '<SObjectApiName>'"
```

If `IsCustomizable = true` → try `SObjectType__c`. If `false` (or no rows) → use `AlternateSObject__c`.

The definitive test is deployment — if it fails with a "bad value for restricted picklist field" error,
switch to `AlternateSObject__c`.

---

## Configuration — TriggerLookupTopic__mdt

One record per query topic. There are three topic types — choose based on what key you have
and what shape of result you need.

### Detail
You have a Salesforce Id that is the primary key of the target object (e.g. `Case.OwnerId` → `User`).
- `Topic__c` — the SObject API name (e.g. `User`). This is what the framework resolves automatically when you call `requestItemDetail(id)`.
- `TopicType__c` — `Detail`
- `KeyFieldname__c` — leave null. The result map is keyed by `Id` implicitly.
- `QueryTemplate__c` — `SELECT Id, <fields> FROM <SObject> WHERE Id IN :keySet`

### RelatedList
You have the primary key of a parent and want its child records (e.g. `Case.Id` → `CaseMilestone` list).
- `Topic__c` — descriptive name, convention is `Related<ChildSObject>` (e.g. `RelatedCaseMilestones`). This is the name passed to `requestRelatedList(topic, id)`.
- `TopicType__c` — `RelatedList`
- `KeyFieldname__c` — the foreign-key field on the child object (e.g. `CaseId`). **Must appear in the SELECT** — the framework uses it to group results by parent.
- `QueryTemplate__c` — `SELECT Id, <KeyFieldname__c>, <fields> FROM <ChildSObject> WHERE <KeyFieldname__c> IN :keySet`

### ExternalId
You have a string value (not a Salesforce Id) that matches a unique field on the target object (e.g. `FederationIdentifier`, `StockKeepingUnit`).
- `Topic__c` — descriptive name (e.g. `UserByFederationId`). This is the name passed to `requestExternalId(topic, key)`.
- `TopicType__c` — `ExternalId`
- `KeyFieldname__c` — the string field used as the key (e.g. `FederationIdentifier`). **Must appear in the SELECT**.
- `QueryTemplate__c` — `SELECT Id, <KeyFieldname__c>, <fields> FROM <SObject> WHERE <KeyFieldname__c> IN :keySet`

**Common rules for all types:**
- `:keySet` is the only bind variable — it is bound by the framework, never by the helper.
- `Context__c = Production` for all live records.
- `SObjectTypeName__c` — the API name of the queried SObject. Documentation only, not used at runtime.
- If a topic for the same SObject already exists (e.g. a `User` Detail topic shared by multiple helpers), add your needed fields to the existing query's SELECT rather than creating a duplicate. Validate the merged query in Developer Console before deploying.

---

## Testing

Use `TestTriggerHelperHarness`. It isolates a single helper and mocks DML — no live DML on the object under test.

```apex
@isTest
static void testOwnerChange() {
    // Setup: build in-memory records (no insert on target object)
    Account oldAcct = new Account(Id = TestUtility.generateFakeId(Account.SObjectType), OwnerId = UserInfo.getUserId());
    Account newAcct = new Account(Id = oldAcct.Id, OwnerId = UserInfo.getOrganizationId()); // different owner

    TestTriggerHelperHarness harness = new TestTriggerHelperHarness(Account.SObjectType);
    harness.setHelperUnderTest('AccountStatusHelper');
    harness.doUpdate(new List<SObject>{newAcct}, new List<SObject>{oldAcct});

    // Verify deferred DML
    TriggerDMLHandler dmlHandler = harness.getDMLHandler();
    Assert.isFalse(dmlHandler.toUpdate.isEmpty());
    Account updated = (Account) dmlHandler.toUpdate.values()[0];
    Assert.isTrue(updated.Description.contains('Owner changed'));
}
```

**Harness entry points:**

| Method | Phases run |
|--------|-----------|
| `doInsert(newRecords)` | before insert + after insert (auto-assigns mock Ids) |
| `doUpdate(newRecords, oldRecords)` | before update + after update |
| `doDelete(deletedRecords)` | before delete + after delete |
| `doUndelete(undeletedRecords)` | after undelete only |

**Accessing results:**

| Method | Returns |
|--------|---------|
| `harness.getDMLHandler()` | `TriggerDMLHandler` — inspect `.toInsert`, `.toUpdate`, `.toDelete`, `.toPublish` |
| `harness.getBeforePhaseHelper()` | `ITriggerHelper` instance from the before phase |
| `harness.getAfterPhaseHelper()` | `ITriggerHelper` instance from the after phase |

Records passed to `doUpdate`, `doDelete`, `doUndelete` must already have Ids. Use `TestUtility.generateFakeId(SObjectType)` for in-memory Ids, or insert dependent/parent records in `@TestSetup` and read their Ids.

---

## Claude Code skills

If you have cloned the TriggerHelper repository as a peer to this project, you can link the authoring skills:

```bash
# From your project root
ln -s ../TriggerHelper/.claude/skills/triggerhelper-write-helper .claude/skills/
ln -s ../TriggerHelper/.claude/skills/triggerhelper-unit-tests .claude/skills/
```

Then invoke them as:
- `/triggerhelper-write-helper` — generates a helper class + trigger + CMT stub for a given SObject and use case
- `/triggerhelper-unit-tests` — generates a test class using `TestTriggerHelperHarness` for an existing helper

To keep framework documentation current in your project's `CLAUDE.md`, add this import (adjust relative path if your layout differs):

```
@../TriggerHelper/CLAUDE-framework-adopter.md
```
