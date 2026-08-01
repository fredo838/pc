#!/bin/bash
# Re-apply this repo's config to the live system (VS Code profiles + zsh).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/components-personal/04-vscode/install.sh"

cp "$SCRIPT_DIR/components-global/12-zsh/.zshrc" ~/.zshrc

bash "$SCRIPT_DIR/components-work/04-vscode/install.sh"
