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
    
    # Download and run Homebrew installer
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    print_success "Homebrew installation completed!"
}

# =============================================================================
# Main Installation Flow
# =============================================================================

main() {
    print_header "ZSH Dotfiles Setup - macOS Development Environment"
    
    print_info "This script will install essential development prerequisites:"
    print_info "• Xcode Command Line Tools"
    print_info "• Homebrew Package Manager"
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
    
    print_header "Prerequisites Installation Complete"
    print_success "All prerequisites have been successfully installed!"
    print_info "You can now proceed with additional development environment setup."
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
