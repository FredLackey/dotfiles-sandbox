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

# Install and configure ZSH
install_zsh() {
    print_title "ZSH Installation"
    
    if check_command zsh; then
        local current_version=$(zsh --version 2>/dev/null | awk '{print $2}')
        print_success "ZSH already installed (version $current_version)"
        
        # Update to latest version if available
        execute \
            "sudo apt-get install -qqy --only-upgrade zsh" \
            "Checking for ZSH updates"
        
        # Check if version changed after update
        local new_version=$(zsh --version 2>/dev/null | awk '{print $2}')
        if [ "$current_version" != "$new_version" ]; then
            print_success "ZSH updated to version $new_version"
        fi
    else
        # Install ZSH
        execute \
            "sudo apt-get install -qqy zsh" \
            "Installing ZSH"
        
        # Verify installation and get version
        if check_command zsh; then
            local version=$(zsh --version 2>/dev/null | awk '{print $2}')
            print_success "ZSH installed successfully"
            print_success "ZSH version: $version"
        else
            print_error "Failed to install ZSH"
            return 1
        fi
    fi
    
    # Display final installed version
    local final_version=$(zsh --version 2>/dev/null | awk '{print $2}')
    local zsh_path=$(which zsh 2>/dev/null)
    if [ -n "$final_version" ] && [ -n "$zsh_path" ]; then
        print_info "ZSH $final_version installed at $zsh_path"
    fi
    
    # Ensure ZSH is in /etc/shells
    if [ -n "$zsh_path" ]; then
        if ! grep -q "^$zsh_path$" /etc/shells 2>/dev/null; then
            execute \
                "echo '$zsh_path' | sudo tee -a /etc/shells > /dev/null" \
                "Adding ZSH to /etc/shells"
        else
            print_success "ZSH already in /etc/shells"
        fi
    fi
}

# Install Oh My Zsh
install_oh_my_zsh() {
    print_title "Oh My Zsh Installation"
    
    # Check if Oh My Zsh is already installed
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_success "Oh My Zsh already installed"
        
        # Check for updates
        if [ -f "$HOME/.oh-my-zsh/tools/upgrade.sh" ]; then
            print_info "Checking for Oh My Zsh updates..."
            # Run update in non-interactive mode
            export DISABLE_UPDATE_PROMPT=true
            sh "$HOME/.oh-my-zsh/tools/upgrade.sh" 2>/dev/null || true
        fi
        return 0
    fi
    
    # Ensure prerequisites are installed
    if ! check_command zsh; then
        print_error "ZSH is required for Oh My Zsh"
        return 1
    fi
    
    if ! check_command git; then
        print_error "Git is required for Oh My Zsh"
        return 1
    fi
    
    # Check for curl or wget
    local download_cmd=""
    if check_command curl; then
        download_cmd="curl -fsSL"
    elif check_command wget; then
        download_cmd="wget -qO-"
    else
        print_error "curl or wget is required for Oh My Zsh installation"
        return 1
    fi
    
    # Back up existing .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        execute \
            "cp '$HOME/.zshrc' '$HOME/.zshrc.pre-oh-my-zsh'" \
            "Backing up existing .zshrc"
    fi
    
    # Download and run Oh My Zsh installer
    # Use unattended mode to prevent interactive prompts
    print_info "Installing Oh My Zsh..."
    
    # Set environment variables for unattended installation
    export RUNZSH=no  # Don't run ZSH after installation
    export CHSH=no    # Don't change shell (we handle this separately)
    
    if [ "$download_cmd" = "curl -fsSL" ]; then
        execute \
            "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended" \
            "Installing Oh My Zsh"
    else
        execute \
            "sh -c \"\$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended" \
            "Installing Oh My Zsh"
    fi
    
    # Check if installation was successful
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_error "Oh My Zsh installation failed"
        return 1
    fi
    
    print_success "Oh My Zsh installed successfully"
    
    # Copy our custom Oh My Zsh configuration template
    local ohmyzsh_config="$SCRIPT_DIR/configs/ohmyzsh/zshrc-ohmyzsh-template"
    if [ -f "$ohmyzsh_config" ]; then
        execute \
            "cp '$ohmyzsh_config' '$HOME/.zshrc'" \
            "Installing custom Oh My Zsh configuration"
    else
        print_warning "Custom Oh My Zsh configuration not found, using default"
    fi
    
    # Install popular third-party plugins
    install_oh_my_zsh_plugins
    
    # Install Powerline fonts for themes
    install_powerline_fonts
    
    return 0
}

# Install popular Oh My Zsh plugins
install_oh_my_zsh_plugins() {
    print_title "Oh My Zsh Plugins"
    
    local custom_plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
    # Create custom plugins directory if it doesn't exist
    if [ ! -d "$custom_plugins_dir" ]; then
        execute \
            "mkdir -p '$custom_plugins_dir'" \
            "Creating custom plugins directory"
    fi
    
    # Install zsh-autosuggestions
    if [ ! -d "$custom_plugins_dir/zsh-autosuggestions" ]; then
        execute \
            "git clone https://github.com/zsh-users/zsh-autosuggestions '$custom_plugins_dir/zsh-autosuggestions'" \
            "Installing zsh-autosuggestions plugin"
    else
        print_success "zsh-autosuggestions already installed"
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "$custom_plugins_dir/zsh-syntax-highlighting" ]; then
        execute \
            "git clone https://github.com/zsh-users/zsh-syntax-highlighting '$custom_plugins_dir/zsh-syntax-highlighting'" \
            "Installing zsh-syntax-highlighting plugin"
    else
        print_success "zsh-syntax-highlighting already installed"
    fi
    
    # Install zsh-completions
    if [ ! -d "$custom_plugins_dir/zsh-completions" ]; then
        execute \
            "git clone https://github.com/zsh-users/zsh-completions '$custom_plugins_dir/zsh-completions'" \
            "Installing zsh-completions plugin"
    else
        print_success "zsh-completions already installed"
    fi
}

# Install Powerline fonts for advanced themes
install_powerline_fonts() {
    print_title "Powerline Fonts"
    
    # Check if fonts-powerline package is available
    if dpkg -l | grep -q "^ii  fonts-powerline "; then
        print_success "Powerline fonts already installed"
    else
        execute \
            "sudo apt-get install -qqy fonts-powerline" \
            "Installing Powerline fonts"
    fi
    
    # For WSL, provide instructions for Windows-side installation
    if [ -f /proc/version ] && grep -qi "microsoft\|wsl" /proc/version; then
        print_info "WSL detected: Install Powerline fonts on Windows for proper display"
        print_info "Visit: https://github.com/powerline/fonts for Windows installation"
    fi
}

# Configure shell environment (foundation for text-based development)
configure_shell() {
    print_title "Shell Environment Configuration"
    
    # Install ZSH first
    install_zsh || {
        print_warning "ZSH installation failed, continuing with existing shell"
        return 0
    }
    
    # Install Oh My Zsh
    install_oh_my_zsh || {
        print_warning "Oh My Zsh installation failed, using basic ZSH configuration"
        
        # Fall back to basic ZSH configuration
        local zsh_configs_dir="$SCRIPT_DIR/configs/zsh"
        
        if [ -d "$zsh_configs_dir" ]; then
            # Copy main configuration files
            for config_file in .zshenv .zprofile .zshrc; do
                if [ -f "$zsh_configs_dir/$config_file" ]; then
                    if [ ! -f "$HOME/$config_file" ]; then
                        execute \
                            "cp '$zsh_configs_dir/$config_file' '$HOME/$config_file'" \
                            "Installing $config_file"
                    else
                        print_success "$config_file already exists (preserving)"
                    fi
                fi
            done
            
            # Create and populate .zshrc.d directory
            if [ ! -d "$HOME/.zshrc.d" ]; then
                execute \
                    "mkdir -p '$HOME/.zshrc.d'" \
                    "Creating ~/.zshrc.d directory"
            fi
            
            # Copy modular configuration files
            if [ -d "$zsh_configs_dir/.zshrc.d" ]; then
                for module in "$zsh_configs_dir/.zshrc.d"/*.zsh; do
                    if [ -f "$module" ]; then
                        local basename=$(basename "$module")
                        if [ ! -f "$HOME/.zshrc.d/$basename" ]; then
                            execute \
                                "cp '$module' '$HOME/.zshrc.d/$basename'" \
                                "Installing $basename"
                        else
                            print_success "$basename already exists (preserving)"
                        fi
                    fi
                done
            fi
        else
            print_warning "ZSH config templates not found at $zsh_configs_dir"
        fi
    }
    
    # Handle WSL-specific configuration
    if [ -f /proc/version ] && grep -qi "microsoft\|wsl" /proc/version; then
        print_info "WSL environment detected"
        
        # Add ZSH launcher to .bashrc for older WSL versions
        if [ -f "$HOME/.bashrc" ]; then
            if ! grep -q "exec zsh" "$HOME/.bashrc" 2>/dev/null; then
                cat >> "$HOME/.bashrc" << 'EOF'

# Launch ZSH if in interactive terminal (WSL compatibility)
if test -t 1; then
    exec zsh
fi
EOF
                print_success "Added ZSH launcher to ~/.bashrc for WSL"
            fi
        fi
    fi
    
    # Set ZSH as default shell
    local zsh_path=$(which zsh 2>/dev/null)
    if [ -n "$zsh_path" ] && [ "$SHELL" != "$zsh_path" ]; then
        # Check if chsh command exists
        if ! check_command chsh; then
            execute \
                "sudo apt-get install -qqy passwd" \
                "Installing passwd package for chsh"
        fi
        
        # Change default shell
        if execute "sudo chsh -s '$zsh_path' '$USER'" "Setting ZSH as default shell"; then
            print_info "Shell change will take effect on next login"
        else
            print_warning "Failed to set default shell automatically"
            print_info "You can manually set it with: chsh -s $zsh_path"
        fi
    else
        print_success "ZSH is already the default shell"
    fi
    
    print_success "Shell environment configured with Oh My Zsh"
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