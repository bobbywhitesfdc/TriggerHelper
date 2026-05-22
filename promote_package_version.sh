#!/bin/bash
set -euxo pipefail

LOGFILE="promote_package_version.log"

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

SCRIPT_DIR="$(dirname "$0")"
LATEST_ALIAS=$(node "$SCRIPT_DIR/get_latest_package_version.js")
LATEST_ID=$(node "$SCRIPT_DIR/get_latest_package_version.js" --id)

echo "🚀 Promoting TriggerHelperFramework package version..."
echo "  Alias : $LATEST_ALIAS"
echo "  04t ID: $LATEST_ID"

# Promote the package version (removes Beta status)
sf package version promote \
  --package "$LATEST_ID" \
  --target-dev-hub "$DEV_HUB_ALIAS" \
  --no-prompt

# Update all 04t references in README.md
README="$SCRIPT_DIR/README.md"
OLD_ID=$(grep -o '04t[A-Za-z0-9]\+' "$README" | head -1)

if [[ "$OLD_ID" == "$LATEST_ID" ]]; then
  echo "✅ README.md already references $LATEST_ID — no update needed."
else
  echo "📝 Updating README.md: $OLD_ID → $LATEST_ID"
  sed -i '' "s/$OLD_ID/$LATEST_ID/g" "$README"
  echo "✅ README.md updated."
fi
