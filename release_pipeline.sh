#!/bin/bash
set -euxo pipefail

LOGFILE="release_pipeline.log"
PROGRESS_FILE="release_pipeline.progress"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load properties
if [[ ! -f "$SCRIPT_DIR/project.properties" ]]; then
  echo "❌ project.properties not found."
  exit 1
fi
while IFS='=' read -r key value; do
  key=$(echo "$key" | xargs)
  value=$(echo "$value" | xargs)
  [[ "$key" == \#* ]] || [[ -z "$key" ]] && continue
  export "$key"="$value"
done < "$SCRIPT_DIR/project.properties"

exec > >(tee -i "$LOGFILE") 2>&1

function step_done() { grep -Fxq "$1" "$PROGRESS_FILE" 2>/dev/null; }
function mark_step_done() { echo "$1" >> "$PROGRESS_FILE"; }

echo "🚀 TriggerHelper Release Pipeline"
echo "Branch: $(git branch --show-current)"

# ── Step 1: Local scratch org cycle ──────────────────────────────────────────
STEP="local_scratch_cycle"
if step_done "$STEP"; then
  echo "✅ $STEP already done. Skipping."
else
  echo "🔧 Step 1: Local scratch org cycle..."
  rm -f "$SCRIPT_DIR/progress.control"
  "$SCRIPT_DIR/dev_scratch_cycle.sh"
  mark_step_done "$STEP"
fi

# ── Step 2: Package version create ───────────────────────────────────────────
STEP="package_version_create"
if step_done "$STEP"; then
  echo "✅ $STEP already done. Skipping."
else
  echo "📦 Step 2: Creating new package version..."
  "$SCRIPT_DIR/publish_package_version.sh"
  # sfdx-project.json is updated by the CLI — re-read the new alias+id
  mark_step_done "$STEP"
fi

NEW_ALIAS=$(node "$SCRIPT_DIR/get_latest_package_version.js")
NEW_ID=$(node "$SCRIPT_DIR/get_latest_package_version.js" --id)
echo "📌 New version: $NEW_ALIAS ($NEW_ID)"

# ── Step 3: Package install test (scratch org) ───────────────────────────────
STEP="package_install_test"
if step_done "$STEP"; then
  echo "✅ $STEP already done. Skipping."
else
  echo "🧪 Step 3: Package install test in scratch org..."
  rm -f "$SCRIPT_DIR/package_install_test.progress"
  "$SCRIPT_DIR/package_install_test.sh"
  mark_step_done "$STEP"
fi

# ── Step 4: Install in PLATQA ────────────────────────────────────────────────
STEP="platqa_install"
if step_done "$STEP"; then
  echo "✅ $STEP already done. Skipping."
else
  echo "📦 Step 4: Installing $NEW_ID in PLATQA..."
  sf package install \
    --package "$NEW_ID" \
    --target-org PLATQA \
    --wait 20 \
    --publish-wait 10 \
    --no-prompt
  mark_step_done "$STEP"
fi

# ── Step 5: Run package tests in PLATQA, filter to package classes ────────────
STEP="platqa_test"
if step_done "$STEP"; then
  echo "✅ $STEP already done. Skipping."
else
  echo "🧪 Step 5: Running package tests in PLATQA..."
  TEST_CLASSES="AbstractBasePETriggerHelperTest,AbstractBaseTriggerHandlerTest,AbstractBaseTriggerHelperTest,DesignByContractUtilTest,LoggingUtilityTest,LookupDataHandlerTest,QueryTopicFactoryTest,StandardPlatformEventTriggerHandlerTest,StandardSObjectTriggerHandlerTest,TestTriggerHelperHarnessTest,TriggerDispatcherTest,TriggerDMLHandlerTest,TriggerHelperFactoryTest"
  sf apex run test \
    --target-org PLATQA \
    --class-names "$TEST_CLASSES" \
    --result-format json \
    --wait 20 \
    --output-dir "$SCRIPT_DIR/.platqa_test_results" \
    || true  # don't abort on non-zero; we parse results ourselves

  # Find the result JSON and evaluate package-owned failures only
  RESULT_JSON=$(find "$SCRIPT_DIR/.platqa_test_results" -name "*.json" | head -1)
  node "$SCRIPT_DIR/check_package_test_results.js" < "$RESULT_JSON"

  mark_step_done "$STEP"
fi

# ── Step 6: Promote package version ──────────────────────────────────────────
STEP="promote"
if step_done "$STEP"; then
  echo "✅ $STEP already done. Skipping."
else
  echo "🎉 Step 6: Promoting $NEW_ID to released..."
  "$SCRIPT_DIR/promote_package_version.sh"
  mark_step_done "$STEP"
fi

# ── Step 7: Commit and open PR ───────────────────────────────────────────────
STEP="pr"
if step_done "$STEP"; then
  echo "✅ $STEP already done. Skipping."
else
  echo "📝 Step 7: Committing changes and opening PR..."
  BRANCH=$(git branch --show-current)

  git add \
    force-app/main/default/classes/TriggerHelperFactoryTest.cls \
    force-app/main/default/classes/TriggerHelperFactory.cls \
    force-app/main/default/classes/TestUtility.cls \
    sfdx-project.json \
    README.md \
    .gitignore \
    project.properties \
    get_latest_package_version.js \
    package_install_test.sh \
    promote_package_version.sh \
    release_pipeline.sh \
    check_package_test_results.js

  git commit -m "$(cat <<'EOF'
Fix pilot mode permission tests to survive 2GP install auto-grant

Sysadmin profiles receive FF_TriggerHelperPilot automatically on 2GP
package install, breaking negative-assertion tests. Fixes:
- assignFeatureFlag() now creates a fresh PermissionSet + SetupEntityAccess
  rather than querying an existing one (required for runAs recalc)
- Negative tests run as a Standard User (no Customize Application = no auto-grant)
- Test user email domain derived from running user to pass org domain restrictions
- FF_TriggerHelperPilot_Logging__c reads getOrgDefaults() in production and tests
  so logging setting is visible to all users, not just the sysadmin

Also adds release tooling: package_install_test.sh, promote_package_version.sh,
release_pipeline.sh, get_latest_package_version.js, check_package_test_results.js
EOF
)"

  git push -u origin "$BRANCH"

  gh pr create \
    --title "Fix pilot mode permission tests for 2GP package install" \
    --body "$(cat <<'EOF'
## Summary
- `assignFeatureFlag()` in `TestUtility` now creates a fresh `PermissionSet` + `SetupEntityAccess` so `FeatureManagement.checkPermission()` recalculates correctly inside `System.runAs()`
- Negative pilot-mode tests (`userNotInPilot`, `userInPilotAndDebugModeOn`, `userInPilotAndDebugModeOff`) run as a Standard User — sysadmin profiles receive `FF_TriggerHelperPilot` automatically on 2GP install and cannot assert `checkPermission == false`
- Test user email domain is derived from `UserInfo.getUserEmail()` to satisfy org-level email domain restrictions (found in PLATQA)
- `FF_TriggerHelperPilot_Logging__c` changed from `getInstance()` to `getOrgDefaults()` in both `TriggerHelperFactory` and the test class — logging was invisible to non-sysadmin users
- Adds `release_pipeline.sh` for end-to-end scratch → publish → install-test → PLATQA → promote → PR automation

## Test plan
- [x] Local scratch org cycle (all 1382 tests pass)
- [x] Package version create (passes packaging org test run)
- [x] Package install test in clean scratch org
- [x] Installed and tested in PLATQA — no package-owned test failures
- [x] Version promoted to released
EOF
)"

  mark_step_done "$STEP"
fi

echo "✅ Release pipeline complete. Clearing progress."
rm -f "$PROGRESS_FILE"
