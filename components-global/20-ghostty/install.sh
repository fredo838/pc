#!/bin/bash
# Ghostty terminal emulator installation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/component.sh"

echo "Installing Ghostty terminal emulator..."

# Ubuntu doesn't package Ghostty on every release: prefer apt when it does,
# then the snap, and otherwise skip with pointers.
if command -v ghostty >/dev/null 2>&1 || [ -x /snap/bin/ghostty ]; then
    echo "✓ Ghostty already installed"
elif apt-cache show ghostty >/dev/null 2>&1; then
    echo "Installing Ghostty from apt..."
    sudo apt-get install -y ghostty
elif command -v snap >/dev/null 2>&1 && snap info ghostty >/dev/null 2>&1; then
    echo "Installing Ghostty from snap..."
    sudo snap install ghostty --classic
else
    skip_component "no Ghostty package available via apt or snap" \
        "see https://ghostty.org/docs/install/binary for other install options"
fi

# Copy configuration files
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"

mkdir -p "$GHOSTTY_CONFIG_DIR"

if [ -f "$SCRIPT_DIR/ghostty-config" ]; then
    echo "Installing Ghostty configuration..."
    cp "$SCRIPT_DIR/ghostty-config" "$GHOSTTY_CONFIG_DIR/config"
    echo "✓ Configuration installed to $GHOSTTY_CONFIG_DIR/config"
fi

echo "✓ Ghostty installed successfully"

echo ""
echo "Configuration file:"
echo "  Location: $GHOSTTY_CONFIG_DIR/config"
echo "  Reload config: Ctrl+Shift+comma (or Cmd+Shift+comma on macOS)"
echo "  View all options: ghostty +show-config --default --docs"
