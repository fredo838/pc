# VSCode Configuration

Visual Studio Code installation with custom keybindings and settings.

## Files

- **install.sh** - Installation script
- **keybindings.json** - Custom keyboard shortcuts
- **settings.json** - Editor settings and preferences
- **extensions.json** - Recommended extensions

## Installation

```bash
bash install.sh
```

This will:
1. Add Microsoft GPG key and VSCode repository
2. Install VSCode package
3. Copy configuration files to `~/.config/Code/User/`

## Configuration Files

### keybindings.json

Custom keyboard shortcuts for VSCode including:

**Editor Shortcuts:**
- Ctrl+S: Save
- Ctrl+Z: Undo
- Ctrl+A: Select All
- Ctrl+Shift+P: Show Commands
- Ctrl+F: Find
- Ctrl+M: Toggle Comment
- Alt+Ctrl+L: Format Document (with language-specific logic)
- Ctrl+B: Reveal Definition

**Navigation Shortcuts:**
- Ctrl+Home/End: Jump to start/end of file
- Ctrl+Shift+Home/End: Select to start/end of file
- Ctrl+Left/Right: Navigate by word
- Ctrl+Shift+Left/Right: Select by word
- Ctrl+Backspace/Delete: Delete word

**Terminal Shortcuts:**
- Ctrl+U: Toggle between terminal and editor focus
- Ctrl+L: Clear terminal
- Ctrl+PageUp/PageDown: Switch between terminals

**Selection/Clipboard (Editor):**
- Ctrl+C: Copy
- Ctrl+V: Paste
- Ctrl+Shift+C: Copy
- Ctrl+Shift+V: Paste

**Selection/Clipboard (Terminal):**
- Ctrl+Shift+C: Send copy escape sequence
- Ctrl+Shift+V: Send paste escape sequence

**Disabled Shortcuts:**
- Cmd+Q and Ctrl+Q: Quit (disabled to prevent accidental exit)

### settings.json

Editor settings including:

**Terminal:**
- Default profile: zsh (Linux)

**Multi-Command:**
- `superFormatPython`: Format + Ruff autofix + Organize imports
- `superFormatGo`: Fix all + Organize imports + Format
- Generic format for other languages

### extensions.json

Recommended extensions:
- **ryuta46.multi-command** - Execute multiple commands sequentially

## Configuration Locations

Configuration files are stored at:
```
~/.config/Code/User/
├── keybindings.json
├── settings.json
└── extensions.json
```

## Recommended Extensions

To install recommended extensions:

1. Open VSCode
2. Click Extensions icon (Ctrl+Shift+X)
3. Click "Show Recommended Extensions"
4. Install any extensions you want

Currently recommended:
- **multi-command** - Execute multiple commands in sequence (used for super formatting)

## Customization

### Adding More Keybindings

Edit `~/.config/Code/User/keybindings.json`:

```json
{
    "key": "ctrl+shift+k",
    "command": "editor.action.deleteLines",
    "when": "editorTextFocus"
}
```

### Adding More Settings

Edit `~/.config/Code/User/settings.json`:

```json
{
    "editor.fontSize": 14,
    "editor.fontFamily": "Fira Code",
    "editor.formatOnSave": true
}
```

### Disabling Keybindings

To disable a keybinding, prepend with `-`:

```json
{
    "key": "ctrl+q",
    "command": "-workbench.action.quit"
}
```

## Multiple Profiles

Based on the `.zshrc` configuration, VSCode can run different profiles:

**Work Profile** (for Centrica projects):
```bash
code --user-data-dir ~/.vscode-work --extensions-dir ~/.vscode-work-ext
```

**Personal Profile** (for personal projects):
```bash
code --user-data-dir ~/.vscode-personal --extensions-dir ~/.vscode-personal-ext
```

The `.zshrc` `code` function automatically selects the right profile based on the directory.

## Formatting

### Python

Alt+Ctrl+L triggers:
1. Format Document
2. Ruff autofix (requires Ruff extension)
3. Organize Imports

### Go

Alt+Ctrl+L triggers:
1. Fix All
2. Organize Imports
3. Format Document

### Other Languages

Alt+Ctrl+L triggers standard document formatting.

## Terminal Integration

VSCode terminal recognizes the custom escape sequences from keybindings:
- Ctrl+Shift+C in terminal: Copies selected text
- Ctrl+Shift+V in terminal: Pastes clipboard
- Works with the custom zsh keybindings

## Troubleshooting

**Keybindings not working**

1. Check for conflicts: Cmd+K Cmd+S (Show Keybindings)
2. Restart VSCode
3. Ensure the "when" condition is met (e.g., text input focus)

**Settings not applied**

1. Check file syntax (should be valid JSON)
2. Look for conflicts with extensions
3. Reload VSCode

**Extensions not installing**

1. Ensure internet connection
2. Check VSCode version is up to date
3. Try installing manually from Extensions marketplace

## Further Customization

For more VSCode settings and extensions, visit:
- Settings: https://code.visualstudio.com/docs/getstarted/settings
- Extensions: https://marketplace.visualstudio.com/

## After Installation

1. Open VSCode: `code`
2. Install recommended extensions (Ctrl+Shift+X)
3. Test keybindings with the editor
4. Customize as needed with personal preferences
