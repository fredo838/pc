#!/bin/bash
# GitLab setup - SSH key generation + glab CLI for Centrica

set -e

echo "Setting up GitLab..."

SSH_KEY="$HOME/.ssh/id_ed25519_centrica"
EMAIL="frederik.bode@centrica.com"

# --- SSH key (idempotent) ---
if [ -f "$SSH_KEY" ] && [ -f "$SSH_KEY.pub" ]; then
  echo "✓ SSH key already exists at $SSH_KEY, skipping generation"
else
  echo "Generating SSH key for GitLab (Centrica)..."
  ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY" -N ""
  echo "✓ GitLab SSH key generated"
fi

KEY_FINGERPRINT="$(ssh-keygen -lf "$SSH_KEY.pub" | awk '{print $2}')"
if ssh-add -l 2>/dev/null | grep -q "$KEY_FINGERPRINT"; then
  echo "✓ SSH key already loaded in agent"
else
  ssh-add "$SSH_KEY"
  echo "✓ SSH key added to agent"
fi

echo ""
echo "Public key (add to GitLab if not already added, at https://gitlab.com/-/user_settings/ssh_keys):"
cat "$SSH_KEY.pub"

# --- glab CLI (idempotent) ---
echo ""
if command -v glab >/dev/null 2>&1; then
  echo "✓ glab CLI already installed ($(glab --version | head -n1))"
else
  echo "Installing glab CLI..."
  sudo apt-get update
  sudo apt-get install -y glab
  echo "✓ glab CLI installed"
fi

if [ "$(glab config get git_protocol 2>/dev/null)" = "ssh" ]; then
  echo "✓ glab already configured to use SSH protocol"
else
  glab config set git_protocol ssh
  echo "✓ glab configured to use SSH protocol"
fi

if glab auth status >/dev/null 2>&1; then
  echo "✓ glab already authenticated"
else
  echo "glab is not authenticated - launching login..."
  glab auth login --hostname gitlab.com --git-protocol ssh
fi
