#!/bin/bash
set -euxo pipefail

LOGFILE="package_install_test.log"
PROGRESS_FILE="package_install_test.progress"

# Load properties
if [[ ! -f project.properties ]]; then
  echo "❌ project.properties file not found! Please create it before running this script."
  exit 1
fi

while IFS='=' read -r key value; do
  key=$(echo "$key" | xargs)
  value=$(echo "$value" | xargs)
  if [[ "$key" == \#* ]] || [[ -z "$key" ]]; then
    continue
  fi
  export "$key"="$value"
done < project.properties

exec > >(tee -i "$LOGFILE") 2>&1

echo "🚀 Starting TriggerHelperFramework Package Install Test..."
echo "Install test org alias: $INSTALL_TEST_ALIAS"

# Helper: check if step done
function step_done() {
  grep -Fxq "$1" "$PROGRESS_FILE" 2>/dev/null
}

# Helper: mark step done
function mark_step_done() {
  echo "$1" >> "$PROGRESS_FILE"
}

# Step 1 — Create scratch org
STEP="create_scratch_org"
if step_done "$STEP"; then
  echo "✅ Step $STEP already completed. Skipping."
else
  echo "🔧 Creating scratch org..."
  sf org create scratch \
    --definition-file "$SCRATCH_DEF_FILE" \
    --alias "$INSTALL_TEST_ALIAS" \
    --duration-days "$SCRATCH_DURATION" \
    --target-dev-hub "$DEV_HUB_ALIAS" \
    --set-default
  mark_step_done "$STEP"
fi

# Step 2 — Install Nebula Logger dependency
STEP="install_nebula_logger"
if step_done "$STEP"; then
  echo "✅ Step $STEP already completed. Skipping."
else
  echo "📦 Installing Nebula Logger ($NEBULA_ALIAS)..."
  sf package install \
    --package "$NEBULA_ALIAS" \
    --target-org "$INSTALL_TEST_ALIAS" \
    --wait 10 \
    --publish-wait 10 \
    --no-prompt
  mark_step_done "$STEP"
fi

# Step 3 — Install latest published TriggerHelperFramework package version
STEP="package_version_install_test"
if step_done "$STEP"; then
  echo "✅ Step $STEP already completed. Skipping."
else
  LATEST_TF_VERSION_ALIAS=$(node "$(dirname "$0")/get_latest_package_version.js")
  echo "📦 Installing TriggerHelper Published ($LATEST_TF_VERSION_ALIAS) ..."
  sf package install \
    --package "$LATEST_TF_VERSION_ALIAS" \
    --target-org "$INSTALL_TEST_ALIAS" \
    --wait 10 \
    --publish-wait 10 \
    --no-prompt
  mark_step_done "$STEP"
fi

# Step 4 — Run Apex tests in the installed package context
STEP="run_tests"
if step_done "$STEP"; then
  echo "✅ Step $STEP already completed. Skipping."
else
  echo "🧪 Running Apex tests against installed package..."
  sf apex run test \
    --target-org "$INSTALL_TEST_ALIAS" \
    --test-level RunLocalTests \
    --code-coverage \
    --result-format human \
    --wait 20
  mark_step_done "$STEP"
fi

# Step 6 — Delete scratch org
STEP="delete_scratch_org"
if step_done "$STEP"; then
  echo "✅ Step $STEP already completed. Skipping."
else
  echo "🗑️ Deleting scratch org..."
  sf org delete scratch --target-org "$INSTALL_TEST_ALIAS" --no-prompt
  mark_step_done "$STEP"
fi

# If all steps completed, clear progress for next run
echo "✅ Scratch org cycle complete. Clearing progress file."
rm -f "$PROGRESS_FILE"
