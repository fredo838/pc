# Personal VS Code Profile (self-built)

This component configures the **Personal** profile for the self-built VS Code
(Code - OSS) checked out at `~/projects/vscode`. Works on both Linux and macOS.

Personal projects use this self-built checkout instead of a packaged VS Code
build because the `anthropic.claude-code` extension's native Chat Participant
integration relies on `ChatResponseStream.textEdit()`, a proposed (unstable)
VS Code API. Building from source gives unconditional proposed-API access
without needing a signed Insiders build or the `--enable-proposed-api` flag
tied to a specific packaged channel.

## Files

- `install-linux.sh` - Linux-specific installer. Creates/updates the Personal profile,
  manages extensions, and creates an ochre-colored desktop icon.
- `install-macos.sh` - macOS-specific installer. Creates/updates the Personal profile,
  manages extensions, creates a launch helper app wrapper, and applies an ochre-colored icon.
- `keybindings.json` - identical on both platforms
- `settings.json` - identical on both platforms
- `extensions.json` - identical on both platforms
- `product.overrides.json` - adds an `extensionsGallery` pointing at open-vsx.org
  (used by both platforms)
- `make-ochre-icon.py` - Recolors the VS Code logo to ochre. Used by both platforms:
  Linux for the desktop icon, macOS for the app wrapper's custom icon

## Installation

### Prerequisites: Build the self-built VS Code

This must be done first (owned by that repo, not this one):

```bash
cd ~/projects/vscode
bash install.sh        # Does everything: install + compile + electron
```

This creates:
- **macOS**: `.build/electron/Code - OSS.app`
- **Linux**: `.build/electron/code-oss`

### Then provision the profile

From the repo root, use the unified update script:

```bash
bash update.sh
```

Or manually for a specific platform:

```bash
cd components-personal/04-vscode
bash install-linux.sh    # Linux
bash install-macos.sh    # macOS
```

## Notes

### Shared across platforms

- This component does **not** build VS Code itself — it only configures the
  `Personal` profile against whatever build already exists in `~/projects/vscode`.
  The installer fails fast with build instructions if the binary isn't there.
- To pull upstream VS Code changes and rebuild, use `~/projects/vscode/sync.sh`.
- Profile data lives under `~/.vscode-personal` (`user-data/` for
  `--user-data-dir`, `extensions/` for `--extensions-dir`), mirroring the
  Work profile's `~/.vscode-work` + `~/.vscode-work-ext` convention. This is
  the same on Linux and macOS for maximum portability.
- (Linux only) `.build/electron/chrome-sandbox` needs to be owned by `root` with mode
  `4755` for Chromium's SUID sandbox to accept it (a packaged `.deb` fixes
  this via its postinst script; `npm run electron` just extracts a plain
  zip owned by you and doesn't). `install-linux.sh` re-applies this automatically
  (via `sudo`) whenever it's wrong, since `npm run electron` resets it on
  every re-run.
- Vanilla Code-OSS ships with **no extension marketplace configured at
  all** — Microsoft restricts `marketplace.visualstudio.com` to their own
  official builds, so `--install-extension <id>` fails with "No extension
  gallery service configured" out of the box. `install.sh` copies
  `product.overrides.json` into `~/projects/vscode/`, which VS Code's own
  `bootstrap-meta.js` merges over `product.json` whenever `VSCODE_DEV=1` is
  set (already true for every invocation here) — this is the same
  open-vsx.org substitute gallery VSCodium uses, and the override file is
  already in `~/projects/vscode/.gitignore` so it never conflicts with
  `sync.sh` pulling upstream.
- **This is an unpackaged dev build** (no `app.asar`), unlike packaged
  apt-installed `code` (Linux) or Homebrew-installed `code` (macOS). Electron needs an
  explicit app location as its first positional argument or it just shows its own
  generic "no app configured" placeholder window; VS Code's own arg parser
  (`argvHelper.ts`) only strips that argument back out (instead of treating
  it as an extra folder to open) when `VSCODE_DEV` is set. Separately,
  `--list-extensions`/`--install-extension`/`--uninstall-extension` are
  handled *only* by the Node-only CLI entry (`out/cli.js`,
  `ELECTRON_RUN_AS_NODE=1`) — the main Electron/GUI entry
  (`electron-main/main.ts`) has no idea what those flags mean and will just
  open an empty window instead of erroring. Both platform installers define two
  helpers to get both right: `code_oss` (GUI launches) and `code_oss_cli`
  (headless extension management).
- `--enable-proposed-api=local.bode-claude` is kept for consistency even
  though self-built (unsigned) VS Code generally allows proposed APIs
  unconditionally; it's a no-op if not required. Installing the
  `anthropic.claude-code` extension itself into `~/.vscode-personal/extensions` and
  declaring `enabledApiProposals` in its `package.json` is handled in that
  extension's own repo, not here.
- The shell wrapper in `components-global/12-zsh/.zshrc` auto-selects
  this profile for paths under `/Users/fred/projects/`.
- Do not confuse `~/projects/vscode` (this fork, `origin` = `fredo838/vscode`)
  with any other local VS Code source checkout — only this one is built and
  wired up as the Personal profile's binary.

### Linux-specific notes

- **Desktop icon**: `install-linux.sh` writes `~/.local/share/applications/code-oss-personal.desktop`
  with `StartupWMClass=code-oss-dev` for GNOME desktop integration. The icon
  itself is the real VS Code logo at `/usr/share/pixmaps/vscode.png` (installed by
  `components-global/04-vscode`'s apt package), recolored to ochre by
  `make-ochre-icon.py` so Personal is recognizable as VS Code at a glance
  but visually distinct from Work's blue icon.
- **Chrome sandbox**: The chrome-sandbox binary needs SUID setup; `install-linux.sh`
  handles this automatically.
- **Launch**: Use `code-oss-personal [folder]` (via shell wrapper) or the command from above.

### macOS-specific notes

- **App wrapper**: `install-macos.sh` creates `~/Applications/Code-Personal.app`
  as a native macOS app bundle that launches the self-built Code.app with the
  correct environment variables. This allows Spotlight search and Launchpad integration.
- **Ochre icon**: The app wrapper gets a custom ochre-colored icon (recolored from the
  real VS Code logo) so Personal is recognizable as VS Code at a glance but visually
  distinct from other VS Code installations on the system.
- **Launch helpers**: Both `~/.local/bin/code-oss-personal` and the `Code-Personal.app`
  wrapper are created during installation.
- **Launch**: Use `code-oss-personal [folder]` or `open -a 'Code-Personal' [folder]`.
