#!/bin/bash
# Re-apply this repo's config to the live system (VS Code profiles + zsh).
# Supports both macOS and Linux.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_TYPE="$(uname -s)"

# Detect platform
case "$OS_TYPE" in
  Darwin)
    PLATFORM="macos"
    # Configure Zscaler certificate for Node.js if it exists
    if [ -f "$HOME/zscaler-ca.pem" ]; then
      export NODE_EXTRA_CA_CERTS="$HOME/zscaler-ca.pem"
    fi
    ;;
  Linux)
    PLATFORM="linux"
    ;;
  *)
    echo "❌ Unsupported OS: $OS_TYPE"
    exit 1
    ;;
esac

echo "🖥️  Platform: $PLATFORM ($(uname -m))"
echo ""

# Run platform-specific install scripts
echo "════════════════════════════════════════════════════════════════"
echo "📦 Global VS Code Setup"
echo "════════════════════════════════════════════════════════════════"
bash "$SCRIPT_DIR/components-global/04-vscode/install-$PLATFORM.sh"
echo ""

echo "════════════════════════════════════════════════════════════════"
echo "💜 Personal Profile (Self-built Code-OSS + Claude AI)"
echo "════════════════════════════════════════════════════════════════"
bash "$SCRIPT_DIR/components-personal/04-vscode/install-$PLATFORM.sh"
echo ""

echo "════════════════════════════════════════════════════════════════"
echo "💼 Work Profile (VS Code Stable + GitHub Copilot)"
echo "════════════════════════════════════════════════════════════════"
bash "$SCRIPT_DIR/components-work/04-vscode/install-$PLATFORM.sh"
echo ""

echo "Updating shell configuration..."
if [ -f "$HOME/.zshrc" ]; then
  cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d-%H%M%S)"
fi
cp "$SCRIPT_DIR/components-global/12-zsh/.zshrc" "$HOME/.zshrc"

if grep -q -- "--profile Personal" "$HOME/.zshrc" \
  && grep -q -- "--profile Work" "$HOME/.zshrc" \
  && grep -q -- "--extensions-dir ~/.vscode-personal/extensions" "$HOME/.zshrc" \
  && grep -q -- "--user-data-dir ~/.vscode-personal/user-data" "$HOME/.zshrc" \
  && grep -q -- "--extensions-dir ~/.vscode-work-ext" "$HOME/.zshrc"; then
  echo "✓ ~/.zshrc updated with profile-aware code routing"
else
  echo "❌ ~/.zshrc update validation failed"
  exit 1
fi
echo ""

echo "════════════════════════════════════════════════════════════════"
echo "✅ Configuration updated for $PLATFORM"
echo "════════════════════════════════════════════════════════════════"
