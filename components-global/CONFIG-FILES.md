# Configuration Files Organization

This document maps all configuration files to their respective components.

## Summary

Configuration files have been organized into their corresponding component directories. Each install script automatically installs these files to the appropriate locations.

## Component-Specific Configs

### 04-vscode (VSCode)

This component installs the VS Code package only.

Profile-specific VS Code user configuration is now stored separately in:
- `components-personal/04-vscode/`
- `components-work/04-vscode/`

Use the appropriate profile install script to deploy user settings and recommended extensions:

**Install package only:**
```bash
cd components-global/04-vscode
bash install.sh
```

**Install personal profile config:**
```bash
cd components-personal/04-vscode
bash install.sh
```

**Install work profile config:**
```bash
cd components-work/04-vscode
bash install.sh
```

### 12-zsh (Zsh Shell)

Configuration files for Zsh shell and terminal keybindings.

| File | Location | Destination | Purpose |
|------|----------|-------------|---------|
| .zshrc | `components-global/12-zsh/` | `~/.zshrc` | Main shell configuration with keybindings, clipboard, and aliases |
| iterm2-keymap.json | `components-global/12-zsh/` | Manual (iTerm2 Preferences) | iTerm2 key mappings for macOS |

**Install with:**
```bash
cd components-global/12-zsh
bash install.sh
```

### 20-ghostty (Ghostty Terminal)

Configuration file for Ghostty terminal emulator.

| File | Location | Destination | Purpose |
|------|----------|-------------|---------|
| ghostty-config | `components-global/20-ghostty/` | `~/.config/ghostty/config` | Terminal emulator configuration and keybindings |

**Install with:**
```bash
cd components-global/20-ghostty
bash install.sh
```

## Installation Overview

### Automatic Installation

When you run each component's `install.sh`, the configuration files are automatically:
1. Located in the component directory
2. Copied to the appropriate system location
3. Set with correct permissions

### Manual Installation

If needed, you can manually install config files for a profile:

```bash
# Personal VSCode profile
cp components-personal/04-vscode/keybindings.json ~/.vscode-personal/User/keybindings.json
cp components-personal/04-vscode/settings.json ~/.vscode-personal/User/settings.json
cp components-personal/04-vscode/extensions.json ~/.vscode-personal/User/extensions.json

# Work VSCode profile
cp components-work/04-vscode/keybindings.json ~/.vscode-work/User/keybindings.json
cp components-work/04-vscode/settings.json ~/.vscode-work/User/settings.json
cp components-work/04-vscode/extensions.json ~/.vscode-work/User/extensions.json

# Zsh
cp components-global/12-zsh/.zshrc ~/.zshrc

# Ghostty
mkdir -p ~/.config/ghostty
cp components-global/20-ghostty/ghostty-config ~/.config/ghostty/config

# iTerm2 (macOS - manual load in preferences)
# See components-global/12-zsh/README.md for instructions
```

## Configuration Relationships

### Related Components

These components work together and should be installed in order:

1. **12-zsh** → Base shell configuration
2. **04-vscode** → Editor with terminal integration
3. **20-ghostty** → Terminal with zsh

The keybindings in all three are synchronized for consistent behavior.

### Shared Keybindings

The following escape sequences are consistent across components:

- `\x1b[86;5u` - Paste (Ctrl+Shift+V)
- `\x1b[99;6u` - Copy (Ctrl+Shift+C)
- `\x1b[1;6C` - Forward word select (Ctrl+Shift+Right)
- `\x1b[1;6D` - Backward word select (Ctrl+Shift+Left)
- `\x1b[1;6H` - Start of line select (Ctrl+Shift+Home)
- `\x1b[1;6F` - End of line select (Ctrl+Shift+End)
- `\x1b[127;5u` - Delete word backward (Ctrl+Backspace)

## Directory Structure

```
components-global/
├── 04-vscode/
│   ├── install.sh
│   ├── README.md
│   ├── keybindings.json
│   ├── settings.json
│   └── extensions.json
├── 12-zsh/
│   ├── install.sh
│   ├── README.md
│   ├── .zshrc
│   └── iterm2-keymap.json
├── 20-ghostty/
│   ├── install.sh
│   ├── README.md
│   └── ghostty-config
├── CONFIG-FILES.md (this file)
├── README.md
├── QUICK-START.md
└── install-all.sh
```

## File Permissions

After installation, expected file permissions:

```bash
# Personal VSCode profile config
~/.vscode-personal/User/keybindings.json  (644)
~/.vscode-personal/User/settings.json     (644)
~/.vscode-personal/User/extensions.json   (644)

# Work VSCode profile config
~/.vscode-work/User/keybindings.json  (644)
~/.vscode-work/User/settings.json     (644)
~/.vscode-work/User/extensions.json   (644)

# Zsh config
~/.zshrc                               (644)

# Ghostty config
~/.config/ghostty/config               (644)
```

## Updating Configurations

### From Component Directory

To update a configuration after installation:

```bash
# Personal VSCode profile
cp keybindings.json ~/.vscode-personal/User/
cp settings.json ~/.vscode-personal/User/
cp extensions.json ~/.vscode-personal/User/

# Work VSCode profile
cp keybindings.json ~/.vscode-work/User/
cp settings.json ~/.vscode-work/User/
cp extensions.json ~/.vscode-work/User/
```

### Version Control

All configurations are stored in git at:
- `components-global/04-vscode/*.json`
- `components-global/12-zsh/.zshrc`
- `components-global/12-zsh/iterm2-keymap.json`
- `components-global/20-ghostty/ghostty-config`

To track custom changes:
```bash
cd ~/projects/pc
git add components-global/
git commit -m "Update configurations"
```

## Customization Guide

Each component README has customization instructions:

- [04-vscode/README.md](04-vscode/README.md) - VSCode customization
- [12-zsh/README.md](12-zsh/README.md) - Zsh customization
- [20-ghostty/README.md](20-ghostty/README.md) - Ghostty customization

## Original Source Files

These configuration files were originally located in the project root:
- `.zshrc` → Moved to `components-global/12-zsh/`
- `ghostty-config` → Moved to `components-global/20-ghostty/`
- `iterm2-keymap.json` → Moved to `components-global/12-zsh/`
- `vscode-keybindings.json` → Moved to `components-global/04-vscode/keybindings.json`
- `.vscode/settings.json` → Moved to `components-global/04-vscode/settings.json`
- `.vscode/extensions.json` → Moved to `components-global/04-vscode/extensions.json`

You can keep or remove the original files from the project root as needed.

## Troubleshooting

### Configuration not being used

1. Verify correct installation location
   ```bash
   # Personal VSCode profile
   ls ~/.vscode-personal/User/

   # Work VSCode profile
   ls ~/.vscode-work/User/

   # Ghostty
   ls ~/.config/ghostty/

   # Zsh
   cat ~/.zshrc | head -5
   ```

2. Reload the application:
   - VSCode: Restart the application
   - Ghostty: Ctrl+Shift+comma to reload
   - Zsh: `exec zsh` or logout/login

3. Check for syntax errors in JSON files:
   ```bash
   python3 -m json.tool ~/.vscode-personal/User/keybindings.json
   python3 -m json.tool ~/.vscode-work/User/keybindings.json
   ```

### Conflicts with existing configs

If you already have configurations:
1. Backup originals: `cp ~/.zshrc ~/.zshrc.backup`
2. Merge settings manually rather than overwriting
3. Compare files: `diff ~/.zshrc components-global/12-zsh/.zshrc`

### Permissions issues

If configs can't be read:
```bash
# Fix permissions
chmod 644 ~/.vscode-personal/User/*
chmod 644 ~/.vscode-work/User/*
chmod 644 ~/.zshrc
chmod 644 ~/.config/ghostty/config

# Ensure directories exist
mkdir -p ~/.vscode-personal/User
mkdir -p ~/.vscode-work/User
mkdir -p ~/.config/ghostty
```
