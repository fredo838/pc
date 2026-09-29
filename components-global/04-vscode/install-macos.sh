#!/bin/bash
# Install/verify VS Code on macOS (global component)
#
# On macOS, VS Code is typically installed via Homebrew or downloaded from Microsoft.
# This script checks that 'code' is on PATH and that the app bundle is in
# /Applications, where components-personal/04-vscode takes the real logo from
# to build the Personal profile's ochre icon.

set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../lib/component.sh"

APP_BUNDLE="/Applications/Visual Studio Code.app"

if command -v code >/dev/null 2>&1; then
  echo "✓ VS Code already installed at: $(command -v code)"
else
  skip_component "VS Code ('code') not found on PATH" \
    "brew install --cask visual-studio-code" \
    "or download it from https://code.visualstudio.com/download"
fi

if [ -d "$APP_BUNDLE" ]; then
  echo "✓ App bundle found at: $APP_BUNDLE"
else
  echo "⚠ $APP_BUNDLE not found; the Personal profile's ochre icon will be skipped."
  echo "  Move VS Code into /Applications (Homebrew's cask installs it there)."
fi

if ! python3 -c "import PIL" >/dev/null 2>&1; then
  echo "⚠ Pillow not installed for python3; the Personal profile's ochre icon will be skipped."
  echo "  Install it with: python3 -m pip install --user Pillow"
fi
