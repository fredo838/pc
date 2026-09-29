#!/bin/bash
# Helpers for component install scripts. Must stay compatible with macOS's
# stock bash 3.2.

# Exit code meaning "skipped: a prerequisite is missing" -- lib/install-runner.sh
# reports these separately from failures.
SKIP_EXIT_CODE=100

# skip_component <reason> [hint...]: print why this component can't run yet
# (plus optional indented hints on how to fix it) and exit with SKIP_EXIT_CODE.
skip_component() {
  local reason="$1" hint
  shift
  echo "⊘ Skipped: $reason"
  for hint in "$@"; do
    echo "    $hint"
  done
  if [ -n "${SKIP_REASON_FILE:-}" ]; then
    printf '%s\n' "$reason" > "$SKIP_REASON_FILE"
  fi
  exit "$SKIP_EXIT_CODE"
}
