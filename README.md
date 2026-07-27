# pc — Personal Machine Setup & Dotfiles

This repository holds the configuration, dotfiles, and installation notes I use to
bootstrap a fresh workstation. It targets **Ubuntu Linux** (with a Belgian keyboard
layout and NVIDIA drivers) as the primary platform, and includes **macOS** fallbacks
where relevant.

The goal is to be able to go from a clean OS install to a fully configured
development environment — terminal, editor, shell, and tooling — in a repeatable way.

## Contents

| File | Purpose |
| --- | --- |
| [install.sh](install.sh) | Step-by-step notes/commands to provision a fresh machine (apt packages, dev tools, GUI apps, cloud CLIs). |
| [.zshrc](.zshrc) | Zsh configuration: prompt, Emacs keybindings, and a custom clipboard/selection engine (Shift+Arrow selection, copy/paste, smart delete). |
| [ghostty-config](ghostty-config) | Configuration for the [Ghostty](https://ghostty.org) terminal emulator. |
| [vscode-keybindings.json](vscode-keybindings.json) | Custom VS Code keybindings (Windows/Linux-style shortcuts, terminal escape sequences that match the `.zshrc` setup). |
| [install-keybindings.sh](install-keybindings.sh) | Installs `vscode-keybindings.json` into the correct VS Code user directory for your OS. |

## Prerequisites

- A fresh **Ubuntu** install (recommended) or **macOS**.
- `sudo` privileges for the package installation steps.
- Internet access to download packages and tools.

## Getting Started

Clone the repository:

```bash
git clone <this-repo-url> pc
cd pc
```

Then apply the pieces you need. The sections below cover each component.

> [!IMPORTANT]
> [install.sh](install.sh) is a **curated set of notes**, not a fully automated
> installer. It contains interactive steps (SSH key generation, GUI logins, config
> file editing). **Read it before running anything** and execute the blocks you need
> rather than running the whole file blindly.

## 1. Provision the Machine (`install.sh`)

[install.sh](install.sh) documents how to install and configure the full environment.
Work through it section by section. Highlights include:

- **Base packages** — `git`, `curl`, `gnupg`, `xclip`, etc.
- **Git & SSH keys** — generates separate keys for GitHub (personal) and GitLab
  (work), and prints the public key to add to each provider.
- **VS Code** — adds the Microsoft apt repository and installs `code`.
- **Languages & runtimes** — Python (via `deadsnakes` PPA), Go, `pip`.
- **Cloud & infra tooling** — AWS CLI, AWS VPN Client, `kubectl`, Pulumi, `gcloud`.
- **Desktop apps** — Steam, Google Chrome, Firefox tweaks, VLC, qBittorrent.
- **GNOME tweaks** — dark mode, dash-to-dock window cycling.
- **Zsh** — installs Zsh and sets it as the default shell.

Suggested usage — copy/paste the blocks you want, for example:

```bash
sudo apt-get update
sudo apt-get install git gedit curl apt-transport-https ca-certificates gnupg xclip
```

## 2. Shell Configuration (`.zshrc`)

The [.zshrc](.zshrc) provides a desktop-like editing experience in the terminal,
including **Shift+Arrow text selection**, clipboard **copy/paste**, and **smart
delete** of selections.

Install it:

```bash
cp .zshrc ~/.zshrc
```

Set Zsh as your default shell (then log out and back in):

```bash
sudo apt install zsh -y
chsh -s "$(which zsh)"
```

Key features:

- **Selection** with `Shift + Arrow` / `Shift + Ctrl + Arrow` / `Shift + Home/End`.
- **Copy** selection to the system clipboard and **paste** over selections.
- **Cross-platform clipboard** — uses `pbcopy`/`pbpaste` on macOS and
  `xclip`/`wl-copy` on Linux (install `xclip` for X11).
- **Smart delete** — Backspace/Delete removes the active selection.

> [!NOTE]
> The selection/clipboard keybindings rely on specific escape sequences. They work
> best with the matching Ghostty and VS Code configurations in this repo (see below).
> On Linux, make sure `xclip` is installed (`sudo apt-get install xclip`).

## 3. Ghostty Terminal (`ghostty-config`)

Copy the config to Ghostty's config location:

```bash
mkdir -p ~/.config/ghostty
cp ghostty-config ~/.config/ghostty/config
```

This config:

- Uses `/usr/bin/zsh` as the shell.
- Disables clipboard paste protection.
- Adds a keybinding so `Ctrl+Shift+V` emits the escape sequence the `.zshrc`
  paste widget expects.

Reload Ghostty's config with `Ctrl+Shift+,` (or restart it).

## 4. VS Code Keybindings

[vscode-keybindings.json](vscode-keybindings.json) provides Windows/Linux-style
shortcuts and terminal sequences that line up with the `.zshrc` clipboard/selection
setup (e.g. `Ctrl+Shift+C/V` in the integrated terminal, word-wise navigation, format
shortcuts).

Install them with the helper script, which detects your OS and copies the file into
the correct VS Code user directory:

```bash
./install-keybindings.sh
```

Destination paths:

- **Linux:** `~/.config/Code/User/keybindings.json`
- **macOS:** `~/Library/Application Support/Code/User/keybindings.json`

> [!WARNING]
> This **overwrites** your existing `keybindings.json`. Back up your current file
> first if you have custom bindings you want to keep.

Some bindings reference the `multiCommand.superFormatPython` / `superFormatGo`
commands, which require the **multi-command** VS Code extension and corresponding
`settings.json` entries to work.

## Platform Notes

- **Primary target:** Ubuntu Linux, Belgian keyboard layout, NVIDIA GPU.
- **macOS:** The clipboard helpers and `install-keybindings.sh` handle macOS paths,
  but the `install.sh` package steps are Ubuntu-specific (`apt`).
- If the terminal is slow after login on NVIDIA systems, see the bug link noted in
  [install.sh](install.sh).

## Customizing

These files reflect personal preferences — adapt them to your own needs:

- Change the Git identity and email in [install.sh](install.sh) before generating
  keys or committing.
- Adjust the prompt, keybindings, or clipboard behavior in [.zshrc](.zshrc).
- Tweak terminal appearance in [ghostty-config](ghostty-config) — see the
  [Ghostty docs](https://ghostty.org/docs/config).
