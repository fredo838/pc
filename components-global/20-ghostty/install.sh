#!/bin/bash
# Ghostty terminal emulator installation

echo "Installing Ghostty terminal emulator..."

# Note: Ghostty installation method depends on your system
# For Fedora/RHEL: dnf install ghostty
# For Debian/Ubuntu: May need to build from source or add PPA

# Check if ghostty is available in repos
if apt-cache search ghostty | grep -q "^ghostty "; then
    echo "Installing Ghostty from repositories..."
    sudo apt-get install -y ghostty
else
    echo "Ghostty not found in default repositories"
    echo "You may need to:"
    echo "  1. Add a PPA with Ghostty"
    echo "  2. Build from source: https://github.com/mitchellh/ghostty"
    echo "  3. Download pre-built binary"
    exit 1
fi

# Copy configuration files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"

mkdir -p "$GHOSTTY_CONFIG_DIR"

if [ -f "$SCRIPT_DIR/ghostty-config" ]; then
    echo "Installing Ghostty configuration..."
    cp "$SCRIPT_DIR/ghostty-config" "$GHOSTTY_CONFIG_DIR/config"
    echo "✓ Configuration installed to $GHOSTTY_CONFIG_DIR/config"
fi

echo "✓ Ghostty installed successfully"
ghostty --version

echo ""
echo "Configuration file:"
echo "  Location: $GHOSTTY_CONFIG_DIR/config"
echo "  Reload config: Ctrl+Shift+comma (or Cmd+Shift+comma on macOS)"
echo "  View all options: ghostty +show-config --default --docs"
