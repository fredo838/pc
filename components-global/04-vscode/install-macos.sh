#!/bin/bash
# Install/verify VS Code on macOS (global component)
#
# On macOS, VS Code is typically installed via Homebrew or downloaded from Microsoft.
# This script checks if 'code' is available; if not, provides installation instructions.

set -e

if command -v code >/dev/null 2>&1; then
  echo "✓ VS Code already installed at: $(command -v code)"
else
  echo "⚠ VS Code ('code') not found on PATH."
  echo ""
  echo "Install via Homebrew:"
  echo "  brew install --cask visual-studio-code"
  echo ""
  echo "Or download from https://code.visualstudio.com/download"
  exit 1
fi
