#!/bin/bash

# Set MesloLGS Nerd Font for Terminal.app profiles
# This updates the font for all Terminal profiles to use MesloLGS NF

# The font we want to use
FONT_NAME="MesloLGS-NF-Regular"
FONT_SIZE="14"

# Apply to the current default profile
osascript <<EOF
tell application "Terminal"
    -- Get the name of the current default settings
    set defaultSettingsName to name of default settings
    
    -- Set the font for the default profile
    set font name of settings set defaultSettingsName to "$FONT_NAME"
    set font size of settings set defaultSettingsName to $FONT_SIZE
    
    -- Also apply to all open windows
    repeat with w in windows
        repeat with t in tabs of w
            set font name of t to "$FONT_NAME"
            set font size of t to $FONT_SIZE
        end repeat
    end repeat
end tell
EOF

echo "Set MesloLGS Nerd Font for Terminal.app"