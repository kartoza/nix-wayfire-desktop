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

# Check if special workspace is visible
# The special workspace ID is -99 in Hyprland
ACTIVE_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')

if [ "$ACTIVE_WORKSPACE" = "-99" ]; then
    # Scratchpad is visible, show indicator
    eww -c "$EWW_CONFIG" update scratchpad_visible=true
else
    # Scratchpad is hidden, hide indicator
    eww -c "$EWW_CONFIG" update scratchpad_visible=false
fi

exit 0
