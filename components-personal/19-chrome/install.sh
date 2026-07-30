#!/bin/bash
# Google Chrome browser installation

echo "Installing Google Chrome..."

# Add Google Chrome GPG key
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Add Google Chrome repository
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'

# Install Google Chrome
sudo apt-get update
sudo apt-get install -y google-chrome-stable

echo "✓ Google Chrome installed successfully"
google-chrome --version

echo ""
echo "Optional configuration:"
echo "  - Sign in to sync bookmarks and settings"
echo "  - Install recommended extensions from Chrome Web Store"
echo "  - Configure privacy settings as needed"
