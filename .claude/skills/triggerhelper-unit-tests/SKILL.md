# TriggerHelper Unit Test Authoring Skill

Generates production-ready Apex unit tests for TriggerHelper implementations using
the `TestTriggerHelperHarness` framework. Tests are pure unit tests: no live DML on
the object under test, helpers exercised in isolation from the full trigger stack.

## Invocation Forms

```
/triggerhelper-unit-tests <HelperClassName>
/triggerhelper-unit-tests <HelperClassName> --scenarios <comma-list>
/triggerhelper-unit-tests          (prompts for scope)
```

## Step 1 — Identify the Helper Under Test

Accept the helper class name from the invocation argument, or ask:
> "Which TriggerHelper class needs a test class? Provide the Apex class name."

Read the helper source file from the project:
- Search under `force-app/main/default/classes/<HelperClassName>.cls`
- If not found, ask the user to supply the path.

Also read (framework reference — relative to this repo root):
- `force-app/main/default/classes/TestTriggerHelperHarness.cls` — harness API
- `force-app/main/default/classes/AbstractBaseTriggerHandler.cls` — dispatcher lifecycle (error handling, addError contract)
- `force-app/main/default/classes/LookupDataHandler.cls` — query API (requestExternalId / getExternalId / requestItemDetail / getItemDetail)
- `force-app/main/default/classes/TestUtility.cls` — fake Id generation
- `force-app/main/default/classes/MockDMLExecutor.cls` — DML mock

## Step 2 — Analyse the Helper

For each overridden lifecycle method, determine:

| Method | Questions to answer |
|--------|---------------------|
| `previewBeforeInsert` | What lookup topics are requested, and under what conditions? |
| `meetsEntryCriteriaBeforeInsert` | What field/state combinations return true vs. false? |
| `processRecordBeforeInsert` | What mutations happen? What error path exists? |
| `finalizeBeforeInsert` | Any deferred work (platform events, DML)? |
| (same pattern for Update, Delete, Undelete phases) | |

Enumerate all observable outcomes that need separate named tests. Include:
- Happy-path scenarios (each branch through `processRecord`)
- Entry-criteria negative path (record skipped entirely)
- Error/fault paths where an exception is expected
- Bulk scenarios where ordering-sensitive logic could break

## Step 3 — Determine the LookupDataHandler Strategy

Check whether the helper calls `requestExternalId` / `getExternalId` or
`requestItemDetail` / `getItemDetail`.

**Key rule — match the API to the key type:**
- **Salesforce Id** (foreign key / lookup field value) → `requestItemDetail(id)` / `getItemDetail(id)`
- **String external identifier** (e.g. `Group.DeveloperName`, `Product2.StockKeepingUnit`) → `requestExternalId(topic, key)` / `getExternalId(topic, key)`

Using the ExternalId API for a Salesforce Id (or vice versa) is a must-fix misuse.

**For ExternalId topics in tests:**
- `QueryTopicFactory.context` stays at its default (`'Production'`). Do not set it in test code — the `'UnitTest'` context is reserved for framework-internal tests only.
- The `TriggerLookupTopic__mdt` record for the topic (Production context) must be deployed to the org.
- Insert the target record (e.g. a `Group`) in `@TestSetup` so the live Production-context query resolves.

**For Id-based detail topics:**
- Insert the target SObject in `@TestSetup` and use its real Id.

**For the "lookup not found" path:**
- Do not insert the target record (or insert one with a different key).
- `getExternalId` / `getItemDetail` returns `null`, triggering the helper's error path.

### Lookup not-found assertion pattern (pending harness enhancement)

`AbstractBaseTriggerHandler.beforeInsert` catches exceptions thrown from
`processRecordBeforeInsert`, calls `LoggingUtility.logError(ex, true)`, and calls
`current.addError(ex.getMessage())`. Helpers must not log directly — they throw narrow,
meaningful exceptions and delegate all logging to the dispatcher.

Until the harness exposes a mechanism to inspect `addError` state on in-memory SObjects,
assert the error path by constructing the helper directly:

```apex
MyHelper helper = new MyHelper();
helper.setDataHandler(new LookupDataHandler()); // nothing inserted → returns null

try {
    helper.processRecordBeforeInsert(record);
    Assert.fail('Expected MyHelper.NotFoundException');
} catch (MyHelper.NotFoundException ex) {
    Assert.isTrue(ex.getMessage().contains('expected-key'),
        'Exception message must identify the missing record');
}
```

> **Open design note:** `addError` inspection on in-memory SObjects is a known harness
> gap. A future harness enhancement will expose this. When it ships, direct-invocation
> error tests should migrate to the harness pattern.

## Step 4 — Derive the Test Class Name

Apex class name limit: **40 characters**.

Convention: `<HelperClassName>Test` — if that exceeds 40 characters, abbreviate the
domain prefix (e.g. `FR` for `FulfillmentRequest`, `IS` for `InteractionSummary`).

| Helper class name | Length | Test class name |
|---|---|---|
| `FulfillmentRequestOwnerAssignmentHelper` | 39 ✓ | `FROwnerAssignmentHelperTest` (27) |
| `InteractionSummaryAdvisorTaskHelper` | 36 ✓ | `ISAdvisorTaskHelperTest` (23) |

## Step 5 — Design the Test Methods

Map every scenario to a method name using the `verb_outcome_when_condition` convention:

```
assignOwner_setsOwnerId_toAnalyst_whenOnlyAnalystPopulated
assignOwner_setsOwnerId_toConsultant_whenOnlyConsultantPopulated
assignOwner_doesNotAssign_whenStatusIsNotNew
assignOwner_logsError_whenQueueNotFound
assignOwner_bulkInsert_allPermutations_correctlyAssigned
```

If the user supplies `--scenarios`, validate against this list and flag any gaps.

## Step 6 — Write the Test Class

### Structure

```apex
/**
 * @description Unit tests for <HelperClassName>.
 *              Pure unit tests — no live DML on <ObjectApiName>.
 *              Helper exercised in isolation via TestTriggerHelperHarness.
 *
 * @author <author>
 * @date <YYYY-MM-DD>
 */
@IsTest
public class <TestClassName> {

    // ========================================================================
    // Test Setup
    // ========================================================================
    @TestSetup
    static void setup() {
        // Insert supporting records only (Users, Groups/Queues, related objects).
        // Never insert the object under test here.
    }

    // ========================================================================
    // Happy-Path Scenarios
    // ========================================================================

    @IsTest
    static void <scenarioMethodName>() {
        // Arrange
        <ObjectType> record = new <ObjectType>(...);
        // No insert — record stays in memory

        TestTriggerHelperHarness harness = new TestTriggerHelperHarness(<ObjectType>.SObjectType);
        harness.setDMLExecutor(new MockDMLExecutor());
        harness.setHelperUnderTest('<HelperClassName>');

        // Act
        Test.startTest();
        harness.doInsert(new List<SObject>{ record });
        Test.stopTest();

        // Assert — before-insert mutations are in-place on the original record list
        Assert.areEqual(expectedValue, record.<field>, '<assertion message>');
    }

    // ========================================================================
    // Entry-Criteria Negative Path
    // ========================================================================

    // ========================================================================
    // Error Path
    // ========================================================================
    // Direct-invocation pattern until harness addError inspection is available.

    // ========================================================================
    // Bulk
    // ========================================================================
}
```

### Rules enforced in generated code

1. **No `insert` on the object under test.** Records are constructed in-memory; `Id` set via `TestUtility.generateFakeId()` when needed for update/delete/undelete.

2. **No `Test.isRunningTest()` in production helper code.** Test isolation is achieved through harness mechanics, not production bypasses.

3. **No `@TestVisible` on constants or pure methods in the helper.** Test the public contract.

4. **`Assert.areEqual(expected, actual, message)` — never bare `System.assertEquals`.** Always include a descriptive message as the third argument.

5. **`Assert.isTrue` / `Assert.isFalse` — never bare `System.assert`.** Same message requirement.

6. **One scenario per method.** No multi-scenario test methods.

7. **`Test.startTest()` / `Test.stopTest()` wraps the Act step.**

8. **`@TestSetup` for shared supporting data only.** If a scenario needs unique state that conflicts with shared setup, use an inline local arrange block.

9. **Bulk test uses a mixed-permutation list** (all branches in a single harness call), asserting correct output for each permutation.

10. **Direct-invocation error tests** construct the helper directly, call the lifecycle method, and assert the exception type and message — no harness.

11. **Do not manipulate `QueryTopicFactory.context` in implementor tests.** The `'UnitTest'` context is reserved for framework-internal tests. Implementor tests run against the `'Production'` context (the default). The `TriggerLookupTopic__mdt` record for the topic must be deployed, and the target record inserted in `@TestSetup`.

### Asserting before-insert field mutations

Before-insert mutations are in-place on the original list reference:

```apex
List<SObject> records = new List<SObject>{ myRecord };
harness.doInsert(records);
Assert.areEqual(expectedValue, ((MyObject__c) records[0]).MyField__c,
    'Field must be set by helper');
```

### Records with Ids (update / delete / undelete)

```apex
Id fakeId = TestUtility.generateFakeId(MyObject__c.SObjectType);
MyObject__c record = new MyObject__c(Id = fakeId, ...);
harness.doUpdate(new List<SObject>{ record }, new List<SObject>{ oldRecord });
```

## Step 7 — Write the Output File

Write the test class to the project under test (not this framework repo):
```
force-app/main/default/classes/<TestClassName>.cls
force-app/main/default/classes/<TestClassName>.cls-meta.xml
```

Standard meta:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>66.0</apiVersion>
    <status>Active</status>
</ApexClass>
```

## Step 8 — Self-Review Checklist

- [ ] No `insert` of the object under test
- [ ] No `Test.isRunningTest()` anywhere
- [ ] No `@TestVisible` on helper constants or pure methods
- [ ] All `Assert.*` calls include a message argument
- [ ] Every scenario from Step 5 has a named method
- [ ] Bulk test covers all permutations in a single harness call
- [ ] Error-path tests use direct-invocation pattern with exception type + message assertions
- [ ] `QueryTopicFactory.context` NOT manipulated — Production context used, target record inserted in `@TestSetup`
- [ ] Test class name ≤ 40 characters
- [ ] LookupDataHandler API matches key type (Id → detail; string external key → externalId)
