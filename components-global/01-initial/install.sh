#!/bin/bash
# Initial system setup - Basic dependencies and tools

set -e

echo "Installing basic system dependencies..."

sudo apt-get update
sudo apt-get upgrade -y
# wget/unzip: aws-cli and apt key downloads;
# python3-pil + imagemagick: the Personal VS Code ochre icon.
sudo apt-get install -y git gedit curl wget unzip apt-transport-https ca-certificates gnupg xclip \
    python3-pil imagemagick

echo "✓ Initial setup complete"
echo "Note: Check nvidia-smi if GPU is installed"
