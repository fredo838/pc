#!/bin/bash
# Zsh shell installation and configuration

echo "Installing Zsh..."

# Install zsh
sudo apt-get update
sudo apt-get install -y zsh

# Set zsh as default shell
ZSH_PATH="$(command -v zsh)"
if [ -n "$ZSH_PATH" ]; then
    chsh -s "$ZSH_PATH"
else
    echo "⚠ Could not find zsh in PATH; skipping default shell change"
fi

# Copy configuration files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/.zshrc" ]; then
    echo "Installing .zshrc configuration..."
    cp "$SCRIPT_DIR/.zshrc" ~/.zshrc
    echo "✓ .zshrc installed to ~/.zshrc"
fi

echo "✓ Zsh installed successfully"
echo ""
echo "Note: You must log out and log back in for zsh to become your default shell"
echo ""
echo "Configuration files available:"
echo "  - .zshrc: Main shell configuration (already installed)"
echo "  - iterm2-keymap.json: For macOS iTerm2 terminal"
echo ""
echo "To use iTerm2 keymap (macOS only):"
echo "  1. Open iTerm2 Preferences > Profiles > Keys"
echo "  2. Click 'Load Preset' and select: $SCRIPT_DIR/iterm2-keymap.json"
echo "  3. Enable 'Report keys using CSI u mode'"
echo ""
echo "Known issue: Slow terminal after login on systems with NVIDIA drivers"
echo "  See: https://bugs.launchpad.net/ubuntu/+source/nvidia-graphics-drivers-535/+bug/2042301"
