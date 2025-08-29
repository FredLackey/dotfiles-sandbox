#!/usr/bin/env zsh

# =============================================================================
# ZSH Dotfiles Setup Script
# =============================================================================
# A single-command setup script for macOS development environment
# Follows governing principles: idempotent, single-command, managed permissions
# =============================================================================

set -e  # Exit on any error

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# =============================================================================
# Utility Functions
# =============================================================================

print_header() {
    echo
    echo "${BLUE}==============================================================================${NC}"
    echo "${BLUE} $1${NC}"
    echo "${BLUE}==============================================================================${NC}"
    echo
}

print_step() {
    echo "${YELLOW}→${NC} $1"
}

print_success() {
    echo "${GREEN}✓${NC} $1"
}

print_error() {
    echo "${RED}✗${NC} $1" >&2
}

print_info() {
    echo "${BLUE}ℹ${NC} $1"
}

# =============================================================================
# Prerequisite Detection Functions
# =============================================================================

check_xcode_cli_tools() {
    if xcode-select -p &> /dev/null; then
        return 0  # Already installed
    else
        return 1  # Not installed
    fi
}



check_homebrew() {
    if command -v brew &> /dev/null; then
        return 0  # Already installed
    else
        return 1  # Not installed
    fi
}

# =============================================================================
# Installation Functions
# =============================================================================

install_homebrew_package() {
    local name="$1"
    local formula="$2"
    local options="$3"
    
    print_step "Installing $name..."
    
    if [[ "$options" == "--cask" ]]; then
        if brew list --cask "$formula" &> /dev/null; then
            print_success "$name already installed"
            return 0
        fi
    else
        if brew list "$formula" &> /dev/null; then
            print_success "$name already installed"
            return 0
        fi
    fi
    
    if brew install $options "$formula" &> /dev/null; then
        print_success "$name installed successfully"
    else
        print_error "Failed to install $name"
        return 1
    fi
}

install_xcode_cli_tools() {
    print_step "Installing Xcode Command Line Tools..."
    
    # Start the installation
    xcode-select --install 2>/dev/null || true
    
    print_info "Please complete the Xcode Command Line Tools installation in the dialog that appeared."
    print_info "Waiting for installation to complete (checking silently every 10 seconds)..."
    
    # Wait for installation to complete silently
    local dots=""
    while ! check_xcode_cli_tools; do
        sleep 10
        dots="${dots}."
        printf "\r${BLUE}ℹ${NC} Still waiting${dots}"
    done
    
    echo  # New line after the dots
    print_success "Xcode Command Line Tools installation completed!"
}



install_homebrew() {
    print_step "Installing Homebrew..."
    print_info "This will require administrator privileges for some operations."
    
    # Pre-create directories that Homebrew needs with proper permissions
    print_info "Setting up Homebrew directories..."
    
    # Determine Homebrew prefix based on architecture
    if [[ $(uname -m) == "arm64" ]]; then
        HOMEBREW_PREFIX="/opt/homebrew"
    else
        HOMEBREW_PREFIX="/usr/local"
    fi
    
    # Create directories and set permissions if they don't exist
    if [[ ! -d "$HOMEBREW_PREFIX" ]]; then
        print_info "Creating $HOMEBREW_PREFIX directory (requires sudo)..."
        sudo mkdir -p "$HOMEBREW_PREFIX"
        sudo chown -R $(whoami):admin "$HOMEBREW_PREFIX"
    fi
    
    # Download and run Homebrew installer
    print_info "Running Homebrew installer..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null
    
    # Add Homebrew to PATH for future sessions
    if [[ $(uname -m) == "arm64" ]]; then
        if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile 2>/dev/null; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        fi
        # Source the profile to make brew available in current session
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        # Intel Mac - Homebrew should already be in PATH at /usr/local/bin
        if ! grep -q '/usr/local/bin' ~/.zprofile 2>/dev/null; then
            echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zprofile
        fi
        export PATH="/usr/local/bin:$PATH"
    fi
    
    # Verify Homebrew is now accessible
    if command -v brew &> /dev/null; then
        print_success "Homebrew installation completed and verified!"
        print_info "Homebrew version: $(brew --version | head -n1)"
    else
        print_error "Homebrew installation completed but 'brew' command is not accessible!"
        print_error "You may need to restart your terminal or manually run: eval \"\$(/opt/homebrew/bin/brew shellenv)\""
        return 1
    fi
}

install_essential_packages() {
    print_header "Installing Essential Development Packages"
    
    # Development Tools
    print_info "Installing development tools..."
    install_homebrew_package "Git" "git"
    install_homebrew_package "Vim" "vim"
    install_homebrew_package "Bash" "bash"
    install_homebrew_package "Bash Completion" "bash-completion@2"
    install_homebrew_package "tmux" "tmux"
    install_homebrew_package "tmux Pasteboard Support" "reattach-to-user-namespace"
    
    # Command Line Utilities  
    print_info "Installing command line utilities..."
    install_homebrew_package "ShellCheck" "shellcheck"
    install_homebrew_package "jq (JSON processor)" "jq"
    install_homebrew_package "yq (YAML processor)" "yq"
    
    # Security Tools
    print_info "Installing security tools..."
    install_homebrew_package "GPG" "gpg"
    install_homebrew_package "GPG PIN Entry" "pinentry-mac"
    
    # Media Tools
    print_info "Installing media tools..."
    install_homebrew_package "FFmpeg" "ffmpeg"
    
    # Essential Applications (Casks)
    print_info "Installing essential applications..."
    install_homebrew_package "Visual Studio Code" "visual-studio-code" "--cask"
    install_homebrew_package "Google Chrome" "google-chrome" "--cask"
    install_homebrew_package "Docker" "docker" "--cask"
    
    print_success "Essential packages installation completed!"
}

# =============================================================================
# Main Installation Flow
# =============================================================================

main() {
    print_header "ZSH Dotfiles Setup - macOS Development Environment"
    
    print_info "This script will install essential development prerequisites:"
    print_info "• Xcode Command Line Tools"
    print_info "• Homebrew Package Manager"
    print_info "• Essential development packages and applications"
    echo
    
    # 1. Xcode Command Line Tools
    print_header "Checking Xcode Command Line Tools"
    if check_xcode_cli_tools; then
        print_success "Xcode Command Line Tools already installed"
    else
        install_xcode_cli_tools
    fi
    
    # 2. Homebrew
    print_header "Checking Homebrew"
    if check_homebrew; then
        print_success "Homebrew already installed"
    else
        install_homebrew
    fi
    
    # 3. Essential Packages
    if command -v brew &> /dev/null; then
        install_essential_packages
    else
        print_error "Homebrew is not available - skipping package installation"
        return 1
    fi
    
    print_header "Development Environment Setup Complete"
    print_success "All prerequisites and essential packages have been successfully installed!"
    print_info "Your macOS development environment is now ready to use."
}

# =============================================================================
# Script Entry Point
# =============================================================================

# Ensure we're running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only."
    exit 1
fi

# Run main installation flow
main "$@"
