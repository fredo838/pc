#!/bin/bash
# AWS CLI installation

set -e

echo "Installing AWS CLI v2..."

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download AWS CLI
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Extract and install
unzip -q awscliv2.zip
# --update makes re-runs upgrade in place instead of failing on an existing install
sudo ./aws/install --update

# Cleanup
cd ~
rm -rf "$TEMP_DIR"

echo "✓ AWS CLI installed successfully"
