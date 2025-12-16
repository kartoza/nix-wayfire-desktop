#!/usr/bin/env bash
# Waybar workspace display widget
# Shows current workspace number and name

WORKSPACE_NAMES_FILE="$(xdg-config-path wayfire/workspace-names.conf 2>/dev/null || echo "$HOME/.config/wayfire/workspace-names.conf")"

# Function to get current workspace
get_current_workspace() {
    # Use wayfire workspace manager for reliable workspace detection
    if [[ -x "$(command -v wayfire-workspace-manager.sh)" ]]; then
        wayfire-workspace-manager.sh get
    else
        # Fallback to cache file reading
        local cache_file="$HOME/.cache/wayfire-current-workspace"
        if [[ -f "$cache_file" ]]; then
            local workspace=$(cat "$cache_file" 2>/dev/null | tr -d '\n')
            if [[ "$workspace" =~ ^[0-8]$ ]]; then
                echo "$workspace"
                return
            fi
        fi
        
        # Default to workspace 0 if cache doesn't exist or is invalid
        echo "0"
        # Create cache with default
        mkdir -p "$(dirname "$cache_file")"
        echo "0" > "$cache_file"
    fi
}

# Function to get workspace name
get_workspace_name() {
    local ws_num="$1"
    if [[ -f "$WORKSPACE_NAMES_FILE" ]]; then
        local name=$(grep "^${ws_num}=" "$WORKSPACE_NAMES_FILE" | cut -d'=' -f2 | head -1)
        echo "${name:-"Workspace $ws_num"}"
    else
        echo "Workspace $ws_num"
    fi
}

# Get current workspace info
current_ws=$(get_current_workspace)
ws_name=$(get_workspace_name "$current_ws")

# Generate waybar JSON output
echo "{\"text\": \"$((current_ws + 1)): ${ws_name}\", \"tooltip\": \"Current workspace: $((current_ws + 1)) (${ws_name})\\nClick to switch workspaces\", \"class\": \"workspace-${current_ws}\"}"