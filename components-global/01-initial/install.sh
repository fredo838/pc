#!/bin/bash
# Initial system setup - Basic dependencies and tools

echo "Installing basic system dependencies..."

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y git gedit curl apt-transport-https ca-certificates gnupg xclip

echo "✓ Initial setup complete"
echo "Note: Check nvidia-smi if GPU is installed"
