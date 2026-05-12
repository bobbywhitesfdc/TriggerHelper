# Claude Code Skills — TriggerHelper Framework

This directory ships two Claude Code skills alongside the TriggerHelper framework.
When you open this repo in Claude Code, both skills are automatically available as
slash commands — no manual setup required beyond the prerequisites below.

## Skills

| Skill | Invocation | Purpose |
|-------|-----------|---------|
| `triggerhelper-write-helper` | `/triggerhelper-write-helper` | Generate a framework-conformant TriggerHelper implementation from a description of your business logic. Produces the helper class, trigger file, and CMT metadata stub. |
| `triggerhelper-unit-tests` | `/triggerhelper-unit-tests` | Generate a production-ready unit test class for an existing TriggerHelper using `TestTriggerHelperHarness`. Pure unit tests — no live DML on the object under test. |

## Prerequisites

| Tool | Required for | Install |
|------|-------------|---------|
| [Claude Code](https://claude.ai/code) | All skills | Follow Anthropic install guide |
| [Salesforce CLI (`sf`)](https://developer.salesforce.com/tools/salesforcecli) | Both skills (test execution) | `npm install -g @salesforce/cli` |
| Git | Both skills | Pre-installed on macOS / Linux |

Authenticate your target org before first use:
```sh
sf org login web --alias MY_ORG
```

## Permissions

The skills run `sf apex test run`, `grep`, and `find` via Claude Code's Bash tool.
Add the entries from `settings-snippet.json` to your `~/.claude/settings.json` to
allow these commands without per-call prompts:

```sh
# View the required snippet
cat .claude/settings-snippet.json
```

Merge the `permissions.allow` array into your existing settings file. If you don't
have a `~/.claude/settings.json` yet, you can copy the snippet as a starting point.

## How the skills work

Both skills read the framework source files (`TestTriggerHelperHarness.cls`,
`AbstractBaseTriggerHandler.cls`, `LookupDataHandler.cls`, etc.) directly from this
repo. There is no external path configuration required — the skills resolve all
framework references relative to the project root.

Your business logic files (`force-app/main/default/classes/MyHelper.cls`) can live in
this repo or in a separate Salesforce project repo. If in a separate repo, open that
project in Claude Code and invoke the skill from there — Claude Code will find this
repo's skills as long as this repo is a dependency or sibling directory. Alternatively,
copy the `.claude/skills/` folder into your project repo.

## Contributing skills improvements

The skills live in `.claude/skills/` and are plain Markdown — no build step required.

If a framework API change makes a skill instruction incorrect:
1. Update the relevant `SKILL.md`
2. Open a PR against `main` with a brief description of what changed and why
3. Skills are versioned with the framework — breaking API changes should update the
   skill in the same PR

If you develop a new skill for the framework (e.g. a query topic authoring skill, a
CMT management skill), contributions are welcome via the same PR process.
