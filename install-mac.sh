#!/bin/bash
# Set up (or re-apply) the parts of this repo that support macOS: the VS Code
# install check, the Personal and Work VS Code profiles, and zsh config.
# Safe to re-run.

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_DIR/lib/install-runner.sh"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "❌ install-mac.sh is for macOS; on Ubuntu run: bash install-ubuntu.sh"
  exit 1
fi

# Behind Zscaler, Node (and so VS Code's extension CLI) needs its CA cert.
if [ -f "$HOME/zscaler-ca.pem" ]; then
  export NODE_EXTRA_CA_CERTS="$HOME/zscaler-ca.pem"
fi

set +e
run_component "$REPO_DIR/components-global/04-vscode/install-macos.sh"
run_component "$REPO_DIR/components-personal/04-vscode/install-macos.sh"
run_component "$REPO_DIR/components-work/04-vscode/install-macos.sh"
run_component "$REPO_DIR/components-global/12-zsh/install.sh"

print_summary
