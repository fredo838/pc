# Personal Components

Personal projects, version control, browsing, and entertainment tools.

## 📋 Components List

### Version Control & Git
| # | Component | Purpose |
|---|-----------|---------|
| 02 | **github** | GitHub SSH configuration (personal account) |

### Browsing & Web
| # | Component | Purpose |
|---|-----------|---------|
| 19 | **chrome** | Google Chrome browser |

### Entertainment
| # | Component | Purpose |
|---|-----------|---------|
| 11 | **steam** | Steam gaming platform |

## 🚀 Quick Installation

### Install All Personal Components

```bash
cd components-personal
bash install-all.sh all
```

### Interactive Selection

```bash
cd components-personal
bash install-all.sh
# Follow prompts to select components
```

### Install Individual Component

```bash
cd components-personal/02-github
bash install.sh
```

## 📖 Component-Specific Guides

Each component has detailed documentation:

- [02-github/install.sh](02-github/install.sh) - GitHub SSH setup
- [11-steam/install.sh](11-steam/install.sh) - Steam gaming
- [19-chrome/README.md](19-chrome/README.md) - Google Chrome browser

## 📁 Directory Structure

```
components-personal/
├── 02-github/
│   └── install.sh
├── 11-steam/
│   └── install.sh
├── 19-chrome/
│   ├── install.sh
│   └── README.md
├── install-all.sh          (Master script)
└── README.md               (This file)
```

## 📋 Recommended Installation Order

For personal setup:

1. **02-github** - Set up GitHub SSH keys (do first)
2. **19-chrome** - Install web browser
3. **11-steam** - Install gaming platform

## ⚙️ Configuration

### GitHub (02-github)

Generates SSH key pair for personal GitHub account:
- Email: `fredo.bode@gmail.com`
- Key location: `~/.ssh/id_ed25519_personal`

After running, add the public key to GitHub:
1. Go to https://github.com/settings/keys
2. Paste contents of `~/.ssh/id_ed25519_personal.pub`
3. Test: `ssh -T git@github.com`

### Google Chrome (19-chrome)

Installs Google Chrome browser with sync support:
- Sign in with Google account for sync
- Install extensions from Chrome Web Store
- Configure privacy settings

Recommended extensions:
- uBlock Origin - Ad blocker
- Privacy Badger - Tracker blocker
- ClearURLs - URL cleaner

### Steam (11-steam)

Installs Steam gaming platform:
- Log in with Steam account
- Access game library
- Optional: Install Hearthstone with Proton compatibility
- Optional: Install 32-bit NVIDIA drivers for better compatibility

## 🔑 SSH Keys

### Generate New Keys

Keys are generated during installation. You need to:

1. Copy the public key from output
2. Add to https://github.com/settings/keys
3. Test connection:
   ```bash
   ssh -T git@github.com
   ```

### View Generated Keys

```bash
# List personal GitHub key
ls -la ~/.ssh/id_ed25519_personal*

# View public key
cat ~/.ssh/id_ed25519_personal.pub
```

### Add to SSH Agent

Keys are automatically added to SSH agent during installation.

To verify:
```bash
ssh-add -l
```

## 🔄 Integration with Global Components

### Combined Setup

For personal development environment, install both:

```bash
# Install global components first
cd components-global
bash install-all.sh all

# Then install personal components
cd ../components-personal
bash install-all.sh all
```

### VSCode Profiles

With this component's VS Code Insiders profile installed (`components-personal/04-vscode`),
personal projects automatically use:
```
~/.vscode-personal-insiders/
```

The `.zshrc` `code` command detects paths under `/home/fred/projects/` and launches
`code-insiders` with the personal profile.

### Git Configuration

Global git config is set up in `components-personal/02-github`:
- Email: `fredo.bode@gmail.com`
- Name: `Frederik Bode`

This is automatically applied to personal projects in `/Users/fred/projects/`.

## 🌐 GitHub Integration

### After Installing GitHub Component

1. SSH key is generated: `~/.ssh/id_ed25519_personal`
2. Add public key to https://github.com/settings/keys
3. Test: `ssh -T git@github.com`

### Clone Personal Repositories

```bash
cd ~/projects
git clone git@github.com:your-username/repo-name.git
cd repo-name
```

### Push to GitHub

```bash
# Create new repo on GitHub first
git remote add origin git@github.com:your-username/new-repo.git
git branch -M main
git push -u origin main
```

## 🎮 Gaming with Steam

### After Installing Steam

1. Launch Steam: Search for "Steam"
2. Log in with your Steam account
3. Browse and install games
4. Configure controller if using one

### Installing Hearthstone

```bash
# Create Hearthstone directory
mkdir -p ~/.steam/debian-installation/steamapps/common/Hearthstone

# Download Battle.net-Setup.exe
# Place in the directory above

# In Steam:
# 1. Click "Add a Game"
# 2. Select "Add a non-Steam Game"
# 3. Browse to ~/.steam/debian-installation/steamapps/common/Hearthstone
# 4. In Compatibility: Select "Proton Hotfix"
```

### 32-bit Support

For better game compatibility with 32-bit games:

```bash
# Add 32-bit architecture
sudo dpkg --add-architecture i386
sudo apt update

# Install 32-bit NVIDIA drivers (if GPU present)
sudo apt install libnvidia-gl-590:i386
```

### Proton Compatibility

Steam uses Proton for Windows game support:
- Automatically handles most games
- Some games need specific Proton versions
- Set per-game in Properties > Compatibility

## 🌐 Chrome Browser

### After Installing Chrome

1. Launch: `google-chrome`
2. Sign in with Google account for sync
3. Install recommended extensions
4. Configure privacy settings

### Recommended Extensions

Install from Chrome Web Store:
- **uBlock Origin** - Ad blocker and privacy
- **Privacy Badger** - Block trackers
- **ClearURLs** - Remove tracking parameters
- **1Password** or similar - Password manager

### Sync Across Devices

1. Sign in to Chrome with Google account
2. Enable sync in Settings > You and Google
3. Bookmarks and settings sync automatically

### Privacy Configuration

In Settings > Privacy and security:
- Enable "Do Not Track"
- Manage third-party cookies
- Review site permissions
- Clear cache regularly

## 📊 Post-Installation Checklist

After installing personal components:

- [ ] GitHub SSH key generated and added to account
- [ ] Test GitHub access: `ssh -T git@github.com`
- [ ] Chrome installed and signed in
- [ ] Chrome extensions installed
- [ ] Steam installed and logged in
- [ ] VSCode opens personal projects with personal profile
- [ ] Git commits use correct email (fredo.bode@gmail.com)

## 🚨 Important Notes

### Personal Account Information

These components use personal accounts:
- Email: `fredo.bode@gmail.com`
- GitHub: https://github.com/your-username
- Google: your-gmail-account@gmail.com
- Steam: Your Steam account

### Separate from Work

These components are separate from work:
- Uses personal GitHub (not GitLab)
- Uses personal Chrome profile (not work browsers)
- Gaming/entertainment tools
- Personal project email

### Privacy & Security

- Don't commit API keys or credentials
- Use Chrome profiles to separate work/personal browsing
- Enable Chrome sync only in personal profile
- Steam: Be cautious with game mods and third-party tools

## 🔄 Using Both Work and Personal

If you have both Centrica work and personal accounts:

1. Install `components-global` for shared tools
2. Install `components-work` for work setup
3. Install `components-personal` for personal setup

VSCode automatically selects profile based on directory:
- `/Users/fred/centrica/*` → work profile, work GitLab
- `/Users/fred/projects/*` → personal profile, personal GitHub

Chrome can use different profiles:
- Settings > Manage profiles > Create new profile
- One for work browsing, one for personal

## 🆘 Troubleshooting

### GitHub SSH Not Working

```bash
# Test connection
ssh -vvv -T git@github.com

# Verify key is loaded
ssh-add -l | grep personal

# If not loaded
ssh-add ~/.ssh/id_ed25519_personal
```

### Chrome Won't Start

```bash
# Try with no sandbox
google-chrome --no-sandbox

# Check for crashes
ps aux | grep chrome

# Clear cache if issues persist
rm -rf ~/.cache/google-chrome
```

### Steam Won't Install Games

1. Check disk space: `df -h`
2. Set install location: Steam > Settings > Downloads
3. Verify game compatibility: Check ProtonDB
4. Try different Proton version

### Sync Issues

**GitHub:**
```bash
# Reset and retest
ssh-add -D
ssh-add ~/.ssh/id_ed25519_personal
ssh -T git@github.com
```

**Chrome:**
1. Sign out: Settings > You and Google
2. Wait 30 seconds
3. Sign back in

## 📞 Support

### GitHub Support

- Documentation: https://docs.github.com/
- SSH Help: https://docs.github.com/authentication/connecting-to-github-with-ssh
- Status: https://www.githubstatus.com/

### Chrome Support

- Help: https://support.google.com/chrome/
- Extensions: https://chromewebstore.google.com/
- Privacy: https://support.google.com/chrome/answer/114836

### Steam Support

- Help: https://help.steampowered.com/
- ProtonDB: https://protondb.com/
- Proton: https://github.com/ValveSoftware/Proton

## 📝 Notes

- Personal components are independent of work components
- Can be installed alongside work components without conflicts
- Git automatically uses personal email for personal repos
- Chrome browser separate from any work browsing tools

## 🎯 Next Steps

1. Install global components first (if not already done)
2. Run `install-all.sh` with interactive selection
3. Generate GitHub SSH key and add to account
4. Test GitHub access
5. Install and sign into Chrome
6. Install and sign into Steam
7. Start working on personal projects

## 📚 Related Documentation

- [../README-INSTALL.md](../README-INSTALL.md) - Overall installation guide
- [../components-global/README.md](../components-global/README.md) - Global components
- [../components-work/README.md](../components-work/README.md) - Work components
- [19-chrome/README.md](19-chrome/README.md) - Chrome detailed guide
