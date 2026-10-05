#!/bin/bash
# Set up (or re-apply) this repo on Ubuntu: every component in
# components-global, components-work and components-personal, in that order.
# Safe to re-run.
#
# Usage: bash install-ubuntu.sh [global] [work] [personal]   (default: all)

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_DIR/lib/install-runner.sh"

if [ "$(uname -s)" != "Linux" ]; then
  echo "❌ install-ubuntu.sh is for Ubuntu; on macOS run: bash install-mac.sh"
  exit 1
fi

SELECTED_GROUPS=("$@")
if [ ${#SELECTED_GROUPS[@]} -eq 0 ]; then
  SELECTED_GROUPS=(global work personal)
fi

# Ask for the sudo password once up front instead of mid-run.
sudo -v

set +e
for group in "${SELECTED_GROUPS[@]}"; do
  group_dir="$REPO_DIR/components-$group"
  if [ ! -d "$group_dir" ]; then
    echo "❌ Unknown group: $group (expected global, work or personal)"
    exit 1
  fi
  for component in "$group_dir"/*/; do
    if [ -f "$component/install-linux.sh" ]; then
      run_component "${component}install-linux.sh"
    elif [ -f "$component/install.sh" ]; then
      run_component "${component}install.sh"
    fi
  done
done

print_summary
