#!/bin/bash
# Install the personal VS Code profile configuration for the self-built
# VS Code (Code - OSS) on macOS at ~/projects/vscode.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/component.sh"
VSCODE_ROOT="$HOME/projects/vscode"
CODE_APP="$VSCODE_ROOT/.build/electron/Code - OSS.app"
CODE_BIN="$CODE_APP/Contents/MacOS/Code - OSS"
PROFILE_DIR="$HOME/.vscode-personal/user-data"
EXTENSIONS_DIR="$HOME/.vscode-personal/extensions"
PROFILE_NAME="Personal"
PROFILE_ICON="heart"

# The self-built VS Code at $VSCODE_ROOT is built by that repo, not here:
# skip with instructions for whichever build step hasn't been done yet.
if [ ! -d "$VSCODE_ROOT/.git" ]; then
  skip_component "self-built VS Code not checked out at $VSCODE_ROOT" \
    "git clone https://github.com/microsoft/vscode.git $VSCODE_ROOT" \
    "then: cd $VSCODE_ROOT && npm install && npm run compile && npm run electron"
elif [ ! -f "$VSCODE_ROOT/out/cli.js" ]; then
  skip_component "self-built VS Code not compiled ($VSCODE_ROOT/out/cli.js missing)" \
    "cd $VSCODE_ROOT && npm install && npm run compile && npm run electron"
elif [ ! -x "$CODE_BIN" ]; then
  skip_component "self-built VS Code Electron app missing ($CODE_APP)" \
    "cd $VSCODE_ROOT && npm run electron"
fi

# Copy product.overrides.json to use open-vsx marketplace
cp "$SCRIPT_DIR/product.overrides.json" "$VSCODE_ROOT/product.overrides.json"

# Headless CLI entry (out/cli.js) for extension management, run as plain
# Node against the Electron binary. VSCODE_ROOT is Electron's app locator
# for this unpackaged dev build; VS Code only strips it back out of argv
# (instead of treating it as a folder) when VSCODE_DEV is set.
vscode_cli() {
  NODE_NO_WARNINGS=1 ELECTRON_RUN_AS_NODE=1 VSCODE_DEV=1 NODE_ENV=development "$CODE_BIN" "$VSCODE_ROOT/out/cli.js" "$VSCODE_ROOT" "$@"
}

echo "✓ Found self-built VS Code binary: $CODE_BIN"

source "$SCRIPT_DIR/../../lib/vscode-profile.sh"

vscode_profile_register
vscode_profile_copy_config
vscode_profile_apply_app_settings
vscode_profile_apply_state
vscode_profile_install_extensions
vscode_profile_remove_python_pack
vscode_profile_reconcile_manifest

echo ""

# On macOS, we create a launch helper script in ~/.local/bin instead of a desktop file.
# This allows the shell wrapper to easily launch with all the right environment variables.
LAUNCH_DIR="$HOME/.local/bin"
LAUNCH_SCRIPT="$LAUNCH_DIR/code-oss-personal"

mkdir -p "$LAUNCH_DIR"

cat > "$LAUNCH_SCRIPT" <<'LAUNCHER'
#!/bin/bash
# Launcher for self-built VS Code Personal profile on macOS.
# Launch via the app wrapper so the ochre icon appears in the dock. `open`
# runs the wrapper with cwd=/ and only forwards argv after --args, so
# resolve paths here and force a fresh wrapper process with -n (otherwise
# `open` just activates a running one and the folder never arrives).
ARGS=()
for arg in "$@"; do
  if [[ "$arg" != -* && -e "$arg" ]]; then
    ARGS+=("$(cd "$(dirname "$arg")" && pwd)/$(basename "$arg")")
  else
    ARGS+=("$arg")
  fi
done
exec open -n -a "Code-Personal" --args "${ARGS[@]}"
LAUNCHER

chmod +x "$LAUNCH_SCRIPT"
echo "✓ Launch script installed at: $LAUNCH_SCRIPT"

# Create a macOS .app wrapper that points to our self-built Code.app
# This allows the app to appear in spotlight/launchpad with the custom icon
APP_WRAPPER="$HOME/Applications/Code-Personal.app"
WRAPPER_CONTENTS="$APP_WRAPPER/Contents"
WRAPPER_MACOS="$WRAPPER_CONTENTS/MacOS"

mkdir -p "$WRAPPER_MACOS"

# Create the launcher script inside the app bundle
cat > "$WRAPPER_MACOS/Code-Personal" <<'APPWRAPPER'
#!/bin/bash
# Arguments arrive via `open -n -a Code-Personal --args ...` (see the
# code_oss_personal function in components-global/12-zsh/.zshrc).
ARGS=()
for arg in "$@"; do
  case "$arg" in
    -*)
      # Keep flags as-is
      ARGS+=("$arg")
      ;;
    *)
      # Resolve relative paths to absolute
      if [[ -e "$arg" ]]; then
        ARGS+=("$(cd "$(dirname "$arg")" && pwd)/$(basename "$arg")")
      else
        ARGS+=("$arg")
      fi
      ;;
  esac
done

exec env \
  VSCODE_DEV=1 \
  NODE_ENV=development \
  "$HOME/projects/vscode/.build/electron/Code - OSS.app/Contents/MacOS/Code - OSS" \
  "$HOME/projects/vscode" \
  --user-data-dir "$HOME/.vscode-personal/user-data" \
  --extensions-dir "$HOME/.vscode-personal/extensions" \
  --profile Personal \
  --enable-proposed-api=local.bode-claude \
  "${ARGS[@]}"
APPWRAPPER

chmod +x "$WRAPPER_MACOS/Code-Personal"

# Create Info.plist for the wrapper app (with icon reference)
cat > "$WRAPPER_CONTENTS/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>Code-Personal</string>
	<key>CFBundleIconFile</key>
	<string>Code</string>
	<key>CFBundleIdentifier</key>
	<string>com.local.code-oss-personal</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>VS Code (Personal)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleVersion</key>
	<string>1.0</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSHumanReadableCopyright</key>
	<string>VS Code Personal Profile</string>
</dict>
</plist>
PLIST

echo "✓ App wrapper installed at: $APP_WRAPPER"

# Create ochre-colored icon for the app wrapper
# Use the proper VS Code icon from the global installation (real Microsoft logo)
REAL_ICON="/Applications/Visual Studio Code.app/Contents/Resources/Code.icns"
if [ ! -f "$REAL_ICON" ]; then
  echo "⚠ VS Code icon not found at $REAL_ICON, skipping ochre icon"
elif ! command -v iconutil >/dev/null 2>&1; then
  echo "⚠ iconutil not found, skipping ochre icon"
elif ! python3 -c "import PIL" >/dev/null 2>&1; then
  echo "⚠ Pillow not installed for python3, skipping ochre icon"
else
  echo "Creating ochre-colored icon for macOS app wrapper..."

  ICON_TEMP="$(mktemp -d)"
  ICON_ICONSET="$ICON_TEMP/Code.iconset"
  mkdir -p "$ICON_ICONSET"

  if iconutil -c iconset -o "$ICON_ICONSET" "$REAL_ICON" 2>/dev/null; then
    SOURCE_PNG=""
    for png in "$ICON_ICONSET"/*.png; do
      if [[ "$png" == *"icon_256x256.png" ]] || [[ "$png" == *"icon_512x512.png" ]]; then
        SOURCE_PNG="$png"
        break
      fi
    done

    if [ -z "$SOURCE_PNG" ]; then
      for png in "$ICON_ICONSET"/*.png; do
        SOURCE_PNG="$png"
        break
      done
    fi

    if [ -n "$SOURCE_PNG" ] && [ -f "$SOURCE_PNG" ]; then
      OCHRE_PNG="$ICON_TEMP/Code-ochre.png"
      if python3 "$SCRIPT_DIR/make-ochre-icon.py" "$SOURCE_PNG" "$OCHRE_PNG"; then
        NEW_ICONSET="$ICON_TEMP/Code-ochre.iconset"
        mkdir -p "$NEW_ICONSET"

        for size in 16 32 64 128 256 512 1024; do
          OUTPUT="$NEW_ICONSET/icon_${size}x${size}.png"
          sips -z $size $size "$OCHRE_PNG" --out "$OUTPUT" >/dev/null 2>&1

          OUTPUT_2X="$NEW_ICONSET/icon_${size}x${size}@2x.png"
          sips -z $((size * 2)) $((size * 2)) "$OCHRE_PNG" --out "$OUTPUT_2X" >/dev/null 2>&1
        done

        WRAPPER_ICON="$WRAPPER_CONTENTS/Resources/Code.icns"
        mkdir -p "$WRAPPER_CONTENTS/Resources"
        if iconutil -c icns -o "$WRAPPER_ICON" "$NEW_ICONSET" 2>/dev/null; then
          echo "✓ Ochre icon created"
        else
          echo "⚠ Failed to create ICNS file"
        fi
      else
        echo "⚠ Failed to recolor icon to ochre"
      fi
    fi
  else
    echo "⚠ Failed to extract icon from ICNS"
  fi

  rm -rf "$ICON_TEMP"
fi

echo ""
echo "To launch the Personal profile, you can use:"
echo "  code-oss-personal [folder]"
echo "or"
echo "  open -n -a 'Code-Personal' --args /absolute/path/to/folder"
echo ""
