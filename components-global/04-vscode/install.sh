#!/bin/bash
# VSCode installation

echo "Installing VSCode..."

# Add Microsoft GPG key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
rm /tmp/packages.microsoft.gpg

# Add VSCode repository
echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# Install VSCode
sudo apt-get update
sudo apt-get install -y code

# Copy configuration files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/Code/User"

mkdir -p "$CONFIG_DIR"

if [ -f "$SCRIPT_DIR/keybindings.json" ]; then
    echo "Installing keybindings configuration..."
    cp "$SCRIPT_DIR/keybindings.json" "$CONFIG_DIR/keybindings.json"
    echo "✓ keybindings.json installed"
fi

if [ -f "$SCRIPT_DIR/settings.json" ]; then
    echo "Installing settings configuration..."
    cp "$SCRIPT_DIR/settings.json" "$CONFIG_DIR/settings.json"
    echo "✓ settings.json installed"
fi

if [ -f "$SCRIPT_DIR/extensions.json" ]; then
    echo "Installing extensions recommendations..."
    cp "$SCRIPT_DIR/extensions.json" "$CONFIG_DIR/extensions.json"
    echo "✓ extensions.json installed"
fi

echo "✓ VSCode installed successfully with configuration"
echo ""
echo "Configuration files installed to: $CONFIG_DIR"
echo "Install recommended extensions in VSCode:"
echo "  - Click Extensions icon (Ctrl+Shift+X)"
echo "  - Click 'Show Recommended Extensions'"
