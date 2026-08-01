# Zsh Configuration

Zsh shell installation with advanced keybindings and clipboard support.

## Files

- **install.sh** - Installation script
- **.zshrc** - Main shell configuration file
- **iterm2-keymap.json** - iTerm2 terminal keybindings (macOS only)

## Installation

```bash
bash install.sh
```

This will:
1. Install zsh package
2. Set zsh as the default shell (requires logout/login)
3. Copy `.zshrc` to `~/.zshrc`

## Configuration Features

### Core Settings
- Emacs key bindings
- Custom prompt with color coding
- Blinking beam cursor

### Clipboard Support
- **Copy**: Shift+Ctrl+C (custom binding)
- **Paste**: Shift+Ctrl+V (custom binding)
- Works on macOS, Linux, and Wayland
- Requires: `pbcopy`/`pbpaste` (macOS), `xclip` (Linux), `wl-copy`/`wl-paste` (Wayland)

### Selection & Navigation
- Shift+Arrows: Select while moving
- Standard Arrows: Move without selection (auto-deselect)
- Ctrl+Arrows: Navigate by word
- Ctrl+Home/End: Jump to line start/end

### Smart Deletion
- Backspace/Delete in selection: Delete selected text
- Backspace/Delete outside selection: Normal delete behavior

### Aliases
- `exit`: Custom exit alias
- `code`: Smart VSCode launcher that opens different profiles based on directory

## Additional Configuration

### iTerm2 Keymap (macOS)

The `iterm2-keymap.json` file contains custom key bindings for iTerm2:

- Ctrl+Shift+Right Arrow: Forward word select
- Ctrl+Shift+Left Arrow: Backward word select
- Ctrl+Shift+Home: Start of line select
- Ctrl+Shift+End: End of line select
- Ctrl+Shift+C: Copy
- Ctrl+Shift+V: Paste
- Ctrl+Backspace: Delete word backward

**To install in iTerm2:**
1. Open Preferences > Profiles > Keys
2. Click "Load Preset..." button
3. Select: `components/12-zsh/iterm2-keymap.json`
4. Enable "Report keys using CSI u mode"

### Pulumi Path

The configuration adds Pulumi to PATH:
```bash
export PATH=$HOME/.pulumi/bin:$PATH
```

## Manual Adjustments

Edit `~/.zshrc` to customize:

```bash
# Change prompt color
PROMPT='%F{red}%n@%m%f:%F{blue}%~%f$ '

# Change cursor style
echo -ne '\e[5 q'  # Blinking beam
# Other options:
# '\e[1 q'  - Blinking block
# '\e[3 q'  - Blinking underline
# '\e[0 q'  - Non-blinking block
# '\e[2 q'  - Non-blinking block
# '\e[4 q'  - Non-blinking underline
# '\e[6 q'  - Non-blinking beam
```

## VSCode Integration

The configuration includes a `code` function that automatically selects the appropriate VSCode profile:

- `/home/fred/centrica/*` → Uses Stable, work profile (`~/.vscode-work`)
- `/home/fred/projects/*` → Uses Insiders, personal profile (`~/.vscode-personal-insiders`)
- Other paths → Uses default `code` profile

## Troubleshooting

**Slow terminal after login**

If using NVIDIA drivers, see: https://bugs.launchpad.net/ubuntu/+source/nvidia-graphics-drivers-535/+bug/2042301

**Clipboard not working**

Make sure the appropriate clipboard tool is installed:
- Linux: `sudo apt-get install xclip`
- Wayland: `sudo apt-get install wl-clipboard`
- macOS: Built-in (pbcopy/pbpaste)

**Terminal not responding to key bindings**

Ensure the terminal is set to report keys using the CSI u mode (iTerm2 on macOS).

## After Installation

Remember to:
1. Log out and log back in for zsh to become your default shell
2. Run `exec zsh` if you want to switch immediately
3. (macOS only) Configure iTerm2 keybindings as described above
