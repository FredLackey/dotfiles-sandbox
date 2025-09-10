#!/bin/bash

# Update Terminal.app theme to use MesloLGS Nerd Font
# This script modifies the Developer Dark.terminal file to use the correct font

THEME_FILE="$1"
FONT_NAME="MesloLGS-NF-Regular"  # The actual PostScript name of the font
FONT_SIZE="14"

if [ ! -f "$THEME_FILE" ]; then
    echo "Theme file not found: $THEME_FILE"
    exit 1
fi

# Create a temporary file with updated font data
# The font data in Terminal themes is a base64-encoded binary plist
# We'll use plutil to create the proper format

# First, create a temporary plist with font information
TEMP_PLIST="/tmp/font_plist_$$.plist"
cat > "$TEMP_PLIST" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>$archiver</key>
    <string>NSKeyedArchiver</string>
    <key>$objects</key>
    <array>
        <string>$null</string>
        <dict>
            <key>$class</key>
            <integer>3</integer>
            <key>NSName</key>
            <string>MesloLGS-NF-Regular</string>
            <key>NSSize</key>
            <real>14</real>
            <key>NSfFlags</key>
            <integer>16</integer>
        </dict>
        <dict>
            <key>$classes</key>
            <array>
                <string>NSFont</string>
                <string>NSObject</string>
            </array>
            <key>$classname</key>
            <string>NSFont</string>
        </dict>
    </array>
    <key>$top</key>
    <dict>
        <key>root</key>
        <integer>1</integer>
    </dict>
    <key>$version</key>
    <integer>100000</integer>
</dict>
</plist>
EOF

# The actual font data for MesloLGS NF Regular, size 14
# This is the base64-encoded NSKeyedArchiver data for the font
FONT_DATA='YnBsaXN0MDDUAQIDBAUGGBlYJHZlcnNpb25YJG9iamVjdHNZJGFyY2hpdmVyVCR0b3AS
AAGGoKQHCBESVSRudWxs1AkKCwwNDg8QVk5TU2l6ZVhOU2ZGbGFnc1ZOU05hbWVWJGNs
YXNzI0AuAAAAAAAAEBCAAoADXxAVTWVzbG9MR1MtTkYtUmVndWxhctITFBUWWiRjbGFz
c25hbWVYJGNsYXNzZXNWTlNGb250ohUXWE5TT2JqZWN0XxAPTlNLZXllZEFyY2hpdmVy
0RobVHJvb3SAAQgRGiMtMjc8QktSW2JpcnR2eJOYnaiv2+AAAAAAAAAAAQEAAAAAAAAA
HAAAAAAAAAAAAAAAAAAAAM4='

# Update the Font key in the theme file
# Use a temporary file for the replacement
TEMP_THEME="/tmp/theme_$$.terminal"
cp "$THEME_FILE" "$TEMP_THEME"

# Use perl to replace the Font data section
perl -i -pe 'BEGIN{undef $/;} s|<key>Font</key>\s*<data>[^<]*</data>|<key>Font</key>\n\t<data>\n\t'"$FONT_DATA"'\n\t</data>|smg' "$TEMP_THEME"

# Move the updated file back
mv "$TEMP_THEME" "$THEME_FILE"

echo "Updated $THEME_FILE to use MesloLGS Nerd Font"

# Clean up
rm -f "$TEMP_PLIST"