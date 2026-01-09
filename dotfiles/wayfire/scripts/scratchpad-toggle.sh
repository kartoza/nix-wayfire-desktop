#!/usr/bin/env bash
# Toggle scratchpad indicator when special workspace is shown/hidden
# Usage: scratchpad-toggle.sh

# Use system eww config from /etc/xdg/eww, or user override from ~/.config/eww
if [ -d "$HOME/.config/eww" ]; then
    EWW_CONFIG="$HOME/.config/eww"
else
    EWW_CONFIG="/etc/xdg/eww"
fi

# Ensure eww is running
if ! pgrep -x eww > /dev/null; then
    eww -c "$EWW_CONFIG" daemon &
    sleep 0.5
fi

# Open the scratchpad indicator window if not already open
if ! eww -c "$EWW_CONFIG" active-windows | grep -q "scratchpad-indicator"; then
    eww -c "$EWW_CONFIG" open scratchpad-indicator 2>/dev/null || true
fi

# Check if special workspace "scratchpad" is currently visible
# In Hyprland, special workspaces can be shown on top of regular workspaces
# We need to check all monitors to see if the scratchpad is displayed on any of them

# Get all monitors and check if any are showing the scratchpad special workspace
SCRATCHPAD_VISIBLE=$(hyprctl monitors -j | jq -r '.[] | .specialWorkspace.name' | grep -q "special:scratchpad" && echo "true" || echo "false")

if [ "$SCRATCHPAD_VISIBLE" = "true" ]; then
    # Scratchpad is visible on at least one monitor, show indicator
    eww -c "$EWW_CONFIG" update scratchpad_visible=true
else
    # Scratchpad is hidden on all monitors, hide indicator
    eww -c "$EWW_CONFIG" update scratchpad_visible=false
fi

exit 0
