#!/bin/bash
set -euxo pipefail

LOGFILE="public_package_version.log"

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

echo "🚀 Publish New TriggerHelperFramework version..."
echo "Using Dev Hub: $DEV_HUB_ALIAS"

sf package version create \
  --package "TriggerHelperFramework" \
  --installation-key-bypass \
  --code-coverage \
  --verbose \
  --target-dev-hub $DEV_HUB_ALIAS \
  --wait 20
