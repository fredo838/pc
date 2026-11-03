#!/bin/bash
# Install the IoT VS Code profile on macOS: the self-built VS Code (Code -
# OSS) at ~/projects/vscode, like Personal (bode-claude needs its proposed
# APIs and Agent Host patches), with data of its own. The `code` shell
# wrapper picks it for exactly ~/centrica/iot-optimisation.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/component.sh"
VSCODE_ROOT="$HOME/projects/vscode"
CODE_APP="$VSCODE_ROOT/.build/electron/Code - OSS.app"
CODE_BIN="$CODE_APP/Contents/MacOS/Code - OSS"
PROFILE_DIR="$HOME/.vscode-iot/user-data"
EXTENSIONS_DIR="$HOME/.vscode-iot/extensions"
PROFILE_NAME="IoT"
PROFILE_ICON="circuit-board"

# Same build prerequisites as the Personal profile (see its README).
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

# The open-vsx marketplace, shared with the Personal profile (same build).
cp "$SCRIPT_DIR/../../components-personal/04-vscode/product.overrides.json" "$VSCODE_ROOT/product.overrides.json"

# Headless CLI entry for extension management (see the Personal installer).
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

# Launch helper (~/.local/bin/code-oss-iot), app wrapper
# (~/Applications/Code-IoT.app) and its teal icon.
source "$SCRIPT_DIR/../../lib/code-oss-macos.sh"
code_oss_install_macos_app Code-IoT code-oss-iot com.local.code-oss-iot "VS Code (IoT)" 1F9E89

echo ""
echo "bode-claude is not on a marketplace: install it into this profile with"
echo "  ~/projects/bode/root/ops/javascript/bode-claude/reinstall.sh"
echo ""
echo "To launch the IoT profile: cd ~/centrica/iot-optimisation && code ."
echo ""
