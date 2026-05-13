# TriggerHelper Lookup Topic Authoring Skill

Generates or updates a `TriggerLookupTopic__mdt` record for use with `LookupDataHandler`.
Handles all three topic types: Detail, RelatedList, and ExternalId.

## Invocation Forms

```
/triggerhelper-write-lookup-topic <description>
/triggerhelper-write-lookup-topic          (prompts for requirements)
```

## Step 1 — Gather Requirements

If no description is provided, ask:
> "Describe the lookup you need. Include: the SObject being queried, what key you're
> looking up by (a Salesforce Id field, a related Id field, or a string external key),
> and what fields you need back."

Determine and confirm:
- **SObject** being queried (the `FROM` object)
- **Key type** — which of the three topic types applies (see Step 2)
- **Fields** needed in the SELECT
- **Topic name** — suggest per convention (see Step 2), allow override
- **Additional WHERE filters** beyond the `:keySet` bind, if any

## Step 2 — Determine Topic Type and Name

### Detail (DETAIL)
- **When:** you have a Salesforce Id that is the *primary key* of the target object.
  e.g. `Case.OwnerId` → look up the `User` record.
- **Query form:** `SELECT <fields> FROM <SObject> WHERE Id IN :keySet`
- **`KeyFieldname__c`:** leave null — the framework keys the result map by `Id` implicitly.
- **Topic name convention:** the SObject API name. e.g. `User`, `Account`, `Queue`.
  This is the name the framework uses automatically when you call `requestItemDetail(id)`.

### RelatedList (RELATED)
- **When:** you have the *primary key* of a parent and want its child records.
  e.g. `Case.Id` → get all `CaseMilestone` records for that case.
- **Query form:** `SELECT <fields> FROM <ChildSObject> WHERE <ParentIdField> IN :keySet`
- **`KeyFieldname__c`:** the foreign-key field on the child object (e.g. `CaseId`). This
  field **must** appear in the SELECT — the framework uses it to group results by parent.
- **Topic name convention:** `Related<ChildSObjectName>`. e.g. `RelatedCaseMilestones`.

#### RelatedList variant — Aggregate queries
Use this when you want aggregate results grouped by a Salesforce Id field (e.g. count of
child records per owner, sum per account). The framework's RelatedList path supports this
without any code changes — `AggregateResult.get(fieldName)` preserves native types, so
the `(Id)` cast on `KeyFieldname__c` works cleanly.

- **Query form:** `SELECT <keyIdField>, <AGG_FUNC>(<field>) <alias> [, ...] FROM <SObject> WHERE <keyIdField> IN :keySet GROUP BY <keyIdField>`
- **`KeyFieldname__c`:** the grouped Id field (e.g. `OwnerId`). Must appear in SELECT and in GROUP BY.
- **`SObjectTypeName__c`:** `AggregateResult` (not the queried SObject name).
- **`Id` must NOT appear in SELECT** — aggregate queries do not return `Id`.
- **Alias all aggregate columns** — e.g. `COUNT(Id) recordCount`. Aliases are required for
  the caller to access values via `AggregateResult.get('alias')`.
- **Topic name convention:** functional description, not `Related<SObject>`. e.g. `AccountsOwnedBy`, `OpportunitiesByOwner`.
- **Consumer pattern:** `getDataSetForRelatedListTopic` returns `Map<Id, List<SObject>>` with
  one-element lists (one aggregate row per key value). The primary use is an existence check —
  `resultsMap.containsKey(ownerId)` — but alias values are accessible if needed:
  ```apex
  AggregateResult ar = (AggregateResult) resultsMap.get(ownerId)[0];
  Integer count = (Integer) ar.get('recordCount');
  ```

### ExternalId (EXTERNALID)
- **When:** you have a string value (not a Salesforce Id) that matches a unique field on
  the target object. e.g. a `StockKeepingUnit` or `FederationIdentifier`.
- **Query form:** `SELECT <fields> FROM <SObject> WHERE <ExternalIdField> IN :keySet`
- **`KeyFieldname__c`:** the string field used as the key (e.g. `StockKeepingUnit`,
  `FederationIdentifier`). This field **must** appear in the SELECT.
- **Topic name convention:** freeform, but descriptive. e.g. `UserByFederationId`.

## Step 3 — Check for Existing Topic

Before generating a new record, scan local source files for an existing topic with the
same name and `Context__c = Production`:

```bash
grep -rl "<value.*>Production</value>" force-app/main/default/customMetadata/TriggerLookupTopic.*.md-meta.xml 2>/dev/null \
  | xargs grep -l "<value.*><TopicName></value>" 2>/dev/null
```

Also check the framework repo as a fallback:
```bash
grep -rl "<value.*>Production</value>" ../TriggerHelper/force-app/main/default/customMetadata/TriggerLookupTopic.*.md-meta.xml 2>/dev/null \
  | xargs grep -l "<value.*><TopicName></value>" 2>/dev/null
```

**If the topic already exists:**
- Read the existing file.
- Merge the requested fields into the SELECT field list — the result is the union of all
  fields. Do not change the WHERE clause, ORDER BY, or any other part of the query.
- Warn the user: "Verify the merged query in Developer Console or Query Editor before
  deploying — field validity cannot be confirmed from metadata alone."
- Update the file in place.

**If the topic does not exist:** proceed to generate a new record.

## Step 4 — Construct the Query Template

Rules that must hold for every generated query:
1. `:keySet` is the only bind variable — it is bound by the framework, never by the helper.
2. For **RelatedList** and **ExternalId**, the `KeyFieldname__c` field must appear in the SELECT.
3. The WHERE clause must filter on `:keySet`:
   - Detail/RelatedList: `WHERE <keyField> IN :keySet`
   - ExternalId: `WHERE <externalIdField> IN :keySet`
4. `Id` should always be in the SELECT — **except aggregate queries**, where `Id` must be omitted.
5. Additional WHERE filters are appended with `AND`.
6. For aggregate queries: every aggregate function must have a named alias; the grouped field must appear in both SELECT and GROUP BY.

Validate the query structure mentally before generating:
- Every field in SELECT is a real API field name (confirm with user if uncertain).
- The FROM object matches the SObject being queried.
- `:keySet` appears exactly once in the WHERE clause.

## Step 5 — Generate the CMT Record

Use an existing `TriggerLookupTopic__mdt` record as the canonical format template.
Check local project first, then fall back to the framework repo:

```bash
ls force-app/main/default/customMetadata/TriggerLookupTopic.*.md-meta.xml 2>/dev/null | head -1
ls ../TriggerHelper/force-app/main/default/customMetadata/TriggerLookupTopic.*.md-meta.xml 2>/dev/null | head -1
```

Read whichever is found first and use it for correct namespaces, field order, and value types.

**File naming:** `TriggerLookupTopic.<RecordName>.md-meta.xml`
- Record name should be descriptive and unique. Suggested: `<TopicName>` for the first
  production record on a topic (e.g. `User`, `RelatedCaseMilestones`).

**Field values:**

| Field | Detail | RelatedList | ExternalId |
|-------|--------|-------------|------------|
| `Topic__c` | SObject API name (e.g. `User`) | `Related<ChildSObject>` | Descriptive name |
| `TopicType__c` | `Detail` | `RelatedList` | `ExternalId` |
| `SObjectTypeName__c` | SObject API name | Child SObject API name | SObject API name |
| `KeyFieldname__c` | `xsi:nil="true"` | Parent Id field on child (e.g. `CaseId`) | String key field (e.g. `FederationIdentifier`) |
| `QueryTemplate__c` | Constructed query | Constructed query | Constructed query |
| `Context__c` | `Production` | `Production` | `Production` |

Example — Detail (User):
```xml
<!-- force-app/main/default/customMetadata/TriggerLookupTopic.User.md-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>User</label>
    <protected>false</protected>
    <values>
        <field>Context__c</field>
        <value xsi:type="xsd:string">Production</value>
    </values>
    <values>
        <field>KeyFieldname__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>QueryTemplate__c</field>
        <value xsi:type="xsd:string">SELECT Id, Name, Email FROM User WHERE Id IN :keySet</value>
    </values>
    <values>
        <field>SObjectTypeName__c</field>
        <value xsi:type="xsd:string">User</value>
    </values>
    <values>
        <field>TopicType__c</field>
        <value xsi:type="xsd:string">Detail</value>
    </values>
    <values>
        <field>Topic__c</field>
        <value xsi:type="xsd:string">User</value>
    </values>
</CustomMetadata>
```

Example — RelatedList (CaseMilestones):
```xml
<!-- force-app/main/default/customMetadata/TriggerLookupTopic.RelatedCaseMilestones.md-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Related Case Milestones</label>
    <protected>false</protected>
    <values>
        <field>Context__c</field>
        <value xsi:type="xsd:string">Production</value>
    </values>
    <values>
        <field>KeyFieldname__c</field>
        <value xsi:type="xsd:string">CaseId</value>
    </values>
    <values>
        <field>QueryTemplate__c</field>
        <value xsi:type="xsd:string">SELECT Id, CaseId, MilestoneTypeId FROM CaseMilestone WHERE CaseId IN :keySet</value>
    </values>
    <values>
        <field>SObjectTypeName__c</field>
        <value xsi:type="xsd:string">CaseMilestone</value>
    </values>
    <values>
        <field>TopicType__c</field>
        <value xsi:type="xsd:string">RelatedList</value>
    </values>
    <values>
        <field>Topic__c</field>
        <value xsi:type="xsd:string">RelatedCaseMilestones</value>
    </values>
</CustomMetadata>
```

Example — RelatedList Aggregate (Account count by owner):
```xml
<!-- force-app/main/default/customMetadata/TriggerLookupTopic.AccountsOwnedBy.md-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Accounts Owned By</label>
    <protected>false</protected>
    <values>
        <field>Context__c</field>
        <value xsi:type="xsd:string">Production</value>
    </values>
    <values>
        <field>KeyFieldname__c</field>
        <value xsi:type="xsd:string">OwnerId</value>
    </values>
    <values>
        <field>QueryTemplate__c</field>
        <value xsi:type="xsd:string">SELECT OwnerId, COUNT(Id) accountCount FROM Account WHERE OwnerId IN :keySet GROUP BY OwnerId</value>
    </values>
    <values>
        <field>SObjectTypeName__c</field>
        <value xsi:type="xsd:string">AggregateResult</value>
    </values>
    <values>
        <field>TopicType__c</field>
        <value xsi:type="xsd:string">RelatedList</value>
    </values>
    <values>
        <field>Topic__c</field>
        <value xsi:type="xsd:string">AccountsOwnedBy</value>
    </values>
</CustomMetadata>
```

Example — ExternalId (User by FederationIdentifier):
```xml
<!-- force-app/main/default/customMetadata/TriggerLookupTopic.UserByFederationId.md-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>User By Federation Id</label>
    <protected>false</protected>
    <values>
        <field>Context__c</field>
        <value xsi:type="xsd:string">Production</value>
    </values>
    <values>
        <field>KeyFieldname__c</field>
        <value xsi:type="xsd:string">FederationIdentifier</value>
    </values>
    <values>
        <field>QueryTemplate__c</field>
        <value xsi:type="xsd:string">SELECT Id, FederationIdentifier, Name FROM User WHERE FederationIdentifier IN :keySet</value>
    </values>
    <values>
        <field>SObjectTypeName__c</field>
        <value xsi:type="xsd:string">User</value>
    </values>
    <values>
        <field>TopicType__c</field>
        <value xsi:type="xsd:string">ExternalId</value>
    </values>
    <values>
        <field>Topic__c</field>
        <value xsi:type="xsd:string">UserByFederationId</value>
    </values>
</CustomMetadata>
```

## Step 6 — Self-Review Checklist

- [ ] Topic type correctly identified (Detail / RelatedList / ExternalId)
- [ ] Topic name follows convention (suggested, confirmed with user if overridden)
- [ ] `:keySet` appears exactly once in the WHERE clause
- [ ] `KeyFieldname__c` is null for Detail; set and present in SELECT for RelatedList and ExternalId
- [ ] `Id` is in the SELECT
- [ ] `Context__c = Production`
- [ ] If topic existed: only SELECT field list was changed; user warned to validate query
- [ ] XML format matches the canonical template from local or framework source files
- [ ] If aggregate: `Id` is absent from SELECT; GROUP BY includes `KeyFieldname__c`; all aggregate functions have named aliases; `SObjectTypeName__c` = `AggregateResult`
