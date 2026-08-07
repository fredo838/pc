# VS Code (package install)

Installs the `code` apt package (VS Code Stable) itself — nothing profile-specific.

## Files

- `install.sh` — adds the Microsoft apt repository if needed and installs the
  `code` package. Idempotent: skips both steps if `code` is already on `PATH`.

## Why this is global, not work-only

Two other components depend on this package being present regardless of
which profile(s) you end up using on a given machine:

- `components-work/04-vscode` configures the Work profile against it.
- `components-personal/04-vscode` reads the real VS Code logo this package
  installs at `/usr/share/pixmaps/vscode.png` and recolors it to ochre for
  the self-built Personal binary's desktop icon (see that component's
  README for why the self-built binary needs its own icon at all).

## Installation

```bash
cd components-global/04-vscode
bash install.sh
```
