#!/bin/bash
# Install the IoT VS Code profile on Linux: the self-built VS Code (Code -
# OSS) at ~/projects/vscode, like Personal (bode-claude needs its proposed
# APIs and Agent Host patches), with data of its own. The `code` shell
# wrapper picks it for exactly ~/centrica/iot-optimisation.

set -e

# Electron variables leaked from a terminal hosted inside VS Code would make
# a GUI launch run as plain Node (see the Personal installer).
unset ELECTRON_RUN_AS_NODE
unset ELECTRON_NO_ATTACH_CONSOLE

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/component.sh"
VSCODE_ROOT="$HOME/projects/vscode"
CODE_BIN="$VSCODE_ROOT/.build/electron/code-oss"
PROFILE_DIR="$HOME/.vscode-iot/user-data"
EXTENSIONS_DIR="$HOME/.vscode-iot/extensions"
PROFILE_NAME="IoT"
PROFILE_ICON="circuit-board"

# Same build prerequisites as the Personal profile (see its README).
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

# The open-vsx marketplace, shared with the Personal profile (same build).
cp "$SCRIPT_DIR/../../components-personal/04-vscode/product.overrides.json" "$VSCODE_ROOT/product.overrides.json"

# Headless CLI entry for extension management (see the Personal installer).
vscode_cli() {
  NODE_NO_WARNINGS=1 ELECTRON_RUN_AS_NODE=1 VSCODE_DEV=1 NODE_ENV=development "$CODE_BIN" "$VSCODE_ROOT/out/cli.js" "$VSCODE_ROOT" "$@"
}

echo "✓ Found self-built VS Code binary: $CODE_BIN"

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

# Desktop entry + teal icons. Its own WM_CLASS (Chromium's --class, which the
# `code` wrapper passes too) so its windows get this icon, not Personal's.
code_oss_install_linux_desktop code-oss-iot "VS Code (IoT)" 1F9E89 code-oss-iot --class=code-oss-iot

echo ""
echo "bode-claude is not on a marketplace: install it into this profile with"
echo "  ~/projects/bode/root/ops/javascript/bode-claude/reinstall.sh"
echo ""
echo "To launch the IoT profile: cd ~/centrica/iot-optimisation && code ."
echo ""
