#!/bin/bash

# Ubuntu Server-specific setup script for dotfiles
# This script configures an Ubuntu Server 22.04 LTS system for full-stack development

# Exit on any error
set -e

# Configuration
DOTFILES_DIR="$HOME/dotfiles"

# Utility functions (copied from src/common/utils.sh for self-contained execution)
print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_warning() {
    echo -e "\033[0;33m[WARNING]\033[0m $1"
}

check_command() {
    command -v "$1" >/dev/null 2>&1
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
    
    print_info "Verified Ubuntu Server environment"
}

# Update package lists
update_package_lists() {
    print_info "Updating package lists..."
    
    # Update apt repositories
    sudo apt-get update || {
        print_error "Failed to update package lists"
        return 1
    }
    
    print_success "Package lists updated"
}

# Install Git and essential build tools
install_git() {
    print_info "Installing Git and build essentials..."
    
    # Check if git is already installed
    if check_command git; then
        print_info "Git already installed"
        sudo apt-get install -y --only-upgrade git 2>/dev/null || true
    else
        sudo apt-get install -y git
        print_success "Git installed"
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
            print_info "$package already installed"
        else
            print_info "Installing $package..."
            sudo apt-get install -y "$package"
        fi
    done
    
    print_success "Git and build essentials installed"
}

# Install essential command-line tools
install_essential_tools() {
    print_info "Installing essential tools..."
    
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
            print_info "$tool already installed"
        else
            print_info "Installing $tool..."
            sudo apt-get install -y "$tool"
        fi
    done
    
    print_success "Essential tools installed"
}

# Initialize Git repository for dotfiles
initialize_git_repo() {
    print_info "Initializing Git repository for dotfiles..."
    
    cd "$DOTFILES_DIR"
    
    # Check if already a git repository
    if [ -d ".git" ]; then
        print_success "Git repository already initialized"
        
        # Set up remote if not already configured
        if ! git remote | grep -q "origin"; then
            git remote add origin "https://github.com/fredlackey/dotfiles-sandbox.git"
            print_info "Added git remote origin"
        fi
    else
        # Initialize new repository
        git init
        git remote add origin "https://github.com/fredlackey/dotfiles-sandbox.git"
        git fetch origin
        git reset --hard origin/main
        git branch --set-upstream-to=origin/main main
        print_success "Git repository initialized"
    fi
    
    cd - >/dev/null
}

# Configure system settings
configure_system() {
    print_info "Configuring system settings..."
    
    # Set timezone (optional, can be configured)
    # sudo timedatectl set-timezone America/New_York
    
    # Configure swap if needed
    if [ ! -f /swapfile ] && [ "$(free -m | awk '/^Mem:/{print $2}')" -lt 2048 ]; then
        print_info "Creating swap file..."
        sudo fallocate -l 2G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        
        # Make swap permanent
        if ! grep -q "/swapfile" /etc/fstab; then
            echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
        fi
        
        print_success "Swap file created"
    fi
    
    # No SSH server configuration needed for development workstation
    
    print_success "System settings configured"
}

# Install development languages and tools (placeholder for future)
install_development_stack() {
    print_info "Development stack installation placeholder..."
    
    # Future installations will include:
    # - Node.js via NodeSource
    # - OpenJDK
    # - Python and pip
    # - Docker CE
    # - Docker Compose
    # - Vim/Neovim with plugins
    
    print_info "Full development stack will be installed in future iterations"
}

# Configure shell environment (placeholder for future)
configure_shell() {
    print_info "Shell configuration placeholder..."
    
    # Future configurations will include:
    # - ZSH installation and configuration
    # - Oh My Zsh or similar
    # - Aliases and functions
    # - PATH modifications
    # - Environment variables
    
    print_info "Shell environment will be configured in future iterations"
}

# Configure terminal and console
configure_terminal() {
    print_info "Configuring terminal settings..."
    
    # Set default editor
    if ! grep -q "EDITOR=" "$HOME/.bashrc" 2>/dev/null; then
        echo 'export EDITOR=vim' >> "$HOME/.bashrc"
        print_info "Set default editor to vim"
    fi
    
    # Enable color prompt if not already enabled
    if [ -f "$HOME/.bashrc" ]; then
        sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' "$HOME/.bashrc"
    fi
    
    print_success "Terminal settings configured"
}

# Main function
main() {
    print_info "Starting Ubuntu Server setup..."
    
    # Verify we're on Ubuntu (not WSL)
    verify_ubuntu
    
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
    
    print_success "Ubuntu Server setup completed!"
    print_info "Some changes may require a new terminal session to take effect"
    
    return 0
}

# Execute main function when script is run directly
main "$@"