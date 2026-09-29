#!/bin/bash
# Install the work profile configuration for VS Code (Stable).
# The `code` package itself is installed by components-global/04-vscode --
# this component only configures the Work profile against whatever install
# already exists.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$HOME/.vscode-work"
EXTENSIONS_DIR="$HOME/.vscode-work-ext"
PROFILE_NAME="Work"
PROFILE_ICON="project"

if ! command -v code >/dev/null 2>&1; then
  echo "⚠ VS Code ('code') not found on PATH."
  echo "  Install it first:"
  echo "    cd $(cd "$SCRIPT_DIR/../../components-global/04-vscode" && pwd)"
  echo "    bash install.sh"
  exit 1
fi

vscode_cli() {
  NODE_NO_WARNINGS=1 command code "$@"
}

source "$SCRIPT_DIR/../../lib/vscode-profile.sh"

# "Centrica" was this profile's old name; migrate its associations and drop it.
vscode_profile_register Centrica
vscode_profile_copy_config
vscode_profile_install_extensions
vscode_profile_remove_python_pack
vscode_profile_reconcile_manifest
vscode_profile_reconcile_storage Centrica "$HOME/centrica"

echo ""
