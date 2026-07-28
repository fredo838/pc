#!/bin/bash

# Installs global (User-level) VS Code settings so they apply to ALL projects.
# Unlike a workspace .vscode/settings.json (which only affects a single repo),
# these are merged into the User settings.json.
#
# The merge is non-destructive: existing keys are kept, and keys present in the
# source file override the current values. A timestamped backup is created first.

set -euo pipefail

# Define the source path (settings we want applied everywhere)
SOURCE_FILE="./vscode-settings.json"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS path
    DEST_DIR="$HOME/Library/Application Support/Code/User"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux path
    DEST_DIR="$HOME/.config/Code/User"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

DEST_FILE="$DEST_DIR/settings.json"

if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file $SOURCE_FILE not found!"
    exit 1
fi

# Create directory if it doesn't exist (unlikely, but safe)
mkdir -p "$DEST_DIR"

# Ensure we have a tool to merge JSON safely
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required to merge settings.json safely."
    exit 1
fi

# Back up the existing settings, if any
if [ -f "$DEST_FILE" ]; then
    BACKUP_FILE="$DEST_FILE.bak.$(date +%Y%m%d%H%M%S)"
    cp "$DEST_FILE" "$BACKUP_FILE"
    echo "Backed up existing settings to $BACKUP_FILE"
fi

# Merge source settings into destination (source wins on conflicts).
# VS Code settings.json may contain comments/trailing commas (JSONC); this loader
# tolerates a plain-JSON existing file. If yours uses comments, strip them first.
python3 - "$SOURCE_FILE" "$DEST_FILE" <<'PY'
import json, os, sys

source_path, dest_path = sys.argv[1], sys.argv[2]

with open(source_path, "r", encoding="utf-8") as f:
    source = json.load(f)

dest = {}
if os.path.exists(dest_path) and os.path.getsize(dest_path) > 0:
    with open(dest_path, "r", encoding="utf-8") as f:
        try:
            dest = json.load(f)
        except json.JSONDecodeError:
            sys.stderr.write(
                "Warning: existing settings.json is not plain JSON (comments/"
                "trailing commas?). Aborting to avoid data loss.\n"
            )
            sys.exit(1)

dest.update(source)

with open(dest_path, "w", encoding="utf-8") as f:
    json.dump(dest, f, indent=4, ensure_ascii=False)
    f.write("\n")
PY

echo "Success: Global settings merged into $DEST_FILE"
