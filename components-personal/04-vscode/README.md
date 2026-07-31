# Personal VS Code Profile

This component contains the personal VS Code user configuration for the `~/.vscode-personal` profile.

## Files

- `install.sh` - creates/updates the `Personal` profile (heart icon) and copies configuration files into its profile folder under `~/.vscode-personal/User/profiles/`
- `keybindings.json` - personal keybindings
- `settings.json` - personal settings
- `extensions.json` - recommended personal extensions

## Installation

```bash
cd components-personal/04-vscode
bash install.sh
```

## Notes

- This is a profile-only component. It does not install the VS Code package.
- Launch personal projects with:

```bash
code --user-data-dir ~/.vscode-personal --extensions-dir ~/.vscode-personal-ext

# Explicitly select the named profile
code --user-data-dir ~/.vscode-personal --extensions-dir ~/.vscode-personal-ext --profile Personal
```

- The shell wrapper in `components-global/12-zsh/.zshrc` can auto-select this profile for paths under `/Users/fred/projects/`.
