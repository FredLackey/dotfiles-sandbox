#!/bin/bash

# Environment verification for dotfiles setup
# Checks prerequisites and system requirements

# Exit on any error
set -e

# Check if command exists
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Verify basic requirements
verify_requirements() {
    local has_downloader=false
    local errors=0
    
    # Check for curl or wget (needed for download)
    if check_command curl; then
        has_downloader=true
        echo "✓ curl found"
    elif check_command wget; then
        has_downloader=true
        echo "✓ wget found"
    else
        echo "✗ Neither curl nor wget is available"
        ((errors++))
    fi
    
    # Check for tar (needed for extraction)
    if check_command tar; then
        echo "✓ tar found"
    else
        echo "✗ tar is not available"
        ((errors++))
    fi
    
    # Check for bash
    if [ -n "$BASH_VERSION" ]; then
        echo "✓ Running with bash"
    else
        echo "✗ Not running with bash"
        ((errors++))
    fi
    
    # Check home directory exists
    if [ -d "$HOME" ]; then
        echo "✓ Home directory exists: $HOME"
    else
        echo "✗ Home directory not found"
        ((errors++))
    fi
    
    # Check write permissions in home directory
    if [ -w "$HOME" ]; then
        echo "✓ Home directory is writable"
    else
        echo "✗ No write permission in home directory"
        ((errors++))
    fi
    
    return $errors
}

# Main function
main() {
    echo "Verifying environment prerequisites..."
    
    if verify_requirements; then
        echo "All prerequisites met"
        exit 0
    else
        echo "Prerequisites check failed"
        exit 1
    fi
}

# Execute main function when script is run directly
main "$@"