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
    
fi

# Common utility function
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Ask for sudo password upfront and keep it alive
ask_for_sudo() {
    # Check if sudo requires a password
    if sudo -n true 2>/dev/null; then
        # Passwordless sudo detected (common on EC2)
        print_success "Passwordless sudo detected"
        return 0
    fi
    
    # Password is required
    print_info "Administrator privileges will be required..."
    
    # Prompt for password
    if ! sudo -v; then
        print_error "Failed to authenticate with sudo"
        print_info "If sudo is not needed, press Ctrl+C to skip"
        exit 1
    fi
    
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
    
    # Check if already a git repository (using same method as alrra)
    if git rev-parse &> /dev/null; then
        print_success "Git repository (already initialized)"
        
        # Check if remote origin exists
        if ! git remote | grep -q "origin"; then
            execute \
                "git remote add origin 'https://github.com/fredlackey/dotfiles-sandbox.git'" \
                "Adding git remote origin"
        else
            print_success "Git remote origin (already configured)"
        fi
    else
        # Simple initialization like alrra project
        execute \
            "git init && git remote add origin 'https://github.com/fredlackey/dotfiles-sandbox.git'" \
            "Initialize Git repository"
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

# Configure shell environment (foundation for text-based development)
configure_shell() {
    print_title "Shell Environment"
    
    # Install and configure ZSH
    if [ -f "$SCRIPT_DIR/steps/setup-zsh.sh" ]; then
        bash "$SCRIPT_DIR/steps/setup-zsh.sh" || {
            print_warning "ZSH setup encountered issues but continuing"
        }
    else
        print_warning "ZSH setup script not found"
    fi
    
    # Future configurations will include:
    # - Oh My Zsh framework
    # - Additional shell enhancements
    # - Custom aliases and functions
    # - Advanced prompt themes
    
    print_info "Additional shell configurations (coming soon)"
}

# Install text-based development environment (primary focus)
install_text_based_dev_environment() {
    print_title "Text-Based Development Environment"
    
    # Future installations will include:
    # - Vim/Neovim as primary IDE
    # - Vim plugins and configuration
    # - Tmux for terminal multiplexing
    # - Terminal-based file managers
    # - Command-line development tools
    
    print_info "Text-based development environment (coming soon)"
}

# Install programming languages and tools
install_programming_tools() {
    print_title "Programming Languages & Tools"
    
    # Future installations will include:
    # - Node.js and npm (via NodeSource)
    # - Java JDK (OpenJDK)
    # - Python and pip
    # - Go
    # - Docker CE and Docker Compose
    # - Build tools (make, cmake, etc.)
    
    print_info "Programming tools installation (coming soon)"
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
    # Step 1: System verification and preparation
    verify_ubuntu
    ask_for_sudo
    update_package_lists
    
    # Step 2: Core system tools
    install_git
    install_essential_tools
    initialize_git_repo
    configure_system
    
    # Step 3: Shell and terminal setup (foundation)
    configure_terminal
    configure_shell
    
    # Step 4: Text-based development environment (primary)
    install_text_based_dev_environment
    
    # Step 5: Programming languages and tools
    install_programming_tools
    
    # Note: Visual development tools not applicable for Ubuntu Server
    # (Those would be in the macOS setup script)
    
    print_title "Setup Complete!"
    print_success "Ubuntu Server configured successfully"
    print_info "Some changes may require a new terminal session to take effect"
    
    return 0
}

# Execute main function when script is run directly
main "$@"