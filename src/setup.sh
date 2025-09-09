#!/bin/bash

# Universal entry point for dotfiles installation
# This script only orchestrates: download, detect, and route to platform-specific setup
# All actual work is done by platform-specific scripts

# Exit on any error
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source output formatting functions if running from local directory
# When run via curl/wget, these functions are embedded below
if [ -f "$SCRIPT_DIR/utils/output.sh" ]; then
    source "$SCRIPT_DIR/utils/output.sh"
else
    # Embedded output functions for one-liner installation
    # These are minimal versions from src/utils/output.sh
    
    print_in_color() {
        printf "%b" \
            "$(tput setaf "$2" 2> /dev/null)" \
            "$1" \
            "$(tput sgr0 2> /dev/null)"
    }
    
    print_error() {
        print_in_color "   [✖] $1\n" 1
    }
    
    print_success() {
        print_in_color "   [✔] $1\n" 2
    }
    
    print_info() {
        print_in_color "   [i] $1\n" 5
    }
    
    print_title() {
        print_in_color "\n   $1\n\n" 5
    }
    
    execute() {
        local -r CMDS="$1"
        local -r MSG="${2:-$1}"
        local -r TMP_FILE="$(mktemp /tmp/XXXXX)"
        local exitCode=0
        
        # Execute command completely silently
        (eval "$CMDS") > "$TMP_FILE" 2>&1
        exitCode=$?
        
        if [ $exitCode -eq 0 ]; then
            print_success "$MSG"
        else
            print_error "$MSG"
            # Show error details
            while read -r line; do
                print_in_color "   ↳ ERROR: $line\n" 1
            done < "$TMP_FILE"
        fi
        
        rm -rf "$TMP_FILE"
        return $exitCode
    }
fi

# Embedded common variables and functions
REPO_OWNER="fredlackey"
REPO_NAME="dotfiles-sandbox"
REPO_BRANCH="main"
DOTFILES_DIR="$HOME/dotfiles"

check_command() {
    command -v "$1" >/dev/null 2>&1
}
    
download_repository() {
    local tarball_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/tarball/${REPO_BRANCH}"
    local temp_file="/tmp/dotfiles-$$.tar.gz"
    local temp_dir="/tmp/dotfiles-extract-$$"
    
    # Download repository
    if check_command curl; then
        execute "curl -LsS '$tarball_url' -o '$temp_file'" \
                "Downloading repository"
    elif check_command wget; then
        execute "wget -qO '$temp_file' '$tarball_url'" \
                "Downloading repository"
    else
        print_error "Neither curl nor wget is available"
        return 1
    fi
    
    # Extract repository
    execute "mkdir -p '$temp_dir' && tar -xzf '$temp_file' -C '$temp_dir' --strip-components=1" \
            "Extracting repository"
    
    # Move to final location
    if [ -d "$DOTFILES_DIR" ]; then
        # Backup any local changes before updating
        if [ -d "$DOTFILES_DIR/.git" ]; then
            print_info "Backing up any local changes..."
        fi
        execute "cp -r '$temp_dir'/* '$DOTFILES_DIR'/ 2>/dev/null || true; \
                 cp -r '$temp_dir'/.[^.]* '$DOTFILES_DIR'/ 2>/dev/null || true" \
                "Updating existing dotfiles"
    else
        execute "mv '$temp_dir' '$DOTFILES_DIR'" \
                "Creating dotfiles directory"
    fi
    
    # Cleanup
    execute "rm -f '$temp_file' && rm -rf '$temp_dir'" \
            "Cleaning up temporary files"
    
    return 0
}

# Update repository using git (if available and configured)
update_repository_git() {
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        # Not a git repository, use download method
        return 1
    fi
    
    if ! check_command git; then
        # Git not available, use download method
        return 1
    fi
    
    cd "$DOTFILES_DIR"
    
    # Check if there are uncommitted changes
    if git diff --quiet && git diff --staged --quiet; then
        # No local changes, safe to pull
        execute "git fetch origin ${REPO_BRANCH} && git reset --hard origin/${REPO_BRANCH}" \
                "Updating repository to latest version"
        cd - >/dev/null
        return 0
    else
        # Local changes exist
        print_info "Local changes detected in $DOTFILES_DIR"
        execute "git stash push -m 'Auto-stash before dotfiles update'" \
                "Stashing local changes"
        execute "git fetch origin ${REPO_BRANCH} && git reset --hard origin/${REPO_BRANCH}" \
                "Updating repository to latest version"
        print_info "Local changes have been stashed. Use 'git stash pop' to restore them."
        cd - >/dev/null
        return 0
    fi
}

# Main orchestration function
main() {
    print_title "Dotfiles Installation"
    
    # Step 1: Handle repository - download or update
    if [ ! -d "$DOTFILES_DIR" ] || [ ! -f "$DOTFILES_DIR/src/setup.sh" ]; then
        # Fresh installation - download repository
        download_repository || {
            print_error "Failed to download repository"
            exit 1
        }
    else
        # Existing installation - update to latest version
        print_info "Found existing dotfiles at $DOTFILES_DIR"
        print_info "Checking for updates..."
        
        # Try to update using git first (preserves git history)
        if update_repository_git; then
            print_success "Updated dotfiles using git"
        else
            # Fall back to downloading fresh copy
            print_info "Updating dotfiles by downloading latest version..."
            download_repository || {
                print_error "Failed to update repository"
                exit 1
            }
        fi
    fi
    
    # Step 2: Detect platform
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
    
    print_success "Detected platform: $platform"
    
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
    
    print_title "Platform Setup: $platform"
    
    # Run the platform script directly so we can see any prompts or issues
    "$setup_script" || {
        print_error "Platform setup failed"
        exit 1
    }
    
    print_title "Installation Complete!"
    print_success "Dotfiles installed successfully"
    print_info "Please start a new terminal session to load all configurations"
    
    return 0
}

# Execute main function when script is run directly
main "$@"