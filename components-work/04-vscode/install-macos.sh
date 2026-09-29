#!/bin/bash
# Install the work profile configuration for VS Code on macOS.
# Uses standard VS Code (Stable) with custom data/extensions dirs.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$HOME/.vscode-work"
EXTENSIONS_DIR="$HOME/.vscode-work-ext"
PROFILE_NAME="Work"
PROFILE_ICON="project"

if ! command -v code >/dev/null 2>&1; then
  echo "⚠ VS Code ('code') not found on PATH."
  echo "  Install it first:"
  echo "    brew install --cask visual-studio-code"
  exit 1
fi

vscode_cli() {
  command code "$@"
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
