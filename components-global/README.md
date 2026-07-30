# Global Components

Development tools, infrastructure, and settings used in all contexts (work and personal).

## 📋 Components List

### Core System
| # | Component | Purpose |
|---|-----------|---------|
| 01 | **initial** | Base system dependencies and tools |

### Development & Coding
| # | Component | Purpose |
|---|-----------|---------|
| 04 | **vscode** | Visual Studio Code editor with custom keybindings |
| 05 | **python-pip** | Python package manager |
| 12 | **zsh** | Zsh shell with advanced keybindings |
| 13 | **golang** | Go programming language |
| 16 | **python313** | Python 3.13 runtime |

### Infrastructure & DevOps
| # | Component | Purpose |
|---|-----------|---------|
| 08 | **kubectl** | Kubernetes CLI |
| 17 | **pulumi** | Infrastructure as Code (IaC) tool |
| 18 | **gcloud** | Google Cloud SDK |

### Configuration
| # | Component | Purpose |
|---|-----------|---------|
| 09 | **python-config** | Python configuration files (.netrc, pip.conf, .pypirc) |

### Desktop & Terminal
| # | Component | Purpose |
|---|-----------|---------|
| 10 | **gnome-settings** | GNOME desktop customizations |
| 20 | **ghostty** | Ghostty terminal emulator |

### Media & Entertainment
| # | Component | Purpose |
|---|-----------|---------|
| 14 | **qbittorrent** | Torrent client |
| 15 | **vlc** | VLC media player |

## 🚀 Quick Installation

### Install All Global Components

```bash
cd components-global
bash install-all.sh all
```

### Interactive Selection

```bash
cd components-global
bash install-all.sh
# Follow prompts to select components
```

### Install Individual Component

```bash
cd components-global/01-initial
bash install.sh
```

## 📖 Component-Specific Guides

Each component has detailed documentation:

- [01-initial/install.sh](01-initial/install.sh) - Base system setup
- [04-vscode/README.md](04-vscode/README.md) - VSCode with keybindings
- [05-python-pip/install.sh](05-python-pip/install.sh) - Python pip
- [08-kubectl/install.sh](08-kubectl/install.sh) - Kubernetes
- [09-python-config/install.sh](09-python-config/install.sh) - Python configs
- [10-gnome-settings/install.sh](10-gnome-settings/install.sh) - Desktop settings
- [12-zsh/README.md](12-zsh/README.md) - Zsh shell
- [13-golang/install.sh](13-golang/install.sh) - Go language
- [14-qbittorrent/install.sh](14-qbittorrent/install.sh) - Torrent client
- [15-vlc/install.sh](15-vlc/install.sh) - Media player
- [16-python313/install.sh](16-python313/install.sh) - Python 3.13
- [17-pulumi/install.sh](17-pulumi/install.sh) - Pulumi IaC
- [18-gcloud/install.sh](18-gcloud/install.sh) - Google Cloud
- [20-ghostty/README.md](20-ghostty/README.md) - Ghostty terminal

## 📁 Directory Structure

```
components-global/
├── 01-initial/
│   └── install.sh
├── 04-vscode/
│   ├── install.sh
│   ├── README.md
│   ├── keybindings.json
│   ├── settings.json
│   └── extensions.json
├── 05-python-pip/
│   └── install.sh
├── 08-kubectl/
│   └── install.sh
├── 09-python-config/
│   └── install.sh
├── 10-gnome-settings/
│   └── install.sh
├── 12-zsh/
│   ├── install.sh
│   ├── README.md
│   ├── .zshrc
│   └── iterm2-keymap.json
├── 13-golang/
│   └── install.sh
├── 14-qbittorrent/
│   └── install.sh
├── 15-vlc/
│   └── install.sh
├── 16-python313/
│   └── install.sh
├── 17-pulumi/
│   └── install.sh
├── 18-gcloud/
│   └── install.sh
├── 20-ghostty/
│   ├── install.sh
│   ├── README.md
│   └── ghostty-config
├── install-all.sh          (Master script)
├── README.md               (This file)
├── CONFIG-FILES.md         (Configuration mapping)
└── QUICK-START.md          (Quick reference)
```

## 🔑 Configuration Files

Configuration files are included with their components:

| Component | Config Files | Destination |
|-----------|--------------|-------------|
| vscode | keybindings.json, settings.json, extensions.json | `~/.config/Code/User/` |
| zsh | .zshrc, iterm2-keymap.json | `~/.zshrc`, iTerm2 Preferences |
| ghostty | ghostty-config | `~/.config/ghostty/config` |

See [CONFIG-FILES.md](CONFIG-FILES.md) for complete details.

## 📋 Recommended Installation Order

For a fresh Ubuntu system:

1. **01-initial** - System dependencies (required first)
2. **04-vscode** - Code editor
3. **12-zsh** - Shell (requires logout/login)
4. **05-python-pip** - Python
5. **16-python313** - Python 3.13
6. **13-golang** - Go
7. **08-kubectl** - Kubernetes
8. **09-python-config** - Python configs
9. **10-gnome-settings** - Desktop tweaks
10. **17-pulumi** - Infrastructure as Code
11. **18-gcloud** - Google Cloud SDK
12. **20-ghostty** - Terminal emulator
13. **14-qbittorrent** - Torrent client
14. **15-vlc** - Media player

## ⚙️ Key Configuration

### VSCode
- Custom keybindings for editor and terminal
- Settings for Python and Go formatting
- Recommended extensions list
- Multiple profiles (work/personal)

### Zsh
- Advanced clipboard support
- Smart selection and deletion
- Custom keybindings matching VSCode
- Profile-aware `code` command
- Pulumi PATH integration

### Python
- Pip package manager
- Python 3.13 from deadsnakes PPA
- Configuration files for credentials and indexes

### Ghostty Terminal
- Zsh integration
- Custom keybindings
- Clipboard escape sequences

## 🔄 Post-Installation

### After Installing Zsh (12-zsh)

The shell won't become default until you log out and log back in. Or run immediately:

```bash
exec zsh
```

### After Installing VSCode (04-vscode)

1. Open VSCode: `code`
2. Install recommended extensions (Ctrl+Shift+X)
3. Test keybindings
4. Review settings if needed

### After Installing Python (05, 16)

Verify installations:

```bash
python3 --version
python3.13 --version
pip --version
```

### After Installing kubectl (08)

Test connection:

```bash
kubectl version --client
```

### After Installing Pulumi (17)

Update PATH if needed:

```bash
export PATH=$HOME/.pulumi/bin:$PATH
```

(Already included in .zshrc)

### After Installing gcloud (18)

Initialize and authenticate:

```bash
gcloud init
gcloud auth login
```

### After Installing Ghostty (20)

1. Start Ghostty: `ghostty`
2. Test keybindings
3. Reload config with Ctrl+Shift+comma

## ✅ Verification

Verify installations after completing:

```bash
# Check versions
zsh --version
code --version
python3 --version
python3.13 --version
go version
kubectl version --client
ghostty --version
google-chrome --version (if also installed personal)
```

## 🚨 Important Notes

### Zsh Login/Logout Requirement

After installing zsh, you MUST log out and log back in for it to become your default shell. Or run: `exec zsh`

### Path Environment Variables

Some tools add entries to PATH:
- Pulumi: `~/.pulumi/bin`
- Check `~/.zshrc` for active PATH modifications

### Python Configuration

The `09-python-config` component creates config files that you must manually edit:
- `~/.netrc` - Add authentication credentials
- `~/.pip/pip.conf` - Add package index URLs
- `~/.pypirc` - Add PyPI repository configuration

### GPU Support

If you have NVIDIA GPU, check after `01-initial`:

```bash
nvidia-smi
```

If not present and needed, install drivers manually.

## 🔧 Customization

### Edit Component Scripts

Before running, review and customize:

```bash
# View script
cat 04-vscode/install.sh

# Edit if needed
nano 04-vscode/install.sh

# Then run
bash 04-vscode/install.sh
```

### Update Configuration Files

Edit `.zshrc`, keybindings, or other configs:

```bash
# Edit zsh config
nano 12-zsh/.zshrc

# Edit VSCode keybindings
nano 04-vscode/keybindings.json

# Re-run install to update system files
bash 12-zsh/install.sh
bash 04-vscode/install.sh
```

## 📞 Troubleshooting

### Component Fails to Install

1. Check internet connection
2. Run `sudo apt-get update` manually
3. Review error messages
4. Try installing dependencies individually

### Configuration Not Applied

1. Verify correct destination path
2. Reload application (restart or Ctrl+Shift+comma for Ghostty)
3. Check file syntax (JSON validator for .json files)
4. Review script output for errors

### Missing Tools

If a component can't find a tool:

```bash
# Check if repository is accessible
sudo apt-cache search tool-name

# Update package lists
sudo apt-get update

# Try manual installation
sudo apt-get install package-name
```

## 🎯 Next Steps

1. Choose components to install
2. Run `install-all.sh` with interactive selection
3. Review documentation for each component
4. Test installations
5. Customize configurations as needed
6. Commit changes to git

## 📚 Additional Resources

- [CONFIG-FILES.md](CONFIG-FILES.md) - Configuration file locations and usage
- [QUICK-START.md](QUICK-START.md) - Quick reference guide
- [../README-INSTALL.md](../README-INSTALL.md) - Overall installation guide
- [../components-work/README.md](../components-work/README.md) - Work-specific components
- [../components-personal/README.md](../components-personal/README.md) - Personal components

## 📝 Notes

- All scripts use `sudo` and may prompt for password
- Components are numbered for suggested installation order
- Each component is independent but some have soft dependencies (e.g., zsh before ghostty)
- Configuration files are tracked in git for easy backup and sharing
