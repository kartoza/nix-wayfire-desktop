#!/usr/bin/env bash
# Fuzzel-based workspace switcher for Wayfire

WORKSPACE_NAMES_FILE="$HOME/.config/wayfire/workspace-names.conf"
SYSTEM_WORKSPACE_NAMES_FILE="/etc/xdg/wayfire/workspace-names.conf"

# Ensure we have a workspace names file
if [[ ! -f "$WORKSPACE_NAMES_FILE" ]]; then
    if [[ -f "$SYSTEM_WORKSPACE_NAMES_FILE" ]]; then
        mkdir -p "$(dirname "$WORKSPACE_NAMES_FILE")"
        cp "$SYSTEM_WORKSPACE_NAMES_FILE" "$WORKSPACE_NAMES_FILE"
    fi
fi

# Function to get current workspace
get_current_workspace() {
    wlrctl toplevel list 2>/dev/null | grep 'workspace:' | head -1 | sed 's/.*workspace: //' | cut -d' ' -f1 || echo "0"
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

# Function to switch to workspace
switch_to_workspace() {
    local ws_num="$1"
    if [[ "$ws_num" =~ ^[0-8]$ ]]; then
        # Use wlrctl to switch workspace
        wlrctl toplevel focus --workspace "$ws_num" 2>/dev/null || {
            # Fallback: simulate key press for workspace switching
            case "$ws_num" in
                0|1|2|3|4|5|6|7|8) wtype -M super -k "$((ws_num + 1))" -m super ;;
            esac
        }
        
        # Call workspace changed hook
        if [[ -x "$(command -v workspace-changed.sh)" ]]; then
            workspace-changed.sh &
        fi
    fi
}

# Generate workspace list for fuzzel
generate_workspace_list() {
    local current_ws=$(get_current_workspace)
    
    for ws_num in {0..8}; do
        local ws_name=$(get_workspace_name "$ws_num")
        local indicator=""
        
        # Add indicator for current workspace
        if [[ "$ws_num" == "$current_ws" ]]; then
            indicator=" 󰄴"  # Current workspace indicator
        fi
        
        # Format: "workspace_number: workspace_name [current_indicator]"
        echo "${ws_num}: ${ws_name}${indicator}"
    done
}

# Main logic
if command -v fuzzel >/dev/null 2>&1; then
    # Generate options and show fuzzel
    selected=$(generate_workspace_list | fuzzel --dmenu \
        --prompt="Switch to workspace: " \
        --placeholder="Select workspace..." \
        --font="sans-serif:size=12" \
        --width=40 \
        --lines=9 \
        --line-height=24 \
        --horizontal-pad=12 \
        --vertical-pad=8 \
        --inner-pad=8 \
        --border-radius=8 \
        --border-width=2)
    
    if [[ -n "$selected" ]]; then
        # Extract workspace number from selection
        ws_num=$(echo "$selected" | cut -d':' -f1)
        switch_to_workspace "$ws_num"
    fi
else
    echo "Error: fuzzel not found" >&2
    notify-send "Workspace Switcher" "fuzzel not installed" -i dialog-error
    exit 1
fi