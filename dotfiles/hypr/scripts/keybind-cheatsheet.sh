#!/usr/bin/env bash
# Keybind cheat sheet using fuzzel
# Displays pre-computed keybindings list (no parsing latency!)

# Path to pre-computed keybindings list (generated at build time)
KEYBINDINGS_LIST="/etc/xdg/hypr/scripts/keybindings-list.txt"

# Check if keybindings list exists
if [[ ! -f "$KEYBINDINGS_LIST" ]]; then
    echo "Error: Keybindings list not found at $KEYBINDINGS_LIST"
    exit 1
fi

# Display in fuzzel and get selection with Kartoza theming
# The list is pre-computed at build time, so this is instant!
fuzzel --dmenu \
    --prompt="Kartoza Keybinds: " \
    --width=80 \
    --lines=25 \
    --font="JetBrains Mono:size=12" \
    --background-color=1a110fdd \
    --text-color=f1dfdaff \
    --match-color=ffb59dff \
    --selection-color=723520ff \
    --selection-text-color=ffdbd0ff \
    --border-color=ffb59dff \
    --border-width=2 \
    < "$KEYBINDINGS_LIST"
