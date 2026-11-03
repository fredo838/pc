#!/bin/bash
# Linux launch plumbing for a profile of the self-built VS Code (Code - OSS)
# at ~/projects/vscode: the Chromium sandbox fix every fresh build needs, and
# a desktop entry with the profile's own recoloured icon. Shared by the
# Personal and IoT profile installers (the macOS counterpart is
# code-oss-macos.sh).
#
# Callers set VSCODE_ROOT, CODE_BIN, PROFILE_DIR, EXTENSIONS_DIR and
# PROFILE_NAME first.

CODE_OSS_REPO_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# `npm run electron` deletes and re-extracts .build/electron from a plain zip
# on every run, owned by the current user. Chromium's SUID sandbox helper
# refuses to run unless it's owned by root with mode 4755 ("FATAL: The SUID
# sandbox helper binary was found, but is not configured correctly"), which
# a packaged .deb build normally fixes via its postinst script. Re-apply it
# so every extension-management call (and every `code` launch) doesn't crash
# with that error after a fresh build.
code_oss_linux_fix_sandbox() {
  local sandbox_bin="$VSCODE_ROOT/.build/electron/chrome-sandbox"
  if [ -f "$sandbox_bin" ] && [ "$(stat -c '%U:%a' "$sandbox_bin")" != "root:4755" ]; then
    echo "Fixing chrome-sandbox ownership/permissions (requires sudo):"
    sudo chown root:root "$sandbox_bin"
    sudo chmod 4755 "$sandbox_bin"
  fi
}

# code_oss_install_linux_desktop <icon name> <display name> <icon colour> <wm class> [launch arg...]
#
# GNOME (and other desktop shells) picks up an app's dock/taskbar icon by
# matching a running window's WM_CLASS / Wayland app-id against an installed
# .desktop file's StartupWMClass. The apt-installed code/code-insiders get
# this via their .deb's postinst (code.desktop + hicolor icons under
# /usr/share/*), but this is a raw unpackaged Electron binary with no such
# registration. Since VS Code never calls Electron's app.setName() for a dev
# build, the runtime app name (and so WM_CLASS/app-id) defaults to
# VSCODE_ROOT's own package.json "name", "code-oss-dev". A profile that wants
# a dock icon of its own passes Chromium's `--class=<wm class>` as a launch arg
# (X11; under Wayland the window may still group under code-oss-dev).
#
# The icon is the real VS Code logo -- /usr/share/pixmaps/vscode.png, from
# components-global/04-vscode's apt package -- recoloured by
# lib/recolour-icon.py, so each profile reads as VS Code at a glance but
# differs from the others (Work's stays blue).
code_oss_install_linux_desktop() {
  local icon_name="$1" display_name="$2" colour="$3" wm_class="$4"
  shift 4
  local extra_args="" arg
  for arg in "$@"; do
    extra_args="$extra_args $arg"
  done

  local real_logo="/usr/share/pixmaps/vscode.png"
  local desktop_file="$HOME/.local/share/applications/$icon_name.desktop"

  if [ ! -f "$real_logo" ]; then
    echo "⚠ Skipping desktop entry/icon install: $real_logo not found"
    echo "  Install VS Code's apt package first (provides the source logo):"
    echo "    cd $(cd "$CODE_OSS_REPO_LIB_DIR/../components-global/04-vscode" && pwd) && bash install.sh"
    return 0
  elif ! command -v convert >/dev/null 2>&1; then
    echo "⚠ Skipping desktop entry/icon install: ImageMagick 'convert' not found"
    return 0
  elif ! python3 -c "import PIL" >/dev/null 2>&1; then
    echo "⚠ Skipping desktop entry/icon install: Pillow not installed for python3"
    echo "  Install it with: pip install --user Pillow"
    return 0
  fi

  echo "Installing desktop entry + icons for self-built $PROFILE_NAME VS Code..."
  local master size icon_dir
  master="$(mktemp --suffix=.png)"
  python3 "$CODE_OSS_REPO_LIB_DIR/recolour-icon.py" "$real_logo" "$master" "$colour"
  for size in 16 24 32 48 64 96 128 192 256; do
    icon_dir="$HOME/.local/share/icons/hicolor/${size}x${size}/apps"
    mkdir -p "$icon_dir"
    convert "$master" -resize "${size}x${size}" "$icon_dir/$icon_name.png"
  done
  rm -f "$master"

  mkdir -p "$(dirname "$desktop_file")"
  cat > "$desktop_file" <<EOF
[Desktop Entry]
Name=$display_name
Comment=Code Editing. Redefined. (self-built, $PROFILE_NAME profile)
GenericName=Text Editor
Exec=env VSCODE_DEV=1 NODE_ENV=development "$CODE_BIN" "$VSCODE_ROOT" --user-data-dir "$PROFILE_DIR" --extensions-dir "$EXTENSIONS_DIR" --profile $PROFILE_NAME --enable-proposed-api=local.bode-claude$extra_args %F
Icon=$icon_name
Type=Application
StartupNotify=true
StartupWMClass=$wm_class
Categories=TextEditor;Development;IDE;
Keywords=vscode;code-oss;
EOF

  command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1
  command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1
  echo "✓ Desktop entry + icons installed ($desktop_file)"
}
