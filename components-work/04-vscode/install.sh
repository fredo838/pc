#!/bin/bash
# Install VS Code work profile configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$HOME/.vscode-work"
USER_ROOT="$PROFILE_DIR/User"
EXTENSIONS_DIR="$HOME/.vscode-work-ext"
PROFILE_NAME="Work"
PROFILE_ICON="project"
STORAGE_FILE="$USER_ROOT/globalStorage/storage.json"

mkdir -p "$USER_ROOT"

if command -v code >/dev/null 2>&1; then
  mkdir -p "$EXTENSIONS_DIR"
  # Ensure the named profile exists in this user-data-dir.
  env NODE_NO_WARNINGS=1 command code --user-data-dir "$PROFILE_DIR" --extensions-dir "$EXTENSIONS_DIR" --profile "$PROFILE_NAME" --list-extensions >/dev/null 2>&1 || true
fi

PROFILE_DATA="$(python3 - "$STORAGE_FILE" "$PROFILE_NAME" "$PROFILE_ICON" <<'PY'
import hashlib
import json
import os
import sys

storage_file, profile_name, profile_icon = sys.argv[1], sys.argv[2], sys.argv[3]

data = {}
if os.path.exists(storage_file):
  with open(storage_file, "r", encoding="utf-8") as f:
    data = json.load(f)

profiles = data.get("userDataProfiles")
if not isinstance(profiles, list):
  profiles = []

legacy_profile_name = "Centrica"
legacy_locations = []
filtered_profiles = []
for candidate in profiles:
  if isinstance(candidate, dict) and candidate.get("name") == legacy_profile_name:
    location = candidate.get("location")
    if isinstance(location, str) and location:
      legacy_locations.append(location)
    continue
  filtered_profiles.append(candidate)
profiles = filtered_profiles

profile = None
for candidate in profiles:
  if isinstance(candidate, dict) and candidate.get("name") == profile_name:
    profile = candidate
    break

if profile is None:
  used_locations = {
    item.get("location")
    for item in profiles
    if isinstance(item, dict) and isinstance(item.get("location"), str)
  }
  location = hashlib.sha1(profile_name.encode("utf-8")).hexdigest()[:8]
  while location in used_locations:
    location = hashlib.sha1((location + profile_name).encode("utf-8")).hexdigest()[:8]
  profile = {"location": location, "name": profile_name, "icon": profile_icon}
  profiles.append(profile)
else:
  profile["icon"] = profile_icon

data["userDataProfiles"] = profiles

associations = data.get("profileAssociations")
if isinstance(associations, dict) and legacy_locations:
  workspace_map = associations.get("workspaces")
  if isinstance(workspace_map, dict):
    for key, value in list(workspace_map.items()):
      if value in legacy_locations:
        workspace_map[key] = profile.get("location")

  empty_map = associations.get("emptyWindows")
  if isinstance(empty_map, dict):
    for key, value in list(empty_map.items()):
      if value in legacy_locations:
        empty_map[key] = profile.get("location")

os.makedirs(os.path.dirname(storage_file), exist_ok=True)
with open(storage_file, "w", encoding="utf-8") as f:
  json.dump(data, f, indent=4)
  f.write("\n")

print(f"{profile.get('location', '')}|{','.join(legacy_locations)}")
PY
)"

PROFILE_ID="${PROFILE_DATA%%|*}"
LEGACY_IDS="${PROFILE_DATA#*|}"

if [ -z "$PROFILE_ID" ]; then
  echo "⚠ Failed to resolve VS Code profile id for $PROFILE_NAME"
  exit 1
fi

if [ -n "$LEGACY_IDS" ]; then
  IFS=',' read -r -a legacy_array <<< "$LEGACY_IDS"
  for legacy_id in "${legacy_array[@]}"; do
    if [ -n "$legacy_id" ] && [ -d "$USER_ROOT/profiles/$legacy_id" ]; then
      rm -rf "$USER_ROOT/profiles/$legacy_id"
      echo "✓ Removed legacy profile data: $legacy_id"
    fi
  done
fi

USER_DIR="$USER_ROOT/profiles/$PROFILE_ID"
mkdir -p "$USER_DIR"

echo "Installing work VS Code profile config to: $USER_DIR"
for filename in keybindings.json settings.json; do
  if [ -f "$SCRIPT_DIR/$filename" ]; then
    cp "$SCRIPT_DIR/$filename" "$USER_DIR/$filename"
    echo "✓ $filename"
  else
    echo "⚠ $filename not found in $SCRIPT_DIR"
  fi
done

# VS Code owns profile-level extensions.json with a strict schema.
# Keep recommendations only in this component directory for installation input.
if [ -f "$USER_DIR/extensions.json" ]; then
  rm -f "$USER_DIR/extensions.json"
fi

echo ""

echo "Installing work VS Code extensions to: $EXTENSIONS_DIR"
if command -v code >/dev/null 2>&1; then
  mkdir -p "$EXTENSIONS_DIR"
  python3 -c 'import json, sys; print("\n".join(json.load(open(sys.argv[1])).get("recommendations", [])))' "$SCRIPT_DIR/extensions.json" \
  | while IFS= read -r extension; do
    if [ -n "$extension" ]; then
      echo "Installing extension: $extension"
      output="$(env NODE_NO_WARNINGS=1 command code --user-data-dir "$PROFILE_DIR" --extensions-dir "$EXTENSIONS_DIR" --profile "$PROFILE_NAME" --install-extension "$extension" --force 2>&1)" || true
      if printf '%s\n' "$output" | grep -qE 'built-in extension .* cannot be downgraded|Failed Installing Extensions'; then
        echo "⚠ Skipping built-in/downgrade issue for extension: $extension"
      elif [ -n "$output" ]; then
        printf '%s\n' "$output"
      fi
    fi
  done
else
  echo "⚠ VS Code CLI 'code' not found; skipping extension installation."
fi

# Reconcile profile metadata after CLI operations because VS Code can rewrite
# storage.json while installing extensions.
python3 - "$STORAGE_FILE" "$PROFILE_NAME" "$PROFILE_ICON" <<'PY'
import json
import os
import sys

storage_file, profile_name, profile_icon = sys.argv[1], sys.argv[2], sys.argv[3]
if not os.path.exists(storage_file):
  raise SystemExit(0)

with open(storage_file, "r", encoding="utf-8") as f:
  data = json.load(f)

profiles = data.get("userDataProfiles")
if not isinstance(profiles, list):
  profiles = []

work_location = None
filtered = []
for profile in profiles:
  if not isinstance(profile, dict):
    continue
  if profile.get("name") == "Centrica":
    continue
  if profile.get("name") == profile_name:
    profile["icon"] = profile_icon
    work_location = profile.get("location")
  filtered.append(profile)

data["userDataProfiles"] = filtered

if work_location:
  associations = data.get("profileAssociations")
  if isinstance(associations, dict):
    workspace_map = associations.get("workspaces")
    if isinstance(workspace_map, dict):
      for key, value in list(workspace_map.items()):
        if value and isinstance(value, str) and value != work_location and value.startswith("-"):
          # Preserve only current Work association in this user-data-dir.
          if key.startswith("file:///Users/fred/centrica"):
            workspace_map[key] = work_location

with open(storage_file, "w", encoding="utf-8") as f:
  json.dump(data, f, indent=4)
  f.write("\n")
PY

echo ""
