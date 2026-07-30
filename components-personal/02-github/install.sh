#!/bin/bash
# Git and GitHub setup - Configuration and SSH key generation

echo "Setting up Git and GitHub..."

# Configure Git
git config --global user.email "fredo.bode@gmail.com"
git config --global user.name "Frederik Bode"

# Generate SSH key for GitHub
echo "Generating SSH key for GitHub (personal)..."
ssh-keygen -t ed25519 -C "fredo.bode@gmail.com" -f ~/.ssh/id_ed25519_personal -N ""

# Add key to SSH agent
ssh-add ~/.ssh/id_ed25519_personal

echo "✓ GitHub SSH key generated"
echo "Add the following public key to https://github.com/settings/keys :"
cat ~/.ssh/id_ed25519_personal.pub
