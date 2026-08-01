# Personal VS Code Profile (Insiders)

This component installs **VS Code Insiders** and the personal VS Code user configuration
for the `~/.vscode-personal-insiders` profile.

Personal projects only use the Insiders channel now — there is no separate Stable
personal profile. The Insiders channel is required because the `bode-claude` extension's
native Chat Participant integration relies on `ChatResponseStream.textEdit()`, a
proposed (unstable) VS Code API that only works under Insiders with
`--enable-proposed-api=<extension-id>`.

## Files

- `install.sh` - installs the `code-insiders` apt package, then creates/updates the
  `Personal` profile (heart icon) and copies configuration files into its profile
  folder under `~/.vscode-personal-insiders/User/profiles/`
- `keybindings.json` - personal keybindings
- `settings.json` - personal settings
- `extensions.json` - recommended personal extensions

## Installation

```bash
cd components-personal/04-vscode
bash install.sh
```

## Notes

- This component installs both the `code-insiders` package and this profile's
  configuration — it is self-contained and doesn't depend on any other component
  for the VS Code Insiders binary.
- Launch personal projects with:

```bash
code-insiders --user-data-dir ~/.vscode-personal-insiders --extensions-dir ~/.vscode-personal-insiders-ext --profile Personal --enable-proposed-api=local.bode-claude
```

- `--enable-proposed-api=local.bode-claude` is required for the `bode-claude` extension's
  proposed-API features (inline diffs via `textEdit()`) to work. Installing the
  extension itself into `~/.vscode-personal-insiders-ext` and declaring
  `enabledApiProposals` in its `package.json` is handled in that extension's own repo,
  not here.
- The shell wrapper in `components-global/12-zsh/.zshrc` (`code()` and `code-personal()`)
  auto-selects this profile, with the proposed-API flag baked in, for paths under
  `/home/fred/projects/`.
- `settings.json` disables Copilot-specific chat UI (`chat.disableAIFeatures`) and the
  chat command-center icon (`chat.commandCenter.enabled`), carried over unchanged from
  the previous Stable-personal setup. `install.sh` also disables the `github.copilot` /
  `github.copilot-chat` extensions themselves in this profile — only Claude Code and
  `bode-claude` are meant to provide chat here.
