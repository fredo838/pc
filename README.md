# pc — Personal Machine Setup & Dotfiles

This repository holds the configuration, dotfiles, and installation notes I use to
bootstrap a fresh workstation. It targets **Ubuntu Linux** (with a Belgian keyboard
layout and NVIDIA drivers) as the primary platform.

The goal is to be able to go from a clean OS install to a fully configured
development environment — terminal, editor, shell, and tooling — in a repeatable way.

## Structure

Configuration is organized into modular components, grouped by context:

- **[components-global/](components-global/)** — tools and settings used in every
  context (shell, terminal, Python, Go, cloud CLIs, etc.)
- **[components-personal/](components-personal/)** — personal-only tools (GitHub SSH,
  Chrome, Steam, and VS Code **Insiders** for personal projects)
- **[components-work/](components-work/)** — work-only tools (GitLab SSH, AWS, and VS
  Code **Stable** for work projects)

Each component is a numbered directory (e.g. `12-zsh/`) with its own `install.sh` and,
where relevant, the config files it deploys.

[install-ubuntu.sh](install-ubuntu.sh) is a curated set of copy/paste notes for
bootstrapping a brand new machine end-to-end (packages, SSH keys, cloud tooling, desktop
apps) — read it before running anything rather than executing it blindly.

[update.sh](update.sh) re-applies this repo's VS Code and zsh config to an already-set-up
machine (useful after editing something in `components-global/12-zsh/` or either
`04-vscode/` component).

## Getting Started

See **[README-INSTALL.md](README-INSTALL.md)** for the full breakdown of every
component, recommended installation order, and customization instructions.

```bash
git clone <this-repo-url> pc
cd pc
cat README-INSTALL.md
```

## Notes

- VS Code is not a global component: personal projects use **Insiders** (required for
  proposed-API extension features), work projects use **Stable** — each profile
  installs its own package. See `components-personal/04-vscode/README.md` and
  `components-work/04-vscode/README.md`.
- The `.zshrc` `code` function auto-selects the right VS Code channel/profile based on
  the target directory (`/home/fred/centrica/*` → work, `/home/fred/projects/*` →
  personal).
