#!/bin/bash
# GNOME desktop environment settings

echo "Configuring GNOME settings..."

# Set window cycling mode to cycle-windows (scroll action on dash)
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows'

# Set dark mode preference
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

echo "✓ GNOME settings configured"
echo "  - Window cycling: enabled (scroll on dash)"
echo "  - Theme: set to prefer-dark"
