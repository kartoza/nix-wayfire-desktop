#!/usr/bin/env bash
# Deploy dotfiles from repository to user's ~/.config/
# This script copies configurations from dotfiles/ to ~/.config/

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

# Check if source exists in repo
check_source() {
    local source=$1
    if [ ! -e "$source" ]; then
        return 1
    fi
    return 0
}

# Deploy a directory
deploy_dir() {
    local name=$1
    local source="$DOTFILES_DIR/$name"
    local dest="$USER_CONFIG/$name"

    if ! check_source "$source"; then
        print_warning "Skipping $name (not found in repository)"
        return
    fi

    print_info "Deploying $name..."

    # Create backup if destination exists
    if [ -e "$dest" ]; then
        local backup="$dest.backup.$(date +%Y%m%d-%H%M%S)"
        print_info "Creating backup: $backup"
        mv "$dest" "$backup"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    # Copy the directory
    cp -r "$source" "$dest"

    # Make scripts executable
    if [ "$name" = "wayfire/scripts" ] || [ "$name" = "waybar/scripts" ]; then
        chmod +x "$dest"/*.sh 2>/dev/null || true
    fi

    print_success "Deployed $name"
}

# Deploy a single file
deploy_file() {
    local name=$1
    local source="$DOTFILES_DIR/$name"
    local dest="$USER_CONFIG/$name"

    if ! check_source "$source"; then
        print_warning "Skipping $name (not found in repository)"
        return
    fi

    print_info "Deploying $name..."

    # Create backup if destination exists
    if [ -e "$dest" ]; then
        local backup="$dest.backup.$(date +%Y%m%d-%H%M%S)"
        print_info "Creating backup: $backup"
        mv "$dest" "$backup"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    # Copy the file
    cp "$source" "$dest"

    print_success "Deployed $name"
}

# Main deploy function
deploy_dotfiles() {
    echo ""
    echo "================================================"
    echo "  Deploying Dotfiles to User Configuration"
    echo "================================================"
    echo ""
    print_info "Repository: $REPO_ROOT"
    print_info "User config: $USER_CONFIG"
    echo ""

    # Wayfire
    print_info "--- Wayfire Configuration ---"
    deploy_file "wayfire/wayfire.ini"
    deploy_dir "wayfire/scripts"
    if [ -f "$DOTFILES_DIR/wayfire/workspace-names.conf" ]; then
        deploy_file "wayfire/workspace-names.conf"
    fi
    echo ""

    # Waybar
    print_info "--- Waybar Configuration ---"
    deploy_file "waybar/config"
    deploy_file "waybar/style.css"
    deploy_dir "waybar/config.d"
    deploy_dir "waybar/scripts"

    # Copy waybar build script if it exists
    if [ -f "$DOTFILES_DIR/waybar/build-config.sh" ]; then
        cp "$DOTFILES_DIR/waybar/build-config.sh" "$USER_CONFIG/waybar/"
        chmod +x "$USER_CONFIG/waybar/build-config.sh"
        print_success "Deployed waybar/build-config.sh"
    fi
    echo ""

    # Mako
    print_info "--- Mako Configuration ---"
    mkdir -p "$USER_CONFIG/mako"

    # Deploy config or kartoza config
    if [ -f "$DOTFILES_DIR/mako/config" ]; then
        deploy_file "mako/config"
    elif [ -f "$DOTFILES_DIR/mako/kartoza" ]; then
        # Use kartoza as the main config
        cp "$DOTFILES_DIR/mako/kartoza" "$USER_CONFIG/mako/config"
        print_success "Deployed mako/kartoza as config"
    fi

    # Deploy sounds
    if [ -d "$DOTFILES_DIR/mako/sounds" ]; then
        mkdir -p "$USER_CONFIG/mako/sounds"
        cp -r "$DOTFILES_DIR/mako/sounds/"* "$USER_CONFIG/mako/sounds/" 2>/dev/null || true
        print_success "Deployed mako/sounds"
    fi
    echo ""

    # Swaylock
    print_info "--- Swaylock Configuration ---"
    if [ -f "$DOTFILES_DIR/swaylock/config" ]; then
        deploy_file "swaylock/config"
    fi
    echo ""

    # Fuzzel
    print_info "--- Fuzzel Configuration ---"
    if [ -d "$DOTFILES_DIR/fuzzel" ]; then
        deploy_dir "fuzzel"
        # Make fuzzel scripts executable
        chmod +x "$USER_CONFIG/fuzzel/"* 2>/dev/null || true
    fi
    echo ""

    # Qt5ct
    print_info "--- Qt5ct Configuration ---"
    if [ -d "$DOTFILES_DIR/qt5ct" ]; then
        deploy_dir "qt5ct"
    fi
    echo ""

    # nwg-launchers
    print_info "--- nwg-launchers Configuration ---"
    if [ -d "$DOTFILES_DIR/nwggrid" ] || [ -d "$DOTFILES_DIR/nwgbar" ]; then
        mkdir -p "$USER_CONFIG/nwg-launchers"

        if [ -d "$DOTFILES_DIR/nwggrid" ]; then
            cp -r "$DOTFILES_DIR/nwggrid" "$USER_CONFIG/nwg-launchers/"
            print_success "Deployed nwggrid"
        fi

        if [ -d "$DOTFILES_DIR/nwgbar" ]; then
            cp -r "$DOTFILES_DIR/nwgbar" "$USER_CONFIG/nwg-launchers/"
            print_success "Deployed nwgbar"
        fi
    fi
    echo ""

    echo "================================================"
    print_success "Deployment complete!"
    echo "================================================"
    echo ""
    print_info "Your dotfiles have been deployed to ~/.config/"
    print_info "Existing files have been backed up with timestamps"
    echo ""
    print_warning "You may need to reload Wayfire to apply changes:"
    echo "  - Press Super+Shift+R to reload Wayfire"
    echo "  - Or run: wayfire --replace &"
    echo ""
    print_warning "You may also need to restart waybar:"
    echo "  - killall waybar && waybar &"
    echo ""
}

# Show usage
show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Deploy dotfiles from repository's dotfiles/ directory to ~/.config/.

OPTIONS:
    -h, --help      Show this help message
    -d, --dry-run   Show what would be deployed without actually deploying
    -f, --force     Skip confirmation prompt

EXAMPLES:
    # Deploy all dotfiles (with confirmation)
    $(basename "$0")

    # Deploy without confirmation
    $(basename "$0") --force

    # Preview what would be deployed
    $(basename "$0") --dry-run

NOTES:
    - Existing files in ~/.config/ are backed up before deployment
    - Backups are timestamped and saved in ~/.config/
    - Scripts are automatically made executable
    - You may need to reload Wayfire/waybar after deployment
EOF
}

# Dry run function
dry_run() {
    echo ""
    echo "================================================"
    echo "  DRY RUN: Would deploy these files"
    echo "================================================"
    echo ""

    check_and_print() {
        local source="$DOTFILES_DIR/$1"
        if [ -e "$source" ]; then
            echo "  ✓ $1"
        else
            echo "  ✗ $1 (not found in repo)"
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
    check_and_print "nwggrid"
    check_and_print "nwgbar"

    echo ""
    print_info "Run without --dry-run to perform the deployment"
    echo ""
}

# Confirmation prompt
confirm_deployment() {
    echo ""
    print_warning "This will deploy dotfiles to ~/.config/"
    print_warning "Existing files will be backed up"
    echo ""
    read -p "Continue? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deployment cancelled"
        exit 0
    fi
}

# Parse arguments
FORCE=0
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    -d|--dry-run)
        dry_run
        exit 0
        ;;
    -f|--force)
        FORCE=1
        ;;
    "")
        # Continue to confirmation
        ;;
    *)
        print_error "Unknown option: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac

# Ask for confirmation unless --force
if [ $FORCE -eq 0 ]; then
    confirm_deployment
fi

# Run deployment
deploy_dotfiles
