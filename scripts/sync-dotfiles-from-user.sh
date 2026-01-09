#!/usr/bin/env bash
# Sync user dotfiles back to repository
# This script copies configurations from ~/.config/ back to the dotfiles/ directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
DOTFILES_DIR="$REPO_ROOT/dotfiles"
USER_CONFIG="$HOME/.config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if source exists
check_source() {
    local source=$1
    if [ ! -e "$source" ]; then
        return 1
    fi
    return 0
}

# Sync a directory
sync_dir() {
    local name=$1
    local source="$USER_CONFIG/$name"
    local dest="$DOTFILES_DIR/$name"

    if ! check_source "$source"; then
        print_warning "Skipping $name (not found in ~/.config/)"
        return
    fi

    print_info "Syncing $name..."

    # Create backup if destination exists
    if [ -e "$dest" ]; then
        local backup="$dest.backup.$(date +%Y%m%d-%H%M%S)"
        print_info "Creating backup: $backup"
        cp -r "$dest" "$backup"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    # Sync the directory
    rsync -av --delete "$source/" "$dest/" > /dev/null

    print_success "Synced $name"
}

# Sync a single file
sync_file() {
    local name=$1
    local source="$USER_CONFIG/$name"
    local dest="$DOTFILES_DIR/$name"

    if ! check_source "$source"; then
        print_warning "Skipping $name (not found in ~/.config/)"
        return
    fi

    print_info "Syncing $name..."

    # Create backup if destination exists
    if [ -e "$dest" ]; then
        local backup="$dest.backup.$(date +%Y%m%d-%H%M%S)"
        print_info "Creating backup: $backup"
        cp "$dest" "$backup"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    # Copy the file
    cp "$source" "$dest"

    print_success "Synced $name"
}

# Main sync function
sync_dotfiles() {
    echo ""
    echo "================================================"
    echo "  Syncing User Dotfiles to Repository"
    echo "================================================"
    echo ""
    print_info "Repository: $REPO_ROOT"
    print_info "User config: $USER_CONFIG"
    echo ""

    # Wayfire
    print_info "--- Wayfire Configuration ---"
    sync_file "wayfire/wayfire.ini"
    sync_dir "wayfire/scripts"
    sync_file "wayfire/workspace-names.conf"
    echo ""

    # Waybar
    print_info "--- Waybar Configuration ---"
    sync_file "waybar/config"
    sync_file "waybar/style.css"
    sync_dir "waybar/config.d"
    sync_dir "waybar/scripts"
    echo ""

    # Mako
    print_info "--- Mako Configuration ---"
    sync_file "mako/config"
    # Try kartoza config as fallback
    if [ -f "$USER_CONFIG/mako/kartoza" ]; then
        sync_file "mako/kartoza"
    fi
    if [ -d "$USER_CONFIG/mako/sounds" ]; then
        sync_dir "mako/sounds"
    fi
    echo ""

    # Swaylock
    print_info "--- Swaylock Configuration ---"
    sync_file "swaylock/config"
    echo ""

    # Fuzzel
    print_info "--- Fuzzel Configuration ---"
    if [ -d "$USER_CONFIG/fuzzel" ]; then
        sync_dir "fuzzel"
    fi
    echo ""

    # Qt5ct
    print_info "--- Qt5ct Configuration ---"
    if [ -d "$USER_CONFIG/qt5ct" ]; then
        sync_dir "qt5ct"
    fi
    echo ""

    # nwg-launchers
    print_info "--- nwg-launchers Configuration ---"
    if [ -d "$USER_CONFIG/nwg-launchers" ]; then
        if [ -d "$USER_CONFIG/nwg-launchers/nwggrid" ]; then
            mkdir -p "$DOTFILES_DIR/nwggrid"
            if [ -f "$USER_CONFIG/nwg-launchers/nwggrid/style.css" ]; then
                cp "$USER_CONFIG/nwg-launchers/nwggrid/style.css" "$DOTFILES_DIR/nwggrid/style.css"
                print_success "Synced nwggrid/style.css"
            fi
        fi
        if [ -d "$USER_CONFIG/nwg-launchers/nwgbar" ]; then
            mkdir -p "$DOTFILES_DIR/nwgbar"
            if [ -f "$USER_CONFIG/nwg-launchers/nwgbar/style.css" ]; then
                cp "$USER_CONFIG/nwg-launchers/nwgbar/style.css" "$DOTFILES_DIR/nwgbar/style.css"
                print_success "Synced nwgbar/style.css"
            fi
        fi
    fi
    echo ""

    echo "================================================"
    print_success "Sync complete!"
    echo "================================================"
    echo ""
    print_info "Next steps:"
    echo "  1. Review changes: git status"
    echo "  2. Check diffs: git diff"
    echo "  3. Commit changes: git add . && git commit -m 'Update dotfiles from user config'"
    echo ""
}

# Show usage
show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Sync user dotfiles from ~/.config/ back to the repository's dotfiles/ directory.

OPTIONS:
    -h, --help      Show this help message
    -d, --dry-run   Show what would be synced without actually syncing

EXAMPLES:
    # Sync all dotfiles
    $(basename "$0")

    # Preview what would be synced
    $(basename "$0") --dry-run

NOTES:
    - Existing files in the repository are backed up before syncing
    - Backups are timestamped and saved in the dotfiles/ directory
    - Only files that exist in ~/.config/ will be synced
EOF
}

# Dry run function
dry_run() {
    echo ""
    echo "================================================"
    echo "  DRY RUN: Would sync these files"
    echo "================================================"
    echo ""

    check_and_print() {
        local source="$USER_CONFIG/$1"
        if [ -e "$source" ]; then
            echo "  ✓ $1"
        else
            echo "  ✗ $1 (not found)"
        fi
    }

    print_info "Wayfire:"
    check_and_print "wayfire/wayfire.ini"
    check_and_print "wayfire/scripts"
    check_and_print "wayfire/workspace-names.conf"

    echo ""
    print_info "Waybar:"
    check_and_print "waybar/config"
    check_and_print "waybar/style.css"
    check_and_print "waybar/config.d"
    check_and_print "waybar/scripts"

    echo ""
    print_info "Mako:"
    check_and_print "mako/config"
    check_and_print "mako/kartoza"
    check_and_print "mako/sounds"

    echo ""
    print_info "Swaylock:"
    check_and_print "swaylock/config"

    echo ""
    print_info "Fuzzel:"
    check_and_print "fuzzel"

    echo ""
    print_info "Qt5ct:"
    check_and_print "qt5ct"

    echo ""
    print_info "nwg-launchers:"
    check_and_print "nwg-launchers/nwggrid"
    check_and_print "nwg-launchers/nwgbar"

    echo ""
    print_info "Run without --dry-run to perform the sync"
    echo ""
}

# Parse arguments
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    -d|--dry-run)
        dry_run
        exit 0
        ;;
    "")
        sync_dotfiles
        ;;
    *)
        print_error "Unknown option: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
