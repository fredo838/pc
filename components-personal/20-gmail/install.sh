#!/bin/bash
# Gmail filters - sets up the Python environment for apply_filters.py
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Setting up Gmail filters environment..."

python3 -m venv .venv
.venv/bin/pip install --quiet --upgrade pip
.venv/bin/pip install --quiet -r requirements.txt

echo "✓ Python environment ready (.venv)"
echo ""

if [ ! -f credentials.json ]; then
    echo "Next steps (one-time Google Cloud setup):"
    echo "  1. https://console.cloud.google.com/ -> create/select a project"
    echo "  2. Enable the 'Gmail API' for that project"
    echo "  3. Configure the OAuth consent screen (External, add yourself as a test user)"
    echo "  4. Create an OAuth client ID of type 'Desktop app'"
    echo "  5. Download the JSON and save it as:"
    echo "       $SCRIPT_DIR/credentials.json"
    echo ""
    echo "See README.md for details."
else
    echo "credentials.json found."
fi

echo ""
echo "Edit filters.yaml with your real rules, then run:"
echo "  .venv/bin/python apply_filters.py --dry-run   # preview"
echo "  .venv/bin/python apply_filters.py             # apply"
