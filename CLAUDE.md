# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Full scratch org cycle (create → deploy → test → delete):**
```bash
./dev_scratch_cycle.sh
```
Configuration in `project.properties` (`DEV_HUB_ALIAS`, `SCRATCH_ALIAS`, `NEBULA_ALIAS`).

**Deploy source to existing scratch org:**
```bash
sf project deploy start --target-org THF_DEV
```

**Run all Apex tests:**
```bash
sf apex test run --target-org THF_DEV --synchronous --result-format human
```

**Run a single test class:**
```bash
sf apex test run --target-org THF_DEV --class-names TriggerHelperFactoryTest --synchronous --result-format human
```

**Lint / format:**
```bash
npm run prettier          # format in place
npm run prettier:verify   # check only (CI-style)
```

**Publish unlocked package version:**
```bash
./publish_package_version.sh
```

## Architecture

Every trigger calls `TriggerDispatcher.run()` — that's the only line in a trigger file.

**Dispatch chain:**
```
TriggerDispatcher.run()
  → TriggerHandlerFactory (routes SObjectType → StandardSObjectTriggerHandler or StandardPlatformEventTriggerHandler)
  → TriggerHelperFactory (reads TriggerHelperConfig__mdt, filters by SObject + Context + pilot mode, instantiates helpers in ExecutionSequence order)
  → AbstractBaseTriggerHandler.executeTriggerPhase()
      1. helper.preview*()          — register SOQL topics with LookupDataHandler
      2. QueryTopicFactory          — loads TriggerLookupTopic__mdt, executes batch queries
      3. helper.meetsEntryCriteria*() — per-record gate
      4. helper.processRecord*()    — per-record business logic (DML deferred via TriggerDMLHandler)
      5. helper.finalize*()         — cross-record aggregation
      6. TriggerDMLHandler.execute() — execute batched DML via DMLExecutor
```

**Key abstractions:**
- `ITriggerHelper` — contract for all helpers: `preview*`, `meetsEntryCriteria*`, `processRecord*`, `finalize*` per phase
- `AbstractBaseTriggerHelper` — no-op defaults; subclass and override only the methods needed
- `LookupDataHandler` — two bulk query patterns: (1) detail via Id lookup, (2) related list via foreign key
- `TriggerDMLHandler` — defers and batches DML by operation type; never do direct DML in helpers
- `TriggerHelperConfig__mdt` — wires helpers to objects (SObjectType, HelperClassName, ExecutionSequence, Context, IsPilotMode)
- `TriggerLookupTopic__mdt` — defines SOQL query templates (Topic, SObjectTypeName, KeyFieldname, QueryTemplate, TopicType, Context)

**Contexts:** CMT records carry a `Context__c` field. Production helpers use `Production`. Unit/factory tests use separate context values so test-only configs don't leak into production dispatch.

**Pilot mode:** Set `IsPilotMode__c = true` on a CMT record to gate that helper behind the `FF_TriggerHelperPilot` custom permission.

## Testing

Tests use `TestTriggerHelperHarness` — a subclass of `StandardSObjectTriggerHandler` that isolates a single helper and mocks DML execution. There is no live DML on the object under test; test records are built in memory only.

**Pattern:**
```apex
TestTriggerHelperHarness harness = new TestTriggerHelperHarness(new MyHelper());
harness.runBeforeInsert(records);          // or runAfterUpdate(newRecords, oldMap), etc.
MockDMLExecutor mockDml = harness.getMockDMLExecutor();
// Assert on mockDml.getInsertedRecords(), getUpdatedRecords(), etc.
```

- Use `TestUtility.generateFakeId(SObjectType)` for non-insert scenarios where real Ids are needed.
- `@TestSetup` is for dependent/lookup records only — never the target object.
- `TestDataFactory` for building SObject instances.
- Direct handler invocation (bypassing harness) is acceptable only for error/exception path tests.

## Claude Code Skills

Two project skills accelerate new helper and test authoring:

| Skill | Invocation | Output |
|-------|-----------|--------|
| `triggerhelper-write-helper` | `/triggerhelper-write-helper` | Helper class + trigger file + CMT stub |
| `triggerhelper-unit-tests` | `/triggerhelper-unit-tests` | Unit test class using `TestTriggerHelperHarness` |

Skills read the framework source directly. See `.claude/README.md` for prerequisites and permissions setup.

To avoid per-call prompts during the scratch org lifecycle, deploy, and GitHub PR workflow, merge the framework developer permissions snippet into your `~/.claude/settings.json`:

```sh
cat .claude/settings-snippet-framework-dev.json
```

## Conventions

- **No logging in helpers.** All logging goes through `LoggingUtility` (Nebula Logger wrapper), called from the handler layer.
- **No direct DML in helpers.** Queue everything through `getDMLHandler()`.
- **Narrow exceptions.** Throw specific typed exceptions, not `Exception`.
- **Bulk-safe queries.** Use `LookupDataHandler.request*` in `preview*` methods; never SOQL inside loops.
- `DesignByContractUtil` — use for precondition/postcondition assertions, not ad-hoc `if (x == null) throw`.

## Dependencies

- **Nebula Logger 4.16.5** — only external dependency; installed from package ID `04tKe0000011N4KIAU` during scratch org init.
- **Salesforce API version:** 62.0
- **Unlocked package:** TriggerHelperFramework (`0HoDn000000oM1cKAE`)
