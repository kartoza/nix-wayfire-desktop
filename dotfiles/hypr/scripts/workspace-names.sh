#!/usr/bin/env bash
# Hyprland workspace name management script

WORKSPACE_NAMES_FILE="$HOME/.config/hypr/workspace-names.conf"
SYSTEM_WORKSPACE_NAMES_FILE="/etc/xdg/hypr/workspace-names.conf"

# Ensure user config directory exists
mkdir -p "$(dirname "$WORKSPACE_NAMES_FILE")"

# Copy system default if user config doesn't exist
if [[ ! -f "$WORKSPACE_NAMES_FILE" && -f "$SYSTEM_WORKSPACE_NAMES_FILE" ]]; then
    cp "$SYSTEM_WORKSPACE_NAMES_FILE" "$WORKSPACE_NAMES_FILE"
fi

# Get workspace name by number
get_name() {
    local ws_num="$1"
    if [[ -f "$WORKSPACE_NAMES_FILE" ]]; then
        grep "^${ws_num}=" "$WORKSPACE_NAMES_FILE" | cut -d'=' -f2 | head -1
    fi
}

# Set workspace name
set_name() {
    local ws_num="$1"
    local ws_name="$2"
    
    # Remove existing entry for this workspace
    if [[ -f "$WORKSPACE_NAMES_FILE" ]]; then
        grep -v "^${ws_num}=" "$WORKSPACE_NAMES_FILE" > "${WORKSPACE_NAMES_FILE}.tmp" || true
        mv "${WORKSPACE_NAMES_FILE}.tmp" "$WORKSPACE_NAMES_FILE"
    fi
    
    # Add new entry
    echo "${ws_num}=${ws_name}" >> "$WORKSPACE_NAMES_FILE"
    
    # Sort the file by workspace number
    sort -t'=' -k1,1n "$WORKSPACE_NAMES_FILE" -o "$WORKSPACE_NAMES_FILE"
    
    echo "Workspace ${ws_num} named '${ws_name}'"
}

# List all workspace names
list_names() {
    echo "Workspace Names:"
    echo "================"
    if [[ -f "$WORKSPACE_NAMES_FILE" ]]; then
        while IFS='=' read -r ws_num ws_name; do
            [[ "$ws_num" =~ ^[0-9]+$ ]] && echo "  ${ws_num}: ${ws_name}"
        done < "$WORKSPACE_NAMES_FILE"
    else
        echo "  No workspace names configured"
    fi
}

# Get current workspace number
get_current() {
    # Use hyprland workspace manager for reliable workspace detection
    if [[ -x "$(command -v hyprland-workspace-manager.sh)" ]]; then
        hyprland-workspace-manager.sh get
    else
        # Fallback to cache file reading
        local cache_file="$HOME/.cache/hyprland-current-workspace"
        if [[ -f "$cache_file" ]]; then
            local workspace=$(cat "$cache_file" 2>/dev/null | tr -d '\n')
            if [[ "$workspace" =~ ^[0-8]$ ]]; then
                echo "$workspace"
                return
            fi
        fi
        
        # Default to workspace 0 if cache doesn't exist
        echo "0"
    fi
}

case "${1:-}" in
    "get")
        get_name "${2:-$(get_current)}"
        ;;
    "set")
        if [[ -z "$2" || -z "$3" ]]; then
            echo "Usage: $0 set <workspace_number> <workspace_name>"
            exit 1
        fi
        set_name "$2" "$3"
        ;;
    "list")
        list_names
        ;;
    "current")
        current=$(get_current)
        name=$(get_name "$current")
        echo "Current workspace: ${current} (${name:-"Workspace $current"})"
        ;;
    *)
        echo "Usage: $0 {get|set|list|current} [args...]"
        echo "  get [workspace_number]     - Get name of workspace (default: current)"
        echo "  set <workspace_number> <name> - Set workspace name"
        echo "  list                       - List all workspace names"
        echo "  current                    - Show current workspace and name"
        exit 1
        ;;
esac