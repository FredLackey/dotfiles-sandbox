#!/bin/bash

# This script generates the base64-encoded font data for Terminal.app themes
# Usage: ./generate_font_data.sh "FontName" size

FONT_NAME="${1:-MesloLGS NF}"
FONT_SIZE="${2:-14}"

# Create a temporary plist with just the font info
cat > /tmp/font.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>name</key>
    <string>$FONT_NAME</string>
    <key>size</key>
    <real>$FONT_SIZE</real>
</dict>
</plist>
EOF

# Convert to binary and then base64
plutil -convert binary1 /tmp/font.plist
base64 < /tmp/font.plist

# Clean up
rm -f /tmp/font.plist