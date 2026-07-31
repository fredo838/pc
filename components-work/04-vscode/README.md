# Work VS Code Profile

This component contains the work VS Code user configuration for the `~/.vscode-work` profile.

## Files

- `install.sh` - creates/updates the `Work` profile (computer icon) and copies configuration files into its profile folder under `~/.vscode-work/User/profiles/`
- `keybindings.json` - work keybindings
- `settings.json` - work settings
- `extensions.json` - recommended work extensions

## Installation

```bash
cd components-work/04-vscode
bash install.sh
```

## Notes

- This is a profile-only component. It does not install the VS Code package.
- Launch work projects with:

```bash
code --user-data-dir ~/.vscode-work --extensions-dir ~/.vscode-work-ext

# Explicitly select the named profile
code --user-data-dir ~/.vscode-work --extensions-dir ~/.vscode-work-ext --profile Work
```

- The shell wrapper in `components-global/12-zsh/.zshrc` can auto-select this profile for paths under `/Users/fred/centrica/`.
