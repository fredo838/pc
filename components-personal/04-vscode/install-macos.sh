#!/bin/bash
# Install the personal VS Code profile configuration for the self-built
# VS Code (Code - OSS) on macOS at ~/projects/vscode.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_ROOT="$HOME/projects/vscode"
CODE_APP="$VSCODE_ROOT/.build/electron/Code - OSS.app"
CODE_BIN="$CODE_APP/Contents/MacOS/Code - OSS"
PROFILE_DIR="$HOME/.vscode-personal/user-data"
USER_ROOT="$PROFILE_DIR/User"
EXTENSIONS_DIR="$HOME/.vscode-personal/extensions"
PROFILE_NAME="Personal"
PROFILE_ICON="heart"
STORAGE_FILE="$USER_ROOT/globalStorage/storage.json"

# Check if the self-built VS Code binary exists
if [ ! -x "$CODE_BIN" ]; then
  echo "⚠ Self-built VS Code binary not found at $CODE_BIN"
  echo "  Build it first:"
  echo "    cd $VSCODE_ROOT"
  echo "    npm install"
  echo "    npm run compile   # builds ./out"
  echo "    npm run electron  # builds .build/electron/Code.app"
  exit 1
fi

# Copy product.overrides.json to use open-vsx marketplace
cp "$SCRIPT_DIR/product.overrides.json" "$VSCODE_ROOT/product.overrides.json"

# Helper function for GUI launches
code_oss() {
  VSCODE_DEV=1 NODE_ENV=development "$CODE_BIN" "$VSCODE_ROOT" "$@"
}

# Helper function for CLI operations (extension management)
code_oss_cli() {
  NODE_NO_WARNINGS=1 ELECTRON_RUN_AS_NODE=1 VSCODE_DEV=1 NODE_ENV=development "$CODE_BIN" "$VSCODE_ROOT/out/cli.js" "$VSCODE_ROOT" "$@" < /dev/null
}

echo "✓ Found self-built VS Code binary: $CODE_BIN"

mkdir -p "$USER_ROOT"
mkdir -p "$EXTENSIONS_DIR"

# Ensure the named profile exists in this user-data-dir.
code_oss_cli --user-data-dir="$PROFILE_DIR" --extensions-dir="$EXTENSIONS_DIR" --profile="$PROFILE_NAME" --list-extensions >/dev/null 2>&1 || true

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

echo "Installing personal VS Code profile config to: $USER_DIR"
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

echo "Installing personal VS Code extensions to: $EXTENSIONS_DIR"
python3 -c 'import json, sys; print("\n".join(json.load(open(sys.argv[1])).get("recommendations", [])))' "$SCRIPT_DIR/extensions.json" | while IFS= read -r extension; do
  if [ -n "$extension" ]; then
    output="$(code_oss_cli --user-data-dir="$PROFILE_DIR" --extensions-dir="$EXTENSIONS_DIR" --profile="$PROFILE_NAME" --install-extension="$extension" --force 2>&1)" || true
    if printf '%s\n' "$output" | grep -q "already installed\|already exists"; then
      echo "✓ $extension (already installed)"
    elif printf '%s\n' "$output" | grep -q "built-in extension.*cannot be downgraded"; then
      echo "✓ $extension (built-in)"
    elif printf '%s\n' "$output" | grep -q "Successfully installed"; then
      echo "✓ $extension"
    elif printf '%s\n' "$output" | grep -qE 'Failed Installing Extensions|unable to get|certificate'; then
      echo "⚠ $extension (network/certificate issue - may be installed on next sync)"
    else
      echo "✓ $extension (installed)"
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
  if code_oss_cli --user-data-dir="$PROFILE_DIR" --extensions-dir="$EXTENSIONS_DIR" --profile="$PROFILE_NAME" --list-extensions 2>/dev/null | grep -qix "$ext"; then
    echo "Uninstalling extension: $ext"
    code_oss_cli --user-data-dir="$PROFILE_DIR" --extensions-dir="$EXTENSIONS_DIR" --profile="$PROFILE_NAME" --uninstall-extension="$ext" >/dev/null 2>&1 \
      || echo "⚠ Failed to uninstall $ext"
  fi
done

# The profile-scoped extensions.json can drift from what's actually on
# disk in $EXTENSIONS_DIR. Prune any entry whose folder no longer exists.
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

echo ""

# On macOS, we create a launch helper script in ~/.local/bin instead of a desktop file.
# This allows the shell wrapper to easily launch with all the right environment variables.
LAUNCH_DIR="$HOME/.local/bin"
LAUNCH_SCRIPT="$LAUNCH_DIR/code-oss-personal"

mkdir -p "$LAUNCH_DIR"

cat > "$LAUNCH_SCRIPT" <<'LAUNCHER'
#!/bin/bash
# Launcher for self-built VS Code Personal profile on macOS
exec env \
  VSCODE_DEV=1 \
  NODE_ENV=development \
  "$HOME/projects/vscode/.build/electron/Code.app/Contents/MacOS/Code" \
  "$HOME/projects/vscode" \
  --user-data-dir "$HOME/.vscode-personal/user-data" \
  --extensions-dir "$HOME/.vscode-personal/extensions" \
  --profile Personal \
  --enable-proposed-api=local.bode-claude \
  "$@"
LAUNCHER

chmod +x "$LAUNCH_SCRIPT"
echo "✓ Launch script installed at: $LAUNCH_SCRIPT"

# Create a macOS .app wrapper that points to our self-built Code.app
# This allows the app to appear in spotlight/launchpad with the custom icon
APP_WRAPPER="$HOME/Applications/Code-Personal.app"
WRAPPER_CONTENTS="$APP_WRAPPER/Contents"
WRAPPER_MACOS="$WRAPPER_CONTENTS/MacOS"

mkdir -p "$WRAPPER_MACOS"

# Create the launcher script inside the app bundle
cat > "$WRAPPER_MACOS/Code-Personal" <<'APPWRAPPER'
#!/bin/bash
exec env \
  VSCODE_DEV=1 \
  NODE_ENV=development \
  "$HOME/projects/vscode/.build/electron/Code.app/Contents/MacOS/Code" \
  "$HOME/projects/vscode" \
  --user-data-dir "$HOME/.vscode-personal/user-data" \
  --extensions-dir "$HOME/.vscode-personal/extensions" \
  --profile Personal \
  --enable-proposed-api=local.bode-claude \
  "$@"
APPWRAPPER

chmod +x "$WRAPPER_MACOS/Code-Personal"

# Create Info.plist for the wrapper app (with icon reference)
cat > "$WRAPPER_CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>Code-Personal</string>
	<key>CFBundleIconFile</key>
	<string>Code</string>
	<key>CFBundleIdentifier</key>
	<string>com.local.code-oss-personal</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>VS Code (Personal)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleVersion</key>
	<string>1.0</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSHumanReadableCopyright</key>
	<string>VS Code Personal Profile</string>
</dict>
</plist>
PLIST

echo "✓ App wrapper installed at: $APP_WRAPPER"

# Create ochre-colored icon for the app wrapper
REAL_ICON="$HOME/projects/vscode/.build/electron/Code - OSS.app/Contents/Resources/Code - OSS.icns"
if [ ! -f "$REAL_ICON" ]; then
  echo "⚠ VS Code icon not found at $REAL_ICON, skipping ochre icon"
elif ! command -v iconutil >/dev/null 2>&1; then
  echo "⚠ iconutil not found, skipping ochre icon"
elif ! python3 -c "import PIL" >/dev/null 2>&1; then
  echo "⚠ Pillow not installed for python3, skipping ochre icon"
else
  echo "Creating ochre-colored icon for macOS app wrapper..."

  ICON_TEMP="$(mktemp -d)"
  ICON_ICONSET="$ICON_TEMP/Code.iconset"
  mkdir -p "$ICON_ICONSET"

  if iconutil -c iconset -o "$ICON_ICONSET" "$REAL_ICON" 2>/dev/null; then
    SOURCE_PNG=""
    for png in "$ICON_ICONSET"/*.png; do
      if [[ "$png" == *"icon_256x256.png" ]] || [[ "$png" == *"icon_512x512.png" ]]; then
        SOURCE_PNG="$png"
        break
      fi
    done

    if [ -z "$SOURCE_PNG" ]; then
      for png in "$ICON_ICONSET"/*.png; do
        SOURCE_PNG="$png"
        break
      done
    fi

    if [ -n "$SOURCE_PNG" ] && [ -f "$SOURCE_PNG" ]; then
      OCHRE_PNG="$ICON_TEMP/Code-ochre.png"
      if python3 "$SCRIPT_DIR/make-ochre-icon.py" "$SOURCE_PNG" "$OCHRE_PNG"; then
        NEW_ICONSET="$ICON_TEMP/Code-ochre.iconset"
        mkdir -p "$NEW_ICONSET"

        for size in 16 32 64 128 256 512 1024; do
          OUTPUT="$NEW_ICONSET/icon_${size}x${size}.png"
          sips -z $size $size "$OCHRE_PNG" --out "$OUTPUT" >/dev/null 2>&1

          OUTPUT_2X="$NEW_ICONSET/icon_${size}x${size}@2x.png"
          sips -z $((size * 2)) $((size * 2)) "$OCHRE_PNG" --out "$OUTPUT_2X" >/dev/null 2>&1
        done

        WRAPPER_ICON="$WRAPPER_CONTENTS/Resources/Code.icns"
        mkdir -p "$WRAPPER_CONTENTS/Resources"
        if iconutil -c icns -o "$WRAPPER_ICON" "$NEW_ICONSET" 2>/dev/null; then
          echo "✓ Ochre icon created"
        else
          echo "⚠ Failed to create ICNS file"
        fi
      else
        echo "⚠ Failed to recolor icon to ochre"
      fi
    fi
  else
    echo "⚠ Failed to extract icon from ICNS"
  fi

  rm -rf "$ICON_TEMP"
fi

echo ""
echo "To launch the Personal profile, you can use:"
echo "  code-oss-personal [folder]"
echo "or"
echo "  open -a 'Code-Personal' [folder]"
echo ""
