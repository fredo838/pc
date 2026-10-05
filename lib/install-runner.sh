#!/bin/bash
# Runs component installers and reports a summary. Sourced by
# install-ubuntu.sh and install-mac.sh; must stay compatible with macOS's
# stock bash 3.2.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SUCCEEDED=()
SKIPPED=()
FAILED=()

print_header() {
  echo ""
  echo "════════════════════════════════════════════════════════════════"
  echo "  $1"
  echo "════════════════════════════════════════════════════════════════"
}

# run_component <script>: run one installer, recording success, skip (a
# prerequisite is missing, see lib/component.sh) or failure without stopping
# the remaining components.
run_component() {
  local script="$1"
  local name="${script#"$REPO_DIR"/}"
  local rc=0 reason
  print_header "$name"
  SKIP_REASON_FILE="$(mktemp)"
  export SKIP_REASON_FILE
  bash "$script" || rc=$?
  reason="$(cat "$SKIP_REASON_FILE")"
  rm -f "$SKIP_REASON_FILE"
  unset SKIP_REASON_FILE

  if [ "$rc" -eq 0 ]; then
    SUCCEEDED+=("$name")
  elif [ "$rc" -eq 100 ]; then
    SKIPPED+=("$name — ${reason:-prerequisite missing}")
  else
    FAILED+=("$name")
    echo -e "${RED}✗ $name failed (exit $rc)${NC}"
  fi
}

print_summary() {
  local name
  print_header "Summary"
  for name in "${SUCCEEDED[@]}"; do
    echo -e "${GREEN}✓ $name${NC}"
  done
  for name in "${SKIPPED[@]}"; do
    echo -e "${YELLOW}⊘ $name${NC}"
  done
  for name in "${FAILED[@]}"; do
    echo -e "${RED}✗ $name${NC}"
  done
  echo ""
  if [ ${#SKIPPED[@]} -gt 0 ]; then
    echo -e "${YELLOW}${#SKIPPED[@]} skipped: a prerequisite is missing.${NC} Fix it as described in"
    echo "that component's output above, then re-run."
  fi
  if [ ${#FAILED[@]} -eq 0 ]; then
    echo -e "${GREEN}${#SUCCEEDED[@]} components completed, none failed.${NC}"
    echo "Manual follow-up steps: see README-INSTALL.md"
    return 0
  fi
  echo -e "${RED}${#FAILED[@]} failed.${NC} Review the output above; every component is safe to"
  echo "re-run on its own, e.g.: bash ${FAILED[0]}"
  return 1
}
