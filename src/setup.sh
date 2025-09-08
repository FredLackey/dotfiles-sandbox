#!/bin/bash

# Universal entry point for dotfiles installation
# This script only orchestrates: download, detect, and route to platform-specific setup
# All actual work is done by platform-specific scripts

# Exit on any error
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common functions if running from local directory
# When run via curl/wget, these functions are embedded below
if [ -f "$SCRIPT_DIR/utils/common.sh" ]; then
    source "$SCRIPT_DIR/utils/common.sh"
else
    # Embedded functions for one-liner installation
    # These are copied from src/utils/common.sh
    
    REPO_OWNER="fredlackey"
    REPO_NAME="dotfiles-sandbox"
    REPO_BRANCH="main"
    DOTFILES_DIR="$HOME/dotfiles"
    
    print_error() {
        echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
    }
    
    print_success() {
        echo -e "\033[0;32m[SUCCESS]\033[0m $1"
    }
    
    print_info() {
        echo -e "\033[0;34m[INFO]\033[0m $1"
    }
    
    check_command() {
        command -v "$1" >/dev/null 2>&1
    }
    
    download_repository() {
        local tarball_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/tarball/${REPO_BRANCH}"
        local temp_file="/tmp/dotfiles-$$.tar.gz"
        local temp_dir="/tmp/dotfiles-extract-$$"
        
        print_info "Downloading dotfiles repository..."
        
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
        
        mkdir -p "$temp_dir"
        
        print_info "Extracting repository..."
        tar -xzf "$temp_file" -C "$temp_dir" --strip-components=1 || {
            print_error "Failed to extract repository"
            rm -f "$temp_file"
            rm -rf "$temp_dir"
            return 1
        }
        
        if [ -d "$DOTFILES_DIR" ]; then
            print_info "Existing dotfiles directory found, updating..."
            cp -r "$temp_dir"/* "$DOTFILES_DIR"/ 2>/dev/null || true
            cp -r "$temp_dir"/.[^.]* "$DOTFILES_DIR"/ 2>/dev/null || true
        else
            print_info "Creating dotfiles directory..."
            mv "$temp_dir" "$DOTFILES_DIR"
        fi
        
        rm -f "$temp_file"
        rm -rf "$temp_dir"
        
        print_success "Repository downloaded to $DOTFILES_DIR"
        return 0
    }
fi

# Main orchestration function
main() {
    print_info "Starting dotfiles installation..."
    
    # Step 1: Download repository (if not already present)
    if [ ! -d "$DOTFILES_DIR" ] || [ ! -f "$DOTFILES_DIR/src/setup.sh" ]; then
        download_repository || {
            print_error "Failed to download repository"
            exit 1
        }
    else
        print_info "Using existing dotfiles directory at $DOTFILES_DIR"
    fi
    
    # Step 2: Detect platform
    print_info "Detecting platform..."
    if [ -f "$DOTFILES_DIR/src/utils/detect_os.sh" ]; then
        platform=$("$DOTFILES_DIR/src/utils/detect_os.sh") || {
            print_error "Failed to detect platform"
            exit 1
        }
    else
        # Fallback detection if utility script not found
        if [ "$(uname -s)" = "Darwin" ]; then
            platform="macos"
        elif [ "$(uname -s)" = "Linux" ]; then
            if [ -f /proc/version ] && grep -qi "microsoft\|wsl" /proc/version; then
                platform="wsl"
            elif [ -f /etc/os-release ] && grep -qi "ubuntu" /etc/os-release; then
                platform="ubuntu"
            else
                platform="linux"
            fi
        else
            platform="unknown"
        fi
    fi
    
    print_info "Detected platform: $platform"
    
    # Step 3: Route to platform-specific setup
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
            print_error "Unsupported platform: $platform"
            exit 1
            ;;
    esac
    
    # Verify platform script exists
    if [ ! -f "$setup_script" ]; then
        print_error "Platform setup script not found: $setup_script"
        exit 1
    fi
    
    # Make executable and run platform-specific setup
    chmod +x "$setup_script"
    print_info "Executing platform-specific setup..."
    "$setup_script" || {
        print_error "Platform setup failed"
        exit 1
    }
    
    print_success "Dotfiles installation completed successfully!"
    print_info "Please start a new terminal session to load all configurations"
    
    return 0
}

# Execute main function when script is run directly
main "$@"