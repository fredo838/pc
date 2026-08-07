# Personal VS Code Profile (self-built)

This component configures the **Personal** profile for the self-built VS Code
(Code - OSS) checked out at `~/projects/vscode`.

Personal projects use this self-built checkout instead of a packaged VS Code
build because the `bode-claude` extension's native Chat Participant
integration relies on `ChatResponseStream.textEdit()`, a proposed (unstable)
VS Code API. Building from source gives unconditional proposed-API access
without needing a signed Insiders build or the `--enable-proposed-api` flag
tied to a specific packaged channel.

## Files

- `install.sh` - creates/updates the `Personal` profile (heart icon) in the
  self-built checkout's data dirs and copies configuration files into its
  profile folder
- `keybindings.json` - personal keybindings
- `settings.json` - personal settings
- `extensions.json` - recommended personal extensions
- `product.overrides.json` - adds an `extensionsGallery` pointing at
  open-vsx.org (see Notes below for why this is needed at all)
- `make-ochre-icon.py` - recolors the real VS Code logo to ochre for the
  Personal profile's desktop icon (see Notes below)

## Installation

Build the self-built VS Code first (owned by that repo, not this one). `npm
install` alone does not compile or fetch Electron — `scripts/code.sh`
normally does both on first launch via `build/lib/preLaunch.ts`, but this
component's `install.sh` bypasses that script (see Notes below), so run all
three steps explicitly:

```bash
cd ~/projects/vscode
bash install.sh   # npm install
npm run compile   # builds ./out
npm run electron  # fetches .build/electron
```

Then provision the profile:

```bash
cd components-personal/04-vscode
bash install.sh
```

## Notes

- This component does **not** build VS Code itself — it only configures the
  `Personal` profile against whatever build already exists at
  `~/projects/vscode/.build/electron/code-oss`. `install.sh` fails fast with
  build instructions if that binary isn't there.
- To pull upstream VS Code changes and rebuild, use `~/projects/vscode/sync.sh`.
- Profile data lives under `~/.vscode-personal` (`user-data/` for
  `--user-data-dir`, `extensions/` for `--extensions-dir`), mirroring the
  Work profile's `~/.vscode-work` + `~/.vscode-work-ext` convention.
- `.build/electron/chrome-sandbox` needs to be owned by `root` with mode
  `4755` for Chromium's SUID sandbox to accept it (a packaged `.deb` fixes
  this via its postinst script; `npm run electron` just extracts a plain
  zip owned by you and doesn't). `install.sh` re-applies this automatically
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
- **This is an unpackaged dev build** (no `app.asar`), unlike the packaged
  apt-installed `code`/`code-insiders`. Electron needs an explicit app
  location as its first positional argument or it just shows its own
  generic "no app configured" placeholder window; VS Code's own arg parser
  (`argvHelper.ts`) only strips that argument back out (instead of treating
  it as an extra folder to open) when `VSCODE_DEV` is set. Separately,
  `--list-extensions`/`--install-extension`/`--uninstall-extension` are
  handled *only* by the Node-only CLI entry (`out/cli.js`,
  `ELECTRON_RUN_AS_NODE=1`) — the main Electron/GUI entry
  (`electron-main/main.ts`) has no idea what those flags mean and will just
  open an empty window instead of erroring. `install.sh` defines two
  helpers to get both right: `code_oss` (GUI launches) and `code_oss_cli`
  (headless extension management).
- Launch personal projects with:

```bash
VSCODE_DEV=1 NODE_ENV=development ~/projects/vscode/.build/electron/code-oss ~/projects/vscode --user-data-dir ~/.vscode-personal/user-data --extensions-dir ~/.vscode-personal/extensions --profile Personal --enable-proposed-api=local.bode-claude
```

- `--enable-proposed-api=local.bode-claude` is kept for consistency even
  though self-built (unsigned) VS Code generally allows proposed APIs
  unconditionally; it's a no-op if not required. Installing the
  `bode-claude` extension itself into `~/.vscode-personal/extensions` and
  declaring `enabledApiProposals` in its `package.json` is handled in that
  extension's own repo, not here.
- The shell wrapper in `components-global/12-zsh/.zshrc` (`code()`,
  `code-personal()`, and the shared `code_oss_personal` helper) auto-selects
  this profile, with the app-locator/`VSCODE_DEV`/proposed-API handling
  baked in, for paths under `/home/fred/projects/`.
- Do not confuse `~/projects/vscode` (this fork, `origin` = `fredo838/vscode`)
  with any other local VS Code source checkout — only this one is built and
  wired up as the Personal profile's binary.
- **Desktop icon**: this is a raw unpackaged Electron binary, so unlike the
  apt-installed `code` (which registers `code.desktop` + hicolor icons via
  its `.deb` postinst), GNOME has no icon to show for its window and falls
  back to a generic placeholder in the dash/dock. `install.sh` fixes this by
  writing `~/.local/share/applications/code-oss-personal.desktop` with
  `StartupWMClass=code-oss-dev` — the actual runtime app-id here, since VS
  Code never calls Electron's `app.setName()` for a dev build, so it falls
  back to `~/projects/vscode/package.json`'s `"name": "code-oss-dev"` field
  (not `product.json`'s `applicationName`/`nameShort`). The icon itself is
  the real VS Code logo at `/usr/share/pixmaps/vscode.png` (installed by
  `components-global/04-vscode`'s apt package — required even though this
  profile doesn't use packaged VS Code), recolored to ochre by
  `make-ochre-icon.py` so Personal is recognizable as VS Code at a glance
  but visually distinct from Work's blue icon. `install.sh` skips this step
  (with an explanatory message, not a failure) if that source logo,
  ImageMagick, or Pillow isn't available.
