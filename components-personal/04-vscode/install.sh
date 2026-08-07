#!/bin/bash
# Install the personal VS Code profile configuration for the self-built
# VS Code (Code - OSS) at ~/projects/vscode.

set -e

# If this script runs from a terminal already hosted inside an Electron
# process (e.g. VS Code's own integrated terminal), these leak into our
# environment and make a plain `code_oss` GUI launch below run out/main.js
# as plain Node instead of as Electron, breaking with "does not provide an
# export named 'Menu'" or similar. Unset them here as the default; the CLI
# helper below re-adds ELECTRON_RUN_AS_NODE=1 deliberately, only for itself.
unset ELECTRON_RUN_AS_NODE
unset ELECTRON_NO_ATTACH_CONSOLE

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_ROOT="$HOME/projects/vscode"
CODE_BIN="$VSCODE_ROOT/.build/electron/code-oss"
PROFILE_DIR="$HOME/.vscode-personal/user-data"
USER_ROOT="$PROFILE_DIR/User"
EXTENSIONS_DIR="$HOME/.vscode-personal/extensions"
PROFILE_NAME="Personal"
PROFILE_ICON="heart"
STORAGE_FILE="$USER_ROOT/globalStorage/storage.json"

# This component configures the "Personal" profile for the self-built VS Code
# checked out at $VSCODE_ROOT (see components-personal/04-vscode/README.md for
# why: proposed-API access for the bode-claude extension's native chat
# integration). Building it is that repo's own responsibility
# (bash install.sh, npm run compile, npm run electron) -- this script only
# fails fast with instructions if the build isn't there yet.
if [ ! -x "$CODE_BIN" ]; then
  echo "⚠ Self-built VS Code binary not found at $CODE_BIN"
  echo "  Build it first (scripts/code.sh normally does this on first launch"
  echo "  via preLaunch.ts, but this wrapper bypasses that script):"
  echo "    cd $VSCODE_ROOT"
  echo "    bash install.sh   # npm install"
  echo "    npm run compile   # builds ./out"
  echo "    npm run electron  # fetches .build/electron"
  exit 1
fi

# Vanilla Code-OSS ships with no extensionsGallery in product.json at all --
# Microsoft restricts marketplace.visualstudio.com to their own official
# builds, so a from-source checkout can't install-by-ID/search out of the
# box (a local .vsix would still work, but --install-extension <id> fails
# with "No extension gallery service configured"). product.overrides.json
# is VS Code's own supported mechanism for this: bootstrap-meta.js merges it
# over product.json, but only when VSCODE_DEV is set (see both code_oss
# helpers below), and it's already in VSCODE_ROOT's .gitignore, so this
# never conflicts with syncing upstream. Point it at open-vsx.org, the
# standard FOSS-friendly registry (same approach VSCodium uses).
cp "$SCRIPT_DIR/product.overrides.json" "$VSCODE_ROOT/product.overrides.json"

# This is an unpackaged dev build (no app.asar), so unlike the packaged
# apt-installed code/code-insiders binaries, Electron doesn't know what app
# to load unless told: the raw binary run with no arguments just shows
# Electron's own generic "To run a local app..." placeholder window. The fix
# is to pass VSCODE_ROOT as the first positional arg (Electron's app
# locator) -- but VS Code's own CLI arg parser (argvHelper.ts) only strips
# that arg back out of its argv, instead of treating it as a folder to open
# alongside whatever real target follows, when VSCODE_DEV is set. Wrap every
# call so both are always correct together. This is the GUI/main-process
# entry point -- fine for opening editor windows, but src/vs/code/
# electron-main/main.ts has no idea what --list-extensions/
# --install-extension/--uninstall-extension even are (only
# src/vs/code/node/cli.ts does), so it just opens an empty window instead of
# doing anything with them. Use code_oss_cli below for extension management.
code_oss() {
  VSCODE_DEV=1 NODE_ENV=development "$CODE_BIN" "$VSCODE_ROOT" "$@"
}

# The headless CLI entry (out/cli.js -> cliProcessMain.ts), reached by
# running code-oss as plain Node (ELECTRON_RUN_AS_NODE=1) against that
# script instead of the main Electron entry. Needs VSCODE_ROOT and
# VSCODE_DEV=1 for the same app-locator-stripping reason as code_oss above
# (cli.ts's own argv parsing has the identical convention: `Electron cli.js
# . --flags`) -- this is genuinely headless: no window, exits in well under
# a second.
code_oss_cli() {
  NODE_NO_WARNINGS=1 ELECTRON_RUN_AS_NODE=1 VSCODE_DEV=1 NODE_ENV=development "$CODE_BIN" "$VSCODE_ROOT/out/cli.js" "$VSCODE_ROOT" "$@" < /dev/null
}

echo "✓ Found self-built VS Code binary: $CODE_BIN"

# `npm run electron` deletes and re-extracts .build/electron from a plain zip
# on every run, owned by the current user. Chromium's SUID sandbox helper
# refuses to run unless it's owned by root with mode 4755 ("FATAL: The SUID
# sandbox helper binary was found, but is not configured correctly"), which
# a packaged .deb build normally fixes via its postinst script. Re-apply it
# here so every extension-management call below (and every `code` launch)
# doesn't crash with that error after a fresh build.
SANDBOX_BIN="$VSCODE_ROOT/.build/electron/chrome-sandbox"
if [ -f "$SANDBOX_BIN" ] && [ "$(stat -c '%U:%a' "$SANDBOX_BIN")" != "root:4755" ]; then
  echo "Fixing chrome-sandbox ownership/permissions (requires sudo):"
  sudo chown root:root "$SANDBOX_BIN"
  sudo chmod 4755 "$SANDBOX_BIN"
fi

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
# Read the recommendation list into an array first rather than piping it
# into `while read`: any command inside that loop's body reading its own
# stdin (even a no-op read) would otherwise consume the rest of the piped
# list and silently truncate the loop after one iteration.
mapfile -t RECOMMENDED_EXTENSIONS < <(python3 -c 'import json, sys; print("\n".join(json.load(open(sys.argv[1])).get("recommendations", [])))' "$SCRIPT_DIR/extensions.json")
for extension in "${RECOMMENDED_EXTENSIONS[@]}"; do
  if [ -n "$extension" ]; then
    echo "Installing extension: $extension"
    output="$(code_oss_cli --user-data-dir="$PROFILE_DIR" --extensions-dir="$EXTENSIONS_DIR" --profile="$PROFILE_NAME" --install-extension="$extension" --force 2>&1)" || true
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
  if code_oss_cli --user-data-dir="$PROFILE_DIR" --extensions-dir="$EXTENSIONS_DIR" --profile="$PROFILE_NAME" --list-extensions 2>/dev/null | grep -qix "$ext"; then
    echo "Uninstalling extension: $ext"
    code_oss_cli --user-data-dir="$PROFILE_DIR" --extensions-dir="$EXTENSIONS_DIR" --profile="$PROFILE_NAME" --uninstall-extension="$ext" >/dev/null 2>&1 \
      || echo "⚠ Failed to uninstall $ext"
  fi
done

# The profile-scoped extensions.json (VS Code's own bookkeeping of which
# extensions are enabled in this profile) can drift from what's actually on
# disk in $EXTENSIONS_DIR -- e.g. after manual --install-extension calls or
# extension folders removed outside of this script. A stale entry here
# breaks VS Code's extension loading entirely ("Unable to read file ... for
# all extensions"). Prune any entry whose folder no longer exists so reruns
# of this script always leave a working profile behind.
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

# GNOME (and other desktop shells) picks up an app's dock/taskbar icon by
# matching a running window's WM_CLASS / Wayland app-id against an installed
# .desktop file's StartupWMClass. The apt-installed code/code-insiders get
# this via their .deb's postinst (code.desktop + hicolor icons under
# /usr/share/*), but this is a raw unpackaged Electron binary with no such
# registration -- so the running window shows the desktop's generic
# fallback icon next to properly-integrated apps like Chrome/Steam. Since
# VS Code never calls Electron's app.setName() for a dev build, the runtime
# app name (and therefore WM_CLASS/app-id) defaults to VSCODE_ROOT's own
# package.json "name" field, which is "code-oss-dev" -- not "code-oss"
# (product.json's applicationName) or "Code - OSS" (nameShort).
#
# The icon itself is the real VS Code logo -- installed at
# /usr/share/pixmaps/vscode.png by components-global/04-vscode's apt
# package -- recolored to ochre via make-ochre-icon.py so the Personal
# profile is recognizable as VS Code at a glance but visually distinct
# from the blue Work icon.
REAL_LOGO="/usr/share/pixmaps/vscode.png"
ICON_NAME="code-oss-personal"
DESKTOP_FILE="$HOME/.local/share/applications/$ICON_NAME.desktop"

if [ ! -f "$REAL_LOGO" ]; then
  echo "⚠ Skipping desktop entry/icon install: $REAL_LOGO not found"
  echo "  Install VS Code's apt package first (provides the source logo):"
  echo "    cd $(cd "$SCRIPT_DIR/../../components-global/04-vscode" && pwd) && bash install.sh"
elif ! command -v convert >/dev/null 2>&1; then
  echo "⚠ Skipping desktop entry/icon install: ImageMagick 'convert' not found"
elif ! python3 -c "import PIL" >/dev/null 2>&1; then
  echo "⚠ Skipping desktop entry/icon install: Pillow not installed for python3"
  echo "  Install it with: pip install --user Pillow"
else
  echo "Installing desktop entry + icons for self-built Personal VS Code..."
  OCHRE_MASTER="$(mktemp --suffix=.png)"
  python3 "$SCRIPT_DIR/make-ochre-icon.py" "$REAL_LOGO" "$OCHRE_MASTER"
  for size in 16 24 32 48 64 96 128 192 256; do
    ICON_DIR="$HOME/.local/share/icons/hicolor/${size}x${size}/apps"
    mkdir -p "$ICON_DIR"
    convert "$OCHRE_MASTER" -resize "${size}x${size}" "$ICON_DIR/$ICON_NAME.png"
  done
  rm -f "$OCHRE_MASTER"

  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=VS Code (Personal)
Comment=Code Editing. Redefined. (self-built, Personal profile)
GenericName=Text Editor
Exec=env VSCODE_DEV=1 NODE_ENV=development "$CODE_BIN" "$VSCODE_ROOT" --user-data-dir "$PROFILE_DIR" --extensions-dir "$EXTENSIONS_DIR" --profile Personal --enable-proposed-api=local.bode-claude %F
Icon=$ICON_NAME
Type=Application
StartupNotify=true
StartupWMClass=code-oss-dev
Categories=TextEditor;Development;IDE;
Keywords=vscode;code-oss;
EOF

  command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1
  command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1
  echo "✓ Desktop entry + icons installed ($DESKTOP_FILE)"
fi

echo ""
