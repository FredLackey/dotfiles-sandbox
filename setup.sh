#!/usr/bin/env bash

# Dotfiles Setup Script
# Cross-platform dotfiles configuration for Ubuntu and macOS
# Supports ZSH (primary) and Bash (fallback)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Platform detection
detect_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v lsb_release >/dev/null 2>&1; then
            if lsb_release -i | grep -q "Ubuntu"; then
                echo "ubuntu"
            else
                echo "linux"
            fi
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Check if running from correct location
check_location() {
    local expected_location="$HOME/.files"
    if [[ "$DOTFILES_DIR" != "$expected_location" ]]; then
        log_warning "Dotfiles should be located at $expected_location"
        log_warning "Current location: $DOTFILES_DIR"
        log_info "Consider moving this directory to $expected_location for optimal setup"
    fi
}

# Backup existing configuration files
backup_file() {
    local file="$1"
    if [[ -f "$file" ]] && [[ ! -L "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up existing $file to $backup"
        cp "$file" "$backup"
    fi
}

# Check if ZSH is available and can be used
check_zsh_availability() {
    if command -v zsh >/dev/null 2>&1; then
        # Check if ZSH is in /etc/shells (allowed shells)
        if grep -q "$(command -v zsh)" /etc/shells 2>/dev/null; then
            echo "available"
        else
            echo "not_allowed"
        fi
    else
        echo "not_installed"
    fi
}

# Install ZSH based on platform
install_zsh() {
    local platform="$1"
    
    log_info "Installing ZSH..."
    
    case "$platform" in
        "ubuntu")
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update
                sudo apt-get install -y zsh
            else
                log_error "apt-get not found. Please install ZSH manually."
                return 1
            fi
            ;;
        "macos")
            if command -v brew >/dev/null 2>&1; then
                brew install zsh
            else
                log_info "ZSH should already be available on macOS"
                if ! command -v zsh >/dev/null 2>&1; then
                    log_error "ZSH not found and Homebrew not available. Please install ZSH manually."
                    return 1
                fi
            fi
            ;;
        *)
            log_error "Unsupported platform for automatic ZSH installation: $platform"
            return 1
            ;;
    esac
    
    # Add ZSH to allowed shells if not already there
    local zsh_path
    zsh_path="$(command -v zsh)"
    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
        log_info "Adding ZSH to /etc/shells"
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi
}

# Set ZSH as default shell
set_zsh_as_default() {
    local current_shell
    current_shell="$(basename "$SHELL")"
    
    if [[ "$current_shell" != "zsh" ]]; then
        log_info "Setting ZSH as default shell"
        chsh -s "$(command -v zsh)"
        log_success "ZSH set as default shell. Please restart your terminal or log out and back in."
    else
        log_info "ZSH is already the default shell"
    fi
}

# Main setup function
main() {
    log_info "Starting dotfiles setup..."
    
    # Detect platform
    local platform
    platform="$(detect_platform)"
    log_info "Detected platform: $platform"
    
    # Check location
    check_location
    
    # Check ZSH availability
    local zsh_status
    zsh_status="$(check_zsh_availability)"
    log_info "ZSH status: $zsh_status"
    
    # Handle ZSH installation and setup
    case "$zsh_status" in
        "available")
            log_success "ZSH is available and allowed"
            # Run ZSH setup
            if [[ -f "$DOTFILES_DIR/zsh/setup.sh" ]]; then
                log_info "Running ZSH setup..."
                bash "$DOTFILES_DIR/zsh/setup.sh" "$platform"
                set_zsh_as_default
            else
                log_warning "ZSH setup script not found"
            fi
            ;;
        "not_installed")
            log_warning "ZSH is not installed"
            log_info "Installing ZSH automatically..."
            if install_zsh "$platform"; then
                log_success "ZSH installed successfully"
                if [[ -f "$DOTFILES_DIR/zsh/setup.sh" ]]; then
                    bash "$DOTFILES_DIR/zsh/setup.sh" "$platform"
                    set_zsh_as_default
                fi
            else
                log_error "Failed to install ZSH, falling back to Bash"
                zsh_status="fallback_to_bash"
            fi
            ;;
        "not_allowed")
            log_warning "ZSH is installed but not in /etc/shells (not allowed)"
            log_info "Falling back to Bash configuration"
            zsh_status="fallback_to_bash"
            ;;
    esac
    
    # Setup Bash if ZSH is not available or as fallback
    if [[ "$zsh_status" == "fallback_to_bash" ]] || [[ "$zsh_status" == "not_allowed" ]]; then
        log_info "Setting up Bash configuration..."
        if [[ -f "$DOTFILES_DIR/bash/setup.sh" ]]; then
            bash "$DOTFILES_DIR/bash/setup.sh" "$platform"
        else
            log_warning "Bash setup script not found"
        fi
    fi
    
    # Run common setup
    if [[ -f "$DOTFILES_DIR/common/setup.sh" ]]; then
        log_info "Running common setup..."
        bash "$DOTFILES_DIR/common/setup.sh" "$platform"
    fi
    
    # Run platform-specific setup
    if [[ -f "$DOTFILES_DIR/platform/$platform/setup.sh" ]]; then
        log_info "Running platform-specific setup for $platform..."
        bash "$DOTFILES_DIR/platform/$platform/setup.sh"
    fi
    
    log_success "Dotfiles setup completed!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' (or ~/.bashrc) to apply changes."
}

# Run main function
main "$@"
