#!/bin/bash
# Pulumi installation

echo "Installing Pulumi..."

curl -fsSL https://get.pulumi.com | sh

echo "✓ Pulumi installed successfully"
echo "Note: You may need to add Pulumi to your PATH"
echo "Add to ~/.zshrc or ~/.bashrc: export PATH=~/.pulumi/bin:\$PATH"
