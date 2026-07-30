# Google Chrome Installation

Google Chrome browser installation for personal use.

## Installation

```bash
bash install.sh
```

This will:
1. Add Google Chrome GPG key
2. Add Google Chrome repository
3. Install the latest stable version of Google Chrome

## Features

- Fast and reliable browsing
- Automatic updates
- Sync across devices (with Google account)
- Built-in privacy and security features
- Extensive extension support

## Configuration

### First Run

1. Open Chrome: `google-chrome`
2. Sign in with your Google account (optional but recommended)
3. Enable sync to restore bookmarks, passwords, and settings

### Recommended Extensions

Install from Chrome Web Store:
- **uBlock Origin** - Ad blocker and privacy protection
- **Privacy Badger** - Blocks trackers
- **ClearURLs** - Removes tracking parameters from URLs
- **1Password** - Password manager (or similar)

### Privacy Settings

Configure privacy in Settings > Privacy and security:
- Enable "Do Not Track" requests
- Manage third-party cookies behavior
- Review site permissions

### Performance Tips

- Disable unused extensions
- Clear cache periodically: Settings > Privacy and security > Clear browsing data
- Use profiles for different purposes (work, personal, etc.)

## Profiles

Chrome supports multiple profiles for different contexts:

```bash
# Launch with specific profile
google-chrome --profile-directory="Profile 1"

# Create new profile via UI: ⚙️ > Manage profiles
```

## Command Line

Common Chrome command-line options:

```bash
# Start in fullscreen mode
google-chrome --start-fullscreen

# Disable extensions
google-chrome --disable-extensions

# Incognito mode
google-chrome --incognito

# Specific user data directory
google-chrome --user-data-dir=/path/to/profile
```

## Uninstalling

To uninstall Google Chrome:

```bash
sudo apt-get remove google-chrome-stable
sudo apt-get purge google-chrome-stable
```

Note: This removes the package but preserves user data. To remove user data as well:

```bash
rm -rf ~/.config/google-chrome
rm -rf ~/.cache/google-chrome
```

## Troubleshooting

**Chrome won't start**

Check for crashes:
```bash
google-chrome --no-sandbox
```

**Extensions not loading**

Try disabling and re-enabling extensions in Settings > Extensions.

**Sync not working**

1. Sign out: Settings > You and Google
2. Wait a few seconds
3. Sign back in

**Performance issues**

1. Check for malicious extensions
2. Disable unused extensions
3. Clear cache and cookies
4. Check active tabs and running extensions

## After Installation

1. Run: `google-chrome`
2. Sign in with Google account
3. Install preferred extensions
4. Configure privacy settings
5. Test browsing experience

## Documentation

- Official Chrome: https://www.google.com/chrome/
- Chrome Help: https://support.google.com/chrome/
- Extensions: https://chromewebstore.google.com/
