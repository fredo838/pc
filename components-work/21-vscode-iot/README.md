# IoT VS Code Profile (self-built)

The **IoT** profile is for exactly one folder, `~/centrica/iot-optimisation`. It runs on the
self-built VS Code (Code - OSS) at `~/projects/vscode`, like the
[Personal profile](../../components-personal/04-vscode/README.md), so the bode-claude
extension works in it: bode-claude needs that build's proposed APIs and Agent Host patches.
Its data is its own, apart from both Personal and Work.

| | |
|---|---|
| Binary | `~/projects/vscode` (self-built Code - OSS) |
| `--user-data-dir` | `~/.vscode-iot/user-data` |
| `--extensions-dir` | `~/.vscode-iot/extensions` |
| Profile | `IoT` (codicon `circuit-board`) |
| macOS | app wrapper `~/Applications/Code-IoT.app` (teal icon, `#1F9E89`), launch helper `~/.local/bin/code-oss-iot` |
| Linux | desktop entry `~/.local/share/applications/code-oss-iot.desktop` (teal icon), window class `code-oss-iot` |

## Which folder opens here

The `code` shell wrapper ([.zshrc](../../components-global/12-zsh/.zshrc)) picks this profile
when the target is **exactly** `~/centrica/iot-optimisation` (`code .` inside it, `code ..` from
a folder in it, or its path), or its `iot-optimisation.code-workspace`. Folders inside it, and the
rest of `~/centrica`, keep opening in the Work profile. `code-iot` opens this profile directly.

Like Personal, a folder target is redirected to its sibling `<name>.code-workspace`, the
multi-root workspace bode-claude manages, once that file exists. bode-claude creates it the first
time the folder is opened, so the very first `code .` opens the plain folder.

## Files

- `install-macos.sh` - creates/updates the profile, installs extensions, and the launch helper,
  app wrapper and icon (shared with Personal: [lib/code-oss-macos.sh](../../lib/code-oss-macos.sh))
- `install-linux.sh` - the same steps on Linux, with the Chromium sandbox fix and a desktop
  entry and icon (shared with Personal: [lib/code-oss-linux.sh](../../lib/code-oss-linux.sh)).
  Its windows get their own window class (Chromium's `--class=code-oss-iot`, passed by the
  desktop entry and the `code` wrapper), so the dock shows the teal icon; under Wayland they may
  still group under the build's own `code-oss-dev`
- `settings.json`, `keybindings.json`, `extensions.json`, `state.json` - start as Personal's

## bode-claude

bode-claude isn't on a marketplace, so `extensions.json` doesn't list it. Its own
`reinstall.sh` (in `~/projects/bode/root/ops/javascript/bode-claude`) installs it into every
self-built profile, this one included.
