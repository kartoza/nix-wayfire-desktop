#!/usr/bin/env bash
# Show workspace overlay using eww
# Usage: workspace-overlay.sh <workspace_number> <workspace_name>

WORKSPACE_NUMBER="${1:-0}"
WORKSPACE_NAME="${2:-Workspace}"
DISPLAY_DURATION="${3:-5000}" # milliseconds to show overlay (5 seconds)

# Use system eww config from ~/.config/eww, or user override from ~/.config/eww
if [ -d "$HOME/.config/eww" ]; then
  EWW_CONFIG="$HOME/.config/eww"
else
  EWW_CONFIG="~/.config/eww"
fi

# Ensure eww is running
if ! pgrep -x eww >/dev/null; then
  eww -c "$EWW_CONFIG" daemon &
  sleep 0.5
fi

# Open the overlay window if not already open
if ! eww -c "$EWW_CONFIG" active-windows | grep -q "workspace-overlay"; then
  eww -c "$EWW_CONFIG" open workspace-overlay 2>/dev/null || true
fi

# Update workspace information
eww -c "$EWW_CONFIG" update workspace_number="$WORKSPACE_NUMBER"
eww -c "$EWW_CONFIG" update workspace_name="$WORKSPACE_NAME"

# Show the overlay with animation
eww -c "$EWW_CONFIG" update workspace_visible=true

# Hide after duration (in background)
(
  sleep $(echo "scale=2; $DISPLAY_DURATION / 1000" | bc)
  eww -c "$EWW_CONFIG" update workspace_visible=false

  # Close the window after animation completes (add animation duration)
  sleep 0.5
  eww -c "$EWW_CONFIG" close workspace-overlay 2>/dev/null || true
) &

exit 0
