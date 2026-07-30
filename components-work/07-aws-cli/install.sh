#!/bin/bash
# AWS CLI installation

echo "Installing AWS CLI v2..."

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Extract and install
unzip awscliv2.zip
sudo ./aws/install

# Cleanup
cd ~
rm -rf "$TEMP_DIR"

echo "✓ AWS CLI installed successfully"
