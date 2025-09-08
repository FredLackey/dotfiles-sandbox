#!/bin/bash

# Ubuntu Server-specific setup script for dotfiles
# This script configures an Ubuntu Server 22.04 LTS system for full-stack development

# Exit on any error
set -e

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source output formatting utilities if available
if [ -f "$SCRIPT_DIR/../utils/output.sh" ]; then
    source "$SCRIPT_DIR/../utils/output.sh"
else
    # Fallback to basic output functions
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
    
    print_warning() {
        print_in_color "   [!] $1\n" 3
    }
    
    print_title() {
        print_in_color "\n   $1\n\n" 5
    }
    
    execute() {
        local -r CMDS="$1"
        local -r MSG="${2:-$1}"
        local -r TMP_FILE="$(mktemp /tmp/XXXXX)"
        local exitCode=0
        
        echo "   [⋯] $MSG"
        
        # Execute command silently (sudo already authenticated)
        if eval "$CMDS" > "$TMP_FILE" 2>&1; then
            echo -e "\033[1A\033[K   [✔] $MSG"
            exitCode=0
        else
            echo -e "\033[1A\033[K   [✖] $MSG"
            exitCode=1
            # Show error details
            while read -r line; do
                echo "   ↳ $line"
            done < "$TMP_FILE"
        fi
        
        rm -rf "$TMP_FILE"
        return $exitCode
    }
    
    check_command() {
        command -v "$1" >/dev/null 2>&1
    }
fi

# Ask for sudo password upfront and keep it alive
ask_for_sudo() {
    # Ask for the administrator password upfront
    print_info "Administrator privileges will be required..."
    
    # Prompt for password
    sudo -v
    
    # Keep sudo alive until the script finishes
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done &> /dev/null &
}

# Verify we're running on Ubuntu (not WSL)
verify_ubuntu() {
    # Check if we're on Linux
    if [ "$(uname -s)" != "Linux" ]; then
        print_error "This script is for Ubuntu Linux only"
        exit 1
    fi
    
    # Check for Ubuntu in os-release
    if [ -f /etc/os-release ]; then
        if ! grep -qi "ubuntu" /etc/os-release; then
            print_error "This script is for Ubuntu only"
            exit 1
        fi
    else
        print_error "Cannot determine OS distribution"
        exit 1
    fi
    
    # Make sure we're NOT in WSL
    if [ -f /proc/version ]; then
        if grep -qi "microsoft\|wsl" /proc/version; then
            print_error "WSL detected. Please use src/wsl/setup.sh instead"
            exit 1
        fi
    fi
    
    print_success "Ubuntu Server environment verified"
}

# Update package lists  
update_package_lists() {
    execute \
        "sudo apt-get update -qq" \
        "Updating package lists"
}

# Install Git and essential build tools
install_git() {
    print_title "Git & Build Essentials"
    
    # Check if git is already installed
    if check_command git; then
        print_success "Git (already installed)"
        execute \
            "sudo apt-get install -qqy --only-upgrade git" \
            "Updating Git"
    else
        execute \
            "sudo apt-get install -qqy git" \
            "Git"
    fi
    
    # Install build essentials
    local packages=(
        "build-essential"  # Compiler and build tools
        "curl"            # Data transfer tool
        "wget"            # Download tool
        "software-properties-common"  # Repository management
        "apt-transport-https"  # HTTPS support for apt
        "ca-certificates"  # SSL certificates
        "gnupg"           # GNU Privacy Guard
        "lsb-release"     # LSB release info
    )
    
    for package in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            print_success "$package (already installed)"
        else
            execute \
                "sudo apt-get install -qqy '$package'" \
                "$package"
        fi
    done
}

# Install essential command-line tools
install_essential_tools() {
    print_title "Essential Tools"
    
    local tools=(
        "tree"      # Directory listing
        "htop"      # Process viewer
        "ncdu"      # Disk usage analyzer
        "tmux"      # Terminal multiplexer
        "screen"    # Terminal multiplexer alternative
        "vim"       # Text editor
        "nano"      # Simple text editor
        "jq"        # JSON processor
        "unzip"     # Archive extraction
        "zip"       # Archive creation
        "net-tools" # Network utilities
    )
    
    for tool in "${tools[@]}"; do
        if dpkg -l | grep -q "^ii  $tool "; then
            print_success "$tool (already installed)"
        else
            execute \
                "sudo apt-get install -qqy '$tool'" \
                "$tool"
        fi
    done
}

# Initialize Git repository for dotfiles
initialize_git_repo() {
    print_title "Git Repository"
    
    cd "$DOTFILES_DIR"
    
    # Check if already a git repository
    if [ -d ".git" ]; then
        print_success "Git repository (already initialized)"
        
        # Set up remote if not already configured
        if ! git remote | grep -q "origin"; then
            execute \
                "git remote add origin 'https://github.com/fredlackey/dotfiles-sandbox.git'" \
                "Adding git remote origin"
        else
            print_success "Git remote origin (already configured)"
        fi
    else
        # Initialize new repository
        execute \
            "git init && \
             git remote add origin 'https://github.com/fredlackey/dotfiles-sandbox.git' && \
             git fetch origin && \
             git reset --hard origin/main && \
             git branch --set-upstream-to=origin/main main" \
            "Initializing Git repository"
    fi
    
    cd - >/dev/null
}

# Configure system settings
configure_system() {
    print_title "System Configuration"
    
    # Configure swap if needed
    if [ ! -f /swapfile ] && [ "$(free -m | awk '/^Mem:/{print $2}')" -lt 2048 ]; then
        execute \
            "sudo fallocate -l 2G /swapfile && \
             sudo chmod 600 /swapfile && \
             sudo mkswap /swapfile && \
             sudo swapon /swapfile" \
            "Creating 2GB swap file"
        
        # Make swap permanent
        if ! grep -q "/swapfile" /etc/fstab; then
            execute \
                "echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null" \
                "Making swap permanent"
        fi
    else
        print_success "Swap (already configured)"
    fi
}

# Install development languages and tools (placeholder for future)
install_development_stack() {
    print_title "Development Stack"
    
    # Future installations will include:
    # - Node.js via NodeSource
    # - OpenJDK
    # - Python and pip
    # - Docker CE
    # - Docker Compose
    # - Vim/Neovim with plugins
    
    print_info "Development stack installation (coming soon)"
}

# Configure shell environment (placeholder for future)
configure_shell() {
    print_title "Shell Configuration"
    
    # Future configurations will include:
    # - ZSH installation and configuration
    # - Oh My Zsh or similar
    # - Aliases and functions
    # - PATH modifications
    # - Environment variables
    
    print_info "Shell configuration (coming soon)"
}

# Configure terminal and console
configure_terminal() {
    print_title "Terminal Configuration"
    
    # Set default editor
    if ! grep -q "EDITOR=" "$HOME/.bashrc" 2>/dev/null; then
        execute \
            "echo 'export EDITOR=vim' >> '$HOME/.bashrc'" \
            "Setting default editor to vim"
    else
        print_success "Default editor (already set)"
    fi
    
    # Enable color prompt if not already enabled
    if [ -f "$HOME/.bashrc" ]; then
        execute \
            "sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' '$HOME/.bashrc'" \
            "Enabling color prompt"
    fi
}

# Main function
main() {
    # Verify we're on Ubuntu (not WSL)
    verify_ubuntu
    
    # Ask for sudo password upfront
    ask_for_sudo
    
    # Update package lists
    update_package_lists
    
    # Install Git and build essentials
    install_git
    
    # Install essential tools
    install_essential_tools
    
    # Initialize Git repository
    initialize_git_repo
    
    # Configure system
    configure_system
    
    # Configure terminal
    configure_terminal
    
    # Install development stack (placeholder)
    install_development_stack
    
    # Configure shell (placeholder)
    configure_shell
    
    print_title "Setup Complete!"
    print_success "Ubuntu Server configured successfully"
    print_info "Some changes may require a new terminal session to take effect"
    
    return 0
}

# Execute main function when script is run directly
main "$@"