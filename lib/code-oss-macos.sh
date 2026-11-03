#!/bin/bash
# macOS launch plumbing for a profile of the self-built VS Code (Code - OSS)
# at ~/projects/vscode: a launch helper in ~/.local/bin, an app wrapper in
# ~/Applications (so Spotlight/Launchpad/the Dock show it with its own icon),
# and that icon, recoloured from the real VS Code logo. Shared by the Personal
# and IoT profile installers; must stay compatible with macOS's stock bash 3.2.
#
# Callers set, before calling code_oss_install_macos_app:
#   SCRIPT_DIR      the component directory
#   PROFILE_DIR     --user-data-dir
#   EXTENSIONS_DIR  --extensions-dir
#   PROFILE_NAME    profile name (e.g. Personal)
# and pass:
#   $1 app name       e.g. Code-Personal  (~/Applications/<name>.app)
#   $2 launcher name  e.g. code-oss-personal  (~/.local/bin/<name>)
#   $3 bundle id      e.g. com.local.code-oss-personal
#   $4 display name   e.g. "VS Code (Personal)"
#   $5 icon colour    hex, e.g. CC7722 (ochre)

CODE_OSS_REPO_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

code_oss_install_macos_app() {
  local app_name="$1" launcher_name="$2" bundle_id="$3" display_name="$4" icon_colour="$5"

  # Launch helper: launch via the app wrapper so the profile's icon appears
  # in the dock. `open` runs the wrapper with cwd=/ and only forwards argv
  # after --args, so resolve paths here and force a fresh wrapper process
  # with -n (otherwise `open` just activates a running one and the folder
  # never arrives).
  local launch_dir="$HOME/.local/bin"
  local launch_script="$launch_dir/$launcher_name"
  mkdir -p "$launch_dir"
  cat > "$launch_script" <<LAUNCHER
#!/bin/bash
# Launcher for the self-built VS Code $PROFILE_NAME profile on macOS.
ARGS=()
for arg in "\$@"; do
  if [[ "\$arg" != -* && -e "\$arg" ]]; then
    ARGS+=("\$(cd "\$(dirname "\$arg")" && pwd)/\$(basename "\$arg")")
  else
    ARGS+=("\$arg")
  fi
done
exec open -n -a "$app_name" --args "\${ARGS[@]}"
LAUNCHER
  chmod +x "$launch_script"
  echo "✓ Launch script installed at: $launch_script"

  # App wrapper pointing at the self-built Code.app with this profile's dirs.
  local app_wrapper="$HOME/Applications/$app_name.app"
  local wrapper_contents="$app_wrapper/Contents"
  local wrapper_macos="$wrapper_contents/MacOS"
  mkdir -p "$wrapper_macos"
  cat > "$wrapper_macos/$app_name" <<APPWRAPPER
#!/bin/bash
# Arguments arrive via \`open -n -a $app_name --args ...\` (see the code_oss_*
# functions in components-global/12-zsh/.zshrc).
ARGS=()
for arg in "\$@"; do
  case "\$arg" in
    -*)
      # Keep flags as-is
      ARGS+=("\$arg")
      ;;
    *)
      # Resolve relative paths to absolute
      if [[ -e "\$arg" ]]; then
        ARGS+=("\$(cd "\$(dirname "\$arg")" && pwd)/\$(basename "\$arg")")
      else
        ARGS+=("\$arg")
      fi
      ;;
  esac
done

exec env \\
  VSCODE_DEV=1 \\
  NODE_ENV=development \\
  "\$HOME/projects/vscode/.build/electron/Code - OSS.app/Contents/MacOS/Code - OSS" \\
  "\$HOME/projects/vscode" \\
  --user-data-dir "$PROFILE_DIR" \\
  --extensions-dir "$EXTENSIONS_DIR" \\
  --profile $PROFILE_NAME \\
  --enable-proposed-api=local.bode-claude \\
  "\${ARGS[@]}"
APPWRAPPER
  chmod +x "$wrapper_macos/$app_name"

  cat > "$wrapper_contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>$app_name</string>
	<key>CFBundleIconFile</key>
	<string>Code</string>
	<key>CFBundleIdentifier</key>
	<string>$bundle_id</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$display_name</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleVersion</key>
	<string>1.0</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSHumanReadableCopyright</key>
	<string>VS Code $PROFILE_NAME Profile</string>
</dict>
</plist>
PLIST
  echo "✓ App wrapper installed at: $app_wrapper"

  code_oss_macos_icon "$wrapper_contents" "$icon_colour"
}

# Recolours the real VS Code logo (from the global installation) to
# `colour` and installs it as the app wrapper's icon.
code_oss_macos_icon() {
  local wrapper_contents="$1" colour="$2"
  local real_icon="/Applications/Visual Studio Code.app/Contents/Resources/Code.icns"
  if [ ! -f "$real_icon" ]; then
    echo "⚠ VS Code icon not found at $real_icon, skipping the #$colour icon"
    return 0
  elif ! command -v iconutil >/dev/null 2>&1; then
    echo "⚠ iconutil not found, skipping the #$colour icon"
    return 0
  elif ! python3 -c "import PIL" >/dev/null 2>&1; then
    echo "⚠ Pillow not installed for python3, skipping the #$colour icon"
    return 0
  fi

  echo "Creating #$colour icon for the macOS app wrapper..."
  local icon_temp icon_iconset source_png png
  icon_temp="$(mktemp -d)"
  icon_iconset="$icon_temp/Code.iconset"
  mkdir -p "$icon_iconset"

  if iconutil -c iconset -o "$icon_iconset" "$real_icon" 2>/dev/null; then
    source_png=""
    for png in "$icon_iconset"/*.png; do
      if [[ "$png" == *"icon_256x256.png" ]] || [[ "$png" == *"icon_512x512.png" ]]; then
        source_png="$png"
        break
      fi
    done
    if [ -z "$source_png" ]; then
      for png in "$icon_iconset"/*.png; do
        source_png="$png"
        break
      done
    fi

    if [ -n "$source_png" ] && [ -f "$source_png" ]; then
      local tinted_png="$icon_temp/Code-tinted.png"
      if python3 "$CODE_OSS_REPO_LIB_DIR/recolour-icon.py" "$source_png" "$tinted_png" "$colour"; then
        local new_iconset="$icon_temp/Code-tinted.iconset" size
        mkdir -p "$new_iconset"
        for size in 16 32 64 128 256 512 1024; do
          sips -z $size $size "$tinted_png" --out "$new_iconset/icon_${size}x${size}.png" >/dev/null 2>&1
          sips -z $((size * 2)) $((size * 2)) "$tinted_png" --out "$new_iconset/icon_${size}x${size}@2x.png" >/dev/null 2>&1
        done
        mkdir -p "$wrapper_contents/Resources"
        if iconutil -c icns -o "$wrapper_contents/Resources/Code.icns" "$new_iconset" 2>/dev/null; then
          echo "✓ #$colour icon created"
        else
          echo "⚠ Failed to create ICNS file"
        fi
      else
        echo "⚠ Failed to recolour icon to #$colour"
      fi
    fi
  else
    echo "⚠ Failed to extract icon from ICNS"
  fi

  rm -rf "$icon_temp"
}
