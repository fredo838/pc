#!/bin/bash
# GitLab setup - SSH key generation for Centrica

echo "Setting up GitLab..."

# Generate SSH key for GitLab
echo "Generating SSH key for GitLab (Centrica)..."
ssh-keygen -t ed25519 -C "frederik.bode@centrica.com" -f ~/.ssh/id_ed25519_centrica -N ""

# Add key to SSH agent
ssh-add ~/.ssh/id_ed25519_centrica

echo "✓ GitLab SSH key generated"
echo "Add the following public key to your GitLab account settings:"
cat ~/.ssh/id_ed25519_centrica.pub
