#!/bin/bash
# Install the personal VS Code profile configuration for the self-built
# VS Code (Code - OSS) on macOS at ~/projects/vscode.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/component.sh"
VSCODE_ROOT="$HOME/projects/vscode"
CODE_APP="$VSCODE_ROOT/.build/electron/Code - OSS.app"
CODE_BIN="$CODE_APP/Contents/MacOS/Code - OSS"
PROFILE_DIR="$HOME/.vscode-personal/user-data"
EXTENSIONS_DIR="$HOME/.vscode-personal/extensions"
PROFILE_NAME="Personal"
PROFILE_ICON="heart"

# The self-built VS Code at $VSCODE_ROOT is built by that repo, not here:
# skip with instructions for whichever build step hasn't been done yet.
if [ ! -d "$VSCODE_ROOT/.git" ]; then
  skip_component "self-built VS Code not checked out at $VSCODE_ROOT" \
    "git clone https://github.com/microsoft/vscode.git $VSCODE_ROOT" \
    "then: cd $VSCODE_ROOT && npm install && npm run compile && npm run electron"
elif [ ! -f "$VSCODE_ROOT/out/cli.js" ]; then
  skip_component "self-built VS Code not compiled ($VSCODE_ROOT/out/cli.js missing)" \
    "cd $VSCODE_ROOT && npm install && npm run compile && npm run electron"
elif [ ! -x "$CODE_BIN" ]; then
  skip_component "self-built VS Code Electron app missing ($CODE_APP)" \
    "cd $VSCODE_ROOT && npm run electron"
fi

# Copy product.overrides.json to use open-vsx marketplace
cp "$SCRIPT_DIR/product.overrides.json" "$VSCODE_ROOT/product.overrides.json"

# Headless CLI entry (out/cli.js) for extension management, run as plain
# Node against the Electron binary. VSCODE_ROOT is Electron's app locator
# for this unpackaged dev build; VS Code only strips it back out of argv
# (instead of treating it as a folder) when VSCODE_DEV is set.
vscode_cli() {
  NODE_NO_WARNINGS=1 ELECTRON_RUN_AS_NODE=1 VSCODE_DEV=1 NODE_ENV=development "$CODE_BIN" "$VSCODE_ROOT/out/cli.js" "$VSCODE_ROOT" "$@"
}

echo "✓ Found self-built VS Code binary: $CODE_BIN"

source "$SCRIPT_DIR/../../lib/vscode-profile.sh"

vscode_profile_register
vscode_profile_copy_config
vscode_profile_apply_app_settings
vscode_profile_apply_state
vscode_profile_install_extensions
vscode_profile_remove_python_pack
vscode_profile_reconcile_manifest

echo ""

# Launch helper (~/.local/bin/code-oss-personal), app wrapper
# (~/Applications/Code-Personal.app) and its ochre icon.
source "$SCRIPT_DIR/../../lib/code-oss-macos.sh"
code_oss_install_macos_app Code-Personal code-oss-personal com.local.code-oss-personal "VS Code (Personal)" CC7722

echo ""
echo "To launch the Personal profile, you can use:"
echo "  code-oss-personal [folder]"
echo "or"
echo "  open -n -a 'Code-Personal' --args /absolute/path/to/folder"
echo ""
