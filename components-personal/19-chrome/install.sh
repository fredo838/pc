#!/bin/bash
# Google Chrome browser installation

set -e

echo "Installing Google Chrome..."

# Add Google Chrome GPG key (apt-key is deprecated; use a dedicated keyring)
sudo install -d -m 755 /etc/apt/keyrings
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor --yes -o /etc/apt/keyrings/google-chrome.gpg

# Add Google Chrome repository (overwrite, so re-runs don't duplicate the entry)
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

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
