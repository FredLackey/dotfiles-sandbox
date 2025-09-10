#!/bin/bash

# Set MesloLGS Nerd Font for Terminal.app profiles
# This updates the font for all Terminal profiles to use MesloLGS NF

# The font we want to use - this is the actual PostScript name as it appears in Font Book
# MesloLGS NF is the font that includes all Powerline symbols for Oh My Zsh agnoster theme
FONT_NAME="MesloLGSNerdFontComplete-Regular"
FONT_SIZE="14"

# First, try with the full Nerd Font name
osascript <<EOF 2>/dev/null
tell application "Terminal"
    try
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
        
        return "Success: Font set to $FONT_NAME"
    on error
        return "Error: Could not set font to $FONT_NAME"
    end try
end tell
EOF

# If that didn't work, try alternative font names
if [ $? -ne 0 ]; then
    # Try alternate names for the font
    for FONT_VARIANT in "MesloLGS Nerd Font" "MesloLGS NF Regular" "MesloLGS-Regular" "MesloLGS Nerd Font Mono"; do
        osascript <<EOF 2>/dev/null
tell application "Terminal"
    try
        set defaultSettingsName to name of default settings
        set font name of settings set defaultSettingsName to "$FONT_VARIANT"
        set font size of settings set defaultSettingsName to $FONT_SIZE
        
        repeat with w in windows
            repeat with t in tabs of w
                set font name of t to "$FONT_VARIANT"
                set font size of t to $FONT_SIZE
            end repeat
        end repeat
        
        return "Success: Font set to $FONT_VARIANT"
    on error
        return "Error: Could not set font to $FONT_VARIANT"
    end try
end tell
EOF
        if [ $? -eq 0 ]; then
            echo "Set font to $FONT_VARIANT for Terminal.app"
            exit 0
        fi
    done
    
    echo "Warning: Could not set MesloLGS Nerd Font. Please manually select it in Terminal > Preferences > Profiles > Text > Font"
    echo "Look for 'MesloLGS NF' or 'MesloLGS Nerd Font' in the font list"
    exit 1
else
    echo "Set MesloLGS Nerd Font for Terminal.app"
fi