#!/bin/bash

# Define the source path (change this to your backup file location)
SOURCE_FILE="./vscode-keybindings.json"

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

# Create directory if it doesn't exist (unlikely, but safe)
mkdir -p "$DEST_DIR"

# Perform the copy
if [ -f "$SOURCE_FILE" ]; then
    cp "$SOURCE_FILE" "$DEST_DIR/keybindings.json"
    echo "Success: Keybindings copied to $DEST_DIR"
else
    echo "Error: Source file $SOURCE_FILE not found!"
    exit 1
fi