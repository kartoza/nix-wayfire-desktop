#!/usr/bin/env bash
# by Tim Sutton (2025) - Integrated with ML4W style
# -----------------------------------------------------

# wshowkeys toggle script for Hyprland
# Shows on-screen key display with Kartoza theming

PIDFILE="$XDG_RUNTIME_DIR/wshowkeys.pid"

# Check if wshowkeys is running
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  # wshowkeys is running, kill it
  pkill wshowkeys
  rm -f "$PIDFILE"
  echo "disabled"
else
  # wshowkeys is not running, start it with Kartoza theming
  # Colors match the Kartoza orange theme: #DF9E2F (orange), dark background
  wshowkeys \
    -F "Nurito 44" \
    -t 2 \
    -m 20 \
    -a top \
    -a right \
    -b "#1a110f" \
    -f "#f1dfda" \
    -s "#ffb59d" &

  echo $! >"$PIDFILE"
  echo "enabled"
fi
