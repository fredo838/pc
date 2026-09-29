# pc — Personal Machine Setup & Dotfiles

This repository holds the configuration, dotfiles, and installation notes I use to
bootstrap a fresh workstation. Full machine setup targets **Ubuntu Linux** (with a
Belgian keyboard layout and NVIDIA drivers); the VS Code profiles and zsh config
also support **macOS**.

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

- **[lib/](lib/)** — shell helpers shared by components:
  [install-runner.sh](lib/install-runner.sh) runs components and prints the summary, and
  [vscode-profile.sh](lib/vscode-profile.sh) holds the profile/settings/extension steps
  used by both `04-vscode` installers on both platforms

Each component is a numbered directory (e.g. `12-zsh/`) with its own `install.sh` (or
`install-linux.sh`/`install-macos.sh`) and, where relevant, the config files it deploys.

## Usage

Two entry points, both safe to re-run — for a fresh machine, and to re-apply config
after editing something here:

```bash
bash install-ubuntu.sh    # Ubuntu: every component (optionally: global work personal)
bash install-mac.sh       # macOS: VS Code profiles + zsh
```

## Getting Started

See **[README-INSTALL.md](README-INSTALL.md)** for the full breakdown of every
component, the manual follow-up steps, and customization instructions.

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
  the target directory (`~/centrica/*` → work, `~/projects/*` →
  personal).
