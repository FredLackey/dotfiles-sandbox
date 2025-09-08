#!/bin/bash

# WSL Ubuntu-specific setup script for dotfiles
# This script configures WSL Ubuntu for full-stack development with Windows integration

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

# Verify we're running in WSL
verify_wsl() {
    # Check if we're on Linux
    if [ "$(uname -s)" != "Linux" ]; then
        print_error "This script is for WSL Ubuntu only"
        exit 1
    fi
    
    # Check for WSL markers
    local is_wsl=false
    
    if [ -f /proc/version ]; then
        if grep -qi "microsoft\|wsl" /proc/version; then
            is_wsl=true
        fi
    fi
    
    if [ "$is_wsl" = false ]; then
        print_error "WSL not detected. Please use src/ubuntu/setup.sh for standard Ubuntu"
        exit 1
    fi
    
    # Detect WSL version
    if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
        print_info "Detected WSL 2"
    else
        print_info "Detected WSL 1"
    fi
    
    print_success "Verified WSL Ubuntu environment"
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
        "wslu"      # WSL utilities for Windows integration
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

# Configure WSL-specific settings
configure_wsl() {
    print_info "Configuring WSL-specific settings..."
    
    # Create wsl.conf if it doesn't exist
    if [ ! -f /etc/wsl.conf ]; then
        print_info "Creating /etc/wsl.conf..."
        sudo tee /etc/wsl.conf > /dev/null <<EOF
[boot]
systemd=true

[interop]
enabled=true
appendWindowsPath=true

[network]
generateHosts=true
generateResolvConf=true

[automount]
enabled=true
options="metadata,umask=22,fmask=11"
mountFsTab=true
EOF
        print_success "WSL configuration created"
    else
        print_info "WSL configuration already exists"
    fi
    
    # Configure Windows interoperability
    configure_windows_interop
    
    print_success "WSL settings configured"
}

# Configure Windows interoperability
configure_windows_interop() {
    print_info "Configuring Windows interoperability..."
    
    # Set up Windows paths access
    if [ -d "/mnt/c" ]; then
        print_info "Windows C: drive accessible at /mnt/c"
        
        # Create symbolic links for common Windows directories
        if [ ! -L "$HOME/windows" ]; then
            # Find Windows user directory
            WIN_USER=""
            for dir in /mnt/c/Users/*; do
                if [ -d "$dir" ] && [ "$(basename "$dir")" != "Public" ] && [ "$(basename "$dir")" != "Default" ]; then
                    WIN_USER="$(basename "$dir")"
                    break
                fi
            done
            
            if [ -n "$WIN_USER" ]; then
                ln -sf "/mnt/c/Users/$WIN_USER" "$HOME/windows"
                print_info "Created symbolic link to Windows user directory"
            fi
        fi
    fi
    
    # Configure Git to work with Windows line endings
    git config --global core.autocrlf input
    print_info "Configured Git for Windows line endings"
    
    # Set up clipboard integration if available
    if check_command clip.exe; then
        print_info "Windows clipboard integration available"
    fi
    
    print_success "Windows interoperability configured"
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

# Configure terminal for WSL
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
    
    # Add WSL-specific aliases
    if ! grep -q "# WSL Aliases" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" <<'EOF'

# WSL Aliases
alias explorer='explorer.exe'
alias code='code.exe'
alias notepad='notepad.exe'
EOF
        print_info "Added WSL-specific aliases"
    fi
    
    # Configure Windows Terminal integration if available
    if [ -f "/mnt/c/Users/*/AppData/Local/Microsoft/WindowsApps/wt.exe" ]; then
        print_info "Windows Terminal detected"
    fi
    
    print_success "Terminal settings configured"
}

# Install development languages and tools (placeholder for future)
install_development_stack() {
    print_info "Development stack installation placeholder..."
    
    # Future installations will include:
    # - Node.js via NodeSource
    # - OpenJDK
    # - Python and pip
    # - Docker Desktop for Windows integration
    # - Docker CLI tools
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
    # - PATH modifications for Windows tools
    # - Environment variables
    
    print_info "Shell environment will be configured in future iterations"
}

# Main function
main() {
    print_info "Starting WSL Ubuntu setup..."
    
    # Verify we're in WSL
    verify_wsl
    
    # Update package lists
    update_package_lists
    
    # Install Git and build essentials
    install_git
    
    # Install essential tools
    install_essential_tools
    
    # Configure WSL-specific settings
    configure_wsl
    
    # Initialize Git repository
    initialize_git_repo
    
    # Configure terminal
    configure_terminal
    
    # Install development stack (placeholder)
    install_development_stack
    
    # Configure shell (placeholder)
    configure_shell
    
    print_success "WSL Ubuntu setup completed!"
    print_info "Some changes may require WSL restart. Run 'wsl --shutdown' from Windows and restart"
    
    return 0
}

# Execute main function when script is run directly
main "$@"