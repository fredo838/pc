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
source "$SCRIPT_DIR/../../lib/component.sh"
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
# skips with instructions for whichever step hasn't been done yet.
# (scripts/code.sh normally builds on first launch via preLaunch.ts, but the
# launchers here bypass that script.)
if [ ! -d "$VSCODE_ROOT/.git" ]; then
  skip_component "self-built VS Code not checked out at $VSCODE_ROOT" \
    "git clone https://github.com/microsoft/vscode.git $VSCODE_ROOT" \
    "then: cd $VSCODE_ROOT && bash install.sh && npm run compile && npm run electron"
elif [ ! -f "$VSCODE_ROOT/out/cli.js" ]; then
  skip_component "self-built VS Code not compiled ($VSCODE_ROOT/out/cli.js missing)" \
    "cd $VSCODE_ROOT && bash install.sh && npm run compile && npm run electron"
elif [ ! -x "$CODE_BIN" ]; then
  skip_component "self-built VS Code Electron binary missing ($CODE_BIN)" \
    "cd $VSCODE_ROOT && npm run electron"
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

# Root-owned chrome-sandbox after every fresh build (see lib/code-oss-linux.sh).
source "$SCRIPT_DIR/../../lib/code-oss-linux.sh"
code_oss_linux_fix_sandbox

source "$SCRIPT_DIR/../../lib/vscode-profile.sh"

vscode_profile_register
vscode_profile_copy_config
vscode_profile_apply_app_settings
vscode_profile_apply_state
vscode_profile_install_extensions
vscode_profile_remove_python_pack
vscode_profile_reconcile_manifest

echo ""

# Desktop entry + ochre icons (see lib/code-oss-linux.sh). Personal keeps the
# build's own WM_CLASS, code-oss-dev.
code_oss_install_linux_desktop code-oss-personal "VS Code (Personal)" CC7722 code-oss-dev

echo ""
