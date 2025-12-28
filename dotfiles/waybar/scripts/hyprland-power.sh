#!/usr/bin/env bash
# Power menu script for Hyprland - creates temp config with correct logout command

TEMP_CONFIG="/tmp/nwgbar-hyprland.json"

# Create config with hyprland-specific logout command
cat >"$TEMP_CONFIG" <<'EOF'
[
  {
    "name": "Lock screen",
    "exec": "hyprlock",
    "icon": "system-lock-screen"
  },
  {
    "name": "Logout",
    "exec": "hyprctl dispatch exit",
    "icon": "system-log-out"
  },
  {
    "name": "Reboot",
    "exec": "systemctl reboot",
    "icon": "system-reboot"
  },
  {
    "name": "Shutdown",
    "exec": "systemctl poweroff",
    "icon": "system-shutdown"
  }
]
EOF

# Launch nwgbar with hyprland config
nwgbar -t "$TEMP_CONFIG" -c /etc/xdg/nwg-launchers/nwgbar/style.css -s 48

# Clean up
rm -f "$TEMP_CONFIG"
