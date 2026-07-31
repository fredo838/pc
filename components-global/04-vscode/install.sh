#!/bin/bash
# VSCode installation

echo "Installing VSCode..."

# Add Microsoft GPG key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
rm /tmp/packages.microsoft.gpg

# Add VSCode repository
echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# Install VSCode
sudo apt-get update
sudo apt-get install -y code

echo "✓ VSCode package installed"

echo "Note: this script installs the VSCode package only."
echo "Per-profile User configuration is managed in:"
echo "  components-personal/04-vscode/"
echo "  components-work/04-vscode/"
echo "To install config for a profile, run the appropriate component's install.sh."
