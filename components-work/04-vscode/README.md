# Work VS Code Profile

This component configures the **Work** profile for VS Code (Stable) on both Linux and macOS.
It stores configuration in `~/.vscode-work` with extensions in `~/.vscode-work-ext`.

Both profiles and both platforms use identical keybindings and settings, so you can switch
between machines without relearning.

## Files

- `install-linux.sh` - Linux-specific installer. Requires `code` on PATH, then creates/updates the Work profile
- `install-macos.sh` - macOS-specific installer. Requires `code` on PATH (from Homebrew or official download)
- `keybindings.json` - identical on both platforms
- `settings.json` - identical on both platforms
- `extensions.json` - identical on both platforms

## Installation

From the repo root, use the unified update script:

```bash
bash update.sh
```

Or manually:

```bash
# Install global VS Code first (if not already installed)
bash components-global/04-vscode/install-linux.sh    # Linux
bash components-global/04-vscode/install-macos.sh    # macOS

# Then install Work profile
bash components-work/04-vscode/install-linux.sh      # Linux
bash components-work/04-vscode/install-macos.sh      # macOS
```

## Launch

```bash
# Automatic via shell wrapper (if configured in ~/.zshrc)
code  # auto-selects Work profile for /Users/fred/centrica paths

# Explicit
code --user-data-dir ~/.vscode-work --extensions-dir ~/.vscode-work-ext --profile Work
```

## Notes

- Uses custom data dirs (`~/.vscode-work`) instead of platform defaults for portability
- Same keybindings and settings work across Linux and macOS
- Shell wrapper in `components-global/12-zsh/.zshrc` auto-selects this profile based on working directory
