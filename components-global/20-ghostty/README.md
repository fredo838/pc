# Ghostty Terminal Configuration

Ghostty terminal emulator installation with custom configuration.

## Files

- **install.sh** - Installation script
- **ghostty-config** - Terminal configuration file

## Installation

```bash
bash install.sh
```

This will:
1. Install Ghostty package (if available in repositories)
2. Create `~/.config/ghostty/` directory
3. Copy configuration to `~/.config/ghostty/config`

## Configuration File

The configuration file provides sensible defaults and custom settings.

### Current Settings

**Clipboard:**
- `clipboard-paste-protection = false` - Disable paste protection

**Shell:**
- `command = /usr/bin/zsh` - Use zsh as default shell

**Keybindings:**
- `ctrl+shift+v` - Send paste escape sequence

## Configuration Location

```
~/.config/ghostty/config
```

## Customization

Edit `~/.config/ghostty/config` to add more options.

### Common Settings

**Font and Display:**
```
# Font configuration
font-family = JetBrains Mono
font-size = 12

# Window padding
window-padding-x = 8
window-padding-y = 8

# Title bar
window-title = Ghostty
```

**Colors and Theme:**
```
# Theme
theme = dark

# Background opacity
background-opacity = 0.95

# Cursor style
cursor-style = beam
cursor-style-blink = true
```

**Shell and Environment:**
```
# Shell
shell = /bin/zsh

# Environment variables
env = TERM=ghostty
```

**Keybindings:**
```
# Custom keybindings
keybind = ctrl+shift+c=text:\x1b[99;6u
keybind = ctrl+shift+v=text:\x1b[86;5u
keybind = super+enter=toggle_fullscreen
keybind = super+n=new_window
```

## Reloading Configuration

Hot-reload the configuration while Ghostty is running:
- **Default shortcut**: Ctrl+Shift+comma (or Cmd+Shift+comma on macOS)
- **Menu option**: Available in the Ghostty menu

Note: Some options only apply to new windows and may require a full restart for changes to take effect.

## Available Configuration Options

View all available options:
```bash
ghostty +show-config --default --docs
```

Visit the official documentation:
https://ghostty.org/docs/config

## Escape Sequences

The configuration includes custom escape sequences for clipboard operations:

- `\x1b[99;6u` - Copy escape sequence
- `\x1b[86;5u` - Paste escape sequence

These work in conjunction with the `.zshrc` keybindings configuration.

## Integration with Zsh

The Ghostty configuration launches `/usr/bin/zsh` by default.

Ensure the Zsh component is installed for full functionality:
```bash
cd ../12-zsh
bash install.sh
```

This ensures:
- Zsh shell is installed
- Keybindings match between terminal and shell
- Clipboard integration works correctly

## Troubleshooting

**Configuration not loading**

1. Check file permissions: `ls -la ~/.config/ghostty/config`
2. Verify syntax (especially quotes and commas)
3. Reload with Ctrl+Shift+comma or restart Ghostty

**Keybindings not working**

1. Verify escape sequences are correct
2. Check if zsh keybindings configuration is installed
3. Test with `echo -ne '\e[99;6u'` in terminal

**Font issues**

1. Install font: `fc-list | grep "Font Name"`
2. Use full font name in config
3. Restart Ghostty

**Shell not starting**

1. Verify zsh is installed: `which zsh`
2. Test manual launch: `ghostty -- zsh`
3. Check PATH environment variable

## Performance Tips

```
# Reduce visual effects for better performance
disable-ligatures = false  # Set to true to disable

# Reduce font rendering cost
# Try a simpler monospace font if performance is poor
```

## Platform-Specific Notes

### Linux
- Ensure build tools and dependencies are installed
- May need to build from source: https://github.com/mitchellh/ghostty

### macOS
- Native binary available
- Works with iTerm2-style keybindings
- Use Cmd+Shift+comma to reload config

### Windows
- Not yet supported (as of current Ghostty version)

## After Installation

1. Restart Ghostty or run: `ghostty`
2. Test clipboard operations: Ctrl+Shift+C (copy) and Ctrl+Shift+V (paste)
3. Verify Zsh integration: `echo $SHELL`
4. Customize further as needed

## Documentation

- Official Ghostty: https://ghostty.org/
- GitHub: https://github.com/mitchellh/ghostty
- Configuration Docs: https://ghostty.org/docs/config
