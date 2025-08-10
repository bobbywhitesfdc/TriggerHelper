#!/bin/bash
set -euxo pipefail

LOGFILE="dev_scratch_cycle.log"
PROGRESS_FILE="progress.control"

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

echo "🚀 Starting TriggerHelperFramework scratch org cycle..."
echo "Using Dev Hub: $DEV_HUB_ALIAS"
echo "Scratch org alias: $SCRATCH_ALIAS"

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
    --alias "$SCRATCH_ALIAS" \
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
    --target-org "$SCRATCH_ALIAS" \
    --wait 10 \
    --publish-wait 10 \
    --no-prompt
  mark_step_done "$STEP"
fi

# Step 3 — Push TriggerHelperFramework source
STEP="push_source"
if step_done "$STEP"; then
  echo "✅ Step $STEP already completed. Skipping."
else
  echo "📤 Pushing TriggerHelperFramework source..."
  sf project deploy start --target-org "$SCRATCH_ALIAS"
  mark_step_done "$STEP"
fi

# Step 4 — Run Apex tests with code coverage
STEP="run_tests"
if step_done "$STEP"; then
  echo "✅ Step $STEP already completed. Skipping."
else
  echo "🧪 Running Apex tests..."
  sf apex run test \
    --target-org "$SCRATCH_ALIAS" \
    --code-coverage \
    --result-format human \
    --wait 20 
  mark_step_done "$STEP"
fi

# Step 5 — Delete scratch org
STEP="delete_scratch_org"
if step_done "$STEP"; then
  echo "✅ Step $STEP already completed. Skipping."
else
  echo "🗑️ Deleting scratch org..."
  sf org delete scratch --target-org "$SCRATCH_ALIAS" --no-prompt
  mark_step_done "$STEP"
fi

# If all steps completed, clear progress for next run
echo "✅ Scratch org cycle complete. Clearing progress file."
rm -f "$PROGRESS_FILE"
