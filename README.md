# pc — Personal Machine Setup & Dotfiles

This repository holds the configuration, dotfiles, and installation notes I use to
bootstrap a fresh workstation. It targets **Ubuntu Linux** (with a Belgian keyboard
layout and NVIDIA drivers) as the primary platform.

The goal is to be able to go from a clean OS install to a fully configured
development environment — terminal, editor, shell, and tooling — in a repeatable way.

## Structure

Configuration is organized into modular components, grouped by context:

- **[components-global/](components-global/)** — tools and settings used in every
  context (shell, terminal, Python, Go, cloud CLIs, the VS Code apt package, etc.)
- **[components-personal/](components-personal/)** — personal-only tools (GitHub SSH,
  Chrome, Steam, and the self-built VS Code **Personal** profile)
- **[components-work/](components-work/)** — work-only tools (GitLab SSH, AWS, and the
  VS Code **Work** profile, built on the Stable package from components-global)

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

- VS Code's apt package (Stable) is a global component (`components-global/04-vscode/`)
  since both profiles need it — the Work profile runs it directly, and the Personal
  profile (a self-built binary, for proposed-API extension features) still uses its
  real logo as the source for its own ochre-recolored icon. See
  `components-personal/04-vscode/README.md` and `components-work/04-vscode/README.md`.
- The `.zshrc` `code` function auto-selects the right VS Code channel/profile based on
  the target directory (`/home/fred/centrica/*` → work, `/home/fred/projects/*` →
  personal).
