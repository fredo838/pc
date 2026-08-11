# VS Code (package install)

Installs VS Code Stable itself — nothing profile-specific. Adapts to Linux and macOS.

## Files

- `install-linux.sh` — adds the Microsoft apt repository if needed and installs the
  `code` package via apt. Idempotent: skips both steps if `code` is already on `PATH`.
- `install-macos.sh` — verifies `code` is available via Homebrew or official download.
  Install via `brew install --cask visual-studio-code` if needed.

## Why this is global, not work-only

Both Work and Personal profiles depend on this package being present:

- `components-work/04-vscode` configures the Work profile against it.
- `components-personal/04-vscode` (Linux only) reads the real VS Code logo this package
  installs at `/usr/share/pixmaps/vscode.png` and recolors it to ochre for
  the self-built Personal binary's desktop icon.

## Installation

From the repo root, use the platform-agnostic update script:

```bash
bash update.sh
```

Or manually for a specific platform:

```bash
cd components-global/04-vscode
bash install-linux.sh   # Linux
bash install-macos.sh   # macOS
```
