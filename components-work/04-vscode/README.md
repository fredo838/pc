# Work VS Code Profile

This component installs **VS Code** (Stable) and the work VS Code user configuration
for the `~/.vscode-work` profile.

## Files

- `install.sh` - installs the `code` apt package, then creates/updates the `Work` profile (computer icon) and copies configuration files into its profile folder under `~/.vscode-work/User/profiles/`
- `keybindings.json` - work keybindings
- `settings.json` - work settings
- `extensions.json` - recommended work extensions

## Installation

```bash
cd components-work/04-vscode
bash install.sh
```

## Notes

- This component installs both the `code` package and this profile's configuration —
  it is self-contained and doesn't depend on any other component for the VS Code binary.
  Work never needs the Insiders channel; that's personal-only (see
  `components-personal/04-vscode/`).
- Launch work projects with:

```bash
code --user-data-dir ~/.vscode-work --extensions-dir ~/.vscode-work-ext

# Explicitly select the named profile
code --user-data-dir ~/.vscode-work --extensions-dir ~/.vscode-work-ext --profile Work
```

- The shell wrapper in `components-global/12-zsh/.zshrc` can auto-select this profile for paths under `/Users/fred/centrica/`.
