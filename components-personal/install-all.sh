#!/bin/bash
# Master installation script - Install all or selected PERSONAL components

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counter for tracking installations
TOTAL=0
SUCCESSFUL=0
FAILED=0
SKIPPED=0

# Parse command line arguments
INSTALL_ALL=${1:-false}
INTERACTIVE=${2:-true}

print_header() {
    echo ""
    echo "=========================================="
    echo "  $1"
    echo "=========================================="
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_header "Personal Components Installation"

if [ "$INTERACTIVE" = "true" ] && [ "$INSTALL_ALL" != "all" ]; then
    echo "Select installation mode:"
    echo "  1) Install all components"
    echo "  2) Install selected components"
    echo "  3) List available components"
    read -p "Choice (1-3): " choice

    if [ "$choice" = "3" ]; then
        echo ""
        echo "Available personal components:"
        ls -1d */ | sed 's|/||' | nl
        exit 0
    elif [ "$choice" != "1" ] && [ "$choice" != "2" ]; then
        print_error "Invalid choice"
        exit 1
    fi
    INSTALL_ALL=$choice
fi

# Get list of component directories
COMPONENTS=($(ls -1d */ | sed 's|/||' | sort))

if [ "$INSTALL_ALL" = "2" ]; then
    # Interactive selection
    echo ""
    echo "Select components to install (enter numbers separated by spaces):"
    echo "Example: 1 2 3"
    echo ""
    for i in "${!COMPONENTS[@]}"; do
        printf "%2d) %s\n" $((i+1)) "${COMPONENTS[$i]}"
    done
    echo ""
    read -p "Selection: " selection

    SELECTED=()
    for num in $selection; do
        if [ "$num" -ge 1 ] && [ "$num" -le "${#COMPONENTS[@]}" ]; then
            SELECTED+=("${COMPONENTS[$((num-1))]}")
        fi
    done
    COMPONENTS=("${SELECTED[@]}")
fi

# Run selected components
print_header "Starting Personal Components Installation"
echo "Components to install: ${#COMPONENTS[@]}"
echo "Selected components:"
for comp in "${COMPONENTS[@]}"; do
    echo "  - $comp"
done
echo ""

if [ "$INTERACTIVE" = "true" ]; then
    read -p "Press Enter to continue (Ctrl+C to cancel)..."
fi

echo ""

# Install components
for component in "${COMPONENTS[@]}"; do
    TOTAL=$((TOTAL + 1))

    if [ -f "$component/install.sh" ]; then
        print_header "Installing: $component"

        if bash "$component/install.sh"; then
            print_success "$component installed successfully"
            SUCCESSFUL=$((SUCCESSFUL + 1))
        else
            print_error "$component installation failed"
            FAILED=$((FAILED + 1))
        fi
    else
        print_warning "$component/install.sh not found"
        SKIPPED=$((SKIPPED + 1))
    fi

    echo ""
done

# Print summary
print_header "Installation Summary"
echo "Total components:     $TOTAL"
echo -e "Successful:          ${GREEN}$SUCCESSFUL${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "Failed:              ${RED}$FAILED${NC}"
fi
if [ $SKIPPED -gt 0 ]; then
    echo -e "Skipped:             ${YELLOW}$SKIPPED${NC}"
fi

if [ $FAILED -eq 0 ]; then
    print_success "All personal installations completed!"
    echo ""
    echo "Post-installation steps:"
    echo "  1. Add GitHub SSH key to your account"
    echo "  2. Sign into Chrome with Google account"
    echo "  3. Install Chrome extensions"
    echo "  4. Sign into Steam"
    echo "  5. Test: ssh -T git@github.com"
    exit 0
else
    print_error "Some installations failed. Please review the output above."
    exit 1
fi
