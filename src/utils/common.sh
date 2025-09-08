#!/bin/bash

# Common functions for setup scripts
# These are utility functions used by the main setup.sh

# Exit on any error
set -e

# Configuration
REPO_OWNER="fredlackey"
REPO_NAME="dotfiles-sandbox"
REPO_BRANCH="main"
DOTFILES_DIR="$HOME/dotfiles"

# Print colored output
print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

# Check if command exists
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Download repository as tarball
download_repository() {
    local tarball_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/tarball/${REPO_BRANCH}"
    local temp_file="/tmp/dotfiles-$$.tar.gz"
    local temp_dir="/tmp/dotfiles-extract-$$"
    
    print_info "Downloading dotfiles repository..."
    
    # Download using curl or wget
    if check_command curl; then
        curl -LsS "$tarball_url" -o "$temp_file" || {
            print_error "Failed to download repository"
            return 1
        }
    elif check_command wget; then
        wget -qO "$temp_file" "$tarball_url" || {
            print_error "Failed to download repository"
            return 1
        }
    else
        print_error "Neither curl nor wget is available"
        return 1
    fi
    
    # Create temporary extraction directory
    mkdir -p "$temp_dir"
    
    # Extract tarball (GitHub tarballs have a top-level directory we need to strip)
    print_info "Extracting repository..."
    tar -xzf "$temp_file" -C "$temp_dir" --strip-components=1 || {
        print_error "Failed to extract repository"
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        return 1
    }
    
    # Move to final location
    if [ -d "$DOTFILES_DIR" ]; then
        print_info "Existing dotfiles directory found, updating..."
        # Preserve any local changes by merging directories
        cp -r "$temp_dir"/* "$DOTFILES_DIR"/ 2>/dev/null || true
        cp -r "$temp_dir"/.[^.]* "$DOTFILES_DIR"/ 2>/dev/null || true
    else
        print_info "Creating dotfiles directory..."
        mv "$temp_dir" "$DOTFILES_DIR"
    fi
    
    # Cleanup
    rm -f "$temp_file"
    rm -rf "$temp_dir"
    
    print_success "Repository downloaded to $DOTFILES_DIR"
    return 0
}

# Get the path to platform-specific setup script
get_platform_script() {
    local platform="$1"
    local setup_script=""
    
    case "$platform" in
        macos)
            setup_script="$DOTFILES_DIR/src/macos/setup.sh"
            ;;
        wsl)
            setup_script="$DOTFILES_DIR/src/wsl/setup.sh"
            ;;
        ubuntu|linux)
            setup_script="$DOTFILES_DIR/src/ubuntu/setup.sh"
            ;;
        *)
            return 1
            ;;
    esac
    
    echo "$setup_script"
    return 0
}

# Main function (this file should be sourced, not executed)
main() {
    print_error "This file should be sourced, not executed directly"
    exit 1
}

# Execute main function if script is run directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi