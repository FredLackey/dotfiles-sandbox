#!/bin/bash

# OS detection logic for dotfiles setup
# Returns the detected platform identifier

# Exit on any error
set -e

# Detect the current platform
detect_platform() {
    local platform=""
    
    # Check for macOS
    if [ "$(uname -s)" = "Darwin" ]; then
        platform="macos"
    
    # Check for Linux
    elif [ "$(uname -s)" = "Linux" ]; then
        
        # Check if running in WSL
        if [ -f /proc/version ]; then
            if grep -qi "microsoft\|wsl" /proc/version; then
                platform="wsl"
            fi
        fi
        
        # If not WSL, check for Ubuntu
        if [ -z "$platform" ] && [ -f /etc/os-release ]; then
            if grep -qi "ubuntu" /etc/os-release; then
                platform="ubuntu"
            fi
        fi
        
        # Generic Linux if not identified
        if [ -z "$platform" ]; then
            platform="linux"
        fi
    
    else
        # Unsupported OS
        platform="unknown"
    fi
    
    echo "$platform"
}

# Main function
main() {
    detect_platform
}

# Execute main function when script is run directly
main "$@"