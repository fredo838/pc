#!/bin/bash
# Git and GitHub setup - Configuration and SSH key generation

set -e

SSH_KEY="$HOME/.ssh/id_ed25519_personal"
EMAIL="fredo.bode@gmail.com"

echo "Setting up Git and GitHub..."

# Configure Git
git config --global user.email "$EMAIL"
git config --global user.name "Frederik Bode"

# Generate SSH key for GitHub (only once -- never overwrite an existing key)
mkdir -p "$HOME/.ssh"
if [ -f "$SSH_KEY" ] && [ -f "$SSH_KEY.pub" ]; then
  echo "✓ SSH key already exists: $SSH_KEY"
else
  echo "Generating SSH key for GitHub (personal)..."
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY" -N ""
fi

# Add key to SSH agent
KEY_FINGERPRINT="$(ssh-keygen -lf "$SSH_KEY.pub" | awk '{print $2}')"
if ssh-add -l 2>/dev/null | grep -q "$KEY_FINGERPRINT"; then
  echo "✓ SSH key already loaded in agent"
else
  ssh-add "$SSH_KEY"
fi

echo "✓ GitHub SSH key ready"
echo "Add the following public key to https://github.com/settings/keys (if not already added):"
cat "$SSH_KEY.pub"
