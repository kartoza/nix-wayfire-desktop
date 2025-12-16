#!/usr/bin/env bash
# Wayfire workspace change trigger script
# Called whenever a workspace is changed

# Get current workspace information
CURRENT_WS=$(wlrctl toplevel list | grep 'output:' | head -1 | sed 's/.*workspace: //')
WS_NAME=$(cat ~/.config/wayfire/workspace-names.conf 2>/dev/null | grep "^${CURRENT_WS}=" | cut -d'=' -f2 || echo "Workspace ${CURRENT_WS}")

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