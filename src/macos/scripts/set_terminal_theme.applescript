#!/usr/bin/osascript

on run argv
    -- Get the theme file path from arguments (required)
    if (count of argv) < 1 then
        error "Usage: set_terminal_theme.applescript <path-to-theme-file>"
    end if
    
    set themeFilePath to item 1 of argv
    
    -- Extract theme name from file path (filename without .terminal extension)
    set AppleScript's text item delimiters to "/"
    set fileName to last text item of themeFilePath
    set AppleScript's text item delimiters to "."
    set themeName to first text item of fileName
    set AppleScript's text item delimiters to ""
    
    tell application "Terminal"
        
        local allOpenedWindows
        local initialOpenedWindows
        local windowID
        
        -- Store the IDs of all the open terminal windows
        set initialOpenedWindows to id of every window
        
        -- Open the custom theme so that it gets added to the list
        -- of available terminal themes (note: this will open two
        -- additional terminal windows)
        do shell script "open '" & themeFilePath & "'"
        
        -- Wait a little bit to ensure that the custom theme is added
        delay 1
        
        -- Set the custom theme as the default terminal theme
        set default settings to settings set themeName
        
        -- Get the IDs of all the currently opened terminal windows
        set allOpenedWindows to id of every window
        
        repeat with windowID in allOpenedWindows
            
            -- Close the additional windows that were opened in order
            -- to add the custom theme to the list of terminal themes
            if initialOpenedWindows does not contain windowID then
                close (every window whose id is windowID)
                
            -- Change the theme for the initial opened terminal windows
            -- to remove the need to close them in order for the custom
            -- theme to be applied
            else
                set current settings of tabs of (every window whose id is windowID) to settings set themeName
            end if
            
        end repeat
        
    end tell
    
end run