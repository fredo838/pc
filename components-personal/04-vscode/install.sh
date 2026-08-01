#!/bin/bash
# Install VS Code Insiders and the personal profile configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$HOME/.vscode-personal-insiders"
USER_ROOT="$PROFILE_DIR/User"
EXTENSIONS_DIR="$HOME/.vscode-personal-insiders-ext"
PROFILE_NAME="Personal"
PROFILE_ICON="heart"
STORAGE_FILE="$USER_ROOT/globalStorage/storage.json"

echo "Installing VS Code Insiders..."

# Add Microsoft GPG key and apt repository, but only if no source already provides
# packages.microsoft.com/repos/code -- e.g. a prior manual VS Code .deb install writes
# its own vscode.sources file. Adding a second, differently-keyed source for the same
# repo makes apt fail with "Conflicting values set for option Signed-By".
if grep -rq "packages\.microsoft\.com/repos/code" /etc/apt/sources.list.d/ /etc/apt/sources.list 2>/dev/null; then
  echo "Microsoft VS Code apt repository already configured; skipping repo setup."
else
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  rm /tmp/packages.microsoft.gpg
  echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
fi

sudo apt-get update
sudo apt-get install -y code-insiders

echo "✓ VS Code Insiders package installed"

mkdir -p "$USER_ROOT"

if command -v code-insiders >/dev/null 2>&1; then
  mkdir -p "$EXTENSIONS_DIR"
  # Ensure the named profile exists in this user-data-dir.
  NODE_NO_WARNINGS=1 code-insiders --user-data-dir "$PROFILE_DIR" --extensions-dir "$EXTENSIONS_DIR" --profile "$PROFILE_NAME" --list-extensions >/dev/null 2>&1 || true
fi

PROFILE_ID="$(python3 - "$STORAGE_FILE" "$PROFILE_NAME" "$PROFILE_ICON" <<'PY'
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
os.makedirs(os.path.dirname(storage_file), exist_ok=True)
with open(storage_file, "w", encoding="utf-8") as f:
  json.dump(data, f, indent=4)
  f.write("\n")

print(profile.get("location", ""))
PY
)"

if [ -z "$PROFILE_ID" ]; then
  echo "⚠ Failed to resolve VS Code profile id for $PROFILE_NAME"
  exit 1
fi

USER_DIR="$USER_ROOT/profiles/$PROFILE_ID"
mkdir -p "$USER_DIR"

echo "Installing personal VS Code Insiders profile config to: $USER_DIR"
for filename in keybindings.json settings.json; do
  if [ -f "$SCRIPT_DIR/$filename" ]; then
    cp "$SCRIPT_DIR/$filename" "$USER_DIR/$filename"
    echo "✓ $filename"
  else
    echo "⚠ $filename not found in $SCRIPT_DIR"
  fi
done

# security.workspace.trust.enabled is an "application" scope setting in VS Code:
# such settings are shared across all profiles and are only ever read from the
# root/default profile's User/settings.json, never from a named profile's
# settings.json. Without this, the value above is silently ignored and
# Restricted Mode still prompts.
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

# VS Code owns profile-level extensions.json with a strict schema.
# Keep recommendations only in this component directory for installation input.
if [ -f "$USER_DIR/extensions.json" ]; then
  rm -f "$USER_DIR/extensions.json"
fi

echo ""

echo "Installing personal VS Code Insiders extensions to: $EXTENSIONS_DIR"
if command -v code-insiders >/dev/null 2>&1; then
  mkdir -p "$EXTENSIONS_DIR"
  python3 -c 'import json, sys; print("\n".join(json.load(open(sys.argv[1])).get("recommendations", [])))' "$SCRIPT_DIR/extensions.json" \
  | while IFS= read -r extension; do
    if [ -n "$extension" ]; then
      echo "Installing extension: $extension"
      output="$(NODE_NO_WARNINGS=1 code-insiders --user-data-dir "$PROFILE_DIR" --extensions-dir "$EXTENSIONS_DIR" --profile "$PROFILE_NAME" --install-extension "$extension" --force 2>&1)" || true
      if printf '%s\n' "$output" | grep -qE 'built-in extension .* cannot be downgraded|Failed Installing Extensions'; then
        echo "⚠ Skipping built-in/downgrade issue for extension: $extension"
      elif [ -n "$output" ]; then
        printf '%s\n' "$output"
      fi
    fi
  done

  # ms-python.python ships an extensionPack (vscode-pylance, debugpy,
  # vscode-python-envs) that VS Code auto-installs alongside it. This
  # profile only wants the core Python extension: Ty is the language
  # server, Ruff formats/lints, and we don't use VS Code's debugger or
  # the newer environment-manager UI. Remove the unwanted pack members
  # after install since --install-extension has no flag to skip them.
  echo ""
  echo "Removing extensions bundled by ms-python.python's extension pack:"
  for ext in ms-python.vscode-pylance ms-python.debugpy ms-python.vscode-python-envs; do
    if NODE_NO_WARNINGS=1 code-insiders --user-data-dir "$PROFILE_DIR" --extensions-dir "$EXTENSIONS_DIR" --profile "$PROFILE_NAME" --list-extensions 2>/dev/null | grep -qix "$ext"; then
      echo "Uninstalling extension: $ext"
      NODE_NO_WARNINGS=1 code-insiders --user-data-dir "$PROFILE_DIR" --extensions-dir "$EXTENSIONS_DIR" --profile "$PROFILE_NAME" --uninstall-extension "$ext" >/dev/null 2>&1 \
        || echo "⚠ Failed to uninstall $ext"
    fi
  done
else
  echo "⚠ VS Code Insiders CLI 'code-insiders' not found; skipping extension installation."
fi

# The profile-scoped extensions.json (VS Code's own bookkeeping of which
# extensions are enabled in this profile) can drift from what's actually on
# disk in $EXTENSIONS_DIR -- e.g. after manual `code-insiders --install-extension`
# calls or extension folders removed outside of this script. A stale entry
# here breaks VS Code's extension loading entirely ("Unable to read file ...
# for all extensions"). Prune any entry whose folder no longer exists so
# reruns of this script always leave a working profile behind.
if [ -f "$USER_DIR/extensions.json" ]; then
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
fi

echo "Disabling built-in GitHub Copilot in the personal profile"
env NODE_NO_WARNINGS=1 code-insiders --user-data-dir "$PROFILE_DIR" --extensions-dir "$EXTENSIONS_DIR" --profile "$PROFILE_NAME" --disable-extension github.copilot --disable-extension github.copilot-chat >/dev/null 2>&1 || true

echo ""
