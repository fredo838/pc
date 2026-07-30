#!/bin/bash
# Steam installation and configuration

echo "Installing Steam..."

# Add multiverse repository for 32-bit support
sudo add-apt-repository multiverse
sudo apt-get update
sudo apt-get install -y steam

echo "✓ Steam installed successfully"
echo ""
echo "Optional: Install 32-bit NVIDIA drivers for better gaming support"
echo "  sudo dpkg --add-architecture i386"
echo "  sudo apt update"
echo "  sudo apt install libnvidia-gl-590:i386"
echo ""
echo "To install Hearthstone:"
echo "  1. Create directory: mkdir -p ~/.steam/debian-installation/steamapps/common/Hearthstone"
echo "  2. Download Battle.net-Setup.exe and place in that directory"
echo "  3. In Steam: Add a Game > Add a non-Steam Game > Browse and select folder"
echo "  4. Set compatibility to 'Proton Hotfix'"