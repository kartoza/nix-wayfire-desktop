#!/usr/bin/env bash
# Wayfire workspace change trigger script
# Called whenever a workspace is changed

# Get current workspace information
# First try to get from command line argument (preferred)
if [[ -n "$1" ]]; then
    CURRENT_WS="$1"
else
    # Fall back to reading from cache file
    if [[ -f "$HOME/.cache/wayfire-current-workspace" ]]; then
        CURRENT_WS=$(cat "$HOME/.cache/wayfire-current-workspace" 2>/dev/null | tr -d '\n')
    else
        CURRENT_WS="0"
    fi
fi

WS_NAME_FILE="$(xdg-config-path wayfire/workspace-names.conf 2>/dev/null || echo "$HOME/.config/wayfire/workspace-names.conf")"
WS_NAME=$(cat "$WS_NAME_FILE" 2>/dev/null | grep "^${CURRENT_WS}=" | cut -d'=' -f2 || echo "Workspace ${CURRENT_WS}")

# Log the workspace change
echo "$(date '+%Y-%m-%d %H:%M:%S') - Changed to workspace: ${CURRENT_WS} (${WS_NAME})" >> ~/.local/state/wayfire-workspace.log

# Create log directory if it doesn't exist
mkdir -p ~/.local/state

# Optional: Send notification about workspace change
if command -v notify-send >/dev/null 2>&1; then
    notify-send -t 1000 "Workspace" "${WS_NAME}" -i applications-office
fi

# Optional: Update waybar if it has a workspace widget
pkill -SIGUSR1 waybar 2>/dev/null || true

# You can add more custom actions here:
# - Update workspace-specific configs
# - Start/stop workspace-specific services
# - Change wallpaper per workspace
# - etc.

exit 0