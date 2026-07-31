# Ubuntu Installation Components

Modular installation scripts organized into three categories: **global**, **work**, and **personal**.

## 📁 Directory Structure

```
pc/
├── components-global/       # Tools and settings for all contexts
├── components-work/         # Work-specific (Centrica/GitLab)
├── components-personal/     # Personal use and hobbies
├── README-INSTALL.md        # This file
└── install-ubuntu.sh        # Original monolithic script (reference)
```

## 🌍 Components-Global

Tools and configurations used regardless of work or personal context.

### Development Tools
- **01-initial** - Base system dependencies
- **04-vscode** - Visual Studio Code with custom keybindings
- **05-python-pip** - Python package manager
- **08-kubectl** - Kubernetes CLI
- **09-python-config** - Python configuration (.netrc, pip.conf, .pypirc)
- **12-zsh** - Zsh shell with advanced keybindings
- **13-golang** - Go programming language
- **16-python313** - Python 3.13 runtime
- **17-pulumi** - Infrastructure as Code

### Infrastructure & Cloud
- **18-gcloud** - Google Cloud SDK

### Desktop & Terminal
- **10-gnome-settings** - GNOME desktop customizations
- **20-ghostty** - Ghostty terminal emulator

### Media & Entertainment
- **14-qbittorrent** - Torrent client
- **15-vlc** - Media player

### Documentation
- [README.md](components-global/README.md) - Global components guide
- [CONFIG-FILES.md](components-global/CONFIG-FILES.md) - Configuration file locations

## 💼 Components-Work

Work-related tools for Centrica development.

### Version Control & Git
- **03-gitlab** - GitLab SSH configuration (Centrica)

### Infrastructure & Cloud
- **06-aws-vpn-client** - AWS VPN client (work network)
- **07-aws-cli** - AWS CLI v2 (work projects)

### Usage
```bash
cd components-work
bash install-all.sh
```

Or individual components:
```bash
cd components-work/03-gitlab
bash install.sh
```

See [components-work/README.md](components-work/README.md) for details.

## 👤 Components-Personal

Personal projects, browsing, and hobbies.

### Version Control & Git
- **02-github** - GitHub SSH configuration (personal account)

### Browsing
- **19-chrome** - Google Chrome browser

### Entertainment
- **11-steam** - Steam gaming platform

### Usage
```bash
cd components-personal
bash install-all.sh
```

Or individual components:
```bash
cd components-personal/02-github
bash install.sh
```

See [components-personal/README.md](components-personal/README.md) for details.

## 🚀 Quick Start

### Install Everything

```bash
# Global components (all contexts)
cd components-global
bash install-all.sh

# Work components (Centrica projects)
cd ../components-work
bash install-all.sh

# Personal components (personal projects)
cd ../components-personal
bash install-all.sh
```

### Install Selectively

**For development work:**
```bash
cd components-global
bash install-all.sh        # Select core tools
cd ../components-work
bash install-all.sh        # Add work VPN and GitLab
```

**For personal projects:**
```bash
cd components-global
bash install-all.sh        # Select core tools
cd ../components-personal
bash install-all.sh        # Add GitHub and browsing
```

### Interactive Selection

Each directory has `install-all.sh` with interactive mode:

```bash
cd components-global
bash install-all.sh
# Follow prompts to select components
```

## 📋 Component Categories

### By Purpose

| Purpose | Components | Location |
|---------|-----------|----------|
| **Version Control** | GitHub, GitLab | personal, work |
| **Development** | VSCode, Python, Go, kubectl | global |
| **Shell & Terminal** | Zsh, Ghostty | global |
| **Infrastructure** | AWS, gcloud, Pulumi | work (AWS), global (gcloud/Pulumi) |
| **Cloud & DevOps** | kubectl, gcloud, Pulumi | global |
| **Browsers** | Chrome | personal |
| **Media** | Steam, VLC, QBit | personal, global |
| **System** | Initial, GNOME, Python config | global |

### By Context

**Global (Install for all setups):**
All of components-global

**Work Setup (Centrica):**
components-global + components-work

**Personal Setup:**
components-global + components-personal

**Full Setup (Both work and personal):**
All three directories

## 🔑 Key Configuration Files

Configuration files are organized with their components:

- **04-vscode**: `keybindings.json`, `settings.json`, `extensions.json`
- **12-zsh**: `.zshrc`, `iterm2-keymap.json`
- **20-ghostty**: `ghostty-config`

See [CONFIG-FILES.md](components-global/CONFIG-FILES.md) for complete mapping.

## 🔄 Recommended Installation Order

For a fresh Ubuntu setup:

### Phase 1: Base System (Required)
1. components-global/**01-initial** - System dependencies

### Phase 2: Development Environment (Choose based on context)

**For work (Centrica):**
1. components-global/**04-vscode** - Code editor
2. components-work/**03-gitlab** - GitLab SSH keys
3. components-work/**06-aws-vpn-client** - Work VPN
4. components-work/**07-aws-cli** - AWS tooling

**For personal projects:**
1. components-global/**04-vscode** - Code editor
2. components-personal/**02-github** - GitHub SSH keys

### Phase 3: Development Tools (For all)
3. components-global/**05-python-pip** - Python
4. components-global/**12-zsh** - Shell (requires logout)
5. components-global/**13-golang** - Go
6. components-global/**16-python313** - Python 3.13
7. components-global/**08-kubectl** - Kubernetes
8. components-global/**09-python-config** - Config files

### Phase 4: Infrastructure (Optional)
9. components-global/**17-pulumi** - Infrastructure as Code
10. components-global/**18-gcloud** - Google Cloud

### Phase 5: Desktop & Terminal (Optional)
11. components-global/**10-gnome-settings** - Desktop tweaks
12. components-global/**20-ghostty** - Terminal emulator

### Phase 6: Media & Browsers (Optional)
13. components-global/**14-qbittorrent** - Torrents
14. components-global/**15-vlc** - Media player
15. components-personal/**19-chrome** - Web browser
16. components-personal/**11-steam** - Gaming

## 📖 Individual Component Docs

Each component has detailed documentation:

```bash
# View component README
cat components-global/04-vscode/README.md
cat components-work/03-gitlab/README.md
cat components-personal/02-github/README.md
```

## 🛠️ Customization

### Modify Components

Edit component scripts before installing:

```bash
# View before installing
cat components-global/01-initial/install.sh

# Edit if needed
nano components-global/01-initial/install.sh

# Then install
bash components-global/01-initial/install.sh
```

### Update Configurations

Configuration files are stored with their components. Edit and re-run install for the appropriate profile:

```bash
# Edit personal VSCode config
nano components-personal/04-vscode/keybindings.json

# Re-run personal profile install
cd components-personal/04-vscode && bash install.sh
```

Or for work:

```bash
# Edit work VSCode config
nano components-work/04-vscode/keybindings.json

# Re-run work profile install
cd components-work/04-vscode && bash install.sh
```

## 🚨 Important Notes

### After Installation

**Zsh Shell** (components-global/12-zsh)
- Requires logout/login to become default shell
- Or run: `exec zsh`

**VSCode Profiles**
- The package install is handled by `components-global/04-vscode`
- Personal profile config is in `components-personal/04-vscode/`
- Work profile config is in `components-work/04-vscode/`
- The `.zshrc` wrapper should still auto-select `~/.vscode-work` or `~/.vscode-personal`
  based on project path

**AWS VPN** (components-work/06-aws-vpn-client)
- Work-only component
- Not needed for personal projects

### Backup Existing Configs

Before installing, backup existing configurations:

```bash
cp ~/.zshrc ~/.zshrc.backup
cp -r ~/.config/Code ~/.config/Code.backup
cp -r ~/.config/ghostty ~/.config/ghostty.backup
```

### Version Control

Track your customizations:

```bash
cd ~/projects/pc
git add components-global/ components-work/ components-personal/
git commit -m "Installed and customized installation components"
```

## 📊 Component Summary

| Component | Global | Work | Personal | Purpose |
|-----------|--------|------|----------|---------|
| 01-initial | ✓ | - | - | Base dependencies |
| 02-github | - | - | ✓ | Personal Git SSH |
| 03-gitlab | - | ✓ | - | Work Git SSH |
| 04-vscode | ✓ | - | - | Code editor |
| 05-python-pip | ✓ | - | - | Python package manager |
| 06-aws-vpn-client | - | ✓ | - | Work VPN |
| 07-aws-cli | - | ✓ | - | AWS tools |
| 08-kubectl | ✓ | - | - | Kubernetes CLI |
| 09-python-config | ✓ | - | - | Python config |
| 10-gnome-settings | ✓ | - | - | Desktop settings |
| 11-steam | - | - | ✓ | Gaming |
| 12-zsh | ✓ | - | - | Shell |
| 13-golang | ✓ | - | - | Go language |
| 14-qbittorrent | ✓ | - | - | Torrents |
| 15-vlc | ✓ | - | - | Media player |
| 16-python313 | ✓ | - | - | Python 3.13 |
| 17-pulumi | ✓ | - | - | Infrastructure as Code |
| 18-gcloud | ✓ | - | - | Google Cloud SDK |
| 19-chrome | - | - | ✓ | Web browser |
| 20-ghostty | ✓ | - | - | Terminal emulator |

## 🔗 Related Documentation

- [components-global/README.md](components-global/README.md) - Global components guide
- [components-global/CONFIG-FILES.md](components-global/CONFIG-FILES.md) - Configuration file locations
- [components-global/QUICK-START.md](components-global/QUICK-START.md) - Quick reference
- [components-work/README.md](components-work/README.md) - Work components guide
- [components-personal/README.md](components-personal/README.md) - Personal components guide

## ❓ FAQ

**Q: Should I install all components?**
A: No, install only what you need. At minimum: global + (work OR personal based on your needs).

**Q: Can I install both work and personal?**
A: Yes! Install all three directories for full setup.

**Q: How do I use VSCode for both work and personal?**
A: The `.zshrc` automatically selects the right profile. Use `code` command from the project directory.

**Q: Can I install components in any order?**
A: Not entirely. Install 01-initial first, then 12-zsh (needs logout), then others.

**Q: What if I mess up my shell config?**
A: Restore from backup: `cp ~/.zshrc.backup ~/.zshrc`

**Q: Do I need AWS components for personal projects?**
A: Only if you use AWS for personal projects. Otherwise, skip 06-aws-vpn-client and 07-aws-cli.

## 📞 Support

For component-specific help:
1. Check the component's README.md
2. Review install.sh script comments
3. Refer to upstream project documentation
4. Check the CONFIG-FILES.md for configuration details

## 🎯 Next Steps

1. Choose your context (work/personal/both)
2. Run appropriate `install-all.sh` scripts
3. Review and customize configurations as needed
4. Test installation: `which zsh`, `code --version`, etc.
5. Bookmark this README for future reference
