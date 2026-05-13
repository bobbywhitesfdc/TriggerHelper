# Claude Code — TriggerHelper Framework

This directory ships Claude Code skills and settings snippets for two personas:

| Persona | Who | Snippet | Skills |
|---------|-----|---------|--------|
| **Adopter** | Writing helpers in their own Salesforce project | `settings-snippet-adopter.json` | `triggerhelper-write-helper`, `triggerhelper-unit-tests`, `triggerhelper-write-lookup-topic` |
| **Framework Developer** | Contributing to this repo | `settings-snippet-framework-dev.json` | All of the above |

---

## Adopter setup

Adopters install the TriggerHelperFramework unlocked package and write helpers in their own Salesforce project repo. The skills accelerate helper and test authoring; the snippet eliminates per-call permission prompts for deploy and test operations.

### Prerequisites

| Tool | Install |
|------|---------|
| [Claude Code](https://claude.ai/code) | Follow Anthropic install guide |
| [Salesforce CLI (`sf`)](https://developer.salesforce.com/tools/salesforcecli) | `npm install -g @salesforce/cli` |
| Git | Pre-installed on macOS / Linux |

Authenticate your target org before first use:
```sh
sf org login web --alias MY_ORG
```

### Permissions

Merge the `permissions.allow` entries from `settings-snippet-adopter.json` into your `~/.claude/settings.json`. This covers `sf project deploy start`, `sf apex test run`, `sf data query`, and standard read-only shell commands.

```sh
cat .claude/settings-snippet-adopter.json
```

### Skills

| Skill | Invocation | Purpose |
|-------|-----------|---------|
| `triggerhelper-write-helper` | `/triggerhelper-write-helper` | Generate a framework-conformant helper class, trigger file, and CMT metadata stub from a description of your business logic |
| `triggerhelper-unit-tests` | `/triggerhelper-unit-tests` | Generate a production-ready unit test class using `TestTriggerHelperHarness` |
| `triggerhelper-write-lookup-topic` | `/triggerhelper-write-lookup-topic` | Generate a `TriggerLookupTopic__mdt` CMT record for a new query topic |

If your project repo is a peer to this one, symlink the skills:
```sh
# From your project root
ln -s ../TriggerHelper/.claude/skills/triggerhelper-write-helper .claude/skills/
ln -s ../TriggerHelper/.claude/skills/triggerhelper-unit-tests .claude/skills/
ln -s ../TriggerHelper/.claude/skills/triggerhelper-write-lookup-topic .claude/skills/
```

To keep framework documentation current in your project's `CLAUDE.md`:
```
@../TriggerHelper/CLAUDE-framework-adopter.md
```

---

## Framework developer setup

Framework developers work directly in this repo — authoring framework classes, publishing package versions, and managing the scratch org lifecycle.

### Additional prerequisites

| Tool | Install |
|------|---------|
| [GitHub CLI (`gh`)](https://cli.github.com) | `brew install gh` then `gh auth login` |
| Salesforce Dev Hub | Authorized org with `DevHub` enabled, aliased `DEVHUB` |

### Permissions

Merge `settings-snippet-framework-dev.json` into your `~/.claude/settings.json`. This is a superset of the adopter snippet and adds scratch org lifecycle (`sf org create scratch`, `sf org delete scratch`, `sf package install`), anonymous Apex (`sf apex run`), and the GitHub PR workflow (`gh pr create`, `gh pr edit`).

```sh
cat .claude/settings-snippet-framework-dev.json
```

### Scratch org cycle

```sh
./dev_scratch_cycle.sh
```

Configuration lives in `project.properties` (`DEV_HUB_ALIAS`, `SCRATCH_ALIAS`, `NEBULA_ALIAS`). The script is resumable — it tracks completed steps in `progress.control`.

### Publishing a package version

```sh
./publish_package_version.sh
```

---

## Contributing skills improvements

Skills live in `.claude/skills/` as plain Markdown — no build step required. If a framework API change makes a skill instruction incorrect, update the relevant `SKILL.md` and open a PR against `main` in the same commit as the API change.
