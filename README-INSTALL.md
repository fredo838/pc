# Installation

Two entry points, both safe to re-run (use them for a fresh machine and to re-apply
config after editing something in this repo):

```bash
bash install-ubuntu.sh    # Ubuntu: every component
bash install-mac.sh       # macOS: VS Code profiles + zsh
```

Each script runs its components in order, keeps going if one fails, and ends with a
summary of what succeeded (✓), was skipped (⊘) and failed (✗). A component is
**skipped**, not failed, when a prerequisite you have to provide yourself is missing — it
prints the reason and how to fix it, e.g.:

- Personal VS Code: `~/projects/vscode` not cloned, not compiled (`out/cli.js`), or no
  Electron build yet — the message names the missing step
- Work VS Code (and the macOS global check): `code` not on PATH
- Ghostty: no package via apt or snap

Components signal this with `skip_component` from [lib/component.sh](lib/component.sh)
(exit code 100). Skips alone don't make the script exit non-zero; failures do. Every component can also be re-run on its own,
e.g. `bash components-work/04-vscode/install-linux.sh`.

## 📁 Directory Structure

```
pc/
├── install-ubuntu.sh        # Ubuntu entry point
├── install-mac.sh           # macOS entry point
├── lib/                     # Shared helpers (component runner, VS Code profile steps)
├── components-global/       # Tools and settings for all contexts
├── components-work/         # Work-specific (Centrica/GitLab)
└── components-personal/     # Personal use and hobbies
```

Each component is a numbered directory with an `install.sh` (Ubuntu), or
`install-linux.sh`/`install-macos.sh` where it supports both platforms.

## 🐧 install-ubuntu.sh

Runs every component in `components-global`, then `components-work`, then
`components-personal`, each group in numeric order. It asks for your sudo password once
up front. To run only some groups:

```bash
bash install-ubuntu.sh global work    # skip personal
```

| Component | Group | Purpose |
|-----------|-------|---------|
| 01-initial | global | Base packages (git, curl, wget, unzip, gnupg, xclip, python3-venv, Pillow, ImageMagick) |
| 04-vscode | global | VS Code (Stable) apt package — no profile config |
| 05-python-pip | global | pip |
| 08-kubectl | global | Kubernetes CLI (v1.35 apt repo) |
| 09-python-config | global | Creates empty `~/.netrc`, `~/.pip/pip.conf`, `~/.pypirc` (fill in manually) |
| 10-gnome-settings | global | Dock scroll cycles windows, dark mode |
| 12-zsh | global | zsh as login shell + `.zshrc` (previous one backed up) |
| 13-golang | global | Go |
| 14-qbittorrent | global | Torrent client |
| 15-vlc | global | Media player |
| 16-python313 | global | Python 3.13 (deadsnakes PPA) |
| 17-pulumi | global | Pulumi |
| 18-gcloud | global | Google Cloud CLI + GCR docker credential helper |
| 20-ghostty | global | Ghostty terminal (apt, else snap) + config |
| 03-gitlab | work | Work SSH key, `glab` install + login |
| 04-vscode | work | VS Code **Work** profile on the Stable package |
| 06-aws-vpn-client | work | AWS VPN client |
| 07-aws-cli | work | AWS CLI v2 |
| 02-github | personal | Git identity, personal SSH key |
| 04-vscode | personal | VS Code **Personal** profile on the self-built Code - OSS (build `~/projects/vscode` first) |
| 11-steam | personal | Steam |
| 19-chrome | personal | Google Chrome |

## 🍎 install-mac.sh

Runs only what supports macOS:

1. `components-global/04-vscode/install-macos.sh` — checks VS Code is installed (via
   `brew install --cask visual-studio-code`), plus Pillow for the ochre icon
2. `components-personal/04-vscode/install-macos.sh` — Personal profile, `Code-Personal.app`
   wrapper with ochre icon, `code-oss-personal` launcher
3. `components-work/04-vscode/install-macos.sh` — Work profile
4. `components-global/12-zsh/install.sh` — `.zshrc` (previous one backed up)

Close the Personal VS Code before running, otherwise its layout state (`state.json`) is
skipped. If `~/zscaler-ca.pem` exists it is exported as `NODE_EXTRA_CA_CERTS` so extension
installs work behind Zscaler.

## ✋ Manual Steps

Not scriptable, do these by hand after the scripts:

**Ubuntu installer**
- Keyboard: "Belgian", variant "Belgian"; enable automatic NVIDIA driver install
- Check `nvidia-smi` if a GPU is installed
- Slow terminal after login with NVIDIA drivers:
  https://bugs.launchpad.net/ubuntu/+source/nvidia-graphics-drivers-535/+bug/2042301

**Accounts & keys**
- Add `~/.ssh/id_ed25519_personal.pub` at https://github.com/settings/keys
- Add `~/.ssh/id_ed25519_centrica.pub` in GitLab
- Log out and back in so zsh becomes the login shell
- Fill in `~/.netrc`, `~/.pip/pip.conf` and `~/.pypirc` (examples in
  `components-global/09-python-config/install.sh`)
- For GCR pulls, add to `~/.docker/config.json`:
  ```json
  { "credHelpers": { "europe-west1-docker.pkg.dev": "gcr" } }
  ```

**Firefox**
- Log in; extensions: ClearURLs, Privacy Badger, uBlock Origin; set up profiles
- `about:config` → `identity.fxaccounts.toolbar.pxiToolbarEnabled` → off
- Theme: light mode in Settings

**Outlook (web)**
- If it misbehaves, try a hard refresh

**Steam / Hearthstone**
- Optional 32-bit NVIDIA libraries:
  `sudo dpkg --add-architecture i386 && sudo apt update && sudo apt install libnvidia-gl-590:i386`
- Hearthstone: `mkdir -p ~/.steam/debian-installation/steamapps/common/Hearthstone`, put
  `Battle.net-Setup.exe` there, then in Steam: Add a Game → Add a Non-Steam Game → select
  it, and set compatibility to "Proton Hotfix"

**macOS terminal**
- Remove macOS's conflicting keyboard shortcuts (some need rebinding even when inactive)
- iTerm2: Profile → Keys → load `components-global/12-zsh/iterm2-keymap.json`, and enable
  "Report keys using CSI u mode"

## 🔑 Configuration Files

- **04-vscode** (personal and work, separately): `keybindings.json`, `settings.json`,
  `extensions.json` (+ `state.json`, `product.overrides.json` for Personal)
- **12-zsh**: `.zshrc`, `iterm2-keymap.json`
- **20-ghostty**: `ghostty-config`

Edit them here and re-run the entry script (or just that component). See
[CONFIG-FILES.md](components-global/CONFIG-FILES.md) for where each one is installed.

## 🔗 Related Documentation

- [components-global/README.md](components-global/README.md)
- [components-work/README.md](components-work/README.md)
- [components-personal/README.md](components-personal/README.md)
- [components-personal/04-vscode/README.md](components-personal/04-vscode/README.md) and
  [components-work/04-vscode/README.md](components-work/04-vscode/README.md) for the VS Code
  profile details
