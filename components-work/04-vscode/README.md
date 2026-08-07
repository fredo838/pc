# Work VS Code Profile

This component configures the **Work** profile (`~/.vscode-work`) for VS Code (Stable).
It does not install the `code` package itself — that's `components-global/04-vscode`,
since both this component and `components-personal/04-vscode` (which recolors the real
VS Code logo the package ships) depend on it being present.

## Files

- `install.sh` - fails fast if `code` isn't on `PATH` (see `components-global/04-vscode`), then creates/updates the `Work` profile (computer icon) and copies configuration files into its profile folder under `~/.vscode-work/User/profiles/`
- `keybindings.json` - work keybindings
- `settings.json` - work settings
- `extensions.json` - recommended work extensions

## Installation

```bash
cd components-global/04-vscode && bash install.sh   # the code package, if not already installed
cd ../../components-work/04-vscode && bash install.sh
```

## Notes

- Work never needs the Insiders channel; that's personal-only (see
  `components-personal/04-vscode/`).
- Launch work projects with:

```bash
code --user-data-dir ~/.vscode-work --extensions-dir ~/.vscode-work-ext

# Explicitly select the named profile
code --user-data-dir ~/.vscode-work --extensions-dir ~/.vscode-work-ext --profile Work
```

- The shell wrapper in `components-global/12-zsh/.zshrc` can auto-select this profile for paths under `/Users/fred/centrica/`.
