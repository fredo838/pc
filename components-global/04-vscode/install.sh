#!/bin/bash
# Install the VS Code (Stable) apt package itself -- no profile configuration.
#
# This is global rather than work-only because two things depend on the
# package being present regardless of which profile(s) end up used on a
# given machine: components-work/04-vscode (the Work profile) and
# components-personal/04-vscode, which recolors the real VS Code logo this
# package installs at /usr/share/pixmaps/vscode.png into an ochre icon for
# the self-built Personal binary.

set -e

if command -v code >/dev/null 2>&1; then
  echo "✓ VS Code package already installed; skipping apt (no sudo needed)"
else
  echo "Installing VS Code..."

  # Add Microsoft GPG key and apt repository, but only if no source already provides
  # packages.microsoft.com/repos/code -- e.g. a prior manual VS Code .deb install writes
  # its own vscode.sources file. Adding a second, differently-keyed source for the same
  # repo makes apt fail with "Conflicting values set for option Signed-By".
  if grep -rq "packages\.microsoft\.com/repos/code" /etc/apt/sources.list.d/ /etc/apt/sources.list 2>/dev/null; then
    echo "Microsoft VS Code apt repository already configured; skipping repo setup."
  else
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    rm /tmp/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
  fi

  sudo apt-get update
  sudo apt-get install -y code

  echo "✓ VS Code package installed"
fi
