#!/bin/bash
# Zsh shell installation and configuration

set -e

echo "Setting up Zsh..."

# macOS ships zsh as the default shell; only Linux needs installing it and
# switching the login shell.
if [ "$(uname -s)" = "Linux" ]; then
    sudo apt-get update
    sudo apt-get install -y zsh

    # chsh prompts for a password, so skip it if zsh is already the default
    ZSH_PATH="$(command -v zsh)"
    if [ -z "$ZSH_PATH" ]; then
        echo "⚠ Could not find zsh in PATH; skipping default shell change"
    elif [ "$(getent passwd "$USER" | cut -d: -f7)" = "$ZSH_PATH" ]; then
        echo "✓ zsh is already the default shell"
    else
        chsh -s "$ZSH_PATH"
    fi
fi

# Copy configuration files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/.zshrc" ]; then
    echo "Installing .zshrc configuration..."
    if [ -f ~/.zshrc ] && ! cmp -s "$SCRIPT_DIR/.zshrc" ~/.zshrc; then
        backup=~/.zshrc.bak.$(date +%Y%m%d-%H%M%S)
        cp ~/.zshrc "$backup"
        echo "✓ Previous ~/.zshrc backed up to $backup"
    fi
    cp "$SCRIPT_DIR/.zshrc" ~/.zshrc
    echo "✓ .zshrc installed to ~/.zshrc"
fi

echo "✓ Zsh set up successfully"
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
