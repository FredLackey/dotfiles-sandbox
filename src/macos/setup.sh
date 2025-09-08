#!/bin/bash

# macOS-specific setup script for dotfiles
# This script configures a macOS system for full-stack development

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

# Verify we're running on macOS
verify_macos() {
    if [ "$(uname -s)" != "Darwin" ]; then
        print_error "This script is for macOS only"
        exit 1
    fi
    
    print_info "Verified macOS environment"
}

# Check and install Xcode Command Line Tools
install_xcode_tools() {
    print_info "Checking for Xcode Command Line Tools..."
    
    # Check if already installed
    if xcode-select -p &>/dev/null; then
        print_success "Xcode Command Line Tools already installed"
        return 0
    fi
    
    print_info "Installing Xcode Command Line Tools..."
    
    # Trigger the installation
    xcode-select --install &>/dev/null || true
    
    # Wait for installation to complete
    print_info "Waiting for Xcode Command Line Tools installation..."
    print_info "This may take several minutes..."
    
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
    
    print_success "Xcode Command Line Tools installed"
}

# Install Homebrew package manager
install_homebrew() {
    print_info "Checking for Homebrew..."
    
    if check_command brew; then
        print_success "Homebrew already installed"
        print_info "Updating Homebrew..."
        brew update
        return 0
    fi
    
    print_info "Installing Homebrew..."
    
    # Download and run the official Homebrew installer
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        
        # Add to shell profile for future sessions
        if [ -f "$HOME/.zprofile" ]; then
            if ! grep -q "/opt/homebrew/bin/brew" "$HOME/.zprofile"; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            fi
        else
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' > "$HOME/.zprofile"
        fi
    fi
    
    # Add Homebrew to PATH for Intel Macs
    if [ -f "/usr/local/bin/brew" ]; then
        export PATH="/usr/local/bin:$PATH"
    fi
    
    print_success "Homebrew installed"
}

# Install Git via Homebrew
install_git() {
    print_info "Installing Git..."
    
    # Check if git is already installed via Homebrew
    if brew list git &>/dev/null; then
        print_success "Git already installed via Homebrew"
        brew upgrade git 2>/dev/null || true
    else
        brew install git
        print_success "Git installed"
    fi
    
    # Configure git with basic settings
    if [ -f "$DOTFILES_DIR/.gitconfig.example" ]; then
        print_info "Git configuration example found at $DOTFILES_DIR/.gitconfig.example"
    fi
}

# Install essential development tools
install_essential_tools() {
    print_info "Installing essential development tools..."
    
    # Core utilities
    local tools=(
        "coreutils"    # GNU core utilities
        "findutils"    # GNU find, locate, updatedb, xargs
        "grep"         # GNU grep
        "gnu-sed"      # GNU sed
        "gawk"         # GNU awk
        "tree"         # Directory listing
        "wget"         # Alternative to curl
        "jq"           # JSON processor
        "yq"           # YAML processor
    )
    
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            print_info "$tool already installed"
        else
            print_info "Installing $tool..."
            brew install "$tool"
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

# Install development languages and tools (placeholder for future)
install_development_stack() {
    print_info "Development stack installation placeholder..."
    
    # Future installations will include:
    # - Node.js and npm
    # - Java JDK
    # - Python
    # - Docker Desktop
    # - VS Code
    # - Vim/Neovim
    
    print_info "Full development stack will be installed in future iterations"
}

# Configure shell environment (placeholder for future)
configure_shell() {
    print_info "Shell configuration placeholder..."
    
    # Future configurations will include:
    # - ZSH configuration
    # - Aliases and functions
    # - PATH modifications
    # - Environment variables
    
    print_info "Shell environment will be configured in future iterations"
}

# Main function
main() {
    print_info "Starting macOS setup..."
    
    # Verify we're on macOS
    verify_macos
    
    # Install Xcode Command Line Tools
    install_xcode_tools
    
    # Install Homebrew
    install_homebrew
    
    # Install Git
    install_git
    
    # Install essential tools
    install_essential_tools
    
    # Initialize Git repository
    initialize_git_repo
    
    # Install development stack (placeholder)
    install_development_stack
    
    # Configure shell (placeholder)
    configure_shell
    
    print_success "macOS setup completed!"
    print_info "Some changes may require a new terminal session to take effect"
    
    return 0
}

# Execute main function when script is run directly
main "$@"