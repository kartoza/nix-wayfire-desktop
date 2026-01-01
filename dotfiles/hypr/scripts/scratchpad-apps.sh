#!/usr/bin/env bash
# Launch scratchpad applications (aerc email and keph calendar)
# Usage: scratchpad-apps.sh

# Launch protonmail-bridge in the background
#

protonmail-bridge &

# Launch aerc email client in a terminal
kitty --class scratchpad-aerc -e aerc &

# Wait a moment before launching the next app
sleep 0.5

# Launch keph calendar
keph &

exit 0
