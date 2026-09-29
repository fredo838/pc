#!/bin/bash
# Install the personal VS Code profile configuration for the self-built
# VS Code (Code - OSS) at ~/projects/vscode.

set -e

# If this script runs from a terminal already hosted inside an Electron
# process (e.g. VS Code's own integrated terminal), these leak into our
# environment and would make any GUI launch of $CODE_BIN run out/main.js as
# plain Node instead of as Electron, breaking with "does not provide an
# export named 'Menu'" or similar. Unset them here as the default; the CLI
# helper below re-adds ELECTRON_RUN_AS_NODE=1 deliberately, only for itself.
unset ELECTRON_RUN_AS_NODE
unset ELECTRON_NO_ATTACH_CONSOLE

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_ROOT="$HOME/projects/vscode"
CODE_BIN="$VSCODE_ROOT/.build/electron/code-oss"
PROFILE_DIR="$HOME/.vscode-personal/user-data"
EXTENSIONS_DIR="$HOME/.vscode-personal/extensions"
PROFILE_NAME="Personal"
PROFILE_ICON="heart"

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
# to load unless told: VSCODE_ROOT must be passed as the first positional arg
# (Electron's app locator) -- and VS Code's own arg parser (argvHelper.ts,
# and cli.ts's identical `Electron cli.js . --flags` convention) only strips
# that arg back out of argv, instead of treating it as a folder to open, when
# VSCODE_DEV is set. The GUI entry (electron-main/main.ts) doesn't know
# --list-extensions/--install-extension/--uninstall-extension at all, so
# extension management goes through the headless CLI entry (out/cli.js ->
# cliProcessMain.ts), reached by running code-oss as plain Node
# (ELECTRON_RUN_AS_NODE=1): no window, exits in well under a second.
vscode_cli() {
  NODE_NO_WARNINGS=1 ELECTRON_RUN_AS_NODE=1 VSCODE_DEV=1 NODE_ENV=development "$CODE_BIN" "$VSCODE_ROOT/out/cli.js" "$VSCODE_ROOT" "$@"
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

source "$SCRIPT_DIR/../../lib/vscode-profile.sh"

vscode_profile_register
vscode_profile_copy_config
vscode_profile_apply_app_settings
vscode_profile_apply_state
vscode_profile_install_extensions
vscode_profile_remove_python_pack
vscode_profile_reconcile_manifest

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
