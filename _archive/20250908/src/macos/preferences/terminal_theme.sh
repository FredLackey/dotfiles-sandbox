#!/usr/bin/env bash

# Terminal Theme Configuration for macOS
# This script sets Terminal.app themes in an idempotent manner
# Usage: ./terminal_theme.sh [theme_name] [--programmatic]

set -euo pipefail

# Color definitions for programmatic theme (Solarized Dark colors)
readonly SOLARIZED_DARK_BG="3855 31868 40863 65535"  # RGB values (0-65535)
readonly SOLARIZED_DARK_FG="52428 53713 54998 65535"
readonly SOLARIZED_DARK_CURSOR="28784 33410 33924 65535"
readonly SOLARIZED_DARK_SELECTION="24158 7568 65535 39321"

# Function to check if Terminal.app is running
is_terminal_running() {
    osascript -e 'tell application "System Events" to (name of processes) contains "Terminal"' 2>/dev/null
}

# Function to check if a theme exists in Terminal preferences
theme_exists() {
    local theme_name="$1"
    osascript -e "tell application \"Terminal\" to name of settings sets" 2>/dev/null | grep -q "^${theme_name}$"
}

# Function to set Terminal colors programmatically
set_colors_programmatic() {
    echo "Setting Terminal colors programmatically..."
    
    if ! is_terminal_running; then
        echo "Terminal.app is not running. Please open Terminal first."
        return 1
    fi
    
    # Set background color
    osascript -e "tell application \"Terminal\" to set background color of front window to {${SOLARIZED_DARK_BG}}" 2>/dev/null || {
        echo "Warning: Could not set background color"
    }
    
    # Set normal text color
    osascript -e "tell application \"Terminal\" to set normal text color of front window to {${SOLARIZED_DARK_FG}}" 2>/dev/null || {
        echo "Warning: Could not set text color"
    }
    
    # Set cursor color
    osascript -e "tell application \"Terminal\" to set cursor color of front window to {${SOLARIZED_DARK_CURSOR}}" 2>/dev/null || {
        echo "Warning: Could not set cursor color"
    }
    
    echo "Terminal colors updated successfully"
}

# Function to import and set a theme from a .terminal file
set_theme_from_file() {
    local theme_name="$1"
    local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    local theme_file="${script_dir}/themes/${theme_name}.terminal"
    
    # Check if theme file exists
    if [[ ! -f "$theme_file" ]]; then
        echo "Error: Theme file not found: $theme_file"
        echo "Available themes in ${script_dir}/themes/:"
        if [[ -d "${script_dir}/themes" ]]; then
            ls -1 "${script_dir}/themes/" 2>/dev/null | sed 's/\.terminal$//' || echo "  No themes found"
        else
            echo "  Themes directory does not exist"
        fi
        return 1
    fi
    
    # Check if theme is already installed
    if theme_exists "$theme_name"; then
        echo "Theme '${theme_name}' is already installed"
    else
        echo "Installing theme '${theme_name}'..."
        
        # Store current window count
        local initial_windows
        initial_windows=$(osascript -e 'tell application "Terminal" to count of windows' 2>/dev/null || echo "0")
        
        # Import the theme file (this will open Terminal if not running)
        open -a Terminal "$theme_file"
        
        # Wait for theme to be imported
        local max_wait=10
        local waited=0
        while ! theme_exists "$theme_name" && [[ $waited -lt $max_wait ]]; do
            sleep 1
            ((waited++))
        done
        
        if theme_exists "$theme_name"; then
            echo "Theme '${theme_name}' imported successfully"
            
            # Close any extra windows that were opened
            local current_windows
            current_windows=$(osascript -e 'tell application "Terminal" to count of windows' 2>/dev/null || echo "0")
            if [[ $current_windows -gt $initial_windows ]]; then
                osascript -e "tell application \"Terminal\" to close window $((current_windows))" 2>/dev/null || true
            fi
        else
            echo "Error: Failed to import theme '${theme_name}'"
            return 1
        fi
    fi
    
    # Set as default theme (idempotent)
    echo "Setting '${theme_name}' as default theme..."
    osascript -e "tell application \"Terminal\" to set default settings to settings set \"${theme_name}\"" 2>/dev/null || {
        echo "Error: Could not set default theme"
        return 1
    }
    
    # Apply to all current windows and tabs (idempotent)
    echo "Applying theme to current windows..."
    osascript <<EOF 2>/dev/null || true
tell application "Terminal"
    repeat with w in windows
        try
            set current settings of tabs of w to settings set "${theme_name}"
        end try
    end repeat
end tell
EOF
    
    echo "Theme '${theme_name}' applied successfully"
}

# Function to list available built-in themes
list_builtin_themes() {
    echo "Built-in Terminal themes:"
    osascript -e 'tell application "Terminal" to name of settings sets' 2>/dev/null | tr ',' '\n' | sed 's/^ /  /'
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [THEME_NAME]

Sets Terminal.app theme in an idempotent manner.

OPTIONS:
    -h, --help           Show this help message
    -l, --list           List available built-in themes
    -p, --programmatic   Set colors programmatically (Solarized Dark)
    
ARGUMENTS:
    THEME_NAME          Name of theme to apply (default: "Pro")
                       Can be a built-in theme or a .terminal file in themes/

EXAMPLES:
    $(basename "$0")                    # Apply default "Pro" theme
    $(basename "$0") "Ocean"            # Apply built-in "Ocean" theme
    $(basename "$0") "Solarized Dark"   # Apply custom theme from file
    $(basename "$0") --programmatic     # Set colors directly
    $(basename "$0") --list             # Show available themes

NOTES:
    - Script is idempotent (safe to run multiple times)
    - Custom themes should be placed in: $(dirname "$0")/themes/
    - Theme files must have .terminal extension
EOF
}

# Main function
main() {
    local theme_name="Pro"  # Default theme
    local programmatic=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                return 0
                ;;
            -l|--list)
                list_builtin_themes
                return 0
                ;;
            -p|--programmatic)
                programmatic=true
                shift
                ;;
            -*)
                echo "Error: Unknown option: $1"
                show_usage
                return 1
                ;;
            *)
                theme_name="$1"
                shift
                ;;
        esac
    done
    
    # Check if running on macOS
    if [[ "$(uname -s)" != "Darwin" ]]; then
        echo "Error: This script only works on macOS"
        return 1
    fi
    
    # Check if Terminal.app exists
    if ! [[ -d "/Applications/Utilities/Terminal.app" ]] && ! [[ -d "/System/Applications/Utilities/Terminal.app" ]]; then
        echo "Error: Terminal.app not found"
        return 1
    fi
    
    # Apply theme based on mode
    if [[ "$programmatic" == true ]]; then
        set_colors_programmatic
    else
        set_theme_from_file "$theme_name"
    fi
}

# Execute main function when script is run directly
main "$@"