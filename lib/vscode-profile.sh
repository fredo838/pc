#!/bin/bash
# Shared steps for installing a named VS Code profile into its own
# user-data-dir/extensions-dir. Sourced by the Personal and Work
# 04-vscode/install-{linux,macos}.sh scripts; must stay compatible with
# macOS's stock bash 3.2 (no mapfile, no ${var,,}).
#
# Callers set, before sourcing:
#   SCRIPT_DIR      component directory (settings.json, extensions.json, ...)
#   PROFILE_DIR     --user-data-dir
#   EXTENSIONS_DIR  --extensions-dir
#   PROFILE_NAME    profile name (e.g. Personal, Work)
#   PROFILE_ICON    profile codicon (e.g. heart, project)
# and define a `vscode_cli` function that runs the headless VS Code CLI with
# whatever binary/env that install needs (extra args are appended).
#
# Sourcing derives USER_ROOT and STORAGE_FILE; vscode_profile_register then
# sets PROFILE_ID and USER_DIR for the remaining steps.

USER_ROOT="$PROFILE_DIR/User"
STORAGE_FILE="$USER_ROOT/globalStorage/storage.json"

# Run the CLI scoped to this profile. stdin is closed so a CLI call inside a
# `while read` loop can never swallow the rest of the loop's input.
profile_cli() {
  vscode_cli --user-data-dir="$PROFILE_DIR" --extensions-dir="$EXTENSIONS_DIR" --profile="$PROFILE_NAME" "$@" < /dev/null
}

# Ensure the named profile exists in storage.json and set PROFILE_ID/USER_DIR.
# An optional legacy profile name is dropped from the profile list, its
# workspace/empty-window associations are moved over to this profile, and
# its profile data directory is deleted.
vscode_profile_register() {
  local legacy_name="${1:-}"

  mkdir -p "$USER_ROOT" "$EXTENSIONS_DIR"
  profile_cli --list-extensions >/dev/null 2>&1 || true

  local profile_data
  profile_data="$(python3 - "$STORAGE_FILE" "$PROFILE_NAME" "$PROFILE_ICON" "$legacy_name" <<'PY'
import hashlib
import json
import os
import sys

storage_file, profile_name, profile_icon, legacy_name = sys.argv[1:5]

data = {}
if os.path.exists(storage_file):
  with open(storage_file, "r", encoding="utf-8") as f:
    data = json.load(f)

profiles = data.get("userDataProfiles")
if not isinstance(profiles, list):
  profiles = []

legacy_locations = []
if legacy_name:
  filtered_profiles = []
  for candidate in profiles:
    if isinstance(candidate, dict) and candidate.get("name") == legacy_name:
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
  for map_name in ("workspaces", "emptyWindows"):
    assoc_map = associations.get(map_name)
    if isinstance(assoc_map, dict):
      for key, value in list(assoc_map.items()):
        if value in legacy_locations:
          assoc_map[key] = profile.get("location")

os.makedirs(os.path.dirname(storage_file), exist_ok=True)
with open(storage_file, "w", encoding="utf-8") as f:
  json.dump(data, f, indent=4)
  f.write("\n")

print(f"{profile.get('location', '')}|{','.join(legacy_locations)}")
PY
)"

  PROFILE_ID="${profile_data%%|*}"
  local legacy_ids="${profile_data#*|}"

  if [ -z "$PROFILE_ID" ]; then
    echo "⚠ Failed to resolve VS Code profile id for $PROFILE_NAME"
    exit 1
  fi

  if [ -n "$legacy_ids" ]; then
    local legacy_array legacy_id
    IFS=',' read -r -a legacy_array <<< "$legacy_ids"
    for legacy_id in "${legacy_array[@]}"; do
      if [ -n "$legacy_id" ] && [ -d "$USER_ROOT/profiles/$legacy_id" ]; then
        rm -rf "$USER_ROOT/profiles/$legacy_id"
        echo "✓ Removed legacy profile data: $legacy_id"
      fi
    done
  fi

  USER_DIR="$USER_ROOT/profiles/$PROFILE_ID"
  mkdir -p "$USER_DIR"
}

# Copy keybindings.json/settings.json from the component into the profile.
vscode_profile_copy_config() {
  echo "Installing $PROFILE_NAME VS Code profile config to: $USER_DIR"
  local filename
  for filename in keybindings.json settings.json; do
    if [ -f "$SCRIPT_DIR/$filename" ]; then
      cp "$SCRIPT_DIR/$filename" "$USER_DIR/$filename"
      echo "✓ $filename"
    else
      echo "⚠ $filename not found in $SCRIPT_DIR"
    fi
  done
}

# security.workspace.trust.enabled is an "application" scope setting in VS Code:
# such settings are shared across all profiles and are only ever read from the
# root/default profile's User/settings.json, never from a named profile's
# settings.json. Without this, the value is silently ignored and Restricted
# Mode still prompts.
vscode_profile_apply_app_settings() {
  echo "Applying application-scope settings to root User/settings.json: $USER_ROOT/settings.json"
  python3 - "$SCRIPT_DIR/settings.json" "$USER_ROOT/settings.json" <<'PY'
import json
import sys

src_file, dest_file = sys.argv[1], sys.argv[2]
APPLICATION_SCOPE_KEYS = {"security.workspace.trust.enabled"}

with open(src_file, "r", encoding="utf-8") as f:
    src = json.load(f)

try:
    with open(dest_file, "r", encoding="utf-8") as f:
        dest = json.load(f)
except FileNotFoundError:
    dest = {}

for key in APPLICATION_SCOPE_KEYS:
    if key in src:
        dest[key] = src[key]

with open(dest_file, "w", encoding="utf-8") as f:
    json.dump(dest, f, indent=4)
    f.write("\n")
PY
  echo "✓ application-scope settings"
}

# Some layout values (e.g. panel alignment) are no longer settings: VS Code
# keeps them in its state DB, so settings.json can't set them. Write
# state.json into it directly. VS Code flushes its in-memory state on exit,
# so this only sticks while the instance is closed. The launchers pass
# `--user-data-dir <dir>` (space) while the CLI uses `--user-data-dir=<dir>`,
# so match either spelling.
vscode_profile_apply_state() {
  if pgrep -f -- "--user-data-dir[= ]$PROFILE_DIR" >/dev/null; then
    echo "⚠ $PROFILE_NAME VS Code is running; close it and re-run to apply state.json"
    return 0
  fi

  local db
  for db in "$USER_ROOT/globalStorage/state.vscdb" "$USER_DIR/globalStorage/state.vscdb"; do
    [ -f "$db" ] || continue
    python3 - "$SCRIPT_DIR/state.json" "$db" <<'PY'
import json
import sqlite3
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    state = json.load(f)

conn = sqlite3.connect(sys.argv[2])
with conn:
    conn.executemany(
        "INSERT OR REPLACE INTO ItemTable (key, value) VALUES (?, ?)",
        [(k, v if isinstance(v, str) else json.dumps(v)) for k, v in state.items()],
    )
conn.close()
PY
    echo "✓ state.json -> $db"
  done
}

# Install every extension listed in the component's extensions.json.
vscode_profile_install_extensions() {
  # VS Code owns profile-level extensions.json with a strict schema.
  # Keep recommendations only in this component directory for installation input.
  rm -f "$USER_DIR/extensions.json"

  echo ""
  echo "Installing $PROFILE_NAME VS Code extensions to: $EXTENSIONS_DIR"

  local extensions=() extension output
  while IFS= read -r extension; do
    if [ -n "$extension" ]; then
      extensions+=("$extension")
    fi
  done < <(python3 -c 'import json, sys; print("\n".join(json.load(open(sys.argv[1])).get("recommendations", [])))' "$SCRIPT_DIR/extensions.json")

  for extension in "${extensions[@]}"; do
    output="$(profile_cli --install-extension="$extension" --force 2>&1)" || true
    if printf '%s\n' "$output" | grep -q "already installed\|already exists"; then
      echo "✓ $extension (already installed)"
    elif printf '%s\n' "$output" | grep -q "built-in extension.*cannot be downgraded"; then
      echo "✓ $extension (built-in)"
    elif printf '%s\n' "$output" | grep -qi "successfully installed"; then
      echo "✓ $extension"
    elif printf '%s\n' "$output" | grep -qE 'Failed Installing Extensions|unable to get|certificate'; then
      echo "⚠ $extension (network/certificate issue - may be installed on next sync)"
    else
      echo "⚠ $extension (unexpected output):"
      printf '%s\n' "$output" | sed 's/^/    /'
    fi
  done
}

# ms-python.python ships an extensionPack (vscode-pylance, debugpy,
# vscode-python-envs) that VS Code auto-installs alongside it. These profiles
# only want the core Python extension: Ty is the language server, Ruff
# formats/lints, and we don't use VS Code's debugger or the newer
# environment-manager UI. Remove the unwanted pack members after install
# since --install-extension has no flag to skip them.
vscode_profile_remove_python_pack() {
  echo ""
  echo "Removing extensions bundled by ms-python.python's extension pack:"
  local installed ext
  installed="$(profile_cli --list-extensions 2>/dev/null)" || true
  for ext in ms-python.vscode-pylance ms-python.debugpy ms-python.vscode-python-envs; do
    if printf '%s\n' "$installed" | grep -qix "$ext"; then
      echo "Uninstalling extension: $ext"
      profile_cli --uninstall-extension="$ext" >/dev/null 2>&1 \
        || echo "⚠ Failed to uninstall $ext"
    fi
  done
}

# The profile-scoped extensions.json (VS Code's own bookkeeping of which
# extensions are enabled in this profile) can drift from what's actually on
# disk in $EXTENSIONS_DIR -- e.g. after manual --install-extension calls or
# extension folders removed outside of these scripts. A stale entry here
# breaks VS Code's extension loading entirely ("Unable to read file ... for
# all extensions"). Prune any entry whose folder no longer exists so reruns
# always leave a working profile behind.
vscode_profile_reconcile_manifest() {
  [ -f "$USER_DIR/extensions.json" ] || return 0
  echo "Reconciling profile extensions manifest with $EXTENSIONS_DIR contents"
  python3 - "$USER_DIR/extensions.json" <<'PY'
import json
import os
import sys

manifest_file = sys.argv[1]

with open(manifest_file, "r", encoding="utf-8") as f:
    entries = json.load(f)

kept = []
for entry in entries:
    path = entry.get("location", {}).get("path")
    if path and os.path.isdir(path):
        kept.append(entry)
    else:
        identifier = entry.get("identifier", {}).get("id")
        print(f"⚠ Removing stale extension entry: {identifier} -> {path}")

if len(kept) != len(entries):
    with open(manifest_file, "w", encoding="utf-8") as f:
        json.dump(kept, f, indent=4)
        f.write("\n")
PY
}

# Re-apply profile metadata after CLI operations, because VS Code can rewrite
# storage.json while installing extensions: drop the optional legacy profile
# again, restore this profile's icon, and point workspaces under the optional
# directory prefix that are associated with a "-"-prefixed location back at
# this profile.
vscode_profile_reconcile_storage() {
  local legacy_name="${1:-}" workspace_dir="${2:-}"
  python3 - "$STORAGE_FILE" "$PROFILE_NAME" "$PROFILE_ICON" "$legacy_name" "$workspace_dir" <<'PY'
import json
import os
import sys

storage_file, profile_name, profile_icon, legacy_name, workspace_dir = sys.argv[1:6]
if not os.path.exists(storage_file):
  raise SystemExit(0)

with open(storage_file, "r", encoding="utf-8") as f:
  data = json.load(f)

profiles = data.get("userDataProfiles")
if not isinstance(profiles, list):
  profiles = []

profile_location = None
filtered = []
for profile in profiles:
  if not isinstance(profile, dict):
    continue
  if legacy_name and profile.get("name") == legacy_name:
    continue
  if profile.get("name") == profile_name:
    profile["icon"] = profile_icon
    profile_location = profile.get("location")
  filtered.append(profile)

data["userDataProfiles"] = filtered

if profile_location and workspace_dir:
  workspace_prefix = "file://" + os.path.abspath(workspace_dir)
  associations = data.get("profileAssociations")
  if isinstance(associations, dict):
    workspace_map = associations.get("workspaces")
    if isinstance(workspace_map, dict):
      for key, value in list(workspace_map.items()):
        if value and isinstance(value, str) and value != profile_location and value.startswith("-"):
          if key == workspace_prefix or key.startswith(workspace_prefix + "/"):
            workspace_map[key] = profile_location

with open(storage_file, "w", encoding="utf-8") as f:
  json.dump(data, f, indent=4)
  f.write("\n")
PY
}
